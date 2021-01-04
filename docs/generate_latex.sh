#!/usr/bin/env sh

pandoc ./csv_to_sql.md --standalone -o csv_to_sql.tex --toc --toc-depth=5
