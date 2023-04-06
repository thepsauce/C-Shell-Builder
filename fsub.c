#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
	long double f1, f2, df;

	f1 = strtold(argv[1], NULL);
	f2 = strtold(argv[2], NULL);
	df = f1 - f2;
	printf("%Lf", df);
	return 0;
}
