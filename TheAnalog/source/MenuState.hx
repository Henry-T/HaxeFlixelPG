package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;
import org.flixel.system.input.FlxAnalog;

class MenuState extends FlxState
{
	var analog:FlxAnalog;

	override public function create():Void
	{
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		analog = new FlxAnalog(100, 100);
		add(analog);
	}
	
	override public function update():Void
	{
		super.update();
		analog.justPressed();
	}
}