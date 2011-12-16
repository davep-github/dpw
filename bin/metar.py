#!/usr/bin/env python

import sys, os, string
import re
from types import *

def string_formatter(val):
    return '%s' % val

def dec_formatter(val):
    return string.atoi(val)

def pressure_formatter(val):
    val = string.atoi(val) / 100.0
    return '%s' % val

def tempC_formatter(val):
    val = string.replace(val, 'M', '-')
    val = string.atoi(val)              # remove leading zeroes
    return '%s' % val

def vis_formatter(val):
    return string.replace(val, 'M', 'less than ')

def sky_formatter(val):
    m = re.search('([^0-9]*)([0-9]*)', val)
    abbrev = m.group(1)
    height = m.group(2)
    if not height:
        height = ''
    else:
        height = string.atoi(height)*100
    return '%s %s' % (sky_condition_dict[abbrev], height)

present_weather_intensity = {
    '-': 'light',
    '+': 'heavy',
    'VC': 'vicinity'}

present_weather_descriptor = {
    'MI': 'shallow',
    'PR': 'partial',
    'BC': 'patches',
    'DR': 'low drifting',
    'BL': 'blowing',
    'SH': 'shower(s)',
    'TS': 'thunderstorm',
    'FZ': 'freezing'}

present_weather_precipitation = {
    'DZ': 'drizzle',
    'RA': 'rain',
    'SN': 'snow',
    'SG': 'snow grains',
    'IC': 'ice crystals',
    'PE': 'ice pellets',
    'GR': 'hail',
    'GS': 'small hail',
    'UP': 'unknown (?frogs?)'}

present_weather_obscuration = {
    'BR': 'mist',
    'FG': 'fog',
    'FU': 'smoke',
    'VA': 'volcanic ash',
    'DU': 'widespread dust',
    'SA': 'sand',
    'HZ': 'haze',
    'PY': 'spray'}

present_weather_other = {
    'PO': 'well developed dust/sand whirls',
    'SQ': 'squalls',
    'FC': 'funnel clouds',
    'SS': 'sand/dust storm'}

present_weather_dicts = (
    present_weather_intensity,
    present_weather_descriptor,
    present_weather_precipitation,
    present_weather_obscuration,
    present_weather_other)

sky_condition_dict = {
    'VV': 'vertical visibility',
    'SKC': 'clear',
    'CLR': 'clear',
    'BKN': 'broken',
    'SCT': 'scattered',
    'OVC': 'overcast'}

def build_abbrev_re(dicts, extra=''):
    re_strs = []
    for dict in dicts:
        dict_re = []
        for k in dict.keys():
            dict_re.append(re.escape(k)+extra)
        re_strs.append(string.join(dict_re, '|'))
    return '(' + string.join(re_strs, ')?(') + ')?'


def pw_lookup(v, dict):
    if v == None:
        return None
    try:
        return dict[v]
    except KeyError:
        return 'unknown weather code>%s<' % v
    

class METAR_Element:
    def __init__(self, name, locator, re_str, group_names):
        self.name = name
        self.locator = locator
        #print 'locator>%s<' % locator
        self.re_str = re_str
        self.group_names = group_names
        self.observations = []

    def my_part(self, coded_data):
        m = re.search(self.locator, coded_data)
        if m:
            return m.group(0)
        else:
            return None
        
    def parse(self, coded_data):
        m = re.search(self.re_str, coded_data)
        # print 'm:', m
        if m:
            i = 0
            for ma in m.groups():
                try:
                    gname = self.group_names[i]
                except IndexError:
                    # no more named groups, we're done
                    # print 'exit, out of names'
                    break
                
                if gname:
                    if type(gname) == TupleType:
                        formatter = gname[1]
                        gname = gname[0]
                    else:
                        formatter = string_formatter

                    #print 'gname>%s<, ma>%s<, formatter>%s<' %(gname, ma, formatter)
                    val = formatter(ma)
                    # print gname, ":", val # , '(%s)' % type(val)
                    self.observations.append((gname, val))
                i += 1
            self.observations.append(None) # separator
                
        else:
            print 'No match'

    def dump(self):
        print self.name
        for obs in self.observations:
            if not obs:
                print '--'
                continue
            name, val = obs
            print '  %s: %s' % (name, val)
            
