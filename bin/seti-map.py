#!/usr/bin/env python
#
# $Id: seti-map.py,v 1.10 2003/11/11 08:30:15 davep Exp $
#
# David Panariti
#
import os, sys, string, re, getopt
import _imaging, Image, ImageDraw, ImageFont

"""seti-map.py"""

"""
The skymap.xpm file and sky coord to map coord conversion were borrowed from
kseitsaver.
(actually, coord conversion completely rewritten)

/***************************************************************************
                          positionscreen.cpp  -  description
                             -------------------
    begin                : Sun Jan 20 2002
    copyright            : (C) 2002 by Sebastian Schildt
    email                : sebastian@frozenlight.de
 ***************************************************************************/
"""

import dp_io
dp_io.debug_off()
dp_io.debug_file("/tmp/seti-map-debug")
dp_io.dprintf('argv>%s<\n', sys.argv)
dp_io.dprintf('cl>%s<\n', string.join(sys.argv, ' '))

fillcol=0xff000fff
work_info = {}
map_file = os.path.join(os.environ.get('HOME'), "icons", "skymap.ppm")
out_file = os.path.join(os.environ.get('TMP'), "seti-map-out.ppm")
seti_home = '/var/db/setiathome'
x_out = None
y_out = None
out_type = 'PPM'
font_file = '/home/davep/yokel/fonts/PIL/luIS24-ISO8859-1.pil'

# /halo-2003-11-09-18-30-23-53-scaled.png
def_background_image_name = os.path.join(os.environ.get('HOME'),
                            'stuff/halo-2003-11-10-23-47-47-03.png')
background_image_name = def_background_image_name

options, args = getopt.getopt(sys.argv[1:], 'f:o:s:m:x:y:t:d:b:')
for (o, v) in options:
    # Set the fill color.  This is in PIL color format.
    if o == '-f':
        fillcol = eval(v)
        continue

    # place output here
    if o == '-o':
        out_file = v
        continue

    # the seti@home files are here
    if o == '-s':
        seti_home = v
        continue

    # the map file is here.
    # I grabbed the map file from ksetisaver
    if o == '-m':
        map_file = v
        continue

    # x dimension for output
    if o == '-x':
        x_out = eval(v)
        continue

    # y dimension for output
    if o == '-y':
        y_out = eval(v)
        continue

    # type of output file.  A type PIL understands.
    if o == '-t':
        out_type = v
        continue
        
    # A PIL acceptible font file.
    # PIL includes a font conversion utility for .pcf and other
    # font formats.
    if o == '-F':
        font_file = v
        continue

    if o == '-d':
        dp_io.set_debug_level(eval(v))
        dp_io.debug_off()
        continue

    if o == '-b':
        background_image_name = v
        continue
    
work_file = os.path.join(seti_home, 'work_unit.sah')

def pt_off(pt, off):
    return (pt[0]+off, pt[1]+off)

def pt_offs(pts, off):
    ret = []
    for pt in pts:
        ret.append(pt_off(pt, off))
    return ret

def convert_sky_to_map(ra, dec, xMax, yMax):
    xconv = float(xMax)/24.0
    x = xMax/2.0 - (ra * xconv)
    # handle the way that ra wraps
    if x < 0:
        x = x + xMax

    yconv = float(yMax)/180.0
    y = yMax/2.0 - (dec * yconv)

    return (int(x), int(y))
    
def get_work_info(file_name, dict):
    """Get the work info into a dictionary"""
    try:
        work = open(file_name)
    except IOError:
        # no work file, just show the map
        dp_io.cdebug(-1, 'no work file, just showing map.\n')
        return
    
    work.seek(0)
    while 1:
        line = work.readline()
        if not line:
            break
        line = line[:-1]
        if line == 'end_header':
            continue
        if line == 'end_seti_header':
            break
        
        m = re.match('([^= 	]+)=\s*(.*)$', line)
        if not m:
            # dp_io.eprintf('Badly formed line in %s>%s<\n', file_name, line)
            sys.exit(2)
        dict[string.lower(m.group(1))] = m.group(2)

    work.close()
    

get_work_info(work_file, work_info)

skymap = Image.open(map_file).convert()
xMax = skymap.size[0]
yMax = skymap.size[1]
oimage = skymap
dp_io.cdebug(-2, 'xMax: %d, yMax: %d, oimage: %s\n', xMax, yMax, oimage)

start_ra = work_info.get('start_ra')

# see if we have work unit info...
if start_ra != None:
    start_ra = eval(start_ra)
    start_dec = eval(work_info.get('start_dec'))
    end_ra = eval(work_info.get('end_ra'))
    end_dec = eval(work_info.get('end_dec'))
    
    # dp_io.printf('sra>%s<, sdec>%s<, era>%s<, edec>%s<\n',
    #             start_ra, start_dec,
    #             end_ra, end_dec)
    
    start_map = convert_sky_to_map(start_ra, start_dec, xMax, yMax)
    end_map = convert_sky_to_map(end_ra, end_dec, xMax, yMax)
    
    smX = start_map[0]
    smY = start_map[1]

    emX = end_map[0]
    emY = end_map[1]
    
    #
    #  (smX, smY) o      + (emX, smY)
    #
    #
    #  (smX, emY) +      o (emX, emY)
    ul = (smX, smY)
    ur = (emX, smY)
    lr = (emX, emY)
    ll = (smX, emY)
    
    # dp_io.printf('size>%s< sm>%s<, em>%s<\n', skymap.size, start_map, end_map)

    # Draw a large surrounding box around the search rectangle
    draw = ImageDraw.Draw(skymap)
    draw.setfill(0)                         # outlines
    draw.setink(fillcol)

    draw.rectangle ((smX-10, smY+10) + (emX+10, emY-10))
#    draw.rectangle(pt_off(ul, -10) + pt_off(ll, 10))
#    draw.rectangle(pt_off(ul, -11) + pt_off(ll, 11))

    # Fill in a rectangle on the actual search area
    draw.setfill(1)                         # solid
    draw.rectangle(ul + lr)
    
    del draw

# handle resizing
dp_io.cdebug(-1, 'x_out: %s, y_out: %s\n', x_out, y_out)

if x_out != None and y_out != None:
    if x_out <= xMax and y_out <= yMax:
        # handle shrink or no size change
        # dp_io.printf('Resizing, x: %s, y: %s\n', x_out, y_out)
        oimage = skymap.resize((x_out, y_out), Image.BICUBIC)
    else:
        # handle image expansion
        # since resizing looks ugly, we build a black rectangle
        # and insert the map as is into its center.
        # The we draw the text showing the search coords.
        # We ostrich on whether or not the drawn text fits into
        # the x_out, y_out rectangle
        # dp_io.printf('NOT Resizing, x: %s, y: %s\n', x_out, y_out)
        if background_image_name:
            oimage = Image.open(background_image_name).convert()
        else:
            oimage = Image.new(skymap.mode, (x_out, y_out))
        dx = x_out - xMax
        dy = y_out - yMax
        oimage.paste(skymap, (dx/2, dy/2))
        draw = ImageDraw.Draw(oimage)
        if font_file:
            font = ImageFont.load(font_file)
            if start_ra != None:
                s = 'Searching RA: %s, Dec: %s to RA: %s, Dec: %s' % (start_ra,
                start_dec,
                end_ra,
                end_dec)
            else:
                s = 'No work unit data'

            draw.text((dx/2, yMax + dy/2 + 10), s, font=font)
    
oimage.save(out_file, out_type)
oimage.save('/tmp/seti-map-last-image.ppm', out_type)

sys.exit(0)
