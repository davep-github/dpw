#!/bin/bash

[[ ins =~ "(i|ins?|install)$" ]] && install_p=t

: ${prefix:=--prefix=/home/davep/bree}
: ${glitz:=--enable-glitz}

autoreconf -isvf \
    && ./configure ${prefix} ${glitz} \
    && make

[[ -n "$install_p" ]] && make install
