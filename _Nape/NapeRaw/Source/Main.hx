package;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.Lib;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;
import nape.util.Debug;
import nape.util.ShapeDebug;
import nape.constraint.PivotJoint;

class Main extends Sprite {
	private var debug:Debug;
	public var space:Space;
	public var handJoint:PivotJoint;
	public var simTime:Float;
	public var lastTime:Float;

	public function new () {
		super ();

		if(stage != null)
			initialize(null);
		else 
			addEventListener(Event.ADDED_TO_STAGE, initialize);
	}

	public function initialize(e:Event){
		if(e != null)
			removeEventListener(Event.ADDED_TO_STAGE, initialize);

		space = new Space(Vec2.weak(0, 800));

		debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xff333333);
		debug.drawConstraints = true;
		debug.drawShapeDetail = true;
		debug.drawBodyDetail = true;
		debug.drawShapeAngleIndicators = false;
		stage.addChild(debug.display);

		setup();

		stage.addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function setup(){
		var w = stage.stageWidth;
		var h = stage.stageHeight;
		var floor = new Body(BodyType.STATIC);
		floor.shapes.add(new Polygon(Polygon.rect(50, h-50, w-100,1)));
		floor.space = space;

		var cube = new Body(BodyType.DYNAMIC, Vec2.weak(400, 300));
		cube.shapes.add(new Polygon(Polygon.rect(0,0,100,100,true),Material.wood()));
		cube.space = space;
		trace("World Verts");
		for(v in cube.shapes.at(0).castPolygon.worldVerts)
			trace(v);
		trace("Local Verts");
		for(v in cube.shapes.at(0).castPolygon.localVerts)
			trace(v);

		handJoint = new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
		handJoint.active = false;
		handJoint.space = space;
		handJoint.stiff = false;

		lastTime = Lib.getTimer();
		simTime = 0;
	}

	public function update(e:Event){
		// space.step(1/stage.frameRate);
		var dTime:Float = (Lib.getTimer() - lastTime)/1000.0;
		lastTime = Lib.getTimer();
		if(dTime > 0.05)
			dTime = 0.05;
		simTime += dTime;

		if(handJoint.active)
			handJoint.anchor1.setxy(mouseX, mouseY);

		while(space.elapsedTime < simTime)
			space.step(1/stage.frameRate);

		debug.clear();
		debug.draw(space);
		debug.flush();
	}

	public function onMouseDown(e:MouseEvent){
		var mPos:Vec2 = Vec2.get(mouseX, mouseY);
		for (body in space.bodiesUnderPoint(mPos)) {
			if(!body.isDynamic())
				continue;
			handJoint.body2 = body;
			handJoint.anchor2.set(body.worldPointToLocal(mPos, true));
			handJoint.active = true;
			break;
		}
		mPos.dispose();
	}

	public function onMouseUp(e:MouseEvent){
		handJoint.active = false;
	}

	public function onKeyDown(e:KeyboardEvent){
		if(e.keyCode == 82){
			space.clear();
			setup();
		}
	}
}