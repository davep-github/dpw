#!/bin/bash


exec 5> /dev/null

f()
{
  echo "hi to stdout"
  echo "to 5" 1>&5
  if ! echo "to 2 via 1" 2>&1 
  then
    echo 'error' 1>&5
  fi| grep to 1>&2
  echo "to 2" 1>&2
}

x=$(f 5>&1)
echo "0:x>$x<"

y=$(f 5>&1 >/dev/null)
echo_id y

z=$(f 5>&1 >/dev/tty)
echo_id z

#exit 99

(cat 0<&7) 7<<EOF
I am q
EOF
echo 1>&2 "Error is expected on bad fd 7"
(cat 0<&7) <<EOF
I am q
EOF

echo about to hd
f 5>&1 | hd
echo done hd

f2()
{
    echo "f2" 1>&2
    read -e -p "Reading? " -u 5
    echo_id REPLY
}

f2 5<<EOF
blah
EOF

f3()
{
    while read -u 5
    do
      echo_id REPLY
    done
}

f3 5<<EOF
line 1
2 line
linez
EOF

f4()
{
    while read
    do
      echo_id REPLY
      echo HI
    done
}
echo hi | f4


f3i()
{
    while read -u 5
    do
      echo_id REPLY
      #read -e -p "Enter something> "
      echo_id REPLY
    done
}

#f3i 5<<EOF
#line 1
#2 line
#linez
#EOF

f3i 5<<EOF
$(ls -l; sleep 10)
EOF

echo done:99
exit 99

f3j()
{
    while :; do echo blah; done | while read
    do
      #echo 1>&2 "1: $(echo_id REPLY)"
      read -e -p "Enter something> " -u 5 || {
          echo 1>&2 "Exiting loop"
          break
      }
      echo 1>&2 "2: $(echo_id REPLY)"
    done
}
#echo =================
#echo 1 2 3 | f3j 5<<EOF
#line 1
#2 line
#linez
#lasztline
echo =================
echo 1 2 3 | f3j 5<<EOF

# This works for every line typed, but there is no prompting, and all go at once.
# while read -p '? ' -e -u 5; do echo_id REPLY; done 5<<EOF|less
