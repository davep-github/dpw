#!/usr/bin/env python


def calculate():
    married = 1
    exemptions = 3

    frequency = 52
    add_income = 0 # 0.96 # life insurance extra premium
    pay_per_period = (87006.40 / frequency) + add_income
    percent_401k = 7 #9
    benefits_costs = 0	+ 31.37 + 4.25

#     frequency = 24
#     pay_per_period = (74500.08 / frequency)
#     percent_401k = 12.75
#     benefits_costs = 30 + 5 + 1.5

    x401k_etc = (percent_401k / 100.0 * pay_per_period) + benefits_costs
    fedtax = 0
    fica = 0
    medicare = 0
    if not married:
	stateded = 2925
    else:
	stateded = 5850

    exempt = exemptions * 2650;
    taxablegross = ((pay_per_period - x401k_etc) * frequency) - exempt

    fica = ((pay_per_period * .062) * 100) / 100;
    medicare = ((pay_per_period * .0145) * 100) / 100;

    #=============================
    #  federal withholding formula
    #=============================
    if not married:
	if (taxablegross < 2651):
	    taxes = 0; 
	    
	if ((taxablegross > 2650) and (taxablegross < 26151)):
	    taxes = .15 * (taxablegross - 2650)

	if ((taxablegross > 26150) and (taxablegross < 55501)):
	    taxes = .28 * (taxablegross - 26150) + 3525

	if ((taxablegross > 55500) and (taxablegross < 126151)):
	    taxes = .31 * (taxablegross - 55500) + 11743

	if ((taxablegross > 126150) and (taxablegross < 272551)):
	    taxes = .36 * (taxablegross - 126150) + 33644.50

	if (taxablegross > 272550):
	    taxes = .396 * (taxablegross - 272550) + 86348.50; 
    else:
	if (taxablegross < 6451):
	    taxes = 0;

	if ((taxablegross > 6450) and (taxablegross < 45451)):
	    taxes = .15 * (taxablegross - 6450)

	if ((taxablegross > 45450) and (taxablegross < 92851)):
	    taxes = .28 * (taxablegross - 45450) + 5850

	if ((taxablegross > 92850) and (taxablegross < 156001)):
	    taxes = .31 * (taxablegross - 92850) + 19122

	if ((taxablegross > 156000) and (taxablegross < 275301)):
	    taxes = .36 * (taxablegross - 156000) + 38698.50

	if (taxablegross > 275300):
	    taxes = .396 * (taxablegross - 275300) + 81646.5

    fedtax = taxes / frequency;

    statetax = (pay_per_period - x401k_etc - fica - (stateded / frequency)) * \
	        0.0595
    statetax = (pay_per_period - (stateded / frequency)) * \
	        0.0595

    print "exemptions:", exemptions
    print "gross (", frequency, "/ year):", pay_per_period
    print "fed:", fedtax
    print "fica:", fica
    print "medicare:", medicare
    print "state:", statetax
    print "401(k), etc:", x401k_etc
	
    takehome = 	pay_per_period - fedtax - fica - medicare - \
	       x401k_etc - statetax
    print "take home(", frequency, "/ year ):", takehome
    monthly = takehome * frequency / 12
    print "take home( month ):", monthly
    print "after \"expenses\":", monthly - 2600


x = calculate()
