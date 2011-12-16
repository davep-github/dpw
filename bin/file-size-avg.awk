BEGIN { avg=count=0 
}
{
  avg=avg+ $5
  ++count
}
END { print avg/count
}

