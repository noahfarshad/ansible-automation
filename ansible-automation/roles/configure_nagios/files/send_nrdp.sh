#!/bin/bash
#
# Copyright (c) 2010-2012 Nagios Enterprises, LLC.
# Written by: Scott Wilkerson (nagios@nagios.org)
#
#
#
#
#
# Changelog:
# -----------
#	01/13/2016 - Cory McDowell    - Created default values for hostname,
#					nagios server, output, and passphrase 
#					changes annotated inline with date.
#
#	09/21/2017 - Will Stutt       - Created functions for each type of submission.
#			 		Only create the xml variable once.
#					Attempt to eliminate race condition.
#
#	06/20/2018 - Tony Widhalm     - Corrected non-standard hostname logic
#					Corrected wget to ignore certificates.
#
#	09/27/2018 - Chip Needham     - Bugfix for XML-reserved characters
#
#	10/02/2018 - Garry Garrett    - Removed calls to 'which' command to find curl/wget.
#					Added SA_NAGIOS as a method to override
#					the Nagios server.
#
#	11/21/2018 - Tom Polivka      - Added support for validation (v) tier
#
#       09/16/2020 - Chip Needham     - Fixed logic for handling of spooled XML files
#                                       Added support for NRDP_SPOOL_DIR
#                                       Enabled override of hostname for spooled files via the -H switch
#
###########################

PROGNAME=$(basename $0)
RELEASE="Revision 0.5.1"


######   1/13/16 - default values for token, hostname, and url added
token="P@ss1v3Ch3ck$"
host=$HOSTNAME
xml=""
process_type=normal
process_dir=true

# default vaule for directory if not set via an environment variable
if [[ -n "$NRDP_SPOOL_DIR" ]]; then 
   directory=$NRDP_SPOOL_DIR
else 
   directory=/tmp/nrdp.${USER}
fi

# Need to figure out what tier of system this is (prod vs. non-prod)
host=`echo $host|cut -d. -f1`
TIER=`echo "${host:$((${#host}-1)):1}"`  # Print the last character
case "$TIER" in
        x|d|t|v) TIER=t;;
        p) TIER=p;;
        *)
          # This is a non-standard hostname, now it's time to guess..
          if [[ `echo $host|grep -cE '(prod|whatever)'` -gt 0 ]]; then TIER=p; fi
          if [[ `echo $host|grep -cE '(test|validation|dev|sandbox|ose)'` -gt 0 ]]; then TIER=t; fi
        ;;
esac

# If SA_NAGIOS is set, use it.
# This allows specific hosts to override the default Nagios server for NRDP messages
if [[ "${SA_NAGIOS:-unset}" != "unset" ]]; then
	url="https://${SA_NAGIOS}/nrdp"
else
	url="https://ess-nagios-${TIER}/nrdp"
fi


######   1/13/16 - added default output for clarity
output="The application did not specify a cause for this status"



print_release() {
    echo "$RELEASE"
}

print_usage() {
    echo ""
    echo "$PROGNAME $RELEASE - Send NRPD script for Nagios"
    echo ""
    echo "Usage: send_nrdp.sh [options]"
    echo ""
    echo "Usage: $PROGNAME -h display help"
    echo ""
}


