package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

class Trail extends FlxSprite
{
	public var canvas:Sprite;
	public var canvasBD:BitmapData;
	public var target:FlxSprite;
	public var smooth:Bool;

	private var lastPos:Point;
	private var thisPos:Point;

	public function new(Target:FlxSprite){
		super(0,0,null);
		makeGraphic(FlxG.width, FlxG.height, 0x0);
		canvasBD = framePixels;
		target = Target;
		canvas = new Sprite();
		smooth = true;

		lastPos = new Point();
		thisPos = new Point();
	}

	override public function update(){
		super.update();
	}
}