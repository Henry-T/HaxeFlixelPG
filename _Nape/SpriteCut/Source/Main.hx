package;

import haxe.remoting.AsyncDebugConnection;
import openfl.Assets;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.RayResultList;
import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.geom.Geom;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Vec2;
import nape.shape.Polygon;
import nape.util.Debug;
import nape.util.BitmapDebug;

class Main extends Sprite {
	var space:Space;
	var debug:Debug;
	var simTime:Float;
	var lastTime:Float;
	var drawing:Bool;
	var sP:Point;
	var eP:Point;
	
	public function new () {
		super ();
		if (stage != null)
			init(null);
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):Void 
	{
		if(e != null)
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
		space = new Space(Vec2.weak(0, 600));
		debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xff333333);
		debug.drawConstraints = true;
		debug.drawBodyDetail = true;
		debug.drawShapeDetail = true;
		debug.drawShapeAngleIndicators = false;
		stage.addChild(debug.display);
		
		setup();
			
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function setup() {
		var w = stage.stageWidth;
		var h = stage.stageHeight;
		var floor:Body = new Body(BodyType.STATIC);
		floor.shapes.add(new Polygon(Polygon.rect(50, h - 50, w - 100, 1)));
		floor.space = space;
		
		var cube:Body = new Body(BodyType.DYNAMIC);
		cube.setShapeMaterials(Material.steel());
		cube.shapes.add(new Polygon(Polygon.box(200, 200)));
		cube.position.setxy(500, 300);
		cube.space = space;
		
		var spr:Sprite = new Sprite();
		spr.x = cube.position.x;
		spr.y = cube.position.y;
		spr.graphics.beginFill(0xffff00, 0.5);
		spr.graphics.drawRect( -100, -100, 200, 200);
		spr.graphics.endFill();
		cube.userData.sprite = spr;
		stage.addChild(spr);
		
		drawing = false;
	}
	
	private function update(e:Event):Void 
	{
		// Match flash sprite to corresponding body
		for(liveBody in space.liveBodies){
			var flaSprite = liveBody.userData.sprite;
			flaSprite.x = liveBody.position.x;
			flaSprite.y = liveBody.position.y;
			flaSprite.rotation = liveBody.rotation * 180/Math.PI % 360;
		}
		
		space.step(1/stage.frameRate);
		
		debug.clear();
		debug.draw(space);
		debug.flush();
	}
	
	private function onMouseUp(e:MouseEvent):Void 
	{
		drawing = false;
		eP = new Point(mouseX, mouseY);
		
		// Do Cut
		var sPv2:Vec2 = Vec2.get(sP.x, sP.y);
		var ePv2:Vec2 = Vec2.get(eP.x, eP.y);
		var ray:Ray = Ray.fromSegment(sPv2, ePv2);
		if (ray.maxDistance < 1) return;
		var rayResultList:RayResultList = space.rayMultiCast(ray, false);
		for ( rayResult in rayResultList) {
			var orgPoly:Polygon = rayResult.shape.castPolygon;
			var orgBody:Body = orgPoly.body;
			var orgSpr:Sprite = orgBody.userData.sprite;
			if (orgBody.isStatic())	return;
			var geomPoly:GeomPoly = new GeomPoly(rayResult.shape.castPolygon.worldVerts);
			var geomPolyList:GeomPolyList = geomPoly.cut(sPv2, ePv2, true, true);
			if (geomPolyList.length <= 1)	return;
			
			for (cutGeomPoly in geomPolyList) {
				// Make a new body in world space
				var cutPoly:Polygon = new Polygon(cutGeomPoly);
				var cutBody:Body = new Body(BodyType.DYNAMIC);
				cutBody.setShapeMaterials(Material.steel());
				cutBody.shapes.add(cutPoly);
				cutBody.align();
				cutBody.space = space;
				
				var sprite:Sprite = new Sprite();
				sprite.x = cutBody.position.x;
				sprite.y = cutBody.position.y;
				sprite.graphics.beginFill(0xffff00, 0.5);
				var id:Int = 0;
				var d:Vec2 = Vec2.weak(
					(cutBody.bounds.x + cutBody.bounds.width) / 2 - cutBody.worldCOM.x,
					(cutBody.bounds.y + cutBody.bounds.height) / 2 - cutBody.worldCOM.y);
				cutPoly.localVerts.foreach(function(vert:Vec2) {
					if (id == 0)
						sprite.graphics.moveTo(vert.x, vert.y);
					else
						sprite.graphics.lineTo(vert.x, vert.y);
					id++;
				});
				sprite.graphics.endFill();
				stage.addChild(sprite);
				cutBody.userData.sprite = sprite;
			}
			// Remove the cutted one
			stage.removeChild(orgSpr);
			orgBody.space = null;
		}
		sPv2.dispose();
		ePv2.dispose();
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		drawing = true;
		sP = new Point(mouseX, mouseY);
	}
}