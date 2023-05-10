#!/bin/bash

# Check if the <package_name> arg is passed
if [ -z "$1" ]
  then
    echo "No package name supplied"
    exit 1
fi


sui client publish --gas-budget 30000000 /home/atha/sui-intro/$1
