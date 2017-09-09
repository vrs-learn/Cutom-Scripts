#!/bin/sh
##############################################################################
# Author : Vaibhav Raj Saxena
# Description : Generate and FTP the file to frrmdef-ap70
#
#
##############################################################################

#Send files to FTP dir

SCRIPTS_DIR="$HOME"/scripts/morescripts/scripts
DATA_DIR="$HOME"/scripts/morescripts/data
REPORT_DIR="$HOME"/scripts/morescripts/reports
week_no=`date +%U`
weekly_report=Weekly_Reports.xlsx

#Recieve the Weekly Report file from FTP Dir
sftp ftp_user@10.126.48.237 <<EOF
ascii
lcd $DATA_DIR
cd usage_reporting/pivot
get $weekly_report
lcd $REPORT_DIR
get Domains.csv
bye
EOF

cp "$DATA_DIR"/Weekly_Reports.xlsx "$DATA_DIR"/CTLM-Weekly_Reports.xlsx
cat $SCRIPTS_DIR/body_pivot.txt | mail -r ControlmAdmin@total.com -s "CTLM Weekly Jobs Usage Report v2.0 for All Datacenters - Week "$week_no" " -a ""$DATA_DIR"/Weekly_Reports.xlsx" -c rm.si-ip-infra-telco@total.com,vaibhav.saxena@capgemini.com,satya.mohanty@capgemini.com,im_total_controlm.in@capgemini.com bernard.tanzi@total.com

#Recieve the Accumulated Domains Report file from FTP Dir
#sftp ftp_user@10.126.48.237 <<EOF
#bin
#lcd $REPORT_DIR
#cd usage_reporting/pivot
#get Domains.csv
#bye
#EOF

#Append the Domains file with the Master Domains file.
sed -e 's/^M/\n/g' $REPORT_DIR/Domains.csv |sed -e '1d' |sed -e '$d' >> $REPORT_DIR/Master_Domains.csv
cat $REPORT_DIR/Master_Domains.csv

#Send the Master file to FTP server
sftp ftp_user@10.126.48.237 <<EOF
bin
lcd $REPORT_DIR
cd usage_reporting/pivot
put Master_Domains.csv
bye
EOF

#Send the Master Domsins file to Controlm DL
echo "Please find attached the Master Domains File "|mail -r ControlmAdmin@total.com -s "Master Domains File " -a "$REPORT_DIR"/Master_Domains.csv im_total_controlm.in@capgemini.com

#
# Publish the New Report on Web
#

cd /soft/cemp8001/ctm_em/etc/emweb/tomcat/webapps/WebReporting
if [ -f weekly_report.html ]
then
echo " Taking Backup of old Weekly Report"
mv weekly_report.html weekly_report.html.old
else
echo " The File weekly_report.html is not present. "
exit 2;
fi

rm -r weekly_report_files.old
if [ $? -ne 0 ];then
echo " Old Weekly Reports Dir was not deleted . Pls Check "
exit 3;
fi

cp -rp weekly_report_files weekly_report_files.old

rm -r weekly_report_files
if [ $? -ne 0 ];then
echo " Weekly Reports Dir was not deleted . Pls Check "
exit 3;
fi

mkdir weekly_report_files

#Download weekly Report
sftp ftp_user@10.126.48.237 <<EOF
lcd /soft/cemp8001/ctm_em/etc/emweb/tomcat/webapps/WebReporting
cd usage_reporting/pivot/htmlreport
get weekly_report.html
bye
EOF

#Download Associated Files
cd /soft/cemp8001/ctm_em/etc/emweb/tomcat/webapps/WebReporting/weekly_report_files
sftp ftp_user@10.126.48.237 <<EOF
lcd /soft/cemp8001/ctm_em/etc/emweb/tomcat/webapps/WebReporting/weekly_report_files
cd usage_reporting/pivot/htmlreport/weekly_report_files
get *
bye
EOF

echo "Report Published on Web Reporting POrtal. Pls Check " |mail -s "Web-Publish of Weekly_Report - Status" im_total_controlm.in@capgemini.com
