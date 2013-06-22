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

class MenuState extends FlxState
{
	public var background:FlxSprite;
	public var dark:FlxSprite;
	public var light:FlxSprite;

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

		background = new FlxSprite();
		background.loadGraphic("assets/background.png");
		add(background);

		dark = new FlxSprite();
		dark.makeGraphic(FlxG.width,FlxG.height,0xff000000);
		dark.scrollFactor.make(0,0);
		dark.blend = flash.display.BlendMode.MULTIPLY;
		add(dark);

		light = new FlxSprite();
		light.loadGraphic("assets/light.png");
		light.blend = flash.display.BlendMode.SCREEN;
	}

	override public function draw():Void{
		dark.fill(0xff000000);
		dark.stamp(light, Std.int(100), Std.int(100));
		super.draw();
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