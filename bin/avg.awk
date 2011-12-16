BEGIN { avg=count=0 
}
{
  avg=avg+ $1
  ++count
}
END { print avg/count
}

