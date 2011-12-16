#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>

/*
 * Binary editor.
 * Read tokens from stdin and write binary to stdout.
 * <ascii c-num> --> binary byte
 * r num val	--> num binary bytes of value val
 * s [+|i]num	--> seek to num, +|- imply relative shift
 * i num	--> write int in machine order
 * # comment
 * "xxx"	--> string
 * h num	--> short (half)
 *
 * comment lines are limited to < 100 chars
 */

void bed(FILE*);
void
bed(
    FILE	*fp)
{
    char	token[100];
    char	token2[100];
    char	token3[100];
    int		c;

    while(fscanf(fp, "%99s", token) == 1) {
	if (token[0] == '#') {
	    if (strlen(token) < 99) {
		while ((c = getchar()) != EOF && c != '\n')
		    ;
	    }
	}
	else if (isdigit(token[0])) {
	    int	val;

	    val = strtoul(token, NULL, 0);
	    write(1, (char*)&val, 1);
	}
	else if (token[0] == 'r') {
	    int	num, val;

	    fscanf(fp, "%99s %99s", token2, token3);
	    num = strtoul(token2, NULL, 0);
	    val = strtoul(token3, NULL, 0);
	    while (num--)
		write(1, (char*)&val, 1);
	}
	else if (token[0] == 's') {
	    int	num, val;

	    fprintf(stderr, "seek not implemented, writing 0's\n");
	    fscanf(fp, "%99s", token2);
	    num = strtoul(token2, NULL, 0);
	    val = 0;
	    while (num--)
		write(1, (char*)&val, 1);
	}
	else if (token[0] == 'i') {
	    int	val;

	    fscanf(fp, "%99s", token2);
	    val = strtoul(token2, NULL, 0);
	    write(1, (char*)&val, sizeof(int));
	}
	else if (token[0] == 'h') {
	    int	val;

	    fscanf(fp, "%99s", token2);
	    val = strtoul(token2, NULL, 0);
	    write(1, (char*)&val, sizeof(short));
	}
	else if (token[0] == '"') {
	    char*	p = token + 1;

	    while (*p && *p != '"')
		write(1, p++, 1);
	}
    }
}
	      
main(
    int	argc,
    char	*argv[])
{
    int	i;
    FILE	*fp;

    if (argc == 1)
	bed(stdin);
    else
	for (i = 1; i < argc; i++) {
	    fp = fopen(argv[i], "r");
	    bed(fp);
	    fclose(fp);
	}

    exit (0);
}
