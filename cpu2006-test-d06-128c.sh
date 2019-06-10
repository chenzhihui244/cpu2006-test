#!/bin/sh

iso_file=cpu2006-1.2.iso
iso_mnt=/mnt

cpu2006_dir=cpu2006

install_depency_ubuntu() {
	sudo apt install build-essential
	sudo apt install m4
}

install_depency_centos() {
	sudo yum install -y gcc gcc-c++ gcc-gfortran numactl
}

fix_prebuild() {
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
}

fix_test_issue() {
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

<flag name="F-fpermissive"
      class="portability">
<example>
-fpermissive
</example>
<![CDATA[
<p> 
cxx portability
</p>
]]>
</flag>

</flagsdescription>
EOF
	fi
}

mount | grep -q "$iso_file" > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
	sudo mount $iso_file $iso_mnt
fi

[ -d $cpu2006_dir ] || {
	mkdir $cpu2006_dir && cp -a $iso_mnt/* $cpu2006_dir

	# replace make
	#rm -rf $cpu2006_dir/tools/src/make-3.82
	#tar xf make.tar.gz -C $cpu2006_dir/tools/src/
}

[ -f $cpu2006_dir/config/d06-2cpu-128c.cfg ] || cp config/d06-2cpu-128c.cfg $cpu2006_dir/config/

build_test() {
	fix_prebuild
	fix_test_issue
	export FORCE_UNSAFE_CONFIGURE=1
	cd $cpu2006_dir/tools/src
	echo y | ./buildtools
	cd -
}

test2() {
	cd $cpu2006_dir
	. ./shrc

	runspec -c d06-2cpu-128c.cfg 416.gamess --rate 1  -n 1 --no-reportable
	#runspec -c d06-2cpu-128c.cfg 434.zeusmp --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 435.gromacs --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 436.cactusADM --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 437.leslie3d --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 444.namd --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 447.dealII --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 450.soplex --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 453.povray --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 454.calculix --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 459.GemsFDTD --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 465.tonto --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 470.lbm --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 481.wrf --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 482.sphinx3 --rate 1  -n 1 --no-reportable &&
	#runspec -c d06-2cpu-128c.cfg 998.specrand --rate 1  -n 1 --no-reportable
	#runspec -c d06-2cpu-128c.cfg 433.milc --rate 1  -n 1 --no-reportable
	#runspec -c d05-2cpu.cfg fp --rate 1 --output_format html,pdf 
}

run_test() {
	cd $cpu2006_dir
	. ./shrc

	runspec -c d06-2cpu-128c.cfg all --rate 1 --output_format txt,html,pdf 
	runspec -c d06-2cpu-128c.cfg all --rate 128 --output_format txt,html,pdf 
}

#install_depency_centos
#install_depency_ubuntu
build_test
run_test
#test2
