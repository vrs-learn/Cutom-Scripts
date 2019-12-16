#!/bin/sh
##############################################################################
# Author : Vaibhav Raj Saxena
# Description : The Script is used to concatenate a week's Data for the Jobs Usage.
#
#
##############################################################################

#Gets the No of the jobs for Yesterday
get_no_of_jobs(){

table_id=a$yest_date$dcid
table_name=$table_id"_ajob"

psql <<EOF > $DATA_DIR/jobs.txt
select NODEGROUP , application , count(NODEGROUP) from $table_name group by NODEGROUP , application ;
\q
EOF

#cat $DATA_DIR/jobs.txt | sed -e '1,2d' |sed -e '$d' |sed -e '$d'|sed -e 's/^ *|/NONODES|/g' |sed -e 's/\s//g' > $DATA_DIR/cleaned_jobs.txt
cat $DATA_DIR/jobs.txt | sed -e '1,2d' |sed -e '$d' |sed -e '$d'|sed -e 's/^ *|/NONODES|/g' |sed -e 's/| *|/|NOAPPLICATION|/g' | sed -e 's/\s//g' > $DATA_DIR/cleaned_jo
bs.txt


#sed -e 's/|/,/g' $DATA_DIR/cleaned_jobs.txt | sort -n -k1,1 > $DATA_DIR/jobs_"$dcid"_"$yest_day".txt
sed -e 's/\(.*\)|\(.*\)|/\1|\2,/g' $DATA_DIR/cleaned_jobs.txt  | sort -n -k1,1 > $DATA_DIR/jobs_"$dcid"_"$yest_day".txt

}

# Adds Header to the Weekly Report:
add_header(){

#if [ -f ""$DATA_DIR"/all_dc_week.csv" ]
#then
#        echo "The file exists . Adding Header"
#        sed -i '1iWeekly Control-M_Jobs_Usage_Report \' $DATA_DIR/all_dc_week.csv
#        sed -i "2iCMDB_Appl,NodeID,CNTRLM_Appl,$add_head \ " $DATA_DIR/all_dc_week.csv
#fi

sed -i 's/NULL/0/g' $DATA_DIR/all_dc_week.csv
cp $DATA_DIR/all_dc_week.csv $DATA_DIR/all_dc_week8p.csv

}

#Send Email to the Email Group on Monday
send_weekly_email(){


echo "Please find attached the Weekly Jobs Usage Report for the Week Number : "$week_no" for the \
 v8 Production Datacenters " | mail -s "Weekly Jobs Usage Report for Production Datacenters v8 - Week "$week_no" " -a ""$DATA_DIR"/all_dc_week8p.csv" vaibhav.saxena@cap
gemini.com

}

check_files(){

if [ -f $weekfile ];then
        echo "File Check was OK. File exists."
else
        echo " The week file "$weekfile" does not exists . pls check "
        exit 4;
fi
}

merge_all_dc(){

cat ""$DATA_DIR"/jobs_week_p01.txt" > ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_p02.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_p03.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_t01.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_t02.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_r01.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_r02.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_r03.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_r04.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_r05.txt" >> ""$DATA_DIR"/all_dc_week.csv"
cat ""$DATA_DIR"/jobs_week_b01.txt" >> ""$DATA_DIR"/all_dc_week.csv"
sed -i 's/|/,/g' $DATA_DIR/all_dc_week.csv

}

