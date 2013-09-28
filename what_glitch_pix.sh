#!/bin/bash

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#convert the movie to frames
avconv -i $file -qscale 0 out_%d.bmp

#count the number files in the directory
fileno=$(ls out_*.bmp -1 | wc -l)

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e " You may see a lot of error messages here. Don't worry about them"
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.bmp" 1))) (filename "") (image 0) (layer 0) )
  (while (pair? file's)
    (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
    (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
    (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".pix"))
    (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
    (gimp-image-delete image)
    (set! file's (cdr file's))
    )
  (gimp-quit 0)
  )
EOF

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

rand1=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)
rand2=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)

#glitch the files

sed -i s/$rand1/$rand2/g out_$no.pix

echo -e "Glitched file $no of $fileno"

no=$(($no + 1))

done

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e "You may see a lot of error messages here. Don't worry about them"
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.pix" 1))) (filename "") (image 0) (layer 0) )
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

rm out_*.pix

#get path of file
path=$( readlink -f "$( dirname "$file" )" )

#get filename minus extension
file1=$(basename "$file")
filename="${file1%.*}"

#combine the images into a video
avconv -i out_%d.bmp -qscale 0 "$path"/"$filename"_pix.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
