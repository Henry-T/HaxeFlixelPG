package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

class PlayState extends FlxState
{
	var trail:Trail;
	var mouseSpr:FlxSprite;

	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		super.create();

		mouseSpr = new FlxSprite(0,0, null);
		mouseSpr.makeGraphic( 2,2,0xff0000ff);

		//trail = new BallTrail(mouseSpr, 0xffff00);
		trail = new PolygonTrail(mouseSpr, 0x00ddff);

		add(mouseSpr);
		add(trail);
	}
	
	override public function update():Void
	{
		super.update();

		mouseSpr.setPosition(FlxG.mouse.x, FlxG.mouse.y);
	}	
}