#
concat_week_data(){

weekfile=""$DATA_DIR"/jobs_week_"$dcid".txt"
yestfile=""$DATA_DIR"/jobs_"$dcid"_"$yest_day".txt"
tempfile=""$DATA_DIR"/jobs_week_"$dcid"_temp.txt"

check_files

cp $weekfile $tempfile

if [ $loop -eq 1 ];then
#       cp $DATA_DIR/jobs_"$dcid"_"$yest_day".txt $DATA_DIR/jobs_week_"$dcid".txt
        cp $yestfile $weekfile
elif [ $loop -eq 2 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,2.2' $tempfile $yestfile > $weekfile
elif [ $loop -eq 3 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,1.3,2.2' $tempfile $yestfile > $weekfile
elif [ $loop -eq 4 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,1.3,1.4,2.2' $tempfile $yestfile > $weekfile
elif [ $loop -eq 5 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,1.3,1.4,1.5,2.2' $tempfile $yestfile > $weekfile
elif [ $loop -eq 6 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,1.3,1.4,1.5,1.6,2.2' $tempfile $yestfile > $weekfile
elif [ $loop -eq 7 ];then
        join -t',' -a 1 -a 2 -e 'NULL' -o '0,1.2,1.3,1.4,1.5,1.6,1.7,2.2' $tempfile $yestfile > $weekfile
else
        echo " There was some error getting the LOOP No. Please check "
        exit 3;
fi

}


clean_data(){

temp_file=""$DATA_DIR"/temp.txt"
cp $weekfile $temp_file
echo " Checking for any unwanted rows containing errors of join "
grep -v join $temp_file > $weekfile

}

get_info(){
dc=$1
if [ $dc == 'CTMPROD801' ];then
        dcid=p01
        get_no_of_jobs
        concat_week_data
                clean_data
elif [ $dc == 'CTMPROD802' ];then
        dcid=p02
        get_no_of_jobs
        concat_week_data
                clean_data
elif [ $dc == 'CTMPROD803' ];then
        dcid=p03
        get_no_of_jobs
        concat_week_data
                clean_data
elif [ $dc == 'CTMTOOL801' ];then
        dcid=t01
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMTOOL802' ];then
        dcid=t02
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMPROD701' ];then
        dcid=r01
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMPROD702' ];then
        dcid=r02
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMPROD703' ];then
        dcid=r03
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMPROD704' ];then
        dcid=r04
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMPROD705' ];then
        dcid=r05
        get_no_of_jobs
        concat_week_data
        clean_data
elif [ $dc == 'CTMTOOL701' ];then
        dcid=b01
        get_no_of_jobs
        concat_week_data
        clean_data
else
        echo "Invalid Parameter"
        exit 2;
fi

}

week_report(){

echo "Creating the Report for the last whole week"

# 7 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-604800;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-604800;')
loop=1
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
add_head=$yest_day

# 6 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-518400;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-518400;')
loop=2
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

# 5 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-432000;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-432000;')
loop=3
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

# 4 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-345600;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-345600;')
loop=4
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

# 3 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-259200;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-259200;')
loop=5
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

# 2 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-172800;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-172800;')
loop=6
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

# 1 Day Ago
yest_date=$(perl -e 'use POSIX;print strftime "%y%m%d",localtime time-86400;')
yest_day=$(perl -e 'use POSIX;print strftime "%A",localtime time-86400;')
loop=7
get_info CTMPROD801
get_info CTMPROD802
get_info CTMPROD803
get_info CTMTOOL801
get_info CTMTOOL802
get_info CTMPROD701
get_info CTMPROD702
get_info CTMPROD703
get_info CTMPROD704
get_info CTMPROD705
get_info CTMTOOL701
temp_var=$add_head
add_head=""$temp_var","$yest_day""

}

add_dc(){

sed -i s/^/CTMPROD801,/g ""$DATA_DIR"/jobs_week_p01.txt"
sed -i s/^/CTMPROD802,/g ""$DATA_DIR"/jobs_week_p02.txt"
sed -i s/^/CTMPROD803,/g ""$DATA_DIR"/jobs_week_p03.txt"
sed -i s/^/CTMTOOL801,/g ""$DATA_DIR"/jobs_week_t01.txt"
sed -i s/^/CTMTOOL802,/g ""$DATA_DIR"/jobs_week_t02.txt"

}

add_cmdb_app(){

if [ -f $DATA_DIR/ref_cmdb.txt ];then
        echo "ref_cmdb.txt File exists."
else
        echo " The ref_cmdb.txt File Does Not exists . pls check "
        exit 4;
fi

IFS=$'\n'
for x in `cat $DATA_DIR/all_dc_week.csv`
do
        nodex=`echo $x|awk -F"," '{print $1}'`
                temp1=`grep -i "^$nodex," $DATA_DIR/ref_cmdb.txt | grep -v grep`
                if [ $? -eq 0 ];then
                        cmdbapp=`echo $temp1 |awk -F"," '{print $2}'`
                        sed -i s:"^$nodex,":"$cmdbapp,$nodex,": $DATA_DIR/all_dc_week.csv
                else
                        sed -i s:"^$nodex,":",$nodex,": $DATA_DIR/all_dc_week.csv
                fi
done

sed -i s:^,:MISCELLANEOUS,:g $DATA_DIR/all_dc_week.csv

}


############################
########## MAIN ############
############################

SCRIPTS_DIR=/soft/cemp8001/scripts/morescripts/scripts
DATA_DIR=/soft/cemp8001/scripts/morescripts/data

export LANG=en_US
export PGPASSWORD=<SomePassword>
. /soft/cemp8001/ctm_em/.PGenv.sh

loop=0
today_date=`date +%y%m%d`
week_no=`date +%U`

# Performing the Weekly Report Generation
week_report

# All Days Data collected. Now Combining and sending the Report.
merge_all_dc
add_cmdb_app

#add_dc
add_header
#send_weekly_email

