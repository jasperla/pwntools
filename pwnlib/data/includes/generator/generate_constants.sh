#!/bin/bash
set -e
pushd linux
ARCHS="$(ls *.h | sed 's/.h$//' | grep -v -e common -e syscall_map)"
popd

python="../../../constants"
headers="../"

rm -rf "$headers/linux" "$headers/freebsd.h" "$headers/openbsd.h"
mkdir -p "$headers/linux"
find "$python" -type f \( -name '*.py' -o -name '*.pyc' \) -not -name "__init__.py"  -not -name 'constant.py' -delete
find "$python" -type d -empty -delete

for arch in $ARCHS; do
  echo $arch
  swig -Ilinux -Ilinux -Ilinux/diet -includeall -E linux/$arch.h | egrep "^%constant" | ./load_constants.py $python/linux/$arch.py $headers/linux/$arch.h
done

for b in freebsd openbsd; do
  swig -I$b -includeall -E $b/common.h | egrep "^%constant" | ./load_constants.py $python/$b.py $headers/$b.h
done
