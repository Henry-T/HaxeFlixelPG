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
import org.flixel.nape.FlxPhysSprite;
import org.flixel.nape.FlxPhysState;
import nape.geom.GeomPoly;
import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;

class MenuState extends FlxPhysState
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

		this.createWalls(10,10,500,400,10);

		var spr:FlxPhysSprite = new FlxPhysSprite(100,100);
		var vecAry:Array<Vec2> = [];
		vecAry.push(new Vec2(0,0));
		vecAry.push(new Vec2(10,10));
		vecAry.push(new Vec2(0,30));
		vecAry.push(new Vec2(-10,10));
		var poly:Polygon = new Polygon(vecAry);
		spr.body.shapes.add(poly);
		add(spr);
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