#!/usr/bin/env python
#
# $Id: media_lib.py,v 1.17 2004/08/30 06:11:12 davep Exp $
#
import os, sys, getopt, re, string, dp_io, ID3, stat

# 00 prefix so they sort first
playlist_prefix = '00'
meta_playlist_prefix = '00'

playlist_separator = '_'
playlist_extension = '.m3u'
no_playlists_p = 0

OS_NAME_WINDWOES='woes'
OS_NAME_UNIX='unix'
OS_UNIX_EXTRA_PREFIX='0'                # make unix play lists sort first.

music_root = '/media/audio/music'
music_dir = os.path.join(music_root, 'mp3')
hd140_sync_file = os.path.join(music_root, 'h140.mp3.sync')

UNC_music_dir = '//BALOO/music/mp3'     # converted to backslashes later
verbose = 0
no_execute = 0
fix_id3 = 0
fix_id3_minimal = 0                     # fix id3s if 
#
# stuff for fixing filenames to make them work on FAT (i.e. HD media players)
fix_file_names_p = 0                    # set explicitly until tested
ffn_translation_table = string.maketrans('\202\x8b\x88:?\";~', '----____')

non_ascii = '_' * 128
ffn_translation_table = ffn_translation_table[:128] + non_ascii
###print "ffn>%s<" % ffn_translation_table
###print ffn_translation_table
###print "len ffn:", len(ffn_translation_table)
###print 'len non:', len(non_ascii), 'ffn[:128]', len(ffn_translation_table[:128])
###sys.exit(1)

    

########################################################################
def init():
    if fix_id3:
        print('importing ID3')
        import ID3

        
########################################################################
def print_status(fmt, *args):
    if verbose:
        if args:
            fmt = fmt % args
        if verbose == 1:
            dp_io.printf(fmt[0])
        else:
            dp_io.printf(fmt)


########################################################################
def fix_file_name(fname, make_changes=1):
    new_fname = string.translate(fname, ffn_translation_table)
    changed = (new_fname != fname)
    if changed and make_changes:
        dp_io.debug("renaming >%s< to \n >%s<\n", fname, new_fname)
        extra = '\n  to '
        template = 'mv "%s"%s"%s"'
        cmd = template % (fname, ' ', new_fname)
        ###print '>>>cmd>%s<<<' % cmd
        stat = template % (fname, extra, new_fname) + '\n'
        ###print '>>>stat>%s<<<' % stat
        if no_execute:
            print_status("- " + stat)
            cmd_rc = 0
            print('cmd>%s<\n' % cmd)
        else:
            print_status(">>"+stat+"<<")
            cmd_rc = os.rename(fname, new_fname)

        cmd = 'touch "%s"' % new_fname
        stat = '%s\n' % cmd
        if no_execute:
            print_status("- " + stat)
            cmd_rc = 0
            print('cmd>%s<\n' % cmd)
        else:
            print_status(stat)
            cmd_rc = os.utime(new_fname, None)
            
    return new_fname, changed


########################################################################
def is_mp3(fname):
    return re.search('\.[Mm][Pp]3$', fname)


########################################################################
def is_playlist(fname):
    return re.search('\.[Mm]3[Uu]$', fname)


########################################################################
def mk_playlist_name(dirname, artist, album=None, osname=None,
                     extra_prefix=''):
    if osname != None:
        os_str = playlist_separator + osname
    else:
        os_str = ''

    if artist:
        artist = playlist_separator + artist
    else:
        artist = ''
    n = os.path.join(dirname,
                     playlist_prefix + extra_prefix + os_str + artist)
    if album:
        n = n + playlist_separator + album
#     if osname != None:
#         n = n + playlist_separator + osname
    return n + playlist_extension


