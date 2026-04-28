#!/bin/sh

# This script is meant to start the {{consul_name | capitalize }} instance
#
# /etc/init.d/{{consul_name}}
# Subsystem file for {{consul_name | capitalize }}
#
#
# processname: {{consul_name}}
# config: /etc/sysconfig/{{consul_name}}
# pidfile: {{consul_pid}}

# source function library
. /etc/rc.d/init.d/functions

# pull in sysconfig settings
[ -f /etc/sysconfig/consul ] && . /etc/sysconfig/{{consul_name}}

CONSUL_HOME={{consul_dir}}
SERVICE_NAME={{consul_name}}
LOG_LOCATION={{consul_log_dir}}

CMD="{{consul_startup_cmd}}"

RUN_AS="app_admin"
PIDFILE={{consul_pid}}
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
    
    PID_KILL_COUNT=0
    while kill $PID; do
      # 40 iterations at 3s wait is about 2 minutes.
      if [ $PID_KILL_COUNT -eq 40 ]; then
        echo -n "Failed to Stop Process within limit: $SERVICE_NAME (${PID})";echo_warning;echo
        exit 1
      fi
      PID_KILL_COUNT=`expr $PID_KILL_COUNT+1`
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
