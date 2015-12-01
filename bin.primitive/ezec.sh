EZEC=
Non_EZECer()
{
    echo "- $@" 1>&2
}

Verbose_EZECer()
{
    echo "+ $@"
    "$@"
}
