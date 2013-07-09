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
import org.flixel.FlxGroup;
import org.flixel.FlxTypedGroup;

class MenuState extends FlxState
{
	public var spills:FlxTypedGroup<FlxSprite>;
	public static var colors:Array<Int> = [0xffff0000, 0xffffff00, 0xff0000ff, 0xff00ff00];
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xffdddddd;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		super.create();

		spills = new FlxTypedGroup<FlxSprite>();
		add(spills);
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

		if(FlxG.mouse.justPressed())
			spawnSpill(FlxG.mouse.x, FlxG.mouse.y);

		// update life & check for living
		for (s in spills.members) {
			if(s!=null && s.alive){
				s.hurt(FlxG.elapsed * 100 / 2);
				s.alpha = s.health/100;
			}
		}
	}	

	private function spawnSpill(X:Float, Y:Float){
		var spill:FlxSprite = spills.recycle(FlxSprite);
		spill.reset(X-32, Y-32);
		spill.health = 100;
		spill.loadGraphic("assets/spill.png");
		var id:Int = Std.int(Math.random() * 4);
		spill.color = colors[id];
	}
}