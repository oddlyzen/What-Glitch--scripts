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
avconv -i $file -qscale 0 out_%d.sgi

#count the number files in the directory
fileno=$(ls out_*.sgi -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

rand1=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand2=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)

#glitch the files
sed -i s/$rand1/$rand2/g out_$no.sgi

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done
echo -e "You may see a lot of error messages here. Don't worry about them"
#avconv doesn't seem to like sgi files as input so convert them to bmps
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.sgi" 1))) (filename "") (image 0) (layer 0) )
  (while (pair? file's)
    (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
    (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
    (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".bmp"))
    (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
    (gimp-image-delete image)
    (set! file's (cdr file's))
    )
  (gimp-quit 0)
  )
EOF

rm out_*.sgi

#combine the images into a video
avconv -i out_%d.bmp -qscale 0 "$file"_sgi.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
