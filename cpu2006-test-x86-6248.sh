#!/bin/sh

iso_file=cpu2006-1.2.iso
iso_mnt=/mnt

cpu2006_dir=cpu2006

install_depency_ubuntu() {
	apt install build-essential
	apt install m4
}

install_dependency_centos() {
	yum install -y numactl
}

[ -d $cpu2006_dir ] || {
	mount | grep -q "$iso_file" > /dev/null 2>&1
	if [ ! $? -eq 0 ]; then
		mount $iso_file $iso_mnt
	fi

	mkdir $cpu2006_dir && cp -a $iso_mnt/* $cpu2006_dir
}

prepare() {
	# tar-1.25: modify stdio.in.h

	grep -q "//#undef" $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
	if [ ! $? -eq 0 ]; then
		sed -i '146s%#undef%//#undef%' $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
	fi

	grep -q "//_GL_WARN_ON_USE" $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
	if [ ! $? -eq 0 ]; then
		sed -i '147s%_GL_WARN_ON_USE%//_GL_WARN_ON_USE%' $cpu2006_dir/tools/src/tar-1.25/gnu/stdio.in.h
	fi

	# specsum: modify stdio.in.h

	grep -q "//#undef" $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
	if [ ! $? -eq 0 ]; then
		sed -i '161s%#undef%//#undef%' $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
	fi

	grep -q "//_GL_WARN_ON_USE" $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
	if [ ! $? -eq 0 ]; then
		sed -i '162s%_GL_WARN_ON_USE%//_GL_WARN_ON_USE%' $cpu2006_dir/tools/src/specsum/gnulib/stdio.in.h
	fi

	# copy cfg file
	[ -f $cpu2006_dir/config/gold-6248-2cpu.cfg ] || cp config/gold-6248-2cpu.cfg $cpu2006_dir/config/
}

build_test() {
	export FORCE_UNSAFE_CONFIGURE=1
	cd $cpu2006_dir/tools/src
	echo y | ./buildtools
	cd -
}

run_test() {
	cd $cpu2006_dir
	. ./shrc

	#runspec -c gold-6248-2cpu.cfg all --rate 1
	runspec -c gold-6248-2cpu.cfg all --rate `nproc`
}

install_dependency_centos
#prepare
#build_test
run_test
