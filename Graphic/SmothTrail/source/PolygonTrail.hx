package ;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxAngle;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Point;


class PolygonTrail extends Trail
{
	public var blur:Bool;
	public var segments:Array<PTrailSeg>;
	public var pColor:Int;

	public function new(Target:FlxSprite, Color:Int){
		super(Target);

		segments = new Array<PTrailSeg>();
		pColor = Color;
	}

	override public function update(){
		super.update();

		thisPos = new Point(target.getMidpoint().x, target.getMidpoint().y);

		for (i in 0...segments.length) {
			var id:Int = segments.length-i-1;
			segments[id].update();
			if(segments[id].alive == false){
				segments = segments.slice(id, segments.length);
				break;
			}
		}

		// add new segments
		segments.push(new PTrailSeg(20, 1, thisPos, 0.8));

		// draw
		canvas.graphics.clear();
		canvas.graphics.lineStyle(4, 0xff0000, 1);
		for (i in 0...segments.length) {
			// this segment should be alive
			if(i==0){	// the tail
				// will do this later
			}
			//else if(i==segments.length-1){
				// will do this later
			//}
			else{
				var lastSeg:PTrailSeg = segments[i-1];
				var thisSeg:PTrailSeg = segments[i];
				//var nextSeg:PTrailSeg = segments[i+1];
				var agl:Float = FlxAngle.getAngle(
					new FlxPoint(lastSeg.pos.x, lastSeg.pos.y), 
					new FlxPoint(thisSeg.pos.x, thisSeg.pos.y)) * FlxAngle.TO_RAD - Math.PI/2;
				canvas.graphics.beginFill(0xff0000,1);
				canvas.graphics.moveTo(
					lastSeg.pos.x + Math.cos(agl+Math.PI/2)*lastSeg.radius,
					lastSeg.pos.y + Math.sin(agl+Math.PI/2)*lastSeg.radius);
				canvas.graphics.lineTo(
					lastSeg.pos.x + Math.cos(agl-Math.PI/2)*lastSeg.radius,
					lastSeg.pos.y + Math.sin(agl-Math.PI/2)*lastSeg.radius);
				canvas.graphics.lineTo(
					thisSeg.pos.x + Math.cos(agl-Math.PI/2)*thisSeg.radius,
					thisSeg.pos.y + Math.sin(agl-Math.PI/2)*thisSeg.radius);
				canvas.graphics.lineTo(
					thisSeg.pos.x + Math.cos(agl+Math.PI/2)*thisSeg.radius,
					thisSeg.pos.y + Math.sin(agl+Math.PI/2)*thisSeg.radius);
				canvas.graphics.endFill();
			}
				//canvas.graphics.drawCircle(s.pos.x, s.pos.y, s.radius);
		}
		canvasBD.fillRect(canvasBD.rect, 0x0);
		canvasBD.draw(canvas);

		lastPos = thisPos;
	}
}

class PTrailSeg{
	public var radius:Float;
	public var alpha:Float;
	public var pos:Point;
	public var fadeFactor:Float;
	public var alive:Bool;

	public function new(Rad:Float, Alpha:Float, Pos:Point, Fade:Float=0.9){
		radius = Rad;
		alpha = Alpha;
		pos = Pos;
		fadeFactor = Fade;

		alive = true;
	}

	public function update(){
		if(alive){
			radius *= fadeFactor;
			alpha *= fadeFactor;
			if(alpha < 0.05 || radius < 1)
				alive = false; 
		}
	}
}