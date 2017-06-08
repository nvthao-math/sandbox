#!/bin/bash
JOB="/home/cpu10869-local/sandbox/process-monitor/hdoops-1.0.jar"
echo "file execute on $JOB"
# java lib
JAVA="/usr/lib/jvm/java-8-oracle/jre/bin/java"
# memory setting
MEM_OPT="-Xms16M -Xmx32M"
# execute service
echo $JAVA $MEM_OPT -jar $JOB
nohup $JAVA $MEM_OPT -jar $JOB > /dev/null 2>&1 &
echo "$! \t PROCESS-10" > pid
TIME_NANO = date + %s%N
TIME_STR = date +"%Y-%m-%d:%H-%M-%S"
KEY = "mprocess:gms_parse_speed_to_es:$TIME_NANO"
redis-cli -h localhost -p 6379 HMSET $KEY $! false "time_start" $TIME_STR
rm -f nohup.out
