package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeVelocity;

import nape.phys.Body;
import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.dynamics.InteractionFilter;
import nape.callbacks.InteractionType;

class PlayState extends FlxNapeState
{
	public static var OffsetX:Float = 100;
	public static var OffsetY:Float = 100;
	public static var TrackW:Float = 500;
	public static var TrackH:Float = 300;
	public static var CheckPointCnt:Int = 5;

	public var lbLap:FlxText;
	public var lbCp:FlxText;
	public var track:FlxSprite;
	public var car:FlxNapeSprite;
	public static var carType:CbType;
	public static var cpType:CbType;

	public var checkAry:Array<Int>;
	public var curLap:Int;

	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		FlxG.mouse.show();

		carType = new CbType();
		cpType = new CbType();
		
		super.create();

		lbLap = new FlxText(10,30,100, "Lap: 0");
		add(lbLap);

		lbCp = new FlxText(10, 60, 100, "CheckPoint: 0");
		add(lbCp);

		// create race track
		track = new FlxSprite(OffsetX, OffsetY, "assets/track.png");
		add(track);

		car = new FlxNapeSprite(200, 200, "assets/car.png");
		car.setDrag(0.92, 0.80);
		car.body.shapes.at(0).cbTypes.add(carType);
		add(car);

		this.createWalls(OffsetX, OffsetY, OffsetX+TrackW, OffsetY+TrackH);

		// add CheckPoints
		var cp:CheckPoint = null;
		cp = new CheckPoint(0,OffsetX, OffsetY, [Vec2.weak(409, 300-59), Vec2.weak(418,300-15), Vec2.weak(452,300-33), Vec2.weak(479, 300-62), Vec2.weak(442, 300-81)]);
		cp.body.space = FlxNapeState.space;
		cp = new CheckPoint(1,OffsetX, OffsetY, [
			Vec2.weak(441, 300-221), Vec2.weak(479,300-240), 
			Vec2.weak(452,300-269), Vec2.weak(418, 300-287), Vec2.weak(409, 300-243)]);
		cp.body.space = FlxNapeState.space;
		cp = new CheckPoint(2,OffsetX, OffsetY, [
			Vec2.weak(84, 300-287), Vec2.weak(51,300-269), 
			Vec2.weak(24,300-240), Vec2.weak(61, 300-221), Vec2.weak(94, 300-243)]);
		cp.body.space = FlxNapeState.space;
		cp = new CheckPoint(3,OffsetX, OffsetY, [
			Vec2.weak(62, 300-81), Vec2.weak(25,300-62), 
			Vec2.weak(52,300-33), Vec2.weak(86, 300-15), Vec2.weak(95, 300-59)]);
		cp.body.space = FlxNapeState.space;
		cp = new CheckPoint(4,OffsetX, OffsetY, [
			Vec2.weak(241, 300-50), Vec2.weak(241,300-12), 
			Vec2.weak(270,300-12), Vec2.weak(270, 300-49)]);
		cp.body.space = FlxNapeState.space;


		checkAry = [];

		FlxNapeState.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, InteractionType.SENSOR,
			carType, cpType, 
			checkPointHandler
		));

		curLap = 1;
	}
	
	function checkPointHandler(cb:InteractionCallback) {
		var cpBody:Body = cb.int2.castShape.body;//.castBody;
		var id:Int = cpBody.userData.id;
		var lastId:Int = checkAry.length==0?-1:checkAry[checkAry.length-1];
		trace("this id: " + id);
		if(id == lastId+1){
			checkAry.push(id);
			trace("checking: " + id);
		}
		if(checkAry.length==CheckPointCnt){
			checkAry = [];
			curLap++;
		}
	}
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		lbLap.text = "Lap: " + curLap;
		if(checkAry.length == 0)
			lbCp.text = "CheckPoint: " + 0;
		else
			lbCp.text = "CheckPoint: " + (checkAry[checkAry.length-1] + 1);

		if(FlxG.keyboard.pressed("LEFT"))
			car.body.applyAngularImpulse(-25);
		else if (FlxG.keyboard.pressed("RIGHT"))
			car.body.applyAngularImpulse(25);

		var dir:Float = car.angle * flixel.util.FlxAngle.TO_RAD - Math.PI/2;
		var cos:Float = Math.cos(dir);
		var sin:Float = Math.sin(dir);
		if(FlxG.keyboard.pressed("UP"))
			car.body.applyImpulse(Vec2.weak(10*Math.cos(dir), 10*Math.sin(dir)));
		else if(FlxG.keyboard.pressed("DOWN"))
			car.body.applyImpulse(Vec2.weak(10*Math.cos(dir-Math.PI), 10*Math.sin(dir-Math.PI)));
	}
}

class CheckPoint extends FlxNapeSprite{
	public function new(Id:Int, X:Float, Y:Float, Points:Array<Vec2>)
	{
		super(X, Y, null, false);

		body = new Body(nape.phys.BodyType.DYNAMIC);
		body.space = FlxNapeState.space;
		body.userData.id = Id;
		var poly:Polygon = new Polygon(Points);
		poly.sensorEnabled = true;
		poly.cbTypes.add(PlayState.cpType);
		body.shapes.add(poly);
		body.position.setxy(X, Y);
	}
}