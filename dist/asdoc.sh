#!/bin/sh -v

export PATH=$PATH:"/Applications/Adobe Flash Builder 4/sdks/4.0.0/bin"
asdoc -source-path ../src -doc-sources ../src/net/kawa/tween/*.as ../src/net/kawa/tween/*/*.as -output ../docs
ls -l ../docs/index.html
