package;

import flash.ui.Mouse;
import openfl.Assets;
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
		FlxG.mouse.show();
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
	}
	
	private var sP:Vec2;
	private var eP:Vec2;
	override public function update():Void
	{
		super.update();
		if (FlxG.mouse.justPressed()) {
			sP = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
		}
		if (FlxG.mouse.justReleased()) {
			eP = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
			
			// Do Cut
			var ray:Ray = Ray.fromSegment(sP, eP);
			if (ray.maxDistance > 5){
				var rayResultList:RayResultList = FlxPhysState.space.rayMultiCast(ray, false);
				for (rayResult in rayResultList) {
					var orgBody:Body = rayResult.shape.body;
					var orgPoly:Polygon = rayResult.shape.castPolygon;
					var orgPhySpr:FlxPhysSprite = orgBody.userData.flxSprite;
					if (orgBody.isStatic())	continue;
					var geomPoly:GeomPoly = new GeomPoly(orgPoly.worldVerts);
					var geomPolyList:GeomPolyList = geomPoly.cut(sP, eP, true, true);
					if (geomPolyList.length <= 1) continue;
					
					for (cutGeomPoly in geomPolyList){ 	
						// Make a new body in world space
						var cutPoly:Polygon = new Polygon(cutGeomPoly);
						var cutBody:Body = new Body(BodyType.DYNAMIC);
						cutBody.setShapeMaterials(Material.steel());
						cutBody.shapes.add(cutPoly);
						cutBody.align();
						cutBody.space = FlxPhysState.space;
						
						var bmp:BitmapData = new BitmapData(Math.ceil(orgBody.bounds.width), Math.ceil(orgBody.bounds.height), true, 0x0);
						var mat:Matrix = new Matrix();
						mat.translate(-orgPhySpr.origin.x, -orgPhySpr.origin.y);
						mat.rotate(orgPhySpr.angle * Math.PI/180 % 360);
						mat.translate(orgBody.position.x - orgBody.bounds.x, orgBody.position.y - orgBody.bounds.y);
						bmp.draw(orgPhySpr.pixels, mat);
						
						var sprite:Sprite = new Sprite();
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
						
						var cutPhySpr:FlxPhysSprite = new FlxPhysSprite(0, 0, null, false);
						cutPhySpr.body = cutBody;
						// force the bitmap to be unique! or same sized bmp will share one instance
						cutPhySpr.makeGraphic(Math.ceil(cutBody.bounds.width), Math.ceil(cutBody.bounds.height), 0x00ff0000, true);
						cutPhySpr.pixels.draw(sprite, new Matrix(1, 0, 0, 1, cutBody.worldCOM.x - cutBody.bounds.x, cutBody.worldCOM.y - cutBody.bounds.y));
						cutPhySpr.origin.make(cutBody.worldCOM.x - cutBody.bounds.x, cutBody.worldCOM.y - cutBody.bounds.y);
						cutPhySpr.move(cutBody.worldCOM.x - cutPhySpr.origin.x, cutBody.worldCOM.y - cutPhySpr.origin.y);
						cutPhySpr.angle = cutBody.rotation * 180 / Math.PI;
						add(cutPhySpr);
						
						cutBody.userData.flxSprite = cutPhySpr;
					}
					if(orgPhySpr != null){
						orgPhySpr.destroy();
						remove(orgPhySpr);
					}
				}
				sP.dispose();
				eP.dispose();
			}
		}
	}
}