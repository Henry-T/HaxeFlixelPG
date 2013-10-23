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
import org.flixel.nape.FlxPhysState;
import org.flixel.util.FlxAngle;
import org.flixel.nape.FlxPhysSprite;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import org.flixel.util.FlxPoint;
import nape.geom.Vec2;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.shape.Polygon;

class MenuState extends FlxPhysState
{
	public var note:FlxText;
	public var spr:Sprite;
	public var pathSpr:FlxSprite;
	public var points:Array<FlxPoint>;
	public var napeSpr:FlxPhysSprite;

	public var creating:Bool;

	public static var radius:Float = 15;

	override public function create():Void
	{
		FlxG.bgColor = 0xff131c1b;
		FlxG.mouse.show();
		super.create();

		note = new FlxText(10,10, 800, "Press X to start creating a new path, Press C to finish it");

		spr = new Sprite();
		pathSpr = new FlxSprite(0,0);
		add(pathSpr);
		add(note);

		napeSpr = new FlxPhysSprite(0,0);
		napeSpr.createRectangularBody(100,100, nape.phys.BodyType.DYNAMIC);

		add(napeSpr);

		points = new Array<FlxPoint>();

		creating = true;

	}

	override public function update():Void
	{
		super.update();

		if(creating && FlxG.mouse.justReleased()){
			points.push(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
			if(points.length > 1){
				spr.graphics.lineStyle(4, 0xffffff, 1);
				spr.graphics.moveTo(points[points.length-2].x, points[points.length-2].y);
				spr.graphics.lineTo(points[points.length-1].x, points[points.length-1].y);
			}
		}
		else if(FlxG.keys.justPressed("X")){
			reset();
		}

		if(creating && FlxG.keys.justPressed("C")){
			creating = false;

			//FlxPhysState.space.gravity = new Vec2(0, 100);
			var vec2Ary:Array<Vec2> = new Array<Vec2>();
			for (i in 0...points.length) {
				var p:FlxPoint = points[i];
				var vecM:Vec2 = null;
				var vecN:Vec2 = null;
				var agl:Float = 0;
				if(i==0){
					agl = FlxAngle.getAngle(points[0], points[1]) * FlxAngle.RAD - Math.PI/2;
				}
				else if(i==points.length-1){
					agl = FlxAngle.getAngle(points[i-1], points[i]) * FlxAngle.RAD- Math.PI/2;
				}
				else{
					var a1:Float = FlxAngle.getAngle(points[i-1], points[i]) * FlxAngle.RAD;
					var a2:Float = FlxAngle.getAngle(points[i], points[i+1]) * FlxAngle.RAD;
					agl = (a1 + a2)/2 - Math.PI/2;
				}
				vecM = new Vec2(p.x + Math.cos(agl - Math.PI/2)*radius, p.y + Math.sin(agl-Math.PI/2)*radius);
				vecN = new Vec2(p.x + Math.cos(agl + Math.PI/2)*radius, p.y + Math.sin(agl+Math.PI/2)*radius);

				vec2Ary.push(vecM);
				vec2Ary.insert(0, vecN);
			}
		
			napeSpr.body.shapes.clear();
			var polys:GeomPolyList = new GeomPoly(vec2Ary).convexDecomposition();
			polys.foreach(function (p:GeomPoly):Void
			{
				napeSpr.body.shapes.add(new Polygon(p));
			});
		}

		// update path graphics
		if(spr.width != 0){
			pathSpr.makeGraphic(800, 600, 0xff000000);
			pathSpr.pixels.draw(spr);
		}
	}

	public function reset(){
		creating = true;
		napeSpr.body.shapes.clear();
		FlxPhysState.space.gravity = new Vec2(0, 0);
		napeSpr.body.position.setxy(0,0);
		points = new Array<FlxPoint>();
		spr = new Sprite();
	}
}