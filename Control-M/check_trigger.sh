#!/usr/bin/sh

script_name=`basename $0`
#script_name1=$1

#echo "The script name is $script_name"

curr_pid=`ps -ef |grep "$script_name" |grep -v "grep" |head -1 | awk '{print $2}'`

#echo "The pid of my process is $curr_pid"

parent_pid=`ps -ef |grep "$script_name" |grep -v "grep" |head -1 |awk '{print $3}'`

while [ $parent_pid -ne 1 ]
do
        temp="$parent_pid"
        parent_pid=`ps -ef |grep "$parent_pid" |grep -v "grep" |grep -v "$curr_pid"|head -1 | awk '{print $3}'`
        curr_pid="$temp"
done

process_trigger=`ps -ef |grep $curr_pid |awk -v var1="$curr_pid" '$2 == var1'`
#echo "Process Trigger is : $process_trigger"
#echo "Latest CURR PID is : $curr_pid"

echo $process_trigger |grep ctmag
if [ $? -eq 0 ];then
        echo " The script $script_name was triggered from Control-M "
else
        echo " The script $script_name was triggered from Shell "
fi

sleep 1
