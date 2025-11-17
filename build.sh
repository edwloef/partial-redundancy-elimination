#! /usr/bin/env bash

for file in *.dot
do
    dot -Tsvg $file > $(basename $file .dot).svg
done
typst compile slides.typ
