#!/bin/bash

source script-x

f()
{
    while read -u 5
    do
      echo_id REPLY
    done 1>&5
}



