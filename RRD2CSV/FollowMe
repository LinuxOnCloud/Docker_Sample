
This is a simple Perl script I made to change RRD files into CSV's. *RRD2CSV* enables you to export and rrd file to a csv format. It converts all numeric values to decimal and epoch time to date format.

*Usage*: ```rrd2csv.pl --start {epoch time} --end {epoch or negative time in seconds} filename.rrd```

*Example*: ```rrd2csv.pl --start 1286960420 --end -1024 processes-netgod/ps_rss.rrd```

**USAGE**

```usage: rrd2csv [args] some.rrd```   
-a autoscale DS values (also --autoscale)  
-c num convert DS values by "num" (also --conversion)  
-e end report ending at time "end" (also --end)  
-l label label DS values with "label" (also --label)  
-m only report the maximum value (also --max)  
-n only report values around now (--now)  
-s start report starting at time "start" (also --start)  
-v print the start and end times (also --verbose)  

The -s and -e options support the traditional "seconds since the Unix epoch" and the AT-STYLE time specification (see man rrdfetch) ```

**This program requires**:  
librrds-perl  
rrdtool
