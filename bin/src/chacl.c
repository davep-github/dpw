#include <stdio.h>
#include <sys/acl.h>

main(
int	argc,
char	*argv[])
{
	int			i;
	struct acl	aclBuf;

	aclBuf.acl_len = 16;
	aclBuf.acl_mode = 0;

	aclBuf.u_access = R_ACC | W_ACC;
	aclBuf.g_access = R_ACC | W_ACC;
	aclBuf.o_access = R_ACC | W_ACC;


	for (i = 1; i < argc; i++)
	{
		if (chacl(argv[i], &aclBuf, 16))
		{
			fprintf("chacl: chacl() failed on %s", argv[i]);
			perror(" ");
		}
	}

	exit(0);
}
