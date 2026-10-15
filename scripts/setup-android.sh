#!/usr/bin/env bash
set -euo pipefail
# Versions compatible with this legacy Kade Engine source tree.
haxelib install lime 7.9.0 --quiet
haxelib install openfl 9.2.0 --quiet
haxelib install flixel 4.11.0 --quiet
haxelib install flixel-addons 2.11.0 --quiet
haxelib install flixel-ui 2.4.0 --quiet
haxelib install hscript 2.4.0 --quiet
haxelib install newgrounds 1.1.5 --quiet
haxelib install hxcpp 4.2.1 --quiet
# Re-select pins even if a transitive installation changed the active version.
for library in lime:7.9.0 openfl:9.2.0 flixel:4.11.0 flixel-addons:2.11.0 flixel-ui:2.4.0 hscript:2.4.0 newgrounds:1.1.5 hxcpp:4.2.1; do
  haxelib set "${library%%:*}" "${library#*:}"
done
