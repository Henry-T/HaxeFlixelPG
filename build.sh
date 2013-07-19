function buildFlash(){
	echo Test On Flash $projFile
	haxelib run openfl build "$projFile" flash
	return $?
}

function buildCPP(){
  echo Test On CPP $projFile
	haxelib run openfl build "$projFile" cpp
	return $?
}

files=`find . -name *.hxproj`
ret=0
projFile=""
for f in $files; do
  full=`readlink -f $f`
  projFile=${full%%.*}.xml
  buildFlash
  if [ $? -ne 0 ]; then ret=1; fi
  buildCPP
  if [ $? -ne 0 ]; then ret=1; fi
done
exit $ret

