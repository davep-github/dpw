BEGIN {
	state = 0
	printSep = 0
}
{
	if (state == 0)
	{
		if ($1 == "File" && $2 == "Entry" && $3 == "At:")
		{
			line = NR
			fePart=$4
			rec = $0
			state = 1
		}
		else
			state = 0
	}
	else if (state == 1)
	{
		if (substr($3, 1, 9) != "Directory")
		{
			state = 2
		}
		else
			state = 0
	}
	else if (state == 2)
	{
		if ($1 == "------------")
		{
			state = 3
			newTo3 = 1
		}
		else
			state = 2
	}
	else if (state == 3)
	{
		if ($1 == "Statistics:")
		{
			state = 0
		}
		else
		{
			if (newTo3 == 1)
			{
				printf "FE ln %d, %s\n", line, fePart
				newTo3 = 0
			}
			print " ", $0
			state = 3
		}
	}
}
