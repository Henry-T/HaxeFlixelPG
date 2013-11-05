package;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.geom.Point;
import flash.Lib;

import nape.geom.Vec2;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
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
	private var outLine:Sprite;
	public var space:Space;
	private var points:Array<Point>;
	private var body:Body;

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

		points = new Array<Point>();

		space = new Space(Vec2.weak(0, 0));

		debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xffffffff);
		debug.drawConstraints = false;
		debug.drawShapeDetail = false;
		debug.drawBodyDetail = false;
		debug.drawShapeAngleIndicators = false;
		stage.addChild(debug.display);

		outLine = new Sprite();
		stage.addChild(outLine);

		stage.addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function update(e:Event){
		space.step(1/stage.frameRate);

		debug.clear();
		debug.draw(space);
		debug.flush();
	}

	public function onMouseDown(e:MouseEvent){
		points.push(new Point(mouseX, mouseY));
		// redraw out-line
		outLine.graphics.clear();
		outLine.graphics.lineStyle(4, 0xff0000, 1);
		for (i in 0...points.length) {
			if(i == 0)
				outLine.graphics.moveTo(points[i].x, points[i].y);
			else
				outLine.graphics.lineTo(points[i].x, points[i].y);
		}
	}

	public function onKeyDown(e:KeyboardEvent){
		if(e.keyCode == 67){	// c
			body = new Body(BodyType.DYNAMIC);
			body.space = space;
			var vec2Ary:Array<Vec2> = [];
			for (p in points) {
				vec2Ary.push(Vec2.weak(p.x, p.y));
			}

			var gPoly:GeomPoly = new GeomPoly(vec2Ary);
			var gPolyList:GeomPolyList = gPoly.convexDecomposition();
			for (gp in gPolyList) {
				body.shapes.add(new Polygon(gp));
			}
			
			outLine.visible = false;
		}
	}
}