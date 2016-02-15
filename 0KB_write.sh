
bash prepare.sh
echo "start 0K Write"
date >> stat.log
bash call-swift.sh stat >> stat.log
bash run1.sh 0KB-write write_100con_100obj_0KB_
	sleep 30
echo "0K write finished..." >> stat.log
date >> stat.log
bash call-swift.sh stat >> stat.log

echo "======================Run Finished========================"
