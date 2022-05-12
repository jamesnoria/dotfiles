#!bin/bash
# Program to compile a c++ script without losing some time.
# By: James Noria | jamesnoria@gmail.com

#running the file_name as an arg.
g++ -o run $1

#compile the script
./run

rm run