#include <stdio.h>
#include <curl/curl.h>

main(
    int argc,
    char* argv[])
{
    for (int i=1; i < argc; ++i) {
        char* p =curl_easy_escape( CURL *curl, argv[i], 0);
        curl_free(p);
    }
}



