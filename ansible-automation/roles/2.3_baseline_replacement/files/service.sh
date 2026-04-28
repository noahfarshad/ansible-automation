#!/bin/sh

# This script is meant to start the {{service_name}} instance
#
# /etc/init.d/{{service_name}}
# Subsystem file for {{service_name}}
#
#
# processname: {{service_name}}
# config: /etc/sysconfig/{{service_name}}
# pidfile: {{service_pid_file}}

# source function library
. /etc/rc.d/init.d/functions

# pull in sysconfig settings
[ -f /etc/sysconfig/{{service_name}} ] && . /etc/sysconfig/{{service_name}}

SERVICE_NAME={{service_name}}
LOG_LOCATION={{service_log_dir}}

CMD="{{service_startup_cmd}}"

RUN_AS="app_admin"
PIDFILE={{service_pid_file}}
LOCKFILE=/var/lock/subsys/${SERVICE_NAME}


start() {
	echo "Starting $SERVICE_NAME ..."
	touch ${LOCKFILE}
	touch ${PIDFILE}
	chown ${RUN_AS}:${RUN_AS} ${PIDFILE}
	status -p ${PIDFILE} ${SERVICE_NAME} >> /dev/null
	RETVAL=$?

	if [ ${RETVAL} -eq 0 ]
	then
		echo -n "Process ${SERVICE_NAME} appears to be running ($( cat ${PIDFILE} )): ";echo_warning;echo
		exit 0
	fi

    /bin/su - ${RUN_AS} -c "${CMD}" 1> ${LOG_LOCATION}/${SERVICE_NAME}.log 2>&1 & echo $! > $PIDFILE
    # change owner of the files, since we want the log files to be owned by the same user as the executor
    chown ${RUN_AS}:${RUN_AS} ${LOG_LOCATION}/${SERVICE_NAME}.log
    PID=$(/bin/cat $PIDFILE);
    echo "$SERVICE_NAME (${PID}) started..."
	RETVAL=0
}

stop() {
	status -p ${PIDFILE} ${BASE_NAME} >> /dev/null
	RETVAL=$?

	if [ ${RETVAL} -ne 0 ]
	then
		echo -n "Process ${BASE_NAME} appears to be dead already: ";echo_warning;echo
		exit 1
	fi

	TIMESTAMPED_LOG=${LOG_LOCATION}/${SERVICE_NAME}-$(date +%s).log

    mv ${LOG_LOCATION}/${SERVICE_NAME}.log ${TIMESTAMPED_LOG}

    chown ${RUN_AS}:${RUN_AS} ${TIMESTAMPED_LOG}

    PID=$(/bin/cat $PIDFILE);
   
    KILL_RETRY_COUNTER=0
    while kill $PID; do
      # To prevent shutdown from hanging set a retry limit
      # 40 iterations at 3s wait is about 2 minutes.
      if [ $KILL_RETRY_COUNTER -eq 40 ]; then
        echo -n "Failed to Stop Process within limit: $SERVICE_NAME (${PID})";echo_warning;echo
        exit 1
      fi
      KILL_RETRY_COUNTER=`expr $KILL_RETRY_COUNTER+1`
      echo "Requesting service shutdown:  $SERVICE_NAME (${PID})..."
      sleep 3
    done
    
    echo "$SERVICE_NAME (${PID}) stopped ..."
    /bin/rm -f $PIDFILE
	/bin/rm -f ${LOCKFILE}
	RETVAL=0
}

case "$1" in
	start)
		shift
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		shift
		start
		;;
	status)
		status -p ${PIDFILE} ${SERVICE_NAME}
		RETVAL=$?
		;;
	*)
		echo "Usage: ${0} {start|stop|restart|status}"
esac
#exit ${RETVAL}
