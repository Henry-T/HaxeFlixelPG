package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.addons.FlxBackdrop;

class MenuState extends FlxState
{
	public var backDrop1 : FlxBackdrop; 
	public var backDrop2 : FlxBackdrop;

	public static var camScrollSpeed = 100;

	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		backDrop1 = new FlxBackdrop( "assets/bgStar.png", 1, 1, true, true);
		add(backDrop1);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();

		if(FlxG.keys.LEFT)
			FlxG.camera.scroll.x += camScrollSpeed * FlxG.elapsed;
		if(FlxG.keys.RIGHT)
			FlxG.camera.scroll.x -= camScrollSpeed * FlxG.elapsed;
		if(FlxG.keys.UP)
			FlxG.camera.scroll.y += camScrollSpeed * FlxG.elapsed;
		if(FlxG.keys.DOWN)
			FlxG.camera.scroll.y -= camScrollSpeed * FlxG.elapsed;
	}	
}