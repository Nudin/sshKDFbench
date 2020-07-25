#!/bin/bash
# Test how long the KDF takes for given number of rounds
# based on https://crypto.stackexchange.com/a/64425

export LANG=C
iterations=20
declare -ir iterations

dir=$(mktemp -d)
declare -r dir
cd "$dir" || exit

cleanup() {
  rm -rf "$dir"
}
trap cleanup EXIT

bench() {
  printf -- "-a %3s takes on average " "$1"
  iter=0
  while ((iter++ < iterations)); do
      ssh-keygen -qa "$1" -t ed25519 -f test -N test;
      time ssh-keygen -qa "$1" -N tost -pP test -f test;
      rm test{.pub,};
    done |& grep real | awk -F m '{print $2}' | tr -d s | awk \
      'BEGIN { min=999; max=0 }
             {
               sum+=$1;
               if (max < $1)
                 max=$1;
               if (min > $1)
                 min=$1
             }
         END { printf "%7ss (%5s..%5s)\n", sum/NR, min, max }';
}

if [[ "$*" -gt 0 ]]; then
  bench "$1"
else
  declare -i j
  for j in 1 2 4 8 16 32 64 100 150; do
    bench $j
  done
fi
