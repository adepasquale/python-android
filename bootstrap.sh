#!/usr/bin/env sh

ROOTDIR=$(dirname $(readlink -f $0))
VERSION="2.7.9"

if [ ! -e "Python-$VERSION.tgz" ]; then
    wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
fi

if [ ! -e 'Python-host' ]; then
    tar zxvf Python-$VERSION.tgz
    mv Python-$VERSION Python-host
fi

if [ ! -e 'Python' ]; then
    tar zxvf Python-$VERSION.tgz
    mv Python-$VERSION Python
    cd $ROOTDIR/Python
    for patch in ../patch/Python-$VERSION-*.patch; do
        patch -p1 < $patch
    done
fi

if [ ! -e "$ROOTDIR/hostpython" -o ! -e "$ROOTDIR/hostpgen" -o ! -e "$ROOTDIR/prebuilt" ]; then
    cd $ROOTDIR/Python-host
    ./configure --prefix=$ROOTDIR/prebuilt
    make -j4
    make install
    mv python $ROOTDIR/hostpython
    mv Parser/pgen $ROOTDIR/hostpgen
    curl http://python-distribute.org/distribute_setup.py | $ROOTDIR/hostpython
    curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | $ROOTDIR/hostpython
    $ROOTDIR/prebuilt/bin/pip install virtualenv
    $ROOTDIR/prebuilt/bin/pip install virtualenvwrapper
    make distclean
fi

cd $ROOTDIR

if [ ! -e 'openssl' ]; then
    git clone https://github.com/guardianproject/openssl-android.git openssl
fi
