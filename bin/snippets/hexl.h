// -*- mode: C++; c-file-style: "nvidia-c-style" -*-

#include <iostream>

template <class Num_T>
struct Hexl_t
{
    Hexl_t(
        Num_T num)
        : m_num(num)
    {}

    std::ostream& dump(
        std::ostream& os) const
    {
        std::ios::fmtflags f(os.flags());
        os.flags(std::ios::hex | std::ios::showbase | std::ios::internal);
        os.width(2 * sizeof(Num_T) + 2);
        os.fill('0');
        os << m_num;
        os.flags(f);
        return os;
    }

    /********************** <:Hexl_t: private data:> ***********************/
  private:
    Num_T m_num;
};

template <class Num_T>
inline
std::ostream& operator<<(
    std::ostream& os,
    const Hexl_t<Num_T>& o)
{
    return o.dump(os);
}

template <class Hexl_T>
Hexl_t<Hexl_T> hexl(
    Hexl_T num)
{
    return Hexl_t<Hexl_T>(num);
    
}

