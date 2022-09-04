#!/bin/bash
set -e

pushd gcc

echo "Resetting gcc repo"
git reset --hard releases/gcc-12.1.0
git apply ../gcc-patch.diff

echo "Current GCC version is $(cat gcc/BASE-VER)"

source contrib/download_prerequisites

popd

echo "Installing dev libs"
apt-get install -y libmpfr-dev libmpc-dev texinfo flex linux-libc-dev

# This is needed to build GCC in scout
#if [ ! -L "/usr/include/asm" ]; then ln -s /usr/include/asm-generic /usr/include/asm; fi

if [ -d "out" ]; then rm -r out; fi
mkdir out

if cmp -s "gcc/gcc/BASE-VER" "GCC-CUR-VER";
then
  i=$(cat GCC-BUILD-COUNTER)
else
  i=0
  cp gcc/gcc/BASE-VER GCC-CUR-VER
fi

pushd out

CXX=g++-9 CC=gcc-9 ../gcc/configure -v --with-pkgversion="SteamRT $(cat ../gcc/gcc/BASE-VER)-$i+steamrt2.2+bsrt2.1" --with-bugurl=file:///usr/share/doc/gcc-12/README.Bugs --enable-languages=c,c++ --prefix=/usr/lib/gcc-12 --with-gcc-major-version-only --program-prefix= --program-suffix=-12 --enable-shared --enable-linker-build-id --disable-shared --with-pic=yes --enable-nls --enable-bootstrap --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --disable-libquadmath --disable-libquadmath-support --enable-plugin --enable-default-pie --with-system-zlib --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64 --enable-multilib --with-tune=generic --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --with-build-config=bootstrap-lto-lean --enable-link-mutex

#make -j8
make -j16
make install-strip

popd

for FILE in /usr/lib/gcc-12/bin/*; do
	if [ -L /usr/bin/$(basename "$FILE") ]; then
		echo "Removing old symbolic link /usr/bin/$(basename $FILE)";
		rm /usr/bin/$(basename "$FILE")
	fi
	
	ln -s $FILE /usr/bin/$(basename "$FILE")
done

tar -cf gcc12.tar /usr/lib/gcc-12/ /usr/bin/{c++-12,cpp-12,g++-12,gcc-12,gcc-ar-12,gcc-nm-12,gcc-ranlib-12,gcov-12,gcov-dump-12,gcov-tool-12,lto-dump-12,x86_64-linux-gnu-c++-12,x86_64-linux-gnu-g++-12,x86_64-linux-gnu-gcc-12,x86_64-linux-gnu-gcc-ar-12,x86_64-linux-gnu-gcc-nm-12,x86_64-linux-gnu-gcc-ranlib-12}
gzip -f gcc12.tar

((i=i+1))
echo $i > GCC-BUILD-COUNTER

echo "Build done!"
