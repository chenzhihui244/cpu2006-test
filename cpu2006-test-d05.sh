#!/bin/sh

iso_file=cpu2006-1.2.iso
iso_mnt=/mnt

cpu2006_dir=cpu2006

install_depency_ubuntu() {
	apt install build-essential
	apt install m4
}

mount | grep -q "$iso_file" > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
	mount $iso_file $iso_mnt
fi

[ -d $cpu2006_dir ] || {
	mkdir $cpu2006_dir && cp -a $iso_mnt/* $cpu2006_dir

	# replace make
	#rm -rf $cpu2006_dir/tools/src/make-3.82
	#tar xf make.tar.gz -C $cpu2006_dir/tools/src/
}

# replace config.guess
cp build/config.guess $cpu2006_dir/tools/src/specsum/build-aux/
cp build/config.guess $cpu2006_dir/tools/src/tar-1.25/build-aux/
cp build/config.guess $cpu2006_dir/tools/src/xz-5.0.0/build-aux/
cp build/config.guess $cpu2006_dir/tools/src/rxp-1.5.0/
cp build/config.guess $cpu2006_dir/tools/src/make-3.82/config/

# modify Configure of perl
grep -q "aarch64" $cpu2006_dir/tools/src/perl-5.12.3/Configure > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
sed -i 'N;1324atest -d /lib/aarch64-linux-gnu && glibpth="$glibpth /lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu"' $cpu2006_dir/tools/src/perl-5.12.3/Configure
fi

# modify stdio.in.h

grep -q "//#undef" $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
if [ ! $? -eq 0 ]; then
	sed -i '146s%#undef%//#undef%' $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
fi

grep -q "//_GL_WARN_ON_USE" $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
if [ ! $? -eq 0 ]; then
	sed -i '147s%_GL_WARN_ON_USE%//_GL_WARN_ON_USE%' $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
fi

# modify stdio.in.h

grep -q "//#undef" $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
if [ ! $? -eq 0 ]; then
	sed -i '161s%#undef%//#undef%' $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
fi

grep -q "//_GL_WARN_ON_USE" $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
if [ ! $? -eq 0 ]; then
	sed -i '162s%_GL_WARN_ON_USE%//_GL_WARN_ON_USE%' $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
fi

[ -f $cpu2006_dir/config/d05-2cpu.cfg ] || cp config/d05-2cpu.cfg $cpu2006_dir/config/

# make test report valid

grep -q "F-fsigned-char" $cpu2006_dir/config/flags/Example-gcc4x-flags-revA.xml > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
	sed -i 's%F-funsigned-char%F-fsigned-char%' $cpu2006_dir/config/flags/Example-gcc4x-flags-revA.xml
	sed -i '/<\/flagsdescription>/d' $cpu2006_dir/config/flags/Example-gcc4x-flags-revA.xml
	cat >> $cpu2006_dir/config/flags/Example-gcc4x-flags-revA.xml <<EOF

<flag name="F-fno-aggressive-loop-optimizations"
      class="optimization">
<![CDATA[
<p> 
gnu90 portability
</p>
]]>
</flag>

<flag name="F-std"
      class="portability">
<example>
-std=gnu90
</example>
<![CDATA[
<p> 
gnu90 portability
</p>
]]>
</flag>

</flagsdescription>
EOF
fi

build_test() {
	export FORCE_UNSAFE_CONFIGURE=1
	cd $cpu2006_dir/tools/src
	echo y | ./buildtools
	cd -
}

run_test() {
	cd $cpu2006_dir
	. ./shrc

	runspec -c d05-2cpu.cfg all --rate 1
	runspec -c d05-2cpu.cfg all --rate 64
}

build_test
run_test
