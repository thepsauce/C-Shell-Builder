#!/bin/bash

project_name=$(basename "$(pwd)")
if [ ! -f .project ]
then
	read -n 1 -p "First call of c, do you want to initialize the project '$project_name'? [yn] " yn
	echo
	case $yn in
		y) ;;
		*) echo "Cancelled" ; exit ;;
	esac
	mkdir src
	mkdir include
	mkdir build
	mkdir tests
	echo -e "#include \"$project_name.h\"\n\nint\nmain(int argc, char **argv)\n{\n\texit 0;\n}\n" > src/main.c
	echo -e "#ifndef INCLUDED_${project_name^^}_H\n#define INCLUDED_${project_name^^}_H\n\n\n#endif" > include/$project_name.h
	touch .project
	exit 0
fi

# Time the build
START_TIME=$(date +%s.%N)
# flags for building
gcc_flags=
# linker options
gcc_links=
# if the program should be executed at the end
do_execute=
# if the .project file should be used
do_overwrite=
# if the out file should be rebuilt
do_update=
# if everything should be rebuilt
do_rebuild=
# -t [name] can be used to test a program instead of running main.c
test_program=
# Check for program flags
# -x Execute the program
# -t [name] Build and execute a test program
# -o Ignore the .project file
# -r Rebuild the source files
# -B alias for -r
# -g -O* -l* -I* -L* -f* Flags for gcc
if [ "${1:0:1}" = - ]
then
	while [ $# -ne 0 ]
	do
		case "$1" in
		-x) do_execute=1 ;;
		-o) do_overwrite=1 ;;
		-r) do_rebuild=1 ;;
		-B) do_rebuild=1 ;;
		-t) 
			shift
			if [ $# -eq 0 ] ; then echo "expected test program after -t" ; exit 1 ; fi
			test_program="$1"
			;;
		-l* | -I* | -L*) gcc_links="$gcc_links $1" ;;
		-O* | -pg | -g | -f*) gcc_flags="$gcc_flags $1" ;;
		--) shift ; break ;;
		-*) echo "can not recognize flag $1" ; exit 1 ;;
		*) break ;;
		esac
		shift
	done
fi

if [ -n "$test_program" ] && [ -n "$do_execute" ]
then
	echo "-x and -t are conflicting"
	exit 1
fi

# Collect project information from the .project file
old_gcc_flags=
old_gcc_links=
if [ -f .project ] && [ -z "$do_overwrite" ]
then
	exec 6<.project
	read old_gcc_flags <&6
	read old_gcc_links <&6
	# Check if any gcc flags have changed
	for f in $gcc_flags
	do
		case "$old_gcc_flags" in
		*$f*) ;;
		*)
			old_gcc_flags="$old_gcc_flags $f"
			do_update=1
			do_rebuild=1
			;;
		esac
	done
	for f in $gcc_links
	do
		case "$old_gcc_links" in
		*$f*) ;;
		*)
			old_gcc_links="$old_gcc_links $f"
			do_update=1
		esac
	done
	gcc_flags="$old_gcc_flags"
	gcc_links="$old_gcc_links"
else
	do_update=1
	do_rebuild=1
fi
# Write back the information
echo -e "$gcc_flags\n$gcc_links" > .project

# Check if any header file changed
for file in include/*
do
	if [ "$file" -nt "out" ]
	then
		do_rebuild=1
		break
	fi
done

# If the main header file changed, rebuild it
if [ -n "$do_rebuild" ]
then
	echo "gcc \"include/$project_name.h\" -Iinclude"
	gcc "include/$project_name.h" -Iinclude
elif [ "include/$project_name.h" -nt "out" ]
then
	do_rebuild=1
	echo "gcc \"include/$project_name.h\" -Iinclude"
	gcc "include/$project_name.h" -Iinclude
fi

# Collect source files and build all object files
sources=$(find src -name '*.c')
objects=
for s in $sources
do
	o=build/${s:4}.o
	objects="$objects $o"
	if [ -n "$do_rebuild" ] || [ $s -nt $o ]
	then
		echo "gcc $gcc_flags -c $s -o $o -Iinclude"
		if !  gcc $gcc_flags -c $s -o $o -Iinclude ; then exit 1 ; fi
	fi
done

# Check if new object files were added
if [ -z "$do_update" ]
then
	for o in $objects
	do
		if [ $o -nt out ]
		then
			do_update=1
			break
		fi
	done
fi
# Building final program
if [ -n "$do_update" ]
then
	echo "gcc $gcc_flags $objects -o out $gcc_links"
	if !  gcc $gcc_flags $objects -o out $gcc_links ; then exit 1 ; fi
	END_TIME=$(date +%s.%N)
	ELAPSED_TIME=$(~/bin/fdiv $END_TIME $START_TIME)
	echo -e "build time: \e[36m$ELAPSED_TIME\e[0m seconds"
else
	echo "Everything is up to date!"
fi
# Building and executing test program
if [ -n "$test_program" ]
then
	objects="${objects/'build/main.c.o'/} build/$test_program.c.o"
	echo "gcc $gcc_flags -c tests/$test_program.c -o build/$test_program.c.o -Iinclude"
	if !  gcc $gcc_flags -c tests/$test_program.c -o build/$test_program.c.o -Iinclude ; then exit 1 ; fi
	echo "gcc $gcc_flags $objects -o test $gcc_links"
	if !  gcc $gcc_flags $objects -o test $gcc_links ; then exit 1 ; fi
	START_TIME=$(date +%s.%N)
	./test $@
	exit_code=$?
	END_TIME=$(date +%s.%N)
	ELAPSED_TIME=$(~/bin/fdiv $END_TIME $START_TIME)
	echo -e "exit code: \e[36m$exit_code\e[0m; elapsed time: \e[36m$ELAPSED_TIME\e[0m seconds"
fi
# Executing if wanted
if [ -n "$do_execute" ]
then
	START_TIME=$(date +%s.%N)
	./out $@
	exit_code=$?
	END_TIME=$(date +%s.%N)
	ELAPSED_TIME=$(~/bin/fdiv $END_TIME $START_TIME)
	echo -e "exit code: \e[36m$exit_code\e[0m; elapsed time: \e[36m$ELAPSED_TIME\e[0m seconds"
fi

