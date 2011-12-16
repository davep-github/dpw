#include <stdio.h>
#include <sys/limits.h>
#include <sys/id.h>
#include	<grp.h>

main()
{
	int	numGids;
	gid_t	gList[NGROUPS_MAX + 2];

	numGids = getgroups(NGROUPS_MAX, gList);

	printf("numGids: %d\n", numGids);

	if (numGids == -1)
		perror("gid error ");

	exit(0);
}
