#!/bin/bash

#Copyright 2013 Antonio Roberts, License: GPL v3+

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#get bitrate
bitRate=$(avprobe $1 2>&1 | grep bitrate | cut -d ':' -f 6 | sed s/"kb\/s"//)

#convert the movie to frames
avconv -i $file -qscale 0 out_%d.pcx

#count the number files in the directory
fileno=$(ls out_*.pcx -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

rand1=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand2=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 3)

#glitch the files
sed -i s/$rand1/$rand2/g out_$no.pcx

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done

#combine the images into a video
avconv -i out_%d.pcx -qscale 0 "$file"_pcx.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
