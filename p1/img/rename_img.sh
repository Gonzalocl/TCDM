#!/bin/bash

c=0
for i in *.png; do
  mv "$i" "img$(printf %03d $c).png"
  ((c++))
done
