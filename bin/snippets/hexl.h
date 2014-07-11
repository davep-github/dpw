// -*- mode: C++; c-file-style: "nvidia-c-style" -*- 
#ifndef HEXL_DOT_H_INCLUDED /* Reinclusion protection. */
#define HEXL_DOT_H_INCLUDED /* Reinclusion protection. */

template <class Num_T>
struct Hexl_t
{
    Hexl_t(
        Num_T num,
        bool show_base_p=true,
        size_t size=0,
        char fill='0')
        : m_num(num)
        , m_show_base_p(show_base_p)
        , m_size(size)
        , m_fill(fill)
    {}

    std::ostream& dump(
        std::ostream& os) const
    {
        std::ios::fmtflags f(os.flags());
        std::ios::fmtflags newf = std::ios::hex | std::ios::internal;
        if (m_show_base_p) {
            newf |= std::ios::showbase;
        }
        os.flags(newf);
        os.width((2 * (m_size ? m_size : sizeof(Num_T))) + (m_show_base_p ? 2 : 0));
        os.fill('0');
        os << m_num;
        os.flags(f);
        return os;
    }

    /********************** <:Hexl_t: private data:> ***********************/
  private:
    Num_T m_num;
    bool m_show_base_p;
    size_t m_size;
    char m_fill;
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
    Hexl_T num,
    bool show_base_p=true,
    size_t size=0,
    char fill='0')
{
    return Hexl_t<Hexl_T>(num, show_base_p, size, fill);
}

#endif /* #ifndef HEXL_DOT_H_INCLUDED Reinclusion protection. */
