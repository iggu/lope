#!/bin/bash

PRCNAME=$1
if [ -z $PRCNAME ]; then
    echo "Process name is not passed"
    exit 1
fi


while true; do
    PID=$(pgrep $PRCNAME)
    NOW=$(date)
    if [ -z $PID ]; then
        echo "$NOW Process is not running, starting"
	cd /tmp
	nohup $PRCNAME >/dev/null 2>&1 &
	sleep 10 # CPU utilization may be high during startup
	cd $OLDPWD
	echo "   >>PID: " `pgrep $PRCNAME`
    else
	RAWPRC=`top -b -n 1 | grep -w $PRCNAME | tr -s ' ' | tr , .`
        CPUPRCNT=`echo $RAWPRC | cut -d ' ' -f 9`
	if [[ ! $CPUPRCNT =~ [0-9]\.[0-9] ]]; then
	    CPUPRCNT=`echo $RAWPRC | cut -d ' ' -f 10`
	fi
	if [[ ! $CPUPRCNT =~ [0-9]\.[0-9] ]]; then
	    echo "Cannot parse percent value for '$PRCNAME' from '$RAWPRC': $CPUPRCNT"
	fi
        if [ `echo "$CPUPRCNT>90.0" | bc` -eq 1 ]; then
            echo "$NOW Process '$PRCNAME' utilizes too much CPU $CPUPRCNT%, killing"
	    kill $PID >/dev/null 2>&1 
	    sleep 1
	    kill -9 $PID >/dev/null 2>&1 
        else
            #echo "$NOW '$PRCNAME' utilizes $CPUPRCNT% of CPU, that's ok"
            sleep 1
        fi
    fi
done

