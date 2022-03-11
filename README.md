Android Build Stack
==================

The goal of this project is to set up a sandbox system to compile Android without having to modify my operating system, and also to run the best operating system according to the Android version to build.

**WARNING : please be careful when using this tool.**

**Work in progress :)**

# How to use

You need to have Docker installed on your system.

There are several environments variables to define for some commands :
- **BUILD_PATH** : a complete path to the directory accessible to the container (normally your Android sources).
- **OS** : the Linux distribution in the container.
- **RELEASE** : the release or version of the Linux distribution.

The list of distributions and release available for now :

| OS        | RELEASE | Corresponding
|-----------|---------|-------------
| ubuntu    | 18_04   | Ubuntu 18.04
| ubuntu    | 14_04   | Ubuntu 14.04
| archlinux | latest  | Archlinux

**If you use classic Docker, you must have to be root or use sudo for each commands.**

List of commands available :

```bash
# First we need to prepare our system
make build OS=ubuntu RELEASE=18_04

# Next we have to set the buid directory for the first start of the system
make init-start OS=ubuntu RELEASE=18_04 BUILD_PATH=/home/akp/android_sources

# Now you can enter in the shell of your system
make shell OS=ubuntu RELEASE=18_04 # You can do what your want inside this system !

# For shutdown your system
make stop OS=ubuntu RELEASE=18_04

# If you don't have destroye you system,
# you can start it with the simpler command
make start OS=ubuntu RELEASE=18_04

# If you want to remove your system
make rm  OS=ubuntu RELEASE=18_04

# If you want update a system
make stop OS=ubuntu RELEASE=18_04
make update OS=ubuntu RELEASE=18_04
```