#######   1/13/16 - updated usage to reflect the default values
print_help() {
        print_usage
        echo ""
        echo "This script is used to send NRPD data to a Nagios server"
        echo ""
        echo "Required:"
        echo "    -s    service name (must be in quotes if spaces included)"
        echo "    -S    State: 0=ok, 1=warning, 2=critical, 3=unknown(will notify SDO)"
        echo ""
        echo "Options:"
        echo "    Single Check:"
        echo "        -u       URL of NRDP server.  defaults to https://ess-nagios-p/nrdp/ or uses the value of SA_NAGIOS variable for the server name if set."
        echo "        -H       host name(defaults to current hostname).  Will override the hostname on spooled alerts if specified."
        echo "        -o       Define the message Nagios will display for Status Information"
        echo ""
        echo "    STDIN:"
        echo "        -p "
        echo "        [-d    delimiter] (default -d \"\\t\")"
        echo "        With only the required parameters $PROGNAME is capable of"
        echo "        processing data piped to it either from a file or other"
        echo "        process.  By default, we use \t as the delimiter however this"
        echo "        may be specified with the -d option data should be in the"
        echo "        following formats one entry per line."
        echo "        For Host checks:"
        echo "        echo \"<hostname>    <State>    <output>\"| $0 -p"
        echo "        For Service checks"
        echo "        echo \"<hostname>    <servicename>    <State>    <output>\" | $0 -p "
        echo ""
        echo "    File:"
        echo "        -f /full/path/to/file"
        echo "        This file will be sent to the NRDP server specified in -u"
        echo "        The file should be an XML file in the following format"
        echo "        ##################################################"
        echo ""
        echo "        <?xml version='1.0'?>"
        echo "        <checkresults>"
        echo "          <checkresult type=\"host\" checktype=\"1\">"
        echo "            <hostname>YOUR_HOSTNAME</hostname>"
        echo "            <state>0</state>"
        echo "            <output>OK|perfdata=1.00;5;10;0</output>"
        echo "          </checkresult>"
        echo "          <checkresult type=\"service\" checktype=\"1\">"
        echo "            <hostname>YOUR_HOSTNAME</hostname>"
        echo "            <servicename>YOUR_SERVICENAME</servicename>"
        echo "            <state>0</state>"
        echo "            <output>OK|perfdata=1.00;5;10;0</output>"
        echo "          </checkresult>"
        echo "        </checkresults>"
        echo "        ##################################################"
        echo ""
        echo "    Directory:"
        echo "        -b /path/to/temp/dir"
        echo "           This is a directory that XML files will be backed up to (spooled) if Nagios server is unreachable."
        echo "           Defaults to value specified by NRDP_SPOOL_DIR environment variable if defined. Otherwise uses /tmp/nrdp.\$USER if not specified."
        echo "           Future invocations using the -b option will NOT automatically send previously spooled files (allowing them to build up)."
        echo ""
        exit 0
}

# Parse parameters
while getopts "pu:t:H:s:S:o:f:d:b:c:hv" option
do
  case $option in
    p) process_type=redirect;;
    u) url=$OPTARG ;;
    t) token=$OPTARG ;;
    H) host=$OPTARG; hostoverride=true ;;
    s) service=$OPTARG ;;
    S) State=$OPTARG ;;
    o) output=$OPTARG; process_msg=true ;;
    f) file=$OPTARG ;;
    d) delim=$OPTARG ;;
    c) checktype=$OPTARG ;;
    b) directory=$OPTARG; process_dir=false; if [[ -z "$directory" || `echo $directory|cut -c1` == '-' ]]; then echo "ERROR: no directory specified for -b option"; exit 1; fi ;;
    h) print_help 0;;
    v) print_release
	exit 0 ;;
  esac
done

if [[ -z "$directory" ]];then echo "No directory specified"; exit 1; fi

if [ ! $checktype ]; then
 checktype=1
fi
if [ ! $delim ]; then
 delim=`echo -e "\t"`
fi

if [ "x$url" == "x" -o "x$token" == "x" ]
then
  echo "Usage: send_nrdp -u url -t token"
  exit 1
fi

config_check() {
	# detecting curl 
	if [[ -f /usr/bin/curl ]]; then curl=1; fi	
	if [[ -f /usr/bin/wget ]]; then wget=1;	fi
	if [[ ! $curl && ! $wget ]];
	then
		echo "Either curl or wget are required to run $PROGNAME"
		exit 1
	fi
}

#Test to see if we are being redirected


send_data() {
    pdata="token=$token&cmd=submitcheck&XMLDATA=$1"
    if [ ! "x$curl" == "x" ];then
        rslt=`/usr/bin/curl -f --silent --insecure -d "$pdata" "$url/"`
        ret=$?
    else
        rslt=`/usr/bin/wget -q --no-check-certificate -O - --post-data="$pdata" "$url/"`
        ret=$?
    fi
    status=`echo $rslt | sed -n 's|.*<status>\(.*\)</status>.*|\1|p'`
    message=`echo $rslt | sed -n 's|.*<message>\(.*\)</message>.*|\1|p'`
    if [ $ret != 0 ];then
        echo "ERROR: could not connect to NRDP server at $url"
        # verify we are not processing the directory already and then write to the directory
        if [ -z "$2" ] ;then
            if [ ! -d "$directory" ];then
                mkdir -p "$directory"
            fi
            # This is where we write to the tmp directory
            echo $xml > `mktemp $directory/nrdp.XXXXXX`
        fi
        exit 1
    fi
    
    if [ "$status" != "0" ];then
        # This means we couldn't connect to NRDP server
        echo "ERROR: The NRDP Server said $message"
        # verify we are not processing the directory already and then write to the directory
        if [ ! "$2" ] ;then
            if [ ! -d "$directory" ];then
                mkdir -p "$directory"
            fi
            # This is where we write to the tmp directory
            echo $xml > `mktemp $directory/nrdp.XXXXXX`
        fi
        
        exit 2
    fi
    
    # If this was a directory call and was successful, remove the file
    if [ $2 ] && [ "$status" == "0" ];then
        rm -f "$2"
    fi
    # If we weren't successful error
    if [ $ret != 0 ];then
        echo "exited with error "$ret
        exit $ret
    fi
}


