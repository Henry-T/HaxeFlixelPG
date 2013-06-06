package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import nme.display.BlendMode;
import nme.display.Bitmap;
import nme.display.Sprite;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;

class MenuState extends FlxState
{
    private var blender:FlxSprite;
    private var background:FlxSprite;
    private var maskBitmap:Bitmap;
    private var maskSprite:Sprite;
    
	override public function create():Void
	{
		FlxG.bgColor = 0xffffffff;

		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		FlxG.camera.bgColor = 0xff0000ff;

		var cameraWithEffect = new FlxCamera(0,-50,FlxG.width, FlxG.height);
		cameraWithEffect._flashSprite.blendMode = BlendMode.LAYER;
		cameraWithEffect._flashSprite.cacheAsBitmap = true;
		cameraWithEffect.bgColor = 0xff00ff00;
		FlxG.addCamera(cameraWithEffect);

		var cameras = new Array<FlxCamera>();
		cameras.push(cameraWithEffect);

		background = new FlxSprite(0, 0, "assets/img/bg.png");
		background.cameras = cameras;
		add(background);

		blender = new FlxSprite(0, 0, "assets/img/starburst.png");
		blender.blend = BlendMode.ALPHA;
		blender.cameras = cameras;
		add(blender);

		maskBitmap = new nme.display.Bitmap(blender.pixels);
		maskBitmap.blendMode = BlendMode.ALPHA;

		maskSprite = new Sprite();
		maskSprite.graphics.beginFill(0x000000, 1);
		maskSprite.graphics.drawCircle(0,0,40);
		maskSprite.graphics.endFill();

		cameraWithEffect._flashSprite.mask = maskSprite; 
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();

		blender.x = FlxG.mouse.x - blender.width/2;
		blender.y = FlxG.mouse.y - blender.height/2;
		maskBitmap.x = FlxG.mouse.x - maskBitmap.x/2;
		maskBitmap.y = FlxG.mouse.y - maskBitmap.y/2;
		maskSprite.x = FlxG.mouse.x - maskSprite.width;
		maskSprite.y = FlxG.mouse.y - maskSprite.height;
	}	

    override public function draw():Void {
		super.draw();
    }
}