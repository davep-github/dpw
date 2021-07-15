#!/usr/bin/env zsh

#!/usr/bin/env zsh

set -e

function setup {
  echo 'Started.'
}

function do_the_thing {
  echo 'Doing the thing.'
  false
  echo 'This will not print.'
}

function cleanup {
  echo 'Finished.'
}

trap cleanup EXIT
setup
do_the_thing

