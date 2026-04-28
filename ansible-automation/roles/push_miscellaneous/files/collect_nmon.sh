#!/bin/ksh
#
# collect_nmon.sh
#
# Launches nmon to collect performance data for the given duration.
#
# Usage: collect_nmon.sh -d < duration > [ -c ] [ -x ] [ -n <nmon exec> | -z ]
#           [ -r < rootdir > ] 
#
# Change Log:
# Jan 14 2010 - written, Jake Laack
# Jan 15 2010 - added to ibmesa.files, Jake Laack
# Jan 29 2010 - added -@ option to collect WPAR stats and use an alternate nmon binary, Jake Laack
# Feb 04 2010 - added -n option to specify an nmon executable, Jake Laack
# Feb 18 2010 - check for Async I/O ability in nmon before adding -A, displays uses if nmon creates any output (which it shouldn't), Jake Laack
# Feb 22 2010 - ignores nfs_kdes.ext errors from AIX 5.2, Jake Laack
# May 05 2010 - added -x option to remove compressed nmons, reduced compression durations, Jake Laack
# Oct 13 2010 - modified the compress steps to move compressed files into the ./archive directory in an effort to reduce the number of files in each nmon directory, increased the remove limits to 365 & 730 days, removed the -C option (compress only) in favor of -z (don't start nmon), Jake Laack
# Mar 12 2013 - Revised for use on Linux (removed AIX options). Added Diskgroups functionality, Chip Needham
# Mar 25 2013 - Several minor bugfixes, Chip Needham
# Mar 28 2013 - Fixed double-counting disk group I/O, Chip Needham
# Apr 15 2013 - Fixed IOPS metric for local volume groups, Chip Needham
# Jul 01 2015 - Increased disk limit from 2048 to 8192, Chip Needham
# Oct 08 2015 - Bug fix - included incorrect disks in a disk group, Chip Needham
# Oct 12 2015 - Added ability to auto-detect how many samples are left in this reporting period (day/wk/mo), Chip Needham
# Oct 26 2016 - Added regex to grep commands for process count calculation & enhanced startup checks, Lee Burns 
#


usage() {
# Display usage of this script and exit

  if [[ -n $1 ]]; then
    echo $1
  fi

  cat << END
usage: collect_nmon.sh -d <duration> [ -c ] [ -x ] [ -n <nmon exec> | -z ]
           [ -r <rootdir> ] 

       Launches nmon to collect performance data for the given duration.

       -d  The length of time to collect data.  This should be "daily",
           "weekly" or "monthly".
       -c  Compresses existing nmon daily files older than 2 days, weekly
           files older than 15 days and monthly files older than 60 days.
       -n  Specify an alternate nmon executable.  /usr/bin/nmon is used
           by default.
       -r  Specify an alternate root directory for the nmon files.  This
           is /home/essadmin/nmon by default.
       -x  Remove compressed nmon daily files older than 7 days and
           weekly/monthly files older than 90 days
       -z  Does not start nmon.  Ignores -n. Used with -c or -x.
END

  exit 1
}


# Script starts here

NMONROOTDIR="/home/essadmin/nmon"
NMONCOMPRESS=0
NMONCOMPRESSONLY=0
NMONDONTSTART=0
NMONREMOVE=0
NMONREMOVEDURATION=99999

NMONDURATION=""
NMONINTERVAL=0
NMONCOUNT=0
NMONDIR=""

NMONCMD="/usr/local/bin/nmon"
# These are the default arguments to give nmon besides -s -c and -m
NMONARGS="-fT -d 8192"
#NMONARGS="-fNT -d 2048"  #not including NFS stats ("N" option) due to bug on
                          #systems with NFS exports (NAS servers) causes nmon to crash

# Collect command options
while getopts ":cd:r:n:xz" ARG; do
  case $ARG in
    c) NMONCOMPRESS=1
       ;;
    d) NMONDURATION="$OPTARG"
       ;;
    r) NMONROOTDIR="$OPTARG"
       ;;
    n) NMONCMD="$OPTARG"
       ;;
    x) NMONREMOVE=1
       ;;
    z) NMONDONTSTART=1
       ;;
    *) usage "Unknown option!"
       ;;
  esac
done

