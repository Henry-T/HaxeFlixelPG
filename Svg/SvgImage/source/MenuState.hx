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
import org.flixel.util.FlxMath;
import format.SVG;
import format.svg.SVGRenderer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		super.create();

		var sprite:FlxSprite = new FlxSprite();
		sprite.pixels = getBitmapFromSvg("assets/HaxeFlixel.svg", 0, 0, 50, 50);
		add(sprite);

		sprite = new FlxSprite(60, 0);
		sprite.pixels = getBitmapFromSvg("assets/HaxeFlixel.svg", 0, 0, 100, 100);
		add(sprite);

		sprite = new FlxSprite(170, 0);
		sprite.pixels = getBitmapFromSvg("assets/HaxeFlixel.svg", 0, 0, 150, 150);
		add(sprite);		
	}

	public function getBitmapFromSvg(id:String, X:Int=0, Y:Float=0, Width:Int=-1, Height:Int=-1):BitmapData{
		var svgText:String = Assets.getText(id);
		var svg:SVG = new SVG(svgText);
		var spr:Sprite = new Sprite();
		svg.render(spr.graphics, X, Y, Width, Height);
		var bd:BitmapData = new BitmapData(Std.int(spr.width),Std.int(spr.height),true, 0x0);
		bd.draw(spr);
		return bd;
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}