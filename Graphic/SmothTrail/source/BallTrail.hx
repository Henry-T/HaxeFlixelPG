package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.util.FlxMath;

import flash.geom.Point;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.filters.BlurFilter;

class BallTrail extends Trail
{
	var cTrans:ColorTransform;
	var bColor:Int;	// Color of the ball center

	public var blendOnInterpolate:Bool;		// blend on every interpolate or every frame

	public function new(Target:FlxSprite, Color:Int){
		super(Target);

		cTrans = new ColorTransform();
		cTrans.alphaMultiplier = .99;
		bColor = Color;

		lastPos = new Point();

		blendOnInterpolate = false;
	}

	public static var lenGap:Float = 3;
	public static var timeGap:Float = 0.03;
	override public function update(){
		super.update();

		thisPos = new Point(target.getMidpoint().x, target.getMidpoint().y);
		
		// time or lenth? - test lengh gap first
		var seg:Int = Math.round(Point.distance(lastPos, thisPos)/lenGap);
		for (i in 0...seg) {
			var lerp:Point = Point.interpolate(lastPos, thisPos, i/seg);
			// draw another ball
			canvas.graphics.clear();
			canvas.graphics.beginFill(bColor, 1);
			//canvas.graphics.lineStyle(4, 0xff0000,1);
			canvas.graphics.drawCircle(10,10,10);
			canvas.graphics.endFill();

			canvasBD.draw(canvas, new flash.geom.Matrix(1,0,0,1, lerp.x, lerp.y));

			if(blendOnInterpolate){
				canvasBD.colorTransform(canvasBD.rect, cTrans);
				canvasBD.applyFilter(canvasBD, canvasBD.rect, new Point(), new BlurFilter(3,3));
			}
		}

		lastPos = thisPos;

		canvasBD.colorTransform(canvasBD.rect, cTrans);
		canvasBD.applyFilter(canvasBD, canvasBD.rect, new Point(), new BlurFilter(3,3));
	}
}