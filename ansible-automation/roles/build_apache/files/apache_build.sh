#!/bin/bash
# Setup environment
export LDFLAGS=-ldl
DATE=`date +%Y%m%d%H%M`

usage() {
	echo "Usage: ${0##*/} <2.2|2.4> [reset|package]"
	exit 1
}

case ${1} in
	"2.4")
		STAGE_DIR=/opt/stage
		APACHE_PREFIX_DIR=/opt/apache24
		;;
	*)
		usage
		;;
esac
shift

#3 Set up global variables
OSVER=RHEL6
FIPSDIR=${STAGE_DIR}/openssl-fips
OSSLDIR=${STAGE_DIR}/httpd/srclib/openssl
ZDIR=${STAGE_DIR}/httpd/srclib/zlib
APRDIR=${STAGE_DIR}/httpd/srclib/apr
APRUTILDIR=${STAGE_DIR}/httpd/srclib/apr-util
PCREDIR=${STAGE_DIR}/pcre
HTTPDDIR=${STAGE_DIR}/httpd
SLEEP_TIME=1
INCLUDE_LIST="authz_host wl_24 deflate env expires headers proxy proxy_http proxy_connect rewrite speling ssl substitute cache disk_cache cache_disk"
EXCLUDE_LIST="actions asis autoindex cgi cgid imagemap isapi negotiation nw_ssl proxy_ajp proxy_balancer proxy_ftp proxy_scgi setenvif status userdir"
#EXCLUDE_LIST="actions asis authz_dbm autoindex cgi cgid imagemap isapi negotiation nw_ssl proxy_ajp proxy_balancer proxy_connect proxy_ftp proxy_scgi setenvif status userdir"
OSSL_FILE_BASE=openssl
FIPS_FILE_BASE=openssl-fips
ZLIB_FILE_BASE=zlib
HTTPD_FILE_BASE=httpd
APR_FILE_BASE=apr
APR_UTIL_FILE_BASE=apr-util
PCRE_FILE_BASE=pcre
RM_DIR_LIST="cgi-bin manual htdocs man share"
BUILD_LOG=${STAGE_DIR}/apache_build_$DATE.log
FIPS_PREFIX_DIR=${STAGE_DIR}/fipsbuild
PCRE_PREFIX_DIR=${APACHE_PREFIX_DIR}
HTTPDCONFPOST="--with-ssl=${APACHE_PREFIX_DIR} --with-z=${APACHE_PREFIX_DIR} --with-mpm=prefork "
ZLIBCONFCMD="./configure --prefix=${APACHE_PREFIX_DIR}"
# As of 30Mar2015 we aren't using these anymore since the HTTPD config and compile
# will take care of these if they are staged in the srclib/apr and srclib/apr-util
# directories and Apache is configured with '--with-included-apr'
#APRCONFCMD="./configure --prefix=${APACHE_PREFIX_DIR}"
#pr
APRUTILCONFCMD="./configure --prefix=${APACHE_PREFIX_DIR} --with-apr=${APACHE_PREFIX_DIR}"
PCRECONFCMD="./configure --prefix=${PCRE_PREFIX_DIR} --disable-cpp"
#SSLSUPPORTOPTS="no-ssl2 no-ssl3 no-rc4"
#SSLSUPPORTOPTS="no-deprecated"