########################################################################
def generate_meta_playlist(dirname, fnames_in):
    fnames = fnames_in + []
    fnames.sort()
    ########prefix = string.replace(dirname, music_dir, UNC_music_dir)
    if dirname == music_dir:
        artist=''
    else:
        artist = os.path.basename(dirname)
    playlist_file = mk_playlist_name(dirname, artist, osname=OS_NAME_WINDWOES)
    unix_playlist_file = mk_playlist_name(dirname, artist, osname=OS_NAME_UNIX,
                                          extra_prefix=OS_UNIX_EXTRA_PREFIX)

    unc_meta_playlist = None
    unix_meta_playlist = None
    for f in fnames:
        f2 = os.path.join(dirname, f)
        if os.path.isdir(f2):
            # collect dos/UNC playlists
            pf_name = mk_playlist_name(f2, artist, f, osname=OS_NAME_WINDWOES)
            #print 'dn>%s<, art>%s<, f>%s<, f2>%s<' % (dirname, artist, f, f2)
            #print 'pf_name>%s<' % pf_name
            if os.path.exists(pf_name):
                #print 'adding pf_name>%s<' % pf_name
                pf_in = open(pf_name)
                c = pf_in.read()
                dp_io.cdebug(100, 'c to >%s<, >%s<\n', pf_in, c)
                pf_in.close()
                if unc_meta_playlist == None:
                    unc_meta_playlist = open(playlist_file, 'w')
                unc_meta_playlist.write(c)

            pf_name = mk_playlist_name(f2, artist, f, osname=OS_NAME_UNIX,
                                       extra_prefix=OS_UNIX_EXTRA_PREFIX)
            #print 'pf_name>%s<' % pf_name
            if os.path.exists(pf_name):
                #print 'adding f2>%s<' % f2
                pf_in = open(pf_name)
                c = pf_in.read()
                dp_io.cdebug(100, 'c to >%s<, >%s<\n', f2, c)
                pf_in.close()
                if unix_meta_playlist == None:
                    unix_meta_playlist = open(unix_playlist_file, 'w')
                unix_meta_playlist.write(c)

    if unc_meta_playlist:
        unc_meta_playlist.close()
    if unix_meta_playlist:
        unix_meta_playlist.close()

########################################################################
def file_newer(file, ref_time):
    return os.stat(file)[stat.ST_MTIME] > ref_time

########################################################################
def need_id3_changes(dirname, fnames, ref_file):
    try:
        ref_time = os.stat(ref_file)[stat.ST_MTIME]
    except IOError:
        dp_io.debug('ref file>%s< does not exist\n')
        sys.exit(4)

    album = os.path.basename(dirname)
    artist = os.path.basename(os.path.dirname(dirname))
    dp_io.debug("dirn>%s<\nalb>%s<\nart>%s<\n", dirname, album, artist)
    for fname in fnames:
        pathname = os.path.join(dirname, fname)
        if not is_mp3(pathname):
            continue
        
        if file_newer(pathname, ref_time):
            dp_io.debug("%s is newer than %s\n", fname, ref_time)
            return 1
        try:
            id3 = ID3.ID3(pathname)
            # basename dirname is album name
            m = min(len(id3.album), 30)
            if (id3.album != album[:m]):
                dp_io.debug("id3.album != album\n|>%s<\n|>%s<\n",
                            id3.album, album)
                return 1
            m = min(len(id3.artist), 30)
            if  (id3.artist != artist[:m]):
                dp_io.debug("id3.artist != artist\n|>%s<\n|>%s<\n",
                            id3.artist, artist)
                return 1
        except ID3.InvalidTagError:
            dp_io.eprintf('Failed to test >%s<\n', pathname)
    return 0

########################################################################
def mk_UNC_dirname(dirname, music_dir_in=None, UNC_music_dir_in=None):
#     print 'dn>%s<, md>%s<, umd>%s<' % (dirname,
#                                        music_dir_in or music_dir,
#                                        UNC_music_dir_in or UNC_music_dir)
    return string.replace(dirname,
                          music_dir_in or music_dir,
                          UNC_music_dir_in or UNC_music_dir)
    

########################################################################
def mk_UNC_pathname(name, unc_root=None):
    if unc_root == None:
        unc_root = mk_UNC_dirname(name)
    f = os.path.join(unc_root, name)
    return string.replace(f, '/', '\\')


########################################################################
def DOS_writeln(file, s):
    file.write(s+'\r\n')

def unix_writeln(file, s):
    file.write(s+'\n')
    

