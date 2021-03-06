#!/bin/bash

#change those before you run the scripts


SIZE=10
UNIT=MB
DRIVERS=5

CONTAINER=10000
OBJECT=100

ACCOUNT=cosbench
USER=operator
PASS=intel2012

URL=http://10.4.9.105/auth/v1.0

RAMPUP=90
RAMPDOWN=30

RUNTIME=300
TIMEOUT=300000

READ="read"
WRITE="write"

MODE=$WRITE

for workers in 1 2 4 8 16 32 64 128 256 512 1024
do
	filename=${MODE}_${CONTAINER}con_${OBJECT}obj_${SIZE}${UNIT}_$(($workers*$DRIVERS))w.xml
	echo '<?xml version="1.0" encoding="UTF-8"?>' >> $filename
	echo "<workload name=\"${MODE}_${CONTAINER}con_${OBJECT}obj_${SIZE}${UNIT}_$(($workers*$DRIVERS))w\" description=\"`echo $MODE | tr '[:lower:]' '[:upper:]'`-ONLY\">" >> $filename
		echo "<storage type=\"swift\" config=\"timeout=$TIMEOUT\" />" >> $filename
		echo "<auth type=\"swauth\" config=\"username=$ACCOUNT:$USER;password=$PASS;url=$URL;retry=9\" />" >> $filename
		echo '<workflow>' >> $filename
			echo '<workstage name="main">' >> $filename
				echo "<work name=\"${SIZE}${UNIT}\" workers=\"$(($workers*$DRIVERS))\" rampup=\"$RAMPUP\" runtime=\"$RUNTIME\" rampdown=\"$RAMPDOWN\">" >> $filename
					echo "<operation type=\"$MODE\" ratio=\"100\" config=\"containers=u(1,${CONTAINER});objects=u(1,${OBJECT});cprefix=${SIZE}${UNIT}-${MODE};sizes=c($SIZE)$UNIT\"/>" >> $filename
				echo '</work>' >> $filename
			echo '</workstage>' >> $filename
		echo '</workflow>' >> $filename
	echo '</workload>' >> $filename
	echo "$filename generated!"
done

filename=${MODE}_${CONTAINER}con_${OBJECT}obj_${SIZE}${UNIT}_0w.xml

echo '<?xml version="1.0" encoding="UTF-8"?>' >> $filename
echo "<workload name=\"${MODE}_${CONTAINER}con_${OBJECT}obj_${SIZE}${UNIT}_0w\" description=\"INIT-PREPARE\">" >> $filename
	echo "<storage type=\"swift\" config=\"timeout=$TIMEOUT\" />" >> $filename
	echo "<auth type=\"swauth\" config=\"username=$ACCOUNT:$USER;password=$PASS;url=$URL;retry=9\" />" >> $filename
	echo '<workflow>' >> $filename
		echo '<workstage name="init">' >> $filename
			echo "<work type=\"init\" workers=\"$(($DRIVERS*2))\" config=\"containers=r(1,${CONTAINER});cprefix=${SIZE}${UNIT}-${MODE}\"/>" >> $filename
		echo '</workstage>' >> $filename
		if [ $MODE == $READ ];
		then
			echo '<workstage name="prepare">' >> $filename
				echo "<work type=\"prepare\" workers=\"$(($DRIVERS*8))\" config=\"containers=r(1,${CONTAINER});objects=r(1,${OBJECT});cprefix=${SIZE}${UNIT}-${MODE};sizes=c($SIZE)$UNIT\"/>" >> $filename
			echo '</workstage>' >> $filename
		fi
	echo '</workflow>' >> $filename
echo '</workload>' >> $filename
echo "$filename generated!"
