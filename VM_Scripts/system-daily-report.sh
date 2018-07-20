#Start System Daily Report
system_ip=`ec2metadata --local-ipv4`
system_name=`ec2metadata --security-groups`
instance_id=`ec2metadata --instance-id`
EMAIL="abc@example.com"
##Start Html BackGround Function
bg_start() {
echo '<div style="background-color: #F0F0F0 ; float:left; width:98%; padding:1px; border-radius:10px;">
<div dir="ltr" style="text-align: left;" trbidi="on">'>/tmp/hm
}

##System Name & Ip Function
system_name() {
ip=`ec2metadata --local-ipv4`
sysname=`ec2metadata --security-groups`
insid=`ec2metadata --instance-id`
echo '<h1>
<div align="center" style="color: #634843;">'$sysname and $ip' ('$insid')</div></h1><br />'>>/tmp/hm
}

##Get System CPU Function
system_Cpu() {
sysetm="System CPU Details"
top1=`top -bn1 |head -1`
top2=`top -bn1 |head -2|tail -1`
top3=`top -bn1 |head -3|tail -1`
top4=`top -bn1 |head -4|tail -1`
top5=`top -bn1 |head -5|tail -1`
echo '<h3>
<span style="color: #434343;">'$sysetm'</span></h3>

<div style="text-align: justify;">
<span style="color: #38761d;">'$top1'<br />
'$top2'<br />
'$top3'<br />
'$top4'<br />
'$top5'</span></div><br />'>>/tmp/hm
}


##Get System Uptime Function
system_uptime() {
uptim="System UpTime Details"
uptm=`uptime`
echo '<h3>
<span style="color: #434343;">'$uptim'</span></h3>
<div style="text-align: justify;">
<span style="color: #38761d;">'$uptm'</span></div><br />'>>/tmp/hm
}

##Get System Memory Function
system_memory() {
mem="System Memory Details"
free -m > /tmp/mem
count=`wc  -l /tmp/mem|cut -d" " -f1`
counter=`expr $count + 1`
d=1

echo '<h3>
<span style="color: #434343;">'$mem'</span></h3>
<table style="width:500px; color:#38761d">' >/tmp/hm1

while [ $counter -ne $d ]; do

cat /tmp/mem|head -$d|tail -1 >/tmp/temp

firstw=`cat /tmp/temp |awk '{print $1}'`
secondw=`cat /tmp/temp |awk '{print $2}'`
thriedw=`cat /tmp/temp |awk '{print $3}'`
fourthw=`cat /tmp/temp |awk '{print $4}'`
fifthw=`cat /tmp/temp |awk '{print $5}'`
sixthw=`cat /tmp/temp |awk '{print $6}'`
seventhw=`cat /tmp/temp |awk '{print $7}'`

echo '<tr>
  <td>'$firstw'</td>
  <td>'$secondw'</td>
  <td>'$thriedw'</td>
  <td>'$fourthw'</td>
  <td>'$fifthw'</td>
  <td>'$sixthw'</td>
  <td>'$seventhw'</td>
</tr>' >>/tmp/hm1

d=$((d+1))
done

echo '</table>
<br />' >>/tmp/hm1
sed -i "5s/^/<td><\/td> /" /tmp/hm1
sed -ie 's/<td>-\/+<\/td>/<td>-\/+/g' /tmp/hm1
sed -ie 's/<td>buffers\/cache:<\/td>/buffers\/cache:<\/td>/g' /tmp/hm1
cat /tmp/hm1 >> /tmp/hm
}

##Get Disk Space
diskspase() {
disk="System Disk Space Details"
df -Th > /tmp/dfout
count=`wc  -l /tmp/dfout|cut -d" " -f1`
counter=`expr $count + 1`
d=1

echo '<h3>
<span style="color: #434343;">'$disk'</span></h3>
<table style="width:800px; color:#38761d">' >>/tmp/hm

while [ $counter -ne $d ]; do

cat /tmp/dfout|head -$d|tail -1 >/tmp/temp

firstw=`cat /tmp/temp |awk '{print $1}'`
secondw=`cat /tmp/temp |awk '{print $2}'`
thriedw=`cat /tmp/temp |awk '{print $3}'`
fourthw=`cat /tmp/temp |awk '{print $4}'`
fifthw=`cat /tmp/temp |awk '{print $5}'`
sixthw=`cat /tmp/temp |awk '{print $6}'`
seventhw=`cat /tmp/temp |awk '{print $7}'`

echo '<tr>
  <td>'$firstw'</td>
  <td>'$secondw'</td>
  <td>'$thriedw'</td>
  <td>'$fourthw'</td>
  <td>'$fifthw'</td>
  <td>'$sixthw'</td>
  <td>'$seventhw'</td>
</tr>' >>/tmp/hm

d=$((d+1))
done

echo '</table>
<br />' >>/tmp/hm
}


