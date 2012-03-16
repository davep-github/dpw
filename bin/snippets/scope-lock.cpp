// -*- mode: C++; c-file-style: "intel-c-style" -*- 
// -*- mode: C++; c-file-style: "intel-c-style" -*- 
#include <cstdio>
#include <iostream>
#include <assert.h>
#include <stdlib.h>
#include <pthread.h>

struct A_lock_t
{
        A_lock_t(void)
        {
            pthread_mutex_init(&m_lock, NULL);
        }

        ~A_lock_t()
        {
            pthread_mutex_destroy(&m_lock);
        }

        int lock(void)
        {
            return pthread_mutex_lock(&m_lock);
        }

        int unlock(void)
        {
            return pthread_mutex_unlock(&m_lock);
        }

        //////////////////// <:A_lock_t: private data:> /////////////////////
    private:
        pthread_mutex_t m_lock;
};

/*********************************************************************/
/*!
 * @class 
 * @brief Scope_lock_t -- Automagically acquire and release a lock upon
 * entering and leaving a particular scope.
 * Designed for quick in/out ops.
 */
struct Scope_lock_t
{
        Scope_lock_t(
            A_lock_t& lock) 
            : m_lock(lock)
        {
            lock.lock();
        }
        ~Scope_lock_t()
        {
            m_lock.unlock();
        }
        ////////////////// <:Scope_lock_t: private data:> ///////////////////
    private:
        A_lock_t& m_lock;
};

typedef unsigned long q_type_t;

struct T_parms_t
{
        T_parms_t(q_type_t max, int thread_num)
            : m_max(max), m_thread_num(thread_num)
        {}

        q_type_t m_max;
        int m_thread_num;
};

q_type_t q = 0;
A_lock_t l;

void* worker(
    void* args)
{
    T_parms_t* a = static_cast<T_parms_t*>(args);
    int thread_num = a->m_thread_num;
    q_type_t max = a->m_max;

    while (true)
    {
        {
            Scope_lock_t s(l);

            int i = q;
            usleep(3);
            std::cout << "tn: " << thread_num << " i: " << i << std::endl;
            assert(i == q);
            ++q;
            if (q > max) {
                return 0;
            }
        }
        pthread_yield();
    }
    return 0;                   // WTFO?
}

int main(
    int argc,
    char* argv[])
{
    int n_threads = 10;
    if (argc > 1) {
        n_threads = atoi(argv[1]);
    }

    pthread_t pthreads [n_threads];
    
    for(int i = 0; i < n_threads; ++i) {
        Scope_lock_t s(l);
        T_parms_t* a = new T_parms_t(23, i);
        int rc = pthread_create(pthreads + i,
                                NULL,
                                worker,
                                (void*)a);
        std::cout << "created pthread: " << i << std::endl;
    }

    for(int i = 0; i < n_threads; ++i) {
        return pthread_join(pthreads[i], 0);
    }

    return 0;
}

