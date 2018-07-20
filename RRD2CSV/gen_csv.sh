start_date=$1
start_time=$2
end_date=$3
end_time=$4
file_name=$5
server_name=$6

st=`date -d "$start_date $start_time" +"%s"`
et=`date -d "$end_date $end_time" +"%s"`

std=`echo $start_date|tr '/' '-'`
etd=`echo $end_date|tr '/' '-'`
fname=`echo $file_name|tr '%' '-'|tr '.' ' '|awk '{print $1}'`

/root/rrd2csv/rrd2csv.pl --start $st --end $et $file_name > ${server_name}_${fname}_${std}_${etd}.csv