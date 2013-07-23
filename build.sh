function buildFlash(){
	echo Test On Flash $projFile
	haxelib run openfl build "$projFile" flash
	return $?
}

function buildCPP(){
  echo Test On CPP $projFile
	haxelib run openfl build "$projFile" cpp 1>/dev/null
	return $?
}

files=`find . -name *.hxproj`
ret=0
projFile=""
for f in $files; do
  full=`readlink -f $f`
  projFile=${full%%.*}.xml
  confFile=${full%%.*}.build

  for target in `cat $confFile`; do
    if [ $target == "flash" ]; then
      buildFlash
      if [ $? -ne 0 ]; then ret=1; fi
    fi

    if [ $target == "cpp" ]; then
      buildCPP
      if [ $? -ne 0 ]; then ret=1; fi
    fi
  done
done
exit $ret

