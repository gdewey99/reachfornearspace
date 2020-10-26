#!/bin/bash 
while true
do
export SSTVDIR=/home/pi/SSTV
cd $SSTVDIR

# Set Push To Talk GPIO
GPIO_PTT=7

# Initalize the GPIO port 
/usr/local/bin/gpio mode $GPIO_PTT out 
/usr/local/bin/gpio write $GPIO_PTT 1
sleep 60

sudo modprobe bcm2835-v4l2

# capture image and save sstv and hd resolution
raspistill -t 10000 -ex sports --width 320 --height 256 -e png -o /home/pi/SSTV/image.png
raspistill -t 10000 -ex sports --width 2592 --height 1944 -e jpg -o /home/pi/SSTV/image.jpg
# add callsign and text
mogrify -pointsize 24 -fill white -draw "text 10,40 'AB2GD'" ./image.png
mogrify -pointsize 24 -fill white -draw "text 10,240 'Reachfornearspace.com'" ./image.png
convert ./image.png -fill white -pointsize 16 -gravity NorthEast -annotate +0+40 "$(date +%D-%T)" ./image.png

# encode image.png to wav audio file
./pisstv /home/pi/SSTV/image.png 22050

# Turn on PTT
/usr/local/bin/gpio write $GPIO_PTT 0 
sleep .5

# Transmit SSTV Image
/usr/bin/aplay -d 0  ${SSTVDIR}/image.png.wav

# Turn off PTT
/usr/local/bin/gpio write $GPIO_PTT 1

# Move Images to save folder 
 newname=$(date +%Y%m%d_%H%M)
 mv ${SSTVDIR}/image.png ${SSTVDIR}/pictures/lowres/$newname.png
 mv ${SSTVDIR}/image.jpg ${SSTVDIR}/pictures/highres/$newname.jpg
 rm -f ${SSTVDIR}/image.png
 rm -f ${SSTVDIR}/image.jpg
 rm -f ${SSTVDIR}/image.wav
sleep 30
done
