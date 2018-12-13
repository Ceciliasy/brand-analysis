#!/bin/bash
year_list=`ls /mnt/HDD/NYT/`
for year in $year_list
do
echo $year
bash ./NYT.sh $year 1
done
