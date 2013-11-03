

#!/bin/bash
echo "downloading do-files from NBER"
cd ~/datasets/SIPP/2008/do/newdo

# downloading core data files

# define file names as variables and loop over them

for file in sippl08puw sippp08putm

do

	for (( ix=1; ix<=13; ix++ ))
	do
		if [[ -e ${file}${ix}.do  ]];
		then
			echo "file ${file}${ix}.do exists."
			echo ""
		else 
			echo "downloading files ${file}${ix}.do"
			wget -P ~/datasets/SIPP/2008/do/newdo http://www.nber.org/sipp/2008/${file}${ix}.do
		fi
		if [[ -e ${file}${ix}.dct ]];
		then
			echo "file ${file}${ix}.dct exists."
			echo ""
		else 
			echo "downloading files ${file}${ix}.dct"
			wget -P ~/datasets/SIPP/2008/do/newdo http://www.nber.org/sipp/2008/${file}${ix}.dct
		fi
	done

done
			
echo "program end."

