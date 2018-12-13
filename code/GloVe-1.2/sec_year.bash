#!/bin/bash

for ((year=2016;year<2018;++year))
do
echo $year
bash ./SEC_train.sh $year
done
