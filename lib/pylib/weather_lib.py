#!/usr/bin/env python

import os, string, re, sys, getopt, configparser, urllib.request, urllib.parse, urllib.error, ftplib
import dp_io
import types

#cond_url = 'ftp://weather.noaa.gov/data/observations/metar/decoded'
cond_url = 'http://weather.noaa.gov/pub/data/observations/metar/decoded'
wx_host = 'rainmaker.wunderground.com'
wx_port = 3000
#zone_url = 'ftp://weather.noaa.gov/data/forecasts/zone/ma'
zone_url = 'http://iwin.nws.noaa.gov/iwin/%s/zone.html'
#Locations = '/usr/X11R6/share/gnome/gweather/Locations'
Locations = os.path.normpath(os.environ['HOME'] + '/etc/Weather-Locations')
debug_level = 0
verbose = 0

conditions_template = """Conditions at %(xtime)s on %(xdate)s for %(place)s.
Temp(F)    Humidity(%%)    Wind(mph)    Pressure(in)    Weather
========================================================================
 %(temp)4s         %(humidity)3s%%       %(wind_dir)4s at %(wind_vel)-3s     %(pressure)5s         %(sky)s
========================================================================"""


class Globals:
    def __init__(self):
        self.locations = Locations
        self.state = 'MA'
        self.city = 'bedford'
        self.zone = '014'
        self.condition_station = None

globals = Globals()

def set_verbose(level):
    global verbose
    verbose = level

def set_debug(level):
    global debug_level
    debug_level = level

def process_city(state, city, locations=Locations, perror=None, do_exit=None):
    """process the city entry.
    Get a condition_station, e.g.
    """
    c=configparser.ConfigParser()
    c.read(locations)
    l=c.options('US_%s' % state)
    d = {}
    condition_station = None
    zone = None
    for x in l:
        # info: city condition-station zone radar-code
        info = string.split(c.get('US_%s' % state, x))
        if city == string.lower(info[0]):
            if verbose:
                print('info:', info)
            if info[1] != '-'*len(info[1]):
                condition_station = info[1]

            if info[2] != '-'*len(info[2]):
                zone = string.upper(info[2])
                zone = zone[3:]

            return (condition_station, zone)

    if perror:
        dp_io.eprintf("Don't know this state/city: %s/%s\n",
                      self.state,
                      self.city)
    if do_exit:
        sys.exit(1)
        
    return None

def regex_init(state):
    bad0 = string.replace(string.uppercase, state[0], '')
    bad1 = string.replace(string.uppercase, state[1], '')
    #print 'bad0>%s<, bad1>%s<' % (bad0, bad1)

    zone_num='\d\d\d|ALL'
    zone_id = '((%s)|((%s)>(%s)))-' % (zone_num, zone_num, zone_num)
    globals.zones_re = re.compile(zone_id, re.MULTILINE)

    globals.state_zones = re.compile('(%sZ.*)\d\d\d\d\d\d-' % state,
                                     re.MULTILINE)
    globals.other_zones = re.compile('(([%s].)|(.[%s]))Z%s.*$' % \
                                     (bad0, bad1, zone_num), re.MULTILINE)
        
def zone_match_p(s, zone):
    d = {}
    dp_io.debug('zone>%s<\n', zone)
    dp_io.debug('s0>%s<\n', s)
    m = globals.other_zones.search(s)
    if m:
        #print 'found bad'
        s = s[:m.start(0)]          # trim any other states
        dp_io.debug('trimmed other states, s1>%s<\n', s)

    s = string.upper(s)
    dp_io.debug('s2>%s<\n', s)
    groups = globals.zones_re.findall(s)
    #print 'groups>%s<' % groups
    #print 'type(zone):', type(zone)
    zint = int(zone)                # zone number as int
    for group in groups:
        #print ">>>", group, "<<<"
        #print 'group>%s<' % (group,)
        g0 = group[0]
        if len(g0) == 3:            # matched znum ::= (\d\d\d|ALL)
            if g0 == 'ALL' or int(g0) == zint:
                return 1
        else:                       # matched znum>znum
            gl = group[3]           # lower limit
            gu = group[4]           # upper limit
            if gl == 'ALL' or gu == 'ALL':
                return 1
            if int(gl) <= zint and zint <= int(gu):
                return 1
    return 0
        

def find_zone_data(forecast, state, zone):
    regex_init(state)
    pos = 0
    fend = len(forecast)
    while 1:
        #print 'pos: %d, s>%s<' % (pos, forecast[pos: pos+20])
        m = globals.state_zones.search(forecast, pos)
        if m:
            dp_io.debug('state_zones>%s<\n', m.group())
            if zone_match_p(m.group(1), zone):
                start = m.start(1)
                end = string.find(forecast, '$$', start)
                if end < 0:
                    end = fend
                return forecast[start: end+2]
        else:
            break

        pos = m.end(1) + 1
        if pos > fend:
            break
    return None


