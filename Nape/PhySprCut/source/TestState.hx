package;

import flash.geom.Point;
import flash.ui.Mouse;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.RayResultList;
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
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxAngle;

import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.geom.Geom;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Vec2;
import nape.shape.Polygon;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;

class TestState extends FlxPhysState
{
	var space:Space;
	
	override public function create():Void
	{
		FlxG.bgColor = 0xff131c1b;
		Mouse.show();
		super.create();
		space = FlxPhysState.space;
		disablePhysDebug();
		
		createWalls();
		FlxPhysState.space.gravity.setxy(0, 600);
		
		var phySpr = new FlxPhysSprite(100, 100, "assets/200.png", false);
		phySpr.createRectangularBody(200, 200, BodyType.DYNAMIC);
		phySpr.body.position = new Vec2(300, 100);
		phySpr.body.userData.flxSprite = phySpr;
		phySpr.body.setShapeMaterials(Material.steel());
		add(phySpr);
		
		//var orgImg:Sprite = new Sprite();
		//orgImg.x = phySpr.body.position.x;
		//orgImg.y = phySpr.body.position.y;
		//orgImg.graphics.beginBitmapFill(Assets.getBitmapData("assets/200.png"),
			//new Matrix(1,0,0,1,100, 100));
		//orgImg.graphics.drawRect( -100, -100, 200, 200);
		//orgImg.graphics.endFill();
		//phySpr.body.userData.flaSprite = orgImg;
		//FlxG.stage.addChild(orgImg);
		
		drawing = false;
		check = 0;
	}
	
	private var sP:Vec2;
	private var eP:Vec2;
	private var drawing:Bool;
	private var check:Int;
	override public function update():Void
	{
		super.update();
		
		if (FlxG.mouse.justPressed()) {
			drawing = true;
			sP = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
		}
		if (FlxG.mouse.justReleased()) {
			drawing = false;
			eP = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
			
			// Do Cut
			var ray:Ray = Ray.fromSegment(sP, eP);	// NOTE 使用new Ray()+限制长度的方法结果有点奇怪，看起来重心以下的部分都切不开，没深究
			if (ray.maxDistance < 1)	return;	// NOTE !! 这里还是用{}比较好
			var rayResultList:RayResultList = FlxPhysState.space.rayMultiCast(ray, false);
			for (rayResult in rayResultList) {
				var orgBody:Body = rayResult.shape.body;
				var orgPoly:Polygon = rayResult.shape.castPolygon;
				var orgPhySpr:FlxPhysSprite = orgBody.userData.flxSprite;
				if (orgBody.isStatic())	continue;
				var geomPoly:GeomPoly = new GeomPoly(orgPoly.worldVerts);
				var geomPolyList:GeomPolyList = geomPoly.cut(sP, eP, true, true);
				if (geomPolyList.length <= 1) continue;
			
				geomPolyList.foreach(function(cutGeomPoly:GeomPoly) {	
					// Make a new body in world space
					var cutPoly:Polygon = new Polygon(cutGeomPoly);
					var cutBody:Body = new Body(BodyType.DYNAMIC);
					cutBody.setShapeMaterials(Material.steel());
					cutBody.shapes.add(cutPoly);
					cutBody.align();
					cutBody.space = FlxPhysState.space;
					
					var deltaCOM:Vec2 = Vec2.weak(cutBody.worldCOM.x - orgBody.worldCOM.x, cutBody.worldCOM.y-orgBody.worldCOM.y);
					
					var sprite:Sprite = new Sprite();
					sprite.x = cutBody.position.x;
					sprite.y = cutBody.position.y;
					
					var bmp:BitmapData = new BitmapData(Math.ceil(orgBody.bounds.width), Math.ceil(orgBody.bounds.height), true, 0xff333333);
					var mat:Matrix = new Matrix();
					//mat.translate(orgBody.bounds.x-orgBody.position.x, orgBody.bounds.y-orgBody.position.y);
					mat.translate(-orgPhySpr.origin.x, -orgPhySpr.origin.y);	// upper line goes wrong because the bound before rotation is needed !
					mat.rotate(orgPhySpr.angle * Math.PI/180 % 360);	// Right Here
					mat.translate(orgBody.position.x - orgBody.bounds.x, orgBody.position.y - orgBody.bounds.y);
					bmp.draw(orgPhySpr.pixels, mat);
					var bmpp:Bitmap = new Bitmap(bmp);
					bmpp.x = 200 * (check % 4);
					bmpp.y = 200 * Math.floor(check / 4);
					check++;
					//FlxG.stage.addChild(bmpp);	// Bitmap render result triple checked !
					
					sprite.graphics.beginBitmapFill(bmp,
						new Matrix(1, 0, 0, 1,
							orgBody.bounds.x - cutBody.position.x, 
							orgBody.bounds.y - cutBody.position.y));
					for (i in 0...cutPoly.localVerts.length)
					{
						var vert:Vec2 = cutPoly.localVerts.at(i);
						if (i == 0)
							sprite.graphics.moveTo(vert.x, vert.y);
						else
							sprite.graphics.lineTo(vert.x, vert.y);
					}
					sprite.graphics.endFill();
					//FlxG.stage.addChild(sprite);	// Sprite render result triple checked !
					
					var cutPhySpr:FlxPhysSprite = new FlxPhysSprite(cutBody.worldCOM.x, cutBody.worldCOM.y, null, false);
					cutPhySpr.body = cutBody;
					cutPhySpr.makeGraphic(Math.floor(cutBody.bounds.width), Math.floor(cutBody.bounds.height), 0x00ff0000, true); // force the bitmap to be unique! 
					cutPhySpr.pixels.draw(sprite, new Matrix(1, 0, 0, 1, cutBody.worldCOM.x - cutBody.bounds.x, cutBody.worldCOM.y - cutBody.bounds.y));
					//cutPhySpr.centerOffsets(false); // NOTE ???
					cutPhySpr.origin.make(cutBody.worldCOM.x-cutBody.bounds.x, cutBody.worldCOM.y-cutBody.bounds.y);
					add(cutPhySpr);
					
					cutBody.userData.flxSprite = cutPhySpr;
					cutBody.userData.flaSprite = sprite;
				} );
				if(orgPhySpr != null){
					orgPhySpr.destroy();
					remove(orgPhySpr);
				}
				if (orgBody.userData.flaSprite != null && orgBody.userData.flaSprite.stage==FlxG.stage)
					FlxG.stage.removeChild(orgBody.userData.flaSprite);
			}
			sP.dispose();
			eP.dispose();
		}
		// Match flash sprite to corresponding body
		for(liveBody in space.liveBodies){
			var flaSprite = liveBody.userData.flaSprite;
			if(flaSprite != null){
				flaSprite.x = liveBody.position.x;
				flaSprite.y = liveBody.position.y;
				flaSprite.rotation = liveBody.rotation * FlxAngle.DEG % 360;
			}
		}
	}
	
	override public function draw():Void 
	{
		super.draw();
	}
}