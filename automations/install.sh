#!bin/bash
# Program to install or remove packages on Debian based systems
# By: James Noria | Twitter: @jamesnoria

package=$*

echo "[1] Install"
echo "[2] Remove"

read varinput

if [ $varinput == 1 ]; then
  sudo apt install $package -y
else
  sudo apt remove $package -y
fi
