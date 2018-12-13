#!/bin/bash

for ((year=2010;year<2017;++year))
do
echo $year
bash ./AD.sh $year
done
bash ./AD.sh all
