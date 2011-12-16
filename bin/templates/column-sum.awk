# awk 'BEGIN {total=-1434888}{print $1; total += $0; print total}'

BEGIN {
  total=0
}
{
  #print $1;
  total += $1;
  #print total
}
 END {
   print total
}

                           