# Function to check for source files
check_source(){
	if [ $# -eq 2 ]
	then
		if [ $( find ${STAGE_DIR}/ -maxdepth 1 -type f -name "${1}*" -print | wc -l ) -gt 1 ]
		then
			echo "Multiple versions of ${2} found.  Remove extraneous files and restart."
			exit 1
		fi
	elif [ $# -eq 3 ]
	then
		if [ $( find ${STAGE_DIR}/ -maxdepth 1 -type f -name "${1}*" -print | grep -v ${2} | wc -l ) -gt 1 ]
		then
			echo "Multiple versions of ${3} found.  Remove extraneous files and restart."
			exit 1
		fi
	fi
}

create_stage_dir() {
	if [ ! -d ${1} ]
	then
		echo "Creating directory ${1}..."
		if [ "x${2}" = "xroot" ]
		then
			sudo mkdir -p ${1}
			sudo chown $( logname ):$( logname ) ${1}
		else
			mkdir -p ${1}
		fi
	fi
}

# Package the Apache build into a tar gz file
package_apache () {
	echo "Changing Directory to ${STAGE_DIR}..."
	cd ${STAGE_DIR}
	echo "Current Directory: $( pwd )"

	OSSLVER=$( find . -maxdepth 1 -type f -regex "^.*${OSSL_FILE_BASE}-[0-9].*\.tar.*$" | sed -e "s/^.*${OSSL_FILE_BASE}-\([0-9].*\)\.tar.*$/\1/" )
	echo -e "\nOpenSSL Version: ${OSSLVER}"
	HTTPDVER=$( find . -maxdepth 1 -type f -regex "^.*${HTTPD_FILE_BASE}-[0-9].*\.tar.*$" | sed -e "s/^.*${HTTPD_FILE_BASE}-\([0-9].*\)\.tar.*$/\1/" )
	echo "Apache Version: ${HTTPDVER}"
	FIPSVER=$( find . -maxdepth 1 -type f -regex "^.*${FIPS_FILE_BASE}-[0-9].*\.tar.*$" | sed -e "s/^.*${FIPS_FILE_BASE}-\([0-9].*\)\.tar.*$/\1/" )
	echo "FIPS Version: ${FIPSVER}"

	echo -e "\nChanging Directory to ${APACHE_PREFIX_DIR%/*}..."
	cd ${APACHE_PREFIX_DIR%/*}
	echo "Current Directory: $( pwd )"

        for i in ${RM_DIR_LIST}
        do
                if [ -d ${APACHE_PREFIX_DIR}/$i ]
                then
                        echo "Removing Directory ${APACHE_PREFIX_DIR}/$i..."
                        rm -rf ${APACHE_PREFIX_DIR}/$i
                fi
        done

	echo -e "\nArchiving ${APACHE_PREFIX_DIR} to ~/apache_${HTTPDVER}-OpenSSL-FIPS_${FIPSVER}-OpenSSL_${OSSLVER}-$( uname )-$( uname -i )-${OSVER}.tar"
	tar cvf ~/apache_${HTTPDVER}-OpenSSL-FIPS_${FIPSVER}-OpenSSL_${OSSLVER}-$( uname )-$( uname -i )-${OSVER}.tar ${APACHE_PREFIX_DIR##*/} >> /dev/null

	echo -e "\nZipping  ~/apache_${HTTPDVER}-OpenSSL-FIPS_${FIPSVER}-OpenSSL_${OSSLVER}-$( uname )-$( uname -i )-${OSVER}.tar"
	gzip -f ~/apache_${HTTPDVER}-OpenSSL-FIPS_${FIPSVER}-OpenSSL_${OSSLVER}-$( uname )-$( uname -i )-${OSVER}.tar
	exit 0
}

empty_dir() {
	if [ $( ls ${1}/ | wc -l ) -gt 0 ]
	then
		echo "Removing Files from ${1}..."
		rm -rf ${1}/*
	fi
}

remove_dir() {
	if [ -e ${1} ]
	then
		echo "Removing Directory ${1}..."
		rm -rf ${1}
	fi
}

# Check for the existence of files already installed, if they exist remove
cleanup_install () {
	echo "Beginning Apache build cleanup process..."
	empty_dir "${APACHE_PREFIX_DIR}"
	remove_dir "${HTTPDDIR}"
	remove_dir "${FIPSDIR}"
	remove_dir "${PCREDIR}"
	empty_dir "${FIPS_PREFIX_DIR}"
	echo "Completed Apache build cleanup."
}

# Function to test for errors during each step of this process
status_check () {
	if [ ${1} -ne 0 ]
	then
		echo -e "\n\n########## ERROR ##########"
		echo -e "\tAn error occured during the previous operation.  Check logfile ${BUILD_LOG}, correct the error and re-run:"
		echo -e "\t\t\$ ${0##*/}"
		echo "########## ERROR ##########"
		cleanup_install
		exit 1
	fi
}

standard_build() {
	echo "Changing Directory to ${1}..."
	cd ${1}
	echo "Current Directory $(pwd)"
	echo -e "\nConfiguring ${2} with line \"${3}\"..."
	sleep ${SLEEP_TIME}
	eval ${3} >> ${BUILD_LOG} 2>&1
	echo -e "\nMaking ${2}..."
	sleep ${SLEEP_TIME}
	make >> ${BUILD_LOG} 2>&1
	status_check $?
	echo -e "\nInstalling ${2} to ${4}..."
	sleep ${SLEEP_TIME}
	make install >> ${BUILD_LOG} 2>&1
	status_check $?
}

# Check for a valid argument of "reset" if any others are provided echo usage
if [ ! -z "${1}" ]
then
	case ${1} in
		"reset")
			cleanup_install
			exit 0
			;;
		"package")
			package_apache
			;;
		*)
			usage
			;;
	esac
fi

# Before beginning clean up any old installs
cleanup_install

# Verify that only one source package exists for each required package
check_source ${OSSL_FILE_BASE} ${FIPS_FILE_BASE} OpenSSL
check_source ${ZLIB_FILE_BASE} ZLIB
check_source ${FIPS_FILE_BASE} OpenSSL-FIPS
check_source ${HTTPD_FILE_BASE} "Apache HTTPD"

