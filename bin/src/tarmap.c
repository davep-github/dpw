#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#define _PAX_
#include </usr/src/bin/pax/tar.h>

#define REC_LEN		(512)
#define BLKMULT		REC_LEN
#define EOF_CHAR	('\0')
#define OCT		(8)

int	is_stdin = 0;
int	Block_factor = 9;

/*
 * asc_ul()
 *	convert hex/octal character string into a u_long. We do not have to
 *	check for overflow! (the headers in all supported formats are not large
 *	enough to create an overflow).
 *	NOTE: strings passed to us are NOT TERMINATED.
 * Return:
 *	unsigned long value
 */

#if __STDC__
u_long
asc_ul(register char *str, int len, register int base)
#else
u_long
asc_ul(str, len, base)
	register char *str;
	int len;
	register int base;
#endif
{
	u_long	ret;
	char	old;

	old = str[len];
	str[len] = '\0';
	sscanf(str, "%o", &ret);
	str[len] = old;

	return (ret);
}

tar_chksm(register char *blk, register int len)
{
	register char *stop;
	register char *pt;
	u_long chksm = BLNKSUM;	/* inital value is checksum field sum */

	/*
	 * add the part of the block before the checksum field
	 */
	pt = blk;
	stop = blk + CHK_OFFSET;
	while (pt < stop)
		chksm += (u_long)(*pt++ & 0xff);
	/*
	 * move past the checksum field and keep going, spec counts the
	 * checksum field as the sum of 8 blanks (which is pre-computed as
	 * BLNKSUM).
	 * ASSUMED: len is greater than CHK_OFFSET. (len is where our 0 padding
	 * starts, no point in summing zero's)
	 */
	pt += CHK_LEN;
	stop = blk + len;
	while (pt < stop)
		chksm += (u_long)(*pt++ & 0xff);
	return(chksm);
}

tar_id(blk, size)
	register char *blk;
	int size;
{
	register HD_TAR *hd;
	register HD_USTAR *uhd;

	if (size < BLKMULT)
		return(-1);
	hd = (HD_TAR *)blk;
	uhd = (HD_USTAR *)blk;

	/*
	 * check for block of zero's first, a simple and fast test, then make
	 * sure this is not a ustar header by looking for the ustar magic
	 * cookie. We should use TMAGLEN, but some USTAR archive programs are
	 * wrong and create archives missing the \0. Last we check the
	 * checksum. If this is ok we have to assume it is a valid header.
	 */
#if 0
	
	if (hd->name[0] == '\0')
		return(-1);
	if (strncmp(uhd->magic, TMAGIC, TMAGLEN - 1) == 0)
		return(-1);
#endif
	if (asc_ul(hd->chksum,sizeof(hd->chksum),OCT) ==
	    tar_chksm(blk,BLKMULT))
		return(-1);
	return(0);
}

void
perrorf(
	int	report_errno,
	char*	fmt,
	...)
{
	va_list	ap;

	va_start(ap, fmt);

	vfprintf(stderr, fmt, ap);
	if (report_errno)
		perror(" ");
	else
		fprintf(stderr, "\n");
}

int
is_tar_eof(
	char*	buf)
{
	int	i;

	for (i = 0; i < REC_LEN; i++, buf) {
		if (*buf != EOF_CHAR)
			return (0);
	}

	return (1);
}

void
map_lseek(
	int	fd,
	long	displacement,
	long	cur)
{
	if (!is_stdin) {
		if (lseek(fd, displacement, SEEK_CUR) != displacement + cur) {
			perrorf(0, "cannot seek current file");
			exit(2);	
		}
	}
	else {
		char	buf[REC_LEN];
		ssize_t	num_read;

		for (; displacement; displacement -= REC_LEN) {
			if ((num_read = read(fd, buf, REC_LEN)) != REC_LEN) {
				perrorf(num_read < 0 ? 1 : 0,
					"pseudo seek read failed");
				exit(1);
			}
		}
	}
}
	
void
map_tar_file(
	int	fd,
	char	*file_name)
{
	unsigned long	offset;
	ssize_t	num_read;
	long	num_blks;
	long	size;
	char		buf[REC_LEN];
	HD_USTAR*	header;

	
	offset = 0;
	header = (HD_USTAR*)buf;
	for (;;) {
		
		if ((num_read = read(fd, buf, REC_LEN)) < 0) {
			perrorf(1, "cannot read %s", file_name);
			exit(1);
		}
		
		if (is_tar_eof(buf))
			break;

		if (num_read == 0) {
			perrorf(0, "hit file EOF before archive EOF, "
				"offset: 0x%lx",
				offset);
			exit(1);
		}
			
		if (num_read != REC_LEN) {
			perrorf(0, "did not read full record, "
				"offset: 0x%lx",
				offset);
			exit(1);
		}
		
#if 0
		if (memcmp(header->magic, TMAGIC, TMAGLEN - 1) != 0) {
			perrorf(0, "bad magic, offset: 0x%lx", offset);
			exit(1);
		}
#else
		if (!tar_id(buf, REC_LEN)) {
			perrorf(0, "bad tar header, offset: 0x%lx", offset);
			exit(1);
		}
#endif
		
		sscanf(header->size, "%ol", &size);

		/*
		 * round up file size to block size and add one for the
		 * tar header
		 */
		num_blks = (size + REC_LEN - 1) / REC_LEN + 1;
		size = num_blks * REC_LEN;
		
		printf("%ld\t%ld\t%s\n", offset >> Block_factor,
		       size >> Block_factor,
		       header->name);

		map_lseek(fd, size - REC_LEN, offset + REC_LEN);
		offset += size;
	}
}

main(
	int	argc,
	char*	argv[])
{
	int	fd;
	char*	options = "b";
	int	option;
	
	extern char*	optarg;
	extern int	opterr;
	extern int	optind;

	opterr = 1;

	while ((option = getopt(argc, argv, options)) != EOF) {
		switch (option) {
			case 'b':
				Block_factor = 0; /* byte offsets/lens */
				break;
		}
	}
	
	if (optind < argc) {
		is_stdin = 0;
		
		for (; optind < argc; optind++) {

			if ((fd = open(argv[optind], O_RDONLY)) < 0) {
				perrorf(1, "cannot open %s", argv[optind]);
				exit(1);
			}
			
			map_tar_file(fd, argv[optind]);
			
			if (close(fd)) {
				perrorf(1, "error closing %s", argv[optind]);
				exit(1);
			}
		}
	}
	else {
		char	buf[REC_LEN];
		long	num_read;
		
		is_stdin = 1;
		map_tar_file(0, "stdin");
		/* flush stdin in case we're zcatting */
		while (num_read = read(0, buf, REC_LEN))
			;
		if (num_read < 0) {
			perrorf(1, "error reading trailing input");
			exit(1);
		}
	}

	exit(0);
}
