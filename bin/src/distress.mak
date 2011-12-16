#
#  HPUX version
#
distress.hp:		distress.o
	cc -c distress.c 
	cc -o distress.hp distress.o

#
#  SUN version
#
distress.sun:		distress.c
	cc -c -D_SUN distress.c 
	cc -o distress.sun distress.o


clean:
	rm -f *.o distress.[hs]* 

