#!/bin/bash

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#get bitrate
bitRate=$(avprobe $1 2>&1 | grep bitrate | cut -d ':' -f 6 | sed s/"kb\/s"//)

#convert the movie to frames
avconv -i $file -b "$bitRate"k out_%d.bmp

#count the number files in the directory
fileno=$(ls out_*.bmp -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

convert out_$no.bmp +adjoin -depth 1 -dither FloydSteinberg out_$no.gif

echo -e "Glitched file $no of $fileno"

rm out_$no.bmp

no=`expr $no + 1`

done

#combine the images into a video
avconv -i out_%d.gif -b "$bitRate"k "$file"_1bitgif.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/