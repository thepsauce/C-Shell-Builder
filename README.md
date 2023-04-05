# C-Shell-Builder

Use this as a simple project manager for a C project.
Since I am using this myself, I will try to keep adding features whenever I need them.

## Usage

- When you want to make a new C project, make a directory of with the name of the project.
- Then, change into that directory and run the c command.
- You will get asked if you want to make a new project, just hit y for yes
- Now observe the files and folder that were created in the directory using ls -A

### Meaning of directories

**src:** For project .c files (a main.c is automatically created)<br>
**include:** For project .h files (a $project\_name.h file is automatically created)<br>
**build:** For .o files<br>
**tests:** For test programs go<br>

**.project:** Information on the recent calls to c

### Compiling/Executing a project

Compiling is as easy as running the c command. You may add one of the following flags:
**-x:** Execute the program<br>
**-t [name]:** Build and execute a test program (the name must be the file name without file extension inside the tests directory)<br>
**-o:** Ignore the .project file<br>
**-r:** Rebuild the source files<br>
**-B:** Alias for -r (make inspired) <br>
**-g -O* -l* -I* -L* -f* : ** Flags for gcc<br>

When executing the main program or a test, you will also be prompted the exit code and runtime of the program

## Installation

For installation, you can simply put the two lines of the sample\_bashrc into your .bashrc.<br>
You also want to create the ~/bin directory and place the c\_build.sh program there.<br>
Lastly, you must add the fdiv program which can be compiled using `gcc fdiv.c -o fdiv` to ~/bin directory.<br>
Here is a command to do most things for you (this can also be used for updating):
```
cd ~
mkdir -p bin
rm -R C-Shell-Builder
git clone https://github.com/MordorHD/C-Shell-Builder.git
cd C-Shell-Builder
gcc fdiv.c -o ~/bin/fdiv
cp c_build.sh ~/bin/c_build.sh
echo "Lastly, you can make aliases for ~/bin/c_build.sh like in sample_bashrc"
```

## Feature X is missing

If you feel like something is missing or there is an error, please tell me and I will try to improve the script.
