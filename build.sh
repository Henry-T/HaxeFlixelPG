files=`find . -name *.hxproj`
for f in $files; do
  full=`readlink -f $f`
  projFile=${full%%.*}.xml
  echo TEST ON $projFile
  haxelib run openfl build "$projFile" flash
done