DATE_NOW=$(date +%s)
# Setup NMON variables based on given duration
case $NMONDURATION in
  daily)
    DATE_END=$(date -d `date -dtomorrow +%Y%m%d` +%s)
    NMONINTERVAL=60
    NMONDIR="${NMONROOTDIR}/daily"
    NMONCOMPRESSDURATION=2
    NMONREMOVEDURATION=7
    
    ;;
  weekly)
    DATE_END=`date -dnext-sunday +%s`
    NMONINTERVAL=300
    NMONDIR="${NMONROOTDIR}/weekly"
    NMONCOMPRESSDURATION=15
    NMONREMOVEDURATION=90
    ;;
  monthly)
    DATE_END=$(date -d `date -dnext-month +%Y%m`01 +%s)
    NMONINTERVAL=900
    NMONDIR="${NMONROOTDIR}/monthly"
    NMONCOMPRESSDURATION=60
    NMONREMOVEDURATION=90
    ;;
  *)
    usage "Unknown duration!"
    ;;
esac

# Calculate the number of samples left until the next roll-over time (the next day/week/month)
NMONCOUNT=`expr \( $DATE_END - $DATE_NOW \) / $NMONINTERVAL`
#echo start: $DATE_NOW  end: $DATE_END
#echo intervals:  $NMONCOUNT
# Sanity check:
if [[ ! $NMONCOUNT -gt 0 ]]; then echo "Error: Invalid number of samples left ($NMONCOUNT). Aborting.."; exit 1; fi

# Verify there isn't another instance of NMON already collecting at this sampling rate
COUNT=`ps -ef|grep "$NMONCMD"|grep $NMONDURATION|grep -v grep|grep -v "^root *$$ "|grep -v "^root *[0-9]* *$PPID "|wc -l`
# The max count of allowed processes is 2 during the rollover period
if [ $COUNT -gt 2 ];then
   echo "Another instance of this script is already running. Aborting.."
   exit 0
fi
if [[ $COUNT -gt 0 ]]; then 
# One or more processes found for this duration so additional checks are needed
    case $NMONDURATION in
        "daily")
#            Abort daily if not in zero hour
             if [ `date +%H` -gt 0 ];then
                 echo "Another instance of this script is already running. Aborting.."
                 exit 0
             fi
             ;;
        "weekly")
#            Abort weekly if not in zero hour or not on Sunday
             if [ `date +%H` -gt 0 -o `date +%w` -gt 0 ];then
                 echo "Another instance of this script is already running. Aborting.."
                 exit 0
             fi
             ;;
        "monthly")
#            Abort monthly if not in zero hour or not on first day of the month
             if [ `date +%H` -gt 0 -o `date +%d` -gt 1 ];then
                 echo "Another instance of this script is already running. Aborting.."
                 exit 0
             fi
             ;;
        *)
                 echo "Another instance of this script is already running. Aborting.."
                 exit 0

             ;;
    esac
fi

# Check the nmon command only if we are starting it
if [[ $NMONDONTSTART -eq 0 ]]; then
  # Verify nmon executable actually exists
  if [[ ! ( -f $NMONCMD && -x $NMONCMD ) ]]; then
    usage "nmon executable $NMONCMD invalid"
  fi
elif [[ $NMONCOMPRESS -eq 0 && $NMONREMOVE -eq 0 ]]; then
  usage "Nothing to do; use -c or -x with -z";

fi

# Verify destination directory actually exists
if [[ ! -d $NMONDIR/archive ]]; then
   # attempt to make the directory
   mkdir -p $NMONDIR/archive
fi
if [[ ! -d $NMONDIR ]]; then
  usage "Directory $NMONDIR not found!"
fi

