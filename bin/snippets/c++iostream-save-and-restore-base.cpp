// -*- mode: C++; c-file-style: "nvidia-c-style" -*-

void iospp_hex(std::ostream& x)
{
    ios::fmtflags f(x.flags());
    x<< std::hex << 123 <<"\n";
    x.flags(f);
}
