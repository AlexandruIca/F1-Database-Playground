#!/usr/bin/env sh

pandoc ./csv_to_sql.md -s -o csv_to_sql.tex --toc --toc-depth=5

pdflatex csv_to_sql.tex
