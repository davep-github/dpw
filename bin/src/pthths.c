#include <stdio.h>
#include <pthread.h>
#include <assert.h>

int count = 0;

pthread_mutex_t	mutex;
#define	lock()	    pthread_mutex_lock(&mutex)
#define	unlock()    pthread_mutex_unlock(&mutex)

void*f1(
    void*   arg)
{
    while (1) {
	lock();
	
	assert(count == 0);
	
	count++;
	count++;
	count++;
	count++;
	count++;
	
	assert(count == 5);
	
	count--;
	count--;
	count--;
	count--;
	count--;
	
	assert(count == 0);
	
	unlock();
    }

    return NULL;
}


void*
f2(
    void*   arg)
{
    while (1) {
	lock();
	
	assert(count == 0);
	
	count++;
	count++;
	count++;
	count++;
	
	assert(count == 4);
	
	count--;
	count--;
	count--;
	count--;
	
	assert(count == 0);

	unlock();
    }

    return NULL;
}

main(
    int	    argc,
    char*   argv[])
{
    pthread_t	th1;
    pthread_t	th2;
    void*	retp;
    
    pthread_mutex_init(&mutex, NULL);

    pthread_create(&th1, NULL, f1, NULL);
    pthread_create(&th2, NULL, f2, NULL);

    pthread_join(th1, &retp);
    pthread_join(th2, &retp);

    exit(0);
}

    
