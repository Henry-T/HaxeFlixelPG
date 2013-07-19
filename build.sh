files=`find . -name *.hxproj`
ret=0
for f in $files; do
  full=`readlink -f $f`
  projFile=${full%%.*}.xml
  echo TEST ON $projFile
  haxelib run openfl build "$projFile" flash
  curRet=$?
  if [ $curRet -ne 0 ]
  then ret=1
  else echo OK
  fi
done
exit $ret