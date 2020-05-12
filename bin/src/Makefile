
../eko: eko
	mv eko ..

eko: eko.c
	g++ -o eko eko.c

# Trivial test for the cheap-cl-parser.
cclpt: cheap-cl-parser.c
	g++ -DTEST_MODE -o cclt cheap-cl-parser.c

../ech0: ech0
	cp ech0 ..

ech0: ech0.c
	g++ -o ech0 ech0.c
