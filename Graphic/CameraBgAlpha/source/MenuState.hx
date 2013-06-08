package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.display.BlendMode;
import flash.display.Bitmap;
import flash.display.Sprite;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;

class MenuState extends FlxState
{
	var sprite:FlxSprite;

	override public function create():Void
	{
		FlxG.bgColor = 0xff000000;
		// This is the last effect you may want
		FlxG.camera.bgColor = 0x00000000;
		// But this is a fancy blur effect
		FlxG.camera.bgColor = 0x21000000;

		sprite = new FlxSprite(0,0);
		add(sprite);
	}

	override public function update():Void
	{
		super.update();

		sprite.x = FlxG.mouse.x;
		sprite.y = FlxG.mouse.y;
	}	

	override public function draw():Void {
		// # Uncomment this line to clear camera buffer to transparent
		// # Solution: This works if you don't want blend effect!
		// -----------------------------------------------------------
		// FlxG.camera.buffer.fillRect(new flash.geom.Rectangle(0,0,FlxG.width,FlxG.height), 0x00000000);


		// # This method is used inside FlxCamera, but it doesn't work
		// # Answer: FlxCamera is designed to blend two fill instead of replacing the old one
		// # Answer: set last param(mergeAlpha) of copyPixels does the magic
		// # ---------------------------------------------------------
		//var _fill:flash.display.BitmapData = new flash.display.BitmapData(FlxG.width,FlxG.height, true, 0x00000000);
		//_fill.fillRect(new flash.geom.Rectangle(0,0,640, 480), 0x00000000);
		//FlxG.camera.buffer.copyPixels(_fill, new flash.geom.Rectangle(0,0,640,480), new flash.geom.Point(0,0), null, null, true);
		
		super.draw();
	}
}