#Submit Complete XML
submit_xml() {
    xml="<?xml version='1.0'?><checkresults>$xml</checkresults>"
    send_data "$xml"
    echo "Sent $checkcount checks to $url"
}

process_file() {
    xml=`cat $file`
    send_data "$xml"
    echo "Sent $file to $url"
}

# we are not getting piped results 
process_normal(){
    xml=""
    checkcount=0
    if [ "$host" == "" ]; then
	echo "Unable to generate hostname, specify one with -H"
	exit 2
    fi
    if [ "$service" == "" ]; then
	echo "You must identify the service with -s"
	exit 2
    fi
    if [ "$State" == "" ]; then
        echo "You must provide a State -S"
        exit 2
    fi
    if [ "$service" != "" ]; then
        xml="$xml<checkresult type='service' checktype='$checktype'><servicename>$service</servicename>"
    else
        xml="$xml<checkresult type='host' checktype='$checktype'>"
    fi
    #replace XML-reserved characters since they'll mess up the XML formatting if not encoded
    #  note: the %26 is the URL-encoded version of &.  We can't use the & because that messes up the curl/wget URL
    #replace < signs with "&lt;"
    #replace & signs with "&amp;"
    output=`echo "$output"|sed 's/</%26lt;/g'|sed 's/&/%26amp;/g'`
    xml="$xml<hostname>$host</hostname><state>$State</state><output>$output</output></checkresult>"
    checkcount=1
    submit_xml
}

# Generate xml based upon STDIN or redirect
process_redirect() {
    IFS=$delim
    while read -r line ; do
        arr=($line)
        if [ ${#arr[@]} != 0 ];then
            if [[ ${#arr[@]} < 3 ]] || [[ ${#arr[@]} > 4 ]];then
                echo "ERROR: STDIN must be either 3 or 4 fields long, I found "${#arr[@]}
		exit 2
            else
                if [ ${#arr[@]} == 4 ]; then
                    xml="$xml<checkresult type='service' checktype='$checktype'>
                    <servicename>${arr[1]}</servicename>
                    <hostname>${arr[0]}</hostname>
                    <state>${arr[2]}</state>
                    <output>${arr[3]}</output>"
                else
                    xml="$xml<checkresult type='host' checktype='$checktype'>
                    <hostname>${arr[0]}</hostname>
                    <state>${arr[1]}</state>
                    <output>${arr[2]}</output>"
                fi
                
                xml="$xml</checkresult>"
                checkcount=$[checkcount+1]
            fi
        fi
    done
    IFS=" "
    submit_xml
}


#A directory of XML files
process_directory() {
    #echo "Processing directory..."
    for f in `ls $directory/nrdp.* 2>/dev/null`
    do
      echo "Processing $f file..."
      # take action on each file. $f store current file name
      xml=`cat $f`
      #override the hostname if one is supplied via the command line
      if [[ -n "$hostoverride" ]]; then
         xml=`echo "$xml" | sed 's/<hostname.*\/hostname/<hostname>'$host'<\/hostname/g'`
      fi
      #echo $xml
      send_data "$xml" "$f"
      rc=$?
      #if we received a connection error, don't continue to process more files
      if [[ $rc -gt 0 ]];then break; fi
    done
}

#Check to see if server can successfully submit


config_check

case $process_type in 
	normal)
		if [ $file ];then
			process_file
		elif [ -n "$process_msg" ]; then
			process_normal
		fi
		if [ $directory ] && [ $process_dir == "true" ];then
			process_directory
		fi
	;;
	*)
		process_redirect
	;;
esac