##Get Disk Inodes
diskinode() {
inod="System Inods Details"
df -i > /tmp/dfout
count=`wc  -l /tmp/dfout|cut -d" " -f1`
counter=`expr $count + 1`
d=1

echo '<h3>
<span style="color: #434343;">'$inod'</span></h3>
<table style="width:800px; color:#38761d">' >>/tmp/hm

while [ $counter -ne $d ]; do

cat /tmp/dfout|head -$d|tail -1 >/tmp/temp

firstw=`cat /tmp/temp |awk '{print $1}'`
secondw=`cat /tmp/temp |awk '{print $2}'`
thriedw=`cat /tmp/temp |awk '{print $3}'`
fourthw=`cat /tmp/temp |awk '{print $4}'`
fifthw=`cat /tmp/temp |awk '{print $5}'`
sixthw=`cat /tmp/temp |awk '{print $6}'`

echo '<tr>
  <td>'$firstw'</td>
  <td>'$secondw'</td>
  <td>'$thriedw'</td>
  <td>'$fourthw'</td>
  <td>'$fifthw'</td>
  <td>'$sixthw'</td>
</tr>' >>/tmp/hm

d=$((d+1))
done

echo '</table>
<br />' >>/tmp/hm
}


##Get System Mount Entry Details
fstabf() {
ftab="System Mount Entry Details"
cat /etc/fstab > /tmp/fstab
count=`wc  -l /tmp/fstab|cut -d" " -f1`
counter=`expr $count + 1`
d=1

echo '<h3>
<span style="color: #434343;">'$ftab'</span></h3>
<table style="width:800px; color:#38761d">' >>/tmp/hm

while [ $counter -ne $d ]; do

cat /tmp/fstab|head -$d|tail -1 >/tmp/temp

firstw=`cat /tmp/temp |awk '{print $1}'`
secondw=`cat /tmp/temp |awk '{print $2}'`
thriedw=`cat /tmp/temp |awk '{print $3}'`
fourthw=`cat /tmp/temp |awk '{print $4}'`
fifthw=`cat /tmp/temp |awk '{print $5}'`


echo '<tr>
  <td>'$firstw'</td>
  <td>'$secondw'</td>
  <td>'$thriedw'</td>
  <td>'$fourthw'</td>
  <td>'$fifthw'</td>
</tr>' >>/tmp/hm

d=$((d+1))
done

echo '</table>
<br />' >>/tmp/hm
}


##Get System Mounted Partition
system_mounted() {
mounted="System Mounted Partition"
mount > /tmp/sysmount
count=`wc  -l /tmp/sysmount|cut -d" " -f1`
counter=`expr $count + 1`
d=1

echo '<h3>
<span style="color: #434343;">'$mounted'</span></h3>
<table style="width:800px; color:#38761d">' >>/tmp/hm

while [ $counter -ne $d ]; do

mount_data=`cat /tmp/sysmount|head -$d|tail -1`


echo '<tr>
  <td>'$mount_data'</td>
</tr>' >>/tmp/hm

d=$((d+1))
done

echo '</table>
<br />' >>/tmp/hm
}


##End Html BackGround Function
bg_end() {
echo '</div>
</div>'>>/tmp/hm
}

bg_start
system_name
system_Cpu
system_uptime
system_memory
diskspase
diskinode
fstabf
system_mounted
bg_end

mail --append="Content-type: text/html" -s "$system_name ($instance_id / $system_ip) Daily Status Report" $EMAIL </tmp/hm

rm /tmp/temp /tmp/dfout /tmp/fstab /tmp/sysmount /tmp/hm /tmp/mem /tmp/hm1