def fields_init():
    fields = []
    
    # Wind field
    # dddff(f)Gfmfm(fm)KT_dndndnVdxdxdx
    re_str = '(\d\d\d|VRB)(\d\d\d?)(G(\d\d\d?))?KT( (\d\d\d?)V(\d\d\d?))?'
    e = METAR_Element('wind',
                      re_str,
                      re_str,
                      ('dir', ('speed', dec_formatter),
                       None, 'gust',
                       None, 'vdir0', 'vdir1'))
    fields.append(e)

    # Visibility field
    # vvvvvSM
    frac_str = '((^|\d )\d/\d)|(M?\d/\d)'
    whole_str = '(\d\d?\d?\d?\d?\d?)'
    re_str = '(' + frac_str + '|' + whole_str + ')SM'
    # print 're_str>%s<' % re_str
    e = METAR_Element('visibility',
                      re_str,
                      re_str,
                      (('vis', vis_formatter),))
    fields.append(e)

    # Present weather field... lots of little bits...
    re_str = build_abbrev_re(present_weather_dicts)
    e = METAR_Element('weather',
                      re_str,
                      re_str,
                      (('intensity',
                        lambda v, d=present_weather_intensity:
                            pw_lookup(v, d)),
                       ('descriptor',
                        lambda v, d=present_weather_descriptor:
                            pw_lookup(v, d)),
                       ('precipitation',
                        lambda v, d=present_weather_precipitation:
                            pw_lookup(v, d)),
                       ('obscuration',
                        lambda v, d=present_weather_obscuration:
                            pw_lookup(v, d)),
                       ('other',
                        lambda v, d=present_weather_other:
                            pw_lookup(v, d))))
    fields.append(e)

    # Sky conditions
    re_str = build_abbrev_re([sky_condition_dict], '\d{0,3}')
    e = METAR_Element('sky',
                      re_str,
                      re_str,
                      (('sky', sky_formatter),))
    fields.append(e)

    # Temp/dew point
    # T'T'/T'dT'd
    re_str = '^(M?\d\d)/(M?\d\d)$'
    e = METAR_Element('temperature',
                      re_str,
                      re_str,
                      (('tempC', tempC_formatter),
                       ('dewpC', tempC_formatter)))
    fields.append(e)

    # pressure
    # Adddd
    re_str = '^A(\d\d\d\d)$'
    e = METAR_Element('pressure',
                      re_str,
                      re_str,
                      (('pressure', pressure_formatter),))
    fields.append(e)

    return fields

def fields_dump(fields):
    for e in fields:
        e.dump()
        
def decode(metar_data, fields=None):
    if fields == None:
        fields = fields_init()
        
    tokens = string.split(metar_data)
    skip_tok = 0
    toki = 0
    for tok in tokens:

        # Remarks can have anything in them.  We cannot parse safely
        if tok == 'RMK':
            break
        
        if re.search('.*KT', tok):       # dumbass windspeed
            # optional second part is preceeded by a space
            try:
                tok2 = tokens[toki+1]
                if re.search('\d\d\dV\d\d\d', tok2):
                    tok += ' ' + tok2
                    skip_tok = 2
            except IndexError:
                pass

        if skip_tok != 1:
            for e in fields:
                coded_data = e.my_part(tok)
                #print 'tok>%s<, locator>%s<' % (tok, e.locator)
                #print "%s's part>%s<" % (e.name, coded_data)
                if coded_data:
                    e.parse(tok)
                    break
                # print '--'
        else:
            #print 'skipping token>%s<' % tok
            pass

        # print '=='

        if skip_tok > 0:
            skip_tok -= 1

        toki += 1


if __name__ == "__main__":

    fields = fields_init()

    if len(sys.argv) > 1:
        for a in sys.argv[1:]:
            decode(a, fields)
            fields_dump(fields)
    else:
        lines = sys.stdin.readlines()
        metar_data = string.join(lines, ' ')
        print 'obs:', metar_data
        decode(metar_data, fields)
        fields_dump(fields)
