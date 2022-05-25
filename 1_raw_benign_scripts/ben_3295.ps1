#/bin/bash

date=`date '+%d%m%y_%H.%M.%S'`
tcpdump -U -i eth1 udp port 5060 or udp portrange 10000-20000 -s 0 -w $date.cap &
sleep 4h

pid=$(ps -e | pgrep tcpdump)
echo $pid

#interrupt it:
sleep 5
kill -2 $pid