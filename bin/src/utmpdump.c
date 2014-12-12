/*
 * utmpdump     Simple program to dump UTMP and WTMP files in
 *              raw format, so they can be examined.
 *
 * Version:     @(#)utmpdump.c  13-Aug-1996  1.00  miquels@cistron.nl
 *
 *              This file is part of the sysvinit suite,
 *              Copyright 1991-1996 Miquel van Smoorenburg.
 *
 *              This program is free software; you can redistribute it and/or
 *              modify it under the terms of the GNU General Public License
 *              as published by the Free Software Foundation; either version
 *              2 of the License, or (at your option) any later version.
 */

#include <stdio.h>
#include <time.h>
#include <utmp.h>

void dump(
    FILE* fp)
/* [<][>][^][v][top][bottom][index][help] */
{
    struct utmp ut;
    int f;
    time_t tm;
    
    while (fread(&ut, sizeof(struct utmp), 1, fp) == 1) {
	for(f = 0; f < UT_NAMESIZE; f++)
            if (ut.ut_line[f] == ' ') ut.ut_line[f] = '_';
	for(f = 0; f <  UT_NAMESIZE; f++)
            if (ut.ut_name[f] == ' ') ut.ut_name[f] = '_';
	tm = ut.ut_time;
	printf("[%d] [%05d] [%05d] [%s] [%s] [%s] "
               "[%s]\n",
	       0, 0, 0, ut.ut_name, ut.ut_line,
	       ut.ut_host, 4 + ctime(&tm));
    }
}

int main(argc, argv)
    /* [<][>][^][v][top][bottom][index][help] */
    int argc;
    char **argv;
{
    int f;
    FILE *fp;
    
    if (argc < 2) {
	argc = 2;
	argv[1] = _PATH_UTMP;
    }
    
    for(f = 1; f < argc; f++) {
	if (strcmp(argv[f], "-") == 0) {
	    printf("Utmp dump of stdin\n");
	    dump(stdin);
	} else if ((fp = fopen(argv[f], "r")) != NULL) {
	    printf("Utmp dump of %s\n", argv[f]);
	    dump(fp);
	    fclose(fp);
	} else
	    perror(argv[f]);
    }
    return(0);
}

