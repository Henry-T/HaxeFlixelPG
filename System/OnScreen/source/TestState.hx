package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.util.FlxPath;
import flixel.util.FlxSave;
import flixel.util.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.MultiVarTween;

class TestState extends FlxState
{
	// UI
	private var _lbState:FlxText;
	private var _lbObject:FlxText;
	private var _lbObjSpeedX:FlxText;
	private var _lbObjSpeedY:FlxText;
	private var _lbObjAngleSpeed:FlxText;
	private var _lbObjScaleX:FlxText;
	private var _lbObjScaleY:FlxText;
	private var _lbObjOffsetX:FlxText;
	private var _lbObjOffsetY:FlxText;
	private var _lbObjOriginX:FlxText;
	private var _lbObjOriginY:FlxText;
	private var _btnGoOn:FlxButton;

	// Cameras
	private var _camUI:FlxCamera;
	private var _camUIAry:Array<FlxCamera>;
	private var _camScene:FlxCamera;
	private var _camSceneAry:Array<FlxCamera>;

	private var _object:FlxSprite;
	private var _refObject:FlxSprite;

	public static var Cam_Margin:Int = 100;

	private var _scaleTimer:Float;	

	override public function create():Void
	{
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		super.create();

		_camUI = new FlxCamera(0,0,FlxG.width,FlxG.height, 1);
		_camUIAry = [_camUI];
		_camUI.bgColor = 0xff131c1b;
		FlxG.cameras.reset(_camUI);

		_camScene = new FlxCamera(Cam_Margin, Cam_Margin, FlxG.width-2*Cam_Margin, FlxG.height-2*Cam_Margin);
		_camSceneAry = [_camScene];
		_camScene.scroll.make(100,100);
		//_camScene.zoom = 0.5;
		_camScene.bgColor = 0xffb4ffb0;
		FlxG.cameras.add(_camScene);

		_btnGoOn = createCtrlBtn(5,20, "Go On", function(btn:Dynamic=null){resume();});
		_lbState = createUIText(5, 40, "----");
		_lbObjOriginX = createUIText(5, 55, "Origin_X");
		_lbObjOriginY = createUIText(5, 70, "Origin_Y");
		_lbObjOffsetX = createUIText(5, 85, "Offset_X");
		_lbObjOffsetY = createUIText(5, 100, "Offset_Y");
		_lbObjSpeedX = createUIText(5, 115, "Speed_X");
		_lbObjSpeedY = createUIText(5, 130, "Speed_Y");
		_lbObjAngleSpeed = createUIText(5, 145, "AngleV");
		_lbObjScaleX = createUIText(5, 160, "Scale_X");
		_lbObjScaleY = createUIText(5, 175, "Scale_Y");


		// Add Test Object
		_object = new FlxSprite(100,100);
		// Render the object on both scene and ui camera so we can see clear
		_object.makeGraphic(100,50,0xff440088);
		_object.cameras = _camSceneAry;
		add(_object);

		// Add a reference object
		_refObject = new FlxSprite(100, 100);
		_refObject.makeGraphic(100, 50, 0xff228822);
		_refObject.cameras = _camUIAry;
		add(_refObject);

		add(_btnGoOn);
		add(_lbState);
		add(_lbObjOriginX);
		add(_lbObjOriginY);
		add(_lbObjOffsetX);
		add(_lbObjOffsetY);
		add(_lbObjSpeedX);
		add(_lbObjSpeedY);
		add(_lbObjAngleSpeed);
		add(_lbObjScaleX);
		add(_lbObjScaleY);

		// Test Case
		_object.offset.make(0,10);
		_refObject.offset.make(0,10);

		_object.velocity.x = 150;
		_object.velocity.y = 100;
		_refObject.velocity.x = 150;
		_refObject.velocity.y = 100;

		_object.scale.make(0.5, 0.5);
		_refObject.scale.make(0.5, 0.5);

		_object.angularVelocity = 200;
		_refObject.angularVelocity = 200;

		lastInCamera = true;
		_paused = false;
		_scaleTimer = 0;
	}
	
	private var lastInCamera:Bool;
	override public function update():Void
	{
		// Simple bounce
		if(_object.x <= 0 || _object.x+_object.width>=FlxG.width)
			_object.velocity.x = -_object.velocity.x;
		if(_object.y <=0 || _object.y+_object.height>=FlxG.height)
			_object.velocity.y = -_object.velocity.y;

		if(_refObject.x <= 0 || _refObject.x+_refObject.width>=FlxG.width)
			_refObject.velocity.x = -_refObject.velocity.x;
		if(_refObject.y <=0 || _refObject.y+_refObject.height>=FlxG.height)
			_refObject.velocity.y = -_refObject.velocity.y;

		if(!_paused){
			_scaleTimer += FlxG.elapsed;
			if(_scaleTimer > 2)
				_scaleTimer -= 2;
			var scale = getScaleByTime(_scaleTimer);
			_object.scale.make(scale, scale);
			_refObject.scale.make(scale, scale);
		}

		super.update();

		var inCam:Bool = _object.onScreen(_camScene);

		if(inCam)
			_lbState.text = "In Camera";
		else
			_lbState.text = "Out of Camera";

		if(lastInCamera != inCam)
			pause();
		lastInCamera = inCam;

		_lbObjOriginX.text = "Origin_X: " + _object.origin.x;
		_lbObjOriginY.text = "Origin_Y: " + _object.origin.y;
		_lbObjOffsetX.text = "Offset_X: " + _object.offset.x;
		_lbObjOffsetY.text = "Offset_Y: " + _object.offset.y;
		_lbObjSpeedX.text = "Speed_X: " + _object.velocity.x;
		_lbObjSpeedY.text = "Speed_Y: " + _object.velocity.y;
		_lbObjAngleSpeed.text = "AngleV: " + _object.angularVelocity;
		_lbObjScaleX.text = "Scale_X: " + Std.int(_object.scale.x*100) / 100;
		_lbObjScaleY.text = "Scale_Y: " + Std.int(_object.scale.y*100) / 100;
	}

	var _paused:Bool;
	var _speed:FlxPoint;
	var _rotSpeed:Float;
	private function pause():Void{
		_speed = new FlxPoint(_object.velocity.x, _object.velocity.y);
		_rotSpeed = _object.angularVelocity;
		_object.velocity.make(0,0);
		_refObject.velocity.make(0,0);
		_object.angularVelocity = 0;
		_refObject.angularVelocity = 0;
		_paused = true;
	}

	private function resume():Void{
		if(_paused){
			_paused = false;
			_object.velocity.make(_speed.x, _speed.y);
			_refObject.velocity.make(_speed.x, _speed.y);
			_object.angularVelocity = _rotSpeed;
			_refObject.angularVelocity = _rotSpeed;
		}
	}

	private function createUIText(X:Int, Y:Int, Text:String):FlxText{
		var text:FlxText = new FlxText(X,Y, 80, Text);
		text.cameras = _camUIAry;
		return text;
	}

	private function createCtrlBtn(X:Int, Y:Int, Txt:String, Callback:Dynamic->Void):FlxButton{
		var btn = new FlxButton(X,Y,Txt,Callback);
		btn.cameras = _camUIAry;
		return btn;
	}

	private function getScaleByTime(t:Float){
		if(t <= 1)
			return 1-t*0.5;
		else 
			return 0.5 * t;
	}
}