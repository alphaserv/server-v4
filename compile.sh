#!/bin/sh
export REVISION=`svn info | grep 'Revision: ' | awk '{print $2}'`
THREADS=1
if [ `uname -s` = "Linux" -a -d "/proc" ]; then
    THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
fi
ARG_LENGTH=$# 
STRCOMPILE="Compiling"
COMPILEDIR="release_build"
COMPILEFLAGS=""
BUILDTYPE="release"
if [ "$ARG_LENGTH" > 1 -a "$2" = "debug" ]; then
  COMPILEDIR="debug-build"
  COMPILEFLAGS="-D CMAKE_BUILD_TYPE=DEBUG"
  BUILDTYPE="debug"
fi
if [ "$ARG_LENGTH" > 0 -a "$1" = 1 ]; then
  STRCOMPILE="Recompiling"
  rm -rf $COMPILEDIR
fi
mkdir $COMPILEDIR
cd $COMPILEDIR
cmake $COMPILEFLAGS .. >> /dev/null
STRTHREADS="threads"
if [ $THREADS = 1 ]; then
  STRTHREADS="thread"
fi
echo "$STRCOMPILE Hopmod r$REVISION using $THREADS $STRTHREADS ($BUILDTYPE build)\n"
TS_START=`date +%s`
make -j$THREADS 
make install >> /dev/null
TS_END=`date +%s`
TS_DIFF=`echo $TS_END $TS_START | awk '{print $1 - $2}'`
echo "\nTook $TS_DIFF Seconds"