generate_diskgroups()
{
  #### Gather Disk group information
  DISKGROUPS=/tmp/diskgroups.$$

  # RHEL VolumeGroups
  TMPFILE=/tmp/nmon-disks.$$
  TMPFILE2=/tmp/nmon-multipath-disks.$$
  TMPFILE3=/tmp/nmon-pvs-disks.$$



  # RHEL Logical Volumes
  # grab the name of all of the LV's
  /sbin/vgs --noheadings > $TMPFILE 2> /dev/null
  #ls -la /dev/mapper|grep _ > $TMPFILE

  # Grab the mutlipath output for future use
  /sbin/multipath -ll | sed 's/mpath/;\nmpath/g' > ${TMPFILE2}

  # Capture the devices behind the LVs
  #  output like:   mwa_data_lv /dev/mapper/mpathg(0),/dev/mapper/mpathac(0),....

   if [ -a /sbin/lvs ]
   then
   /sbin/lvs -o lv_name,vg_name,devices 2>/dev/null|sed 's/,/ /g' > $TMPFILE3
   else
   /sbin/lvs -o lv_name,vg_name,devices 2>/dev/null|sed 's/,/ /g' > $TMPFILE3
   fi

  #for FS in `cat $TMPFILE |awk '{ print $NF }' |cut -d- -f1|sort|uniq`
   for FS in `cat $TMPFILE |awk '{ print $1 }' |sort|uniq`
   do
      #FS here is the name of the VG like local_vg
      # This is one long command spanning several lines
      echo $FS $( for mpath in `grep " $FS " $TMPFILE3|awk '{$1=""}1'|awk '{$1=""}1'|cut -d\( -f1|uniq|xargs -n1 basename`; do
         if [ `grep -c ${mpath} $TMPFILE2` -gt 0 ]; then
            awk '{FS="\n";RS=";"} /'"${mpath}"'/ { print }' ${TMPFILE2} |grep -E 'dm-'|awk '{ print $3 }'
        else
            #not multipathed, must be a local device
            echo $mpath

        fi
                 done|uniq )  >> $DISKGROUPS
   done



  #StorNext Volumes
  if [ -x /usr/cvfs/bin/cvlabel ]; then
     # StorNext installed and executable for the user, compile SNFS disk info
     /usr/cvfs/bin/cvlabel -l|sed 's/_share.*\"/\" /g'| grep SNFS| awk '{ print $6, $1 }' |grep mapper |sed 's/\"//g' > $TMPFILE
     /sbin/multipath -ll | sed 's/mpath/;\nmpath/g' > ${TMPFILE2} 
     for FS in `cat $TMPFILE |awk '{ print $1 }'|sort|uniq`; do
        #This looks up the /dev/dm-* devices associated with each mpath device utilized by the StorNext volume
        # we purposefully don't include the /dev/sd* devices in this output because that causes NMON to double-count the disk I/O
        #  (once for the dm-* multipath device and again for the sd* physical device underneath it)
        echo $FS $( for mpath in `grep "^$FS " $TMPFILE|awk '{ print $2 }'|xargs -n1 basename`; do awk '{FS="\n";RS=";"} /'"${mpath} "'/ { print }' ${TMPFILE2} |grep -E 'dm-'|awk '{ print $3 }'; done ) >> $DISKGROUPS

     done
  fi
  if [ -e ${TMPFILE} ]; then rm -f ${TMPFILE};fi
  if [ -e ${TMPFILE2} ]; then rm -f ${TMPFILE2};fi
  if [ -e ${TMPFILE3} ]; then rm -f ${TMPFILE3};fi
  #### End of Gather Disk Groups
}

# Compress NMON files if desired
if [[ $NMONCOMPRESS -eq 1 || $NMONCOMPRESSONLY -eq 1 ]]; then
  /bin/find ${NMONDIR} -name "*.nmon" -type f -mtime +${NMONCOMPRESSDURATION} -exec gzip {} \; >/dev/null 2>&1
  /bin/find ${NMONDIR} -name archive -prune -o -name "*.nmon.gz" -type f -mtime +${NMONCOMPRESSDURATION} -exec mv {} ${NMONDIR}/archive \; >/dev/null 2>&1
fi

# Remove NMON files if desired
if [[ $NMONREMOVE -eq 1 ]]; then
  /bin/find ${NMONDIR}/archive -name "*.nmon.gz" -type f -mtime +${NMONREMOVEDURATION} -exec rm -f {} \; >/dev/null 2>&1
fi

# Launch NMON if desired
if [[ $NMONDONTSTART -ne 1 ]]; then
  generate_diskgroups
  NMONOUTPUT=`${NMONCMD} ${NMONARGS} -g${DISKGROUPS} -s${NMONINTERVAL} -c${NMONCOUNT} -m${NMONDIR} 2>&1 | grep -v "nfs_kdes.ext" | head -n 1`

  if [[ -n $NMONOUTPUT ]]; then
    usage "Problem with nmon:\n${NMONOUTPUT}"
  else
   # started up cleanly, we can get rid of the disk groups now
   rm -f ${DISKGROUPS}
  fi
fi


exit 0
