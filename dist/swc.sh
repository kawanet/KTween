#!/bin/sh -v

export PATH=$PATH:"/Applications/Adobe Flash Builder 4/sdks/4.0.0/bin"
compc -source-path ../src -output ../swc/ktween.swc -include-sources ../src/net/kawa/tween/*.as ../src/net/kawa/tween/easing/*.as -- 2>&1 | nkf -Sw
