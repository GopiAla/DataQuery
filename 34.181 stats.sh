#!/bin/bash

if [ $# -ne 3 ]; then
echo "Usage:" $0 "<LastBackupDate> <NextBackupDate> <BackupSize>"
exit
fi

totsp="$(diskutil information -all | grep "Volume Total Space" | tail -2 | head -1 |  sed 's/ //g' | cut -d ':' -f2 | cut -d '(' -f1)"
usdsp="$(diskutil information -all | grep "Volume Used Space" | tail -2|head -1 |  sed 's/ //g' | cut -d ':' -f2 | cut -d '(' -f1)"
avlsp="$(diskutil information -all | grep "Volume Available Space" | tail -2| head -1 |  sed 's/ //g' | cut -d ':' -f2 | cut -d '(' -f1)"
usper="$(diskutil information -all | grep "Volume Used Space" | head  -1 |  sed 's/ //g' | cut -d '(' -f4 | sed 's/)//')"
usrcpu="$(top -n1 | head | grep "CPU usage" | cut -d ':' -f2 | cut -d ',' -f1 | sed 's/ //g' | sed 's/user//')"
syscpu="$(top -n1 | head | grep "CPU usage" | cut -d ':' -f2 | cut -d ',' -f2 | sed 's/ //g' | sed 's/sys//')"
idleper="$(top -n1 | head | grep "CPU usage" | cut -d ':' -f2 | cut -d ',' -f3 | sed 's/ //g' | sed 's/idle//')"
ramusd="$(~/Desktop/memReport.py | grep Real | cut -d':' -f2 | tr '\t' ' '| sed 's/ //g')"
eTime="$(date +%s)"
ILB="$(echo $1)"
INB="$(echo $2)"
IBS="$(echo $3)"

echo $totsp","$usdsp","$avlsp","$usper","$usrcpu","$syscpu","$idleper","$ramusd","$ILB","$INB","$IBS > /tmp/ServerStatsMonitor.txt
echo "Sending Mail.."
 awk 'BEGIN{ OFS=","; print "TotalSpace,UsedSpace,AvailableSpace,UsedPercentage,UserCPU,SystemCPU,IdlePercentage,RAMUsed,InsyncLastBackup,InsyncNextBackup,InsyncBackupSize"};  NR >=1{ FS=","; print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11;}' /tmp/ServerStatsMonitor.txt > /tmp/ServerStatsMonitor.csv
(echo "Please find the attachment for Server Statistics on 17.76.34.181 server";uuencode /tmp/ServerStatsMonitor.csv ServerStatsMonitor.csv) | mail -s "ServerStatsMonitor" -c "gopi_ala@apple.com" -c  "mohammad_hussain@apple.com" -F "T4_MAPS_HYD_IT_Support@group.apple.com"

echo "Posting to splunk.."
curl -ks https://splunk-hec.apple.com:8088/services/collector/event -H 'Authorization: Splunk A781F81B-0A7B-4D40-9527-C81B8826E202' -d '{"time":"'"$eTime"'" , "event":{"TotalSpace":"'"$totsp"'","UsedSpace":"'"$usdsp"'","AvailableSpace":"'"$avlsp"'","UsagePercentage":"'"$usper"'","UserCPU":"'"$usrcpu"'", "SystemCPU":"'"$syscpu"'", "SysIdlePercentage":"'"$idleper"'", "RAMusage":"'"$ramusd"'", "InSyncLastBackup":"'"$ILB"'", "InSyncNextBackup":"'"$INB"'", "InSyncBackupSize":"'"$IBS"'", "Source":"ServerStatsMonitorTest", "Server":"17.76.34.181"}}'