########################################################################
def generate_playlist(dirname, fnames_in):
    fnames = fnames_in + []
    fnames.sort()
    unc_root = mk_UNC_dirname(dirname)
    artist = os.path.dirname(dirname)
    if artist == music_dir:
        artist = ''
    else:
        artist = os.path.basename(artist)
    album = os.path.basename(dirname)
    print_status('album>%s<, artist>%s<, music_dir>%s<\n',
                 album, artist, music_dir)
    #playlist_file = os.path.join(dirname, playlist_prefix+"-"+album+playlist_extension)
    woes_playlist_file = mk_playlist_name(dirname, artist, album,
                                          osname=OS_NAME_WINDWOES)
    unix_playlist_file = mk_playlist_name(dirname, artist, album,
                                          osname=OS_NAME_UNIX,
                                          extra_prefix=OS_UNIX_EXTRA_PREFIX)
    print_status('dirname>%s<, playlist_file>%s<\n',
                 dirname,
                 unix_playlist_file)

    if fix_id3_minimal:
        do_fix_id3 = need_id3_changes(dirname, fnames_in, hd140_sync_file)
        dp_io.debug("do_fix_id3 set by need_id3_changes() in >%s<\n",
                    dirname)
    else:
        do_fix_id3 = fix_id3

    pf = None
    for f in fnames:
        #print 'f>%s<' % f
        if is_mp3(f):
            #print "f>%s<, pre>%s<" % (f, unc_root)
            f_unc = mk_UNC_pathname(f, unc_root)
            f_unix = os.path.join(dirname, f)
            #print 'f_unc>%s<' % f_unc
            #
            # delay opening so that non-mp3 dirs don't get empty playlists.
            if pf == None:
                pf = open(woes_playlist_file, 'w')
                pf2 = open(unix_playlist_file, 'w')
            DOS_writeln(pf, f_unc)
            unix_writeln(pf2, f_unix)
            
            #
            pathname = os.path.join(dirname, f)
            if do_fix_id3:
                #print 'dn>%s<' % (dirname,)
                #print 'pn>%s<, artist>%s<, album>%s<' % (pathname, artist, album)
                try:
                    id3 = ID3.ID3(pathname)
                    if id3.album != album or id3.artist != artist:
                        print_status('fix id3 info\n')
                        id3.artist = artist
                        id3.album = album
                        id3.write()
                    else:
                        print_status('Not fixing id3 info\n')
                        
                except ID3.InvalidTagError:
                    dp_io.eprintf('Failed to fix >%s<\n', pathname)

    if pf:
        pf.close()
        pf2.close()


########################################################################
def has_mp3s(fnames):
    for f in fnames:
        if is_mp3(f):
            return 1
    return 0


########################################################################
def has_playlists(fnames):
    for f in fnames:
        if is_playlist(f):
            return 1
    return 0

meta_items = []


########################################################################
def  generate_playlists_proc_dir(arg, dirname, fnames):
    print_status('gpl: visiting %s\n', dirname)
    if has_mp3s(fnames):
        print_status('making playlist in %s\n', dirname)
        generate_playlist(dirname, fnames)
    else:
        print_status('adding meta item %s\n', dirname)
        meta_items.append((dirname, fnames))


#    else:
#        print_status('skipping %s\n', dirname)

########################################################################
def fix_file_names_in_dir(dirname, fnames):

    nuke_playlists = 0

    new_dirname, changed = fix_file_name(dirname)
    if changed:
        nuke_playlists = 1
        
    for fname in fnames:
        #print 'f>%s<' % f
        if is_mp3(fname):
            pathname = os.path.join(dirname, fname)
            new_pathname, changed = fix_file_name(pathname)
            if changed:
                nuke_playlists = nuke_playlists + 1

    if nuke_playlists:
        for fname in fnames:
            if re.search('^0.*m3u$', fname):
                rm_file =  os.path.join(dirname, fname)
                cmd = 'rm -f "%s"' % rm_file
                if no_execute:
                    print_status("N- %s, nuke: %d\n", cmd, nuke_playlists)
                    cmd_rc = 0
                else:
                    print_status("unlinking playlist>%s<", rm_file)
                    cmd_rc = os.unlink(rm_file)
        

########################################################################
def fix_file_names(arg, dirname, fnames):
    print_status('ffn: visiting %s\n', dirname)
    fix_file_names_in_dir(dirname, fnames)


########################################################################
def media_lib_process_mp3_tree(dir):

    if fix_file_names_p:
        dp_io.debug("fixing file names...\n")
        os.path.walk(dir, fix_file_names, None)
        dp_io.debug("done fixing file names\n")

    if not no_playlists_p:
        os.path.walk(dir, generate_playlists_proc_dir, None)

        meta_items.reverse()
        for dirname, fnames in meta_items:
            print_status('Making meta-playlist %s\n', dirname)
            generate_meta_playlist(dirname, fnames)


########################################################################
