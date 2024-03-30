#!/bin/bash

sleep_time=10

echo "[+] Checking for adb devices..."
if [ $(adb devices | wc -l) -eq 3 ]; then
	echo "	[-] adb devices found!"
else
	echo "	[-] adb device not found!"
	echo "	[-] Exiting..."
	exit 1
fi

echo "[+] Checking for Output directory..."
if [ -d out ]; then
        echo "  [-] Directory found!"
	echo "Following Apks were found in Output directory."
	var=0
	cd out
	for apk in `ls`; do
		((var++))
		echo "	$var. $apk"
	done
	cd ..
	echo "----------------"
else
	echo "	[-] Creating Director."
	mkdir out
fi

echo "[+] Checking for scripts directory..."
if [ -d src ]; then
	echo "	[-] Directory found!"
	cd src
	#python3 web.py &
	cd ..
else
	echo "	[-] src not found!"
	echo "	[-] Exiting..."
	exit 1
fi

echo "[+] Checking for log directory..."
if [ -d log ]; then
	echo "	[-] Directory found!"
	cd log
else
	echo "	[-] Creating Directory."
	mkdir log
	cd log
fi

while :
do
	sleep $sleep_time
	
	if [ ! -f installed.txt ]; then
		adb shell pm list package | cut -d: -f2 > installed.txt
	fi

	echo "-> Updating new package list..."
	adb shell pm list package | cut -d: -f2 > new.txt
	
	if [ "$(cat new.txt | wc -l)" -ge "$(cat installed.txt | wc -l)" ]; then
		diff --suppress-common-lines installed.txt new.txt | cut -d' ' -f2 | grep '\.' > tmp.txt
		mv new.txt installed.txt
		
		for line in `cat tmp.txt`; do
			cd ../out

			echo "Copying $line"
			mkdir $line
			cd $line
			adb shell pm path $line | cut -d: -f2 > tmp2.txt
			for i in `cat tmp2.txt`; do
				adb pull $i
			done
			rm -rf tmp2.txt
			cd ../../log
		done

		if [ $(cat tmp.txt | wc -l) -ge 1 ]; then
			date >> log.txt
			cat tmp.txt >> log.txt
			echo "----------------" >> log.txt
			rm -rf tmp.txt
		fi
	fi
done
