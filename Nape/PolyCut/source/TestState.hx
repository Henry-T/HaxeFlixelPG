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
	var ps:FlxPhysSprite;
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
		
		ps = new FlxPhysSprite(100, 100);
		ps.makeGraphic(200, 200, 0);
		ps.createRectangularBody(200, 200, BodyType.DYNAMIC);
		ps.body.position = new Vec2(300, 100);
		ps.body.userData.flxSprite = ps;
		ps.body.setShapeMaterials(Material.ice());
		add(ps);
		
		var orgImg:Sprite = new Sprite();
		orgImg.x = ps.body.position.x;
		orgImg.y = ps.body.position.y;
		orgImg.graphics.beginBitmapFill(Assets.getBitmapData("assets/200.png"),
			new Matrix(1,0,0,1,100, 100));
		orgImg.graphics.drawRect( -100, -100, 200, 200);
		orgImg.graphics.endFill();
		ps.body.userData.flaSprite = orgImg;
		FlxG.stage.addChild(orgImg);
		
		drawing = false;
	}
	
	private var sP:FlxPoint;
	private var eP:FlxPoint;
	private var drawing:Bool;
	override public function update():Void
	{
		super.update();
		
		if (FlxG.mouse.justPressed() && !drawing) {
			drawing = true;
			sP = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
		}
		if (FlxG.mouse.justReleased() && drawing) {
			drawing = false;
			eP = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			
			// Do Cut
			var sPv2:Vec2 = Vec2.get(sP.x, sP.y);
			var ePv2:Vec2 = Vec2.get(eP.x, eP.y);
			var ray:Ray = Ray.fromSegment(sPv2, ePv2);	// NOTE 使用new Ray()+限制长度的方法结果有点奇怪，看起来重心以下的部分都切不开，没深究
			var rayResultList:RayResultList = FlxPhysState.space.rayMultiCast(ray, false);
			rayResultList.foreach(function (rayResult:RayResult):Void {
				if (rayResult.shape.body.type != BodyType.STATIC)
				{
					var geomPoly:GeomPoly = new GeomPoly(rayResult.shape.castPolygon.worldVerts);
					var geomPolyList:GeomPolyList = geomPoly.cut(sPv2, ePv2, true, true);
					// 如果一个Shape被Ray穿过但未贯穿，它同样会出现在这个列表中，这时候不需要重新创建
					if (geomPolyList.length > 1) {
						// shortcut objects
						var phyS:FlxPhysSprite = cast(rayResult.shape.body.userData.flxSprite, FlxPhysSprite);
						var flaSprite:Sprite = rayResult.shape.body.userData.flaSprite;
						geomPolyList.foreach(function(cutGeomPoly:GeomPoly) {	
							// Make a new body in world space
							var cutPoly:Polygon = new Polygon(cutGeomPoly);
							var cutBody:Body = new Body(BodyType.DYNAMIC);
							cutBody.setShapeMaterials(Material.ice());
							cutBody.shapes.add(cutPoly);
							cutBody.align();
							
							var deltaCOM:Vec2 = Vec2.weak(cutBody.worldCOM.x - phyS.body.worldCOM.x, cutBody.worldCOM.y-phyS.body.worldCOM.y);
							
							var sprite:Sprite = new Sprite();
							sprite.x = cutBody.position.x;//cutBody.worldCOM.x;
							sprite.y = cutBody.position.y;//cutBody.worldCOM.y;
							//sprite.graphics.beginFill(0xffff00, 0.5);
							var bmp:BitmapData = new BitmapData(Math.ceil(flaSprite.width), Math.ceil(flaSprite.height), true, 0);
							bmp.draw(flaSprite,
								new Matrix(1, 0, 0, 1,
									flaSprite.x - flaSprite.getBounds(FlxG.stage).left,
									flaSprite.y - flaSprite.getBounds(FlxG.stage).top));
							sprite.graphics.beginBitmapFill(bmp,
								new Matrix(1, 0, 0, 1,
									flaSprite.getBounds(FlxG.stage).left - flaSprite.x - deltaCOM.x, 
									flaSprite.getBounds(FlxG.stage).top - flaSprite.y - deltaCOM.y));
							
							var id:Int = 0;
							// trace("poly pos: " + poly.localCOM); // NOTE 似乎是切块相对未切割时质心的位置
							cutPoly.localVerts.foreach(function(vert:Vec2) {
								if (id == 0)
									sprite.graphics.moveTo(vert.x, vert.y);
								else
									sprite.graphics.lineTo(vert.x, vert.y);
								id++;
							});
							sprite.graphics.endFill();
							FlxG.stage.addChild(sprite);
							cutBody.userData.flaSprite = sprite;
							
							var fps:FlxPhysSprite = new FlxPhysSprite(0, 0, null, false);
							fps.body = cutBody;
							//fps.makeGraphic(Math.floor(sprite.width), Math.floor(sprite.height), 0x88ff0000);
							fps.makeGraphic(FlxG.width, FlxG.height, 0x00ff0000);
							//fps.pixels.draw(sprite, new Matrix(1,0,0,1,-phyS.body.worldCOM.x, -phyS.body.worldCOM.y));
							
							//fps.body.position.set(rayResult.shape.body.worldCOM);
							fps.body.space = FlxPhysState.space;
							fps.body.userData.flxSprite = fps;
							fps.offset.make( -fps.body.localCOM.x, -fps.body.localCOM.y);
							//fps.origin.make(sprite.width/2-fps.body.localCOM.x, sprite.width/2-fps.body.localCOM.y);
							add(fps);
						} );
						// Clean Up the Old Body
						if(flaSprite != null)
							FlxG.stage.removeChild(flaSprite);
						phyS.destroyPhysObjects();
						remove(phyS);
					}
				}
				sPv2.dispose();
				ePv2.dispose();
			});	
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