# Test for and extract the source
if [ $( ls ${STAGE_DIR}/${HTTPD_FILE_BASE}-* | grep "httpd-2.4" | wc -l ) -eq 1 ]
then
	echo "HTTPD 2.4 Detected"
	check_source ${APR_FILE_BASE} ${APR_UTIL_FILE_BASE} APR
	check_source ${APR_UTIL_FILE_BASE} ARPUTIL
	check_source ${PCRE_FILE_BASE} PCRE
	HTTPD24=true
	INCLUDE_LIST="few deflate env expires headers proxy proxy-http rewrite speling ssl substitute cache cache-disk socache-shmcb"
	EXCLUDE_LIST="actions asis autoindex cgi cgid imagemap isapi negotiation nw-ssl proxy-ajp proxy-balancer proxy-connect proxy-express proxy-fcgi proxy-ftp proxy-scgi proxy-wstunnel lbmethod-bybusyness lbmethod-byrequests lbmethod-bytraffic lbmethod-heartbeat setenvif status userdir watchdog xml2enc"
	#HTTPDCONFPRE="./configure --prefix=${APACHE_PREFIX_DIR} --with-apr=${APACHE_PREFIX_DIR} --with-apr-util=${APACHE_PREFIX_DIR} --with-pcre=${PCRE_PREFIX_DIR} --enable-so --enable-mods-shared='${INCLUDE_LIST}'"
	HTTPDCONFPRE="./configure --prefix=${APACHE_PREFIX_DIR} --with-included-apr --with-pcre=${PCRE_PREFIX_DIR} --enable-so --enable-mods-shared='${INCLUDE_LIST}'"
	SRCFILES="${FIPS_FILE_BASE} ${HTTPD_FILE_BASE} ${OSSL_FILE_BASE} ${ZLIB_FILE_BASE} ${APR_FILE_BASE} ${APR_UTIL_FILE_BASE} ${PCRE_FILE_BASE}"
else
	HTTPD24=false
	HTTPDCONFPRE="./configure --prefix=${APACHE_PREFIX_DIR} --with-included-apr --with-included-apr-util --enable-so --enable-mods-shared='${INCLUDE_LIST}'"
	SRCFILES="${FIPS_FILE_BASE} ${HTTPD_FILE_BASE} ${OSSL_FILE_BASE} ${ZLIB_FILE_BASE}"
fi

# Set options according the version of OpenSSL FIPS being used
if [ $( ls ${STAGE_DIR}/${FIPS_FILE_BASE}* | grep "fips-2" | wc -l ) -eq 1 ]
then
	FIPS2="true"
	echo "Using FIPS-2.0 Settings."
	SSLCONFCMD="./config shared --prefix=${APACHE_PREFIX_DIR} fips --with-fipslibdir=${FIPS_PREFIX_DIR}/lib/ ${SSLSUPPORTOPTS}"
else
	FIPS2="false"
	echo "Using FIPS-1.2 Settings."
	FIPSCONFCMD="./config --prefix=${FIPS_PREFIX_DIR} fipscanisterbuild"
	SSLCONFCMD="./config no-ecdh no-ecdsa --prefix=${APACHE_PREFIX_DIR} fips --with-fipslibdir=${FIPS_PREFIX_DIR}/lib ${SSLSUPPORTOPTS}"
fi
	
# Remove old build log
if [ -e ${BUILD_LOG} ]
then
	rm ${BUILD_LOG}
fi

# Create ${FIPS_PREFIX_DIR} if it does not exist
create_stage_dir ${FIPS_PREFIX_DIR}

# Create ${APACHE_PREFIX_DIR} if it does not exist
create_stage_dir ${APACHE_PREFIX_DIR} root

# Test existence of source files and setup directory structures
echo "Changing Directory to ${STAGE_DIR}."
cd ${STAGE_DIR}
echo "Current Directory: $( pwd )"

for FBASE in ${SRCFILES}
do
	if [ "${FBASE}" = "${OSSL_FILE_BASE}" -o "${FBASE}" = "${ZLIB_FILE_BASE}" -o "${FBASE}" = "${APR_FILE_BASE}" -o "${FBASE}" = "${APR_UTIL_FILE_BASE}" ]
	then
		DIROPT="${HTTPDDIR}/srclib"
	else
		DIROPT="${STAGE_DIR}"
	fi

	# Look for the base file.  The filename must contain at least
	# a '.tar' for the script to work
	FILE=$( find ${STAGE_DIR} -regex "^.*${FBASE}-[0-9].*\.tar.*$" -print )
	if [ ! -z ${FILE} ]
	then
		if [ "${FILE##*.}" = "gz" ]
		then
			echo "Unzipping ${FILE}..."
			gunzip ${FILE}
			status_check $?
			echo "Extracting ${FILE%.*}..."
			tar xvf ${FILE%.*} -C ${DIROPT} >> /dev/null
			status_check $?
		else
			echo "Extracting ${FILE}..."
			tar xvf ${FILE} -C ${DIROPT} >> /dev/null
			status_check $?
		fi

		DIR=$( find ${DIROPT} -maxdepth 1 -type d -regex "^.*${FBASE}-[0-9].*$" -print )
		echo "Renaming ${DIR} to $( echo ${DIR} | sed -e "s/^\(.*${FBASE}\)-[0-9].*$/\1/" )"
		mv ${DIR} $( echo ${DIR} | sed -e "s/^\(.*${FBASE}\)-[0-9].*$/\1/" )
		status_check $?
	else
		echo "${FBASE} Source not found in ${STAGE_DIR}!"
		echo "Cleaning up and exiting..."
		cleanup_install	
		exit 1
	fi
done

if [ "${HTTPD24}" = "true" ]
then
	# Build and install apr
	#standard_build "${APRDIR}" apr "${APRCONFCMD}" "${APACHE_PREFIX_DIR}"
	# Build and install apr-util
	#standard_build "${APRUTILDIR}" apr-util "${APRUTILCONFCMD}" "${APACHE_PREFIX_DIR}"
	# Create ${PCRE_PREFIX_DIR} if it does not exist
	create_stage_dir ${PCRE_PREFIX_DIR}
	# Build and install pcre
	standard_build "${PCREDIR}" pcre "${PCRECONFCMD}" "${PCRE_PREFIX_DIR}"
fi

# Build and install the fipscanister
echo "Changing Directory to ${FIPSDIR}..."
cd ${FIPSDIR}
echo "Current Directory: $( pwd )"
echo -e "\nConfiguring FIPS Canister Build..."
sleep ${SLEEP_TIME}
if [ "${FIPS2}" = "false" ]
then
	eval ${FIPSCONFCMD} >> ${BUILD_LOG} 2>&1
else
	export FIPSDIR=${FIPS_PREFIX_DIR}
	./config >> ${BUILD_LOG} 2>&1
fi
#./config >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nMaking FIPS Canister Build..."
sleep ${SLEEP_TIME}
make >> ${BUILD_LOG} 2>&1
status_check $?
if [ "${FIPS2}" = "false" ]
then
	echo -e "\nTesting FIPS Canister Build..."
	sleep ${SLEEP_TIME}
	make test >> ${BUILD_LOG} 2>&1
	status_check $?
fi
echo -e "\nInstalling FIPS Canister Build to ${FIPS_PREFIX_DIR}..."
sleep ${SLEEP_TIME}
make install >> ${BUILD_LOG} 2>&1
status_check $?


# Build and install OpenSSL with FIPS
echo "Changing Directory to ${OSSLDIR}..."
cd ${OSSLDIR}
echo "Current Directory: $( pwd )"
echo -e "\nConfiguring OpenSSL with FIPS..."
sleep ${SLEEP_TIME}
eval ${SSLCONFCMD} >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nMaking OpenSSL with FIPS..."
sleep ${SLEEP_TIME}
make >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nTesting OpenSSL with FIPS..."
sleep ${SLEEP_TIME}
make test >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nInstalling OpenSSL with FIPS to ${APACHE_PREFIX_DIR}..."
sleep ${SLEEP_TIME}
make install >> ${BUILD_LOG} 2>&1
status_check $?

# Build and install ZLib
standard_build "${ZDIR}" zlib "${ZLIBCONFCMD}" "${APACHE_PREFIX_DIR}"

# Build and install Apache/HTTPD
echo "Changing Directory to ${HTTPDDIR}..."
cd ${HTTPDDIR}
echo "Current Directory: $( pwd )"
echo -e "\nConfiguring HTTPD..."
echo "Including:"
# List out modules being included
for i in ${INCLUDE_LIST}
do
	echo $i
done
echo -e "\nExcluding:"
# List out modules being excluded
for i in ${EXCLUDE_LIST}
do
	echo $i
done
sleep ${SLEEP_TIME}
# Set up initial configure command line
HTTPDCONFBASE="${HTTPDCONFPRE}"
# Append each exclude/disable module to the configure command line
for i in ${EXCLUDE_LIST}
do
	HTTPDCONFBASE="${HTTPDCONFBASE} --disable-${i}"
done

# Complete the configure command line
HTTPDCONFBASE="${HTTPDCONFBASE} ${HTTPDCONFPOST}"
echo -e "\n${HTTPDCONFBASE}"
eval ${HTTPDCONFBASE} >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nMaking HTTPD..."
sleep ${SLEEP_TIME}
make >> ${BUILD_LOG} 2>&1
status_check $?
echo -e "\nInstalling HTTPD to ${APACHE_PREFIX_DIR}..."
sleep ${SLEEP_TIME}
make install >> ${BUILD_LOG} 2>&1
status_check $?

package_apache