def current_conditions(condition_station, stat_func=None):
    url = '%s/%s.TXT' % (cond_url, condition_station)
    try:
        if verbose:
            print('get>%s<' % url)
        lines = []
        if stat_func:
            stat_func('get condition data from %s' % url)
        if debug_level:
            dp_io.printf('get condition data from %s\n' % url)
        u = urllib.request.urlopen(url)
        lines = u.readlines()
        if debug_level > 1:
            dp_io.debug('Raw condition info>>>>>>>>>>>>\n%s<<<<<<<<<<<\n',
                        string.join(lines, '\n'))
        u.close()
    except IOError as e:
        dp_io.eprintf('could not fetch url>%s<, e>%s<\n', url,e)
        pass

    if len(lines) != 0:
        fields = ( ('temp', '^Temperature:\s+(\d+)'),
                   ('humidity', 'Humidity:\s+(\d+)'),
                   ('wind_dir', '^Wind:\s+from\s+the\s+([A-Z]+)'),
                   ('wind_vel', '^Wind:.*at\s+(\d+)'),
                   ('wind_dir', '^Wind:\s+([Cc][Aa][Ll][Mm])'),
                   ('wind_vel', '^Wind:\s+[Cc][Aa][Ll][Mm]:\s*(\d+)'),
                   ('pressure', '^Pressure\s+\(altimeter\):\s+(\d+\.\d+)'),
                   ('sky', '^Sky\s+conditions:\s+(.*)'),
                   ('place', '(.*), United States'),
                   ('xtime', '([01][0-9]:[0-5][0-9]\s+[AP]M\s+[A-Z]+)'),
                   ('xdate', '^(.*) -.*UTC$')
                   )
        data = {}
        for fname, reg in fields:
            rx = re.compile(reg)
            for l in lines:
                if debug_level > 2:
                    dp_io.debug('l>%s<, reg>%s<\n', l, reg)
                m = rx.search(l)
                if m and not data.get(fname):
                    dp_io.debug('match, fname>%s<', fname)
                    data[fname] = m.group(1)
                    break
        # for all that were not found, show an indication
        for fname, reg in fields:
            if not data.get(fname):
                data[fname] = '<"%s" NOT FOUND>' % fname

        return conditions_template % data

def get_forecast(state, zone, stat_func=None):
    try:
        url = zone_url % state
        if verbose:
            print('get>%s<' % url)
        if stat_func:
            stat_func('get forecast from %s' % url)
        if debug_level:
            dp_io.printf('get forecast from %s\n' % url)
        u = urllib.request.urlopen(url)
        data = u.read()
        data = string.replace(data, '\r', '')
        f = open('/tmp/weather_lib.forecast.txt', 'w')
        f.write(data)
        f.close()
        data = find_zone_data(data, state, zone)
    except IOError:
        data = ''
        dp_io.eprintf('could not fetch url>%s<\n', url)
    return data


if __name__ == "__main__":

    def do_city():
        ret = process_city(globals.state, globals.city, globals.locations,
                           perror=1)
        if ret:
            cs, zone = ret
            dp_io.printf("city>%s<, state>%s<, cs>%s<, zone>%s<\n",
                         globals.city,
                         globals.state,
                         cs,
                         zone)

    def do_conditions():
        if globals.condition_station == None:
            ret = process_city(globals.state, globals.city, globals.locations,
                               perror=1)
            if ret:
                cs, zone = ret
        else:
            cs = globals.condition_station
        conds = current_conditions(cs)
        if conds:
            dp_io.printf("%s\n", conds)
        else:
            dp_io.eprintf('current_conditions failed.\n')

    def do_forecast():
        f = get_forecast(globals.state, globals.zone, stat_func=None)
        if f:
            dp_io.printf('%s\n', f)
        else:
            dp_io.eprintf('get_forecast failed.\n')
            
    def do_all():
        do_conditions()
        print('\n')
        do_forecast()

    def test_cond_format():
        d = {'temp': 123,
             'humidity': 100,
             'wind_dir': 'WSW',
             'wind_vel': 100,
             'pressure': 99.99,
             'sky': 'partly cloudy',
             'place': 'Whereeverville',
             'xtime': '07:56 PM EST',
             'xdate': 'Jan 16, 2002',
             }
        print(conditions_template % d)


    def add_func(func, funclist, funcs):
        for names, op in funclist:
            for name in names:
                if name == func:
                    if not op in funcs:
                        funcs.append(op)
                    break
        
    funclist = ((("city",), do_city),
                (("c", "cond", "conditions"), do_conditions),
                (("f", "fc", "fcast", "fore", "forecast"), do_forecast),
                (("a", "al", "all"), do_all))

    testlist = ((("cf",), test_cond_format),)
    
    funcs = []
    tests = []
    set_city_or_state = None
    set_zone = None
    set_cs = None
    
    options, args = getopt.getopt(sys.argv[1:], 'c:s:z:f:l:C:dvt:')
    for (o, v) in options:
        if o == '-c':
            globals.city = string.lower(v)
            set_city_or_state = 1
        if o == '-s':
            globals.state = string.upper(v)
            set_city_or_state = 1
        if o == '-z':
            globals.zone = v
            set_zone = 1
        if o == '-f':
            func = string.lower(v)
            add_func(func, funclist, funcs)
        if o == '-l':
            globals.locations = v
        if o == '-C':
            globals.condtion_station = string.upper(v)
            set_cs = 1
        if o == '-d':
            dp_io.debug_on()
            debug_level = debug_level+1
        if o == '-v':
            verbose = verbose + 1
        if o == '-t':
            test = string.lower(v)
            add_func(test, testlist, tests)


    if set_city_or_state:
        ret = process_city(globals.state, globals.city, globals.locations,
                           perror=1, do_exit=1)
        if ret:
            cs, z = ret
            if not set_zone:
                globals.zone = 1
            if not set_cs:
                globals.condition_station = cs

    for f in tests + funcs:
        f()
