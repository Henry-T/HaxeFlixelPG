package;

import flash.geom.Point;
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
	
	override public function create():Void
	{
		FlxG.bgColor = 0xff131c1b;
		FlxG.mouse.show();
		
		super.create();
		
		drawing = false;
		createWalls();
		FlxPhysState.space.gravity.setxy(0, 300);
		
		ps = new FlxPhysSprite(100, 100);
		ps.makeGraphic(200, 200, 0);
		ps.createRectangularBody(200, 200, BodyType.DYNAMIC);
		ps.body.position = new Vec2(300, 100);
		ps.body.userData.flxSprite = ps;
		ps.body.setShapeMaterials(Material.ice());
		add(ps); 
		trace("Org Pos: " + ps.body.position);
		trace("Org Wrd: "+ps.body.worldCOM);
		trace("Org Loc: "+ps.body.localCOM);
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
			
			// Do Cut ...
			trace("S: " + sP.x + " " + sP.y);
			trace("E:" + eP.x + " " + eP.y);
			var sPv2:Vec2 = Vec2.fromPoint(sP.copyToFlash(new Point()));
			var ePv2:Vec2 = Vec2.fromPoint(eP.copyToFlash(new Point()));
			var ray:Ray = Ray.fromSegment(sPv2, ePv2);	// NOTE 使用new Ray()+限制长度的方法结果有点奇怪，看起来重心以下的部分都切不开，没深究
			var rayResultList:RayResultList = FlxPhysState.space.rayMultiCast(ray, false);
			rayResultList.foreach(function (rayResult:RayResult):Void {
				if (rayResult.shape.body.type != BodyType.STATIC)
				{
					var geomPoly:GeomPoly = new GeomPoly(rayResult.shape.castPolygon.worldVerts);
					var geomPolyList:GeomPolyList = geomPoly.cut(sPv2, ePv2, true, true);
					if (geomPolyList.length > 1) {
						// 如果一个Shape被Ray穿过但未贯穿，它同样会出现在这个列表中，这时候不需要重新创建
						geomPolyList.foreach(function(subGeomPoly:GeomPoly) { 
							var poly:Polygon = new Polygon(subGeomPoly);
							var sprite:Sprite = new Sprite();
							sprite.graphics.beginFill(0xffff00, 0.3);
							var id:Int = 0;
							// trace("poly pos: " + poly.localCOM); // NOTE 似乎是切块相对未切割时质心的位置
							poly.localVerts.foreach(function(vert:Vec2) {
								//trace(vert.x + ":" + vert.y);
								if (id == 0)
									sprite.graphics.moveTo(vert.x, vert.y);
								else
									sprite.graphics.lineTo(vert.x, vert.y);
								id++;
							} );
							sprite.graphics.endFill();
							
							var fps:FlxPhysSprite = new FlxPhysSprite(sprite.x, sprite.y, null, false);
							fps.makeGraphic(Math.floor(sprite.width), Math.floor(sprite.height), 0);
							//fps.pixels.draw(sprite);
							fps.body = new Body(BodyType.DYNAMIC);
							fps.body.setShapeMaterials(Material.ice());
							fps.body.shapes.add(poly);
							//fps.body.position.set(rayResult.shape.body.worldCOM);
							fps.body.space = FlxPhysState.space;
							fps.body.userData.flxSprite = fps;
							add(fps);
						} );
						var phyS:FlxPhysSprite = cast(rayResult.shape.body.userData.flxSprite, FlxPhysSprite);
						phyS.destroyPhysObjects();
						remove(phyS);
					}
				}
			});			
		}
	}
	
	override public function draw():Void 
	{
		super.draw();
		
		
	}
}