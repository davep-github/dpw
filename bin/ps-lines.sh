#!/bin/sh




#
# Shell script to produce a PostScript file that will print graph paper.
#
# I called this shell script "lines". To use it I simply enter:
# "lines (rows per cm) (cols per cm) > (file).ps" 




rows=$1
cols=$2
rinc=`expr 28 / $rows`
cinc=`expr 28 / $cols`
x=0
y=0



echo "%!PS-Adobe-2.0"
echo "%%Pages: 1"
echo "%%PageOrder: Ascend"
echo "%%BoundingBox: 0 0 596 842"
echo "%%EndComments"

echo "0.001 setlinewidth"
echo "newpath"




while [ $x -lt 612 ]
do
echo " $x 0 moveto"
echo " $x 792 lineto"
x=`expr $x + $cinc`
done




while [ $y -lt 792 ]
do
echo " 0 $y moveto"
echo " 612 $y lineto"
y=`expr $y + $rinc`
done




echo "stroke"
echo "showpage"

echo "%%EndDocument"
echo "%%EOF"



