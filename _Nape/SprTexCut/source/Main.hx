package;
import flash.geom.Point;
import openfl.Assets;
import flash.Lib;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.geom.Matrix;

import nape.space.Space;
import nape.shape.Polygon;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.geom.Vec2;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.RayResultList;
import nape.util.BitmapDebug;
import nape.util.Debug;

class Main extends Sprite 
{
	var space:Space;
	var debug:Debug;
	var simTime:Float;
	var lastTime:Float;
	
	var drawing:Bool;
	var sP:Point;
	var eP:Point;
	
	public function new () 
	{
		super();
		if (stage != null) 
			init();
		else 
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(?e:Event = null):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
		space = new Space(Vec2.weak(0, 600));
		debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xff333333);
		debug.drawConstraints = true;
		debug.drawBodyDetail = true;
		debug.drawShapeDetail = true;
		debug.drawShapeAngleIndicators = false;
		stage.addChild(debug.display);
		
		setup();
			
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUP);
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
		spr.graphics.beginBitmapFill(Assets.getBitmapData("assets/200.png"),
			new Matrix(1, 0, 0, 1, 100, 100));
		spr.graphics.drawRect( -100, -100, 200, 200);
		spr.graphics.endFill();
		cube.userData.sprite = spr;
		stage.addChild(spr);
		
		drawing = false;
		lastTime = Lib.getTimer();
		simTime = 0;
	}
	
	private function update(e:Event):Void 
	{
		var deltaT:Float = (Lib.getTimer() - lastTime) / 1000.0;
		lastTime = Lib.getTimer();
		deltaT = deltaT > 0.05?0.05:deltaT;
		simTime += deltaT;
		
		while (space.elapsedTime < simTime)
			space.step(1 / stage.frameRate);
		
		// Match flash sprite to corresponding body
		for(liveBody in space.liveBodies){
			var flaSprite = liveBody.userData.sprite;
			flaSprite.x = liveBody.position.x;
			flaSprite.y = liveBody.position.y;
			flaSprite.rotation = 180/Math.PI * liveBody.rotation % 360;
		}
		
		debug.clear();
		debug.draw(space);
		debug.flush();
	}
	
	private function onMouseUp(e:MouseEvent):Void 
	{
		drawing = false;
		eP = new Point(mouseX, mouseY);
		
		var sPv2:Vec2 = Vec2.get(sP.x, sP.y);
		var ePv2:Vec2 = Vec2.get(eP.x, eP.y);
		var ray:Ray = Ray.fromSegment(sPv2, ePv2);	// NOTE 使用new Ray()+限制长度的方法结果有点奇怪，看起来重心以下的部分都切不开，没深究
		if (ray.maxDistance < 5) return;
		
		var rayResultList:RayResultList = space.rayMultiCast(ray, false);
		for(rayResult in rayResultList) {
			var orgBody:Body = rayResult.shape.body;
			var orgSpr:Sprite = orgBody.userData.sprite;
			var orgPoly:Polygon = rayResult.shape.castPolygon;
			if (orgBody.isStatic()) continue;
			var geomPolyList:GeomPolyList = new GeomPoly(orgPoly.worldVerts).cut(sPv2, ePv2, true, true);
			// 如果一个Shape被Ray穿过但未贯穿，它同样会出现在这个列表中，这时候不需要重新创建
			if (geomPolyList.length <= 1) continue;
			
			for (cutGeomPoly in geomPolyList) 
			{
				// Make a new body in world space
				var cutPoly:Polygon = new Polygon(cutGeomPoly);
				var cutBody:Body = new Body(BodyType.DYNAMIC);
				cutBody.setShapeMaterials(Material.steel());
				cutBody.shapes.add(cutPoly);
				cutBody.align();
				cutBody.space = space;
				
				var deltaCOM:Vec2 = Vec2.weak(cutBody.worldCOM.x - orgBody.worldCOM.x, cutBody.worldCOM.y-orgBody.worldCOM.y);
				
				var cutSpr:Sprite = new Sprite();
				cutSpr.x = cutBody.position.x;
				cutSpr.y = cutBody.position.y;
				var bmp:BitmapData = new BitmapData(Math.ceil(orgSpr.width), Math.ceil(orgSpr.height), true, 0);
				bmp.draw(orgSpr,
					new Matrix(1, 0, 0, 1,
						orgSpr.x - orgSpr.getBounds(stage).left,
						orgSpr.y - orgSpr.getBounds(stage).top));
				cutSpr.graphics.beginBitmapFill(bmp,
					new Matrix(1, 0, 0, 1,
						orgSpr.getBounds(stage).left - orgSpr.x - deltaCOM.x, 
						orgSpr.getBounds(stage).top - orgSpr.y - deltaCOM.y));
				for(i in 0...cutPoly.localVerts.length)
				{
					var vert:Vec2 = cutPoly.localVerts.at(i);
					if (i == 0)
						cutSpr.graphics.moveTo(vert.x, vert.y);
					else
						cutSpr.graphics.lineTo(vert.x, vert.y);
				}
				cutSpr.graphics.endFill();
				stage.addChild(cutSpr);
				cutBody.userData.sprite = cutSpr;
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
	
	private function onKeyUP(e:KeyboardEvent):Void 
	{
		if (e.keyCode == 86)
		{
			space.clear();
			setup();
		}
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Main());
	}
}