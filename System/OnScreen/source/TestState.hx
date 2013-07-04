package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxPath;
import flixel.FlxSave;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.MultiVarTween;

class TestState extends FlxState
{
	// UI Global
	private var _lbState:FlxText;
	private var _btnReset:FlxButton;
	//private var _sg

	// UI Object Control
	private var _lbObject:FlxText;
	private var _lbObjSpeedX:FlxText;
	private var _lbObjSpeedY:FlxText;
	private var _lbObjAngleX:FlxText;
	private var _lbObjScaleX:FlxText;
	private var _lbObjScaleY:FlxText;
	private var _btnSpeedXUp:FlxButton;
	private var _btnSpeedXDown:FlxButton;
	private var _btnSpeedYUo:FlxButton;
	private var _btnSpeedYDown:FlxButton;
	private var _btnSpeedReset:FlxButton;

	// UI Camera Control
	private var _lbCamera:FlxText;
	private var _lbCamZoom:FlxText;
	private var _lbCamScrollFactorX:FlxText;
	private var _lbCamScrollFactorY:FlxText;
	private var _lbCamScrollX:FlxText;
	private var _lbCamScrollY:FlxText;
	private var _btnCamZoomUp:FlxButton;
	private var _btnCamZoomDown:FlxButton;
	private var _btnCamScrollXUp:FlxText;
	private var _btnCamScrollXDown:FlxText;
	private var _btnCamScrollYUp:FlxText;
	private var _btnCamScrollYDown:FlxText;

	// Cameras
	private var _camUI:FlxCamera;
	private var _camUIAry:Array<FlxCamera>;
	private var _camScene:FlxCamera;
	private var _camSceneAry:Array<FlxCamera>;

	private var _object:FlxSprite;
	private var _refObject:FlxSprite;

	public static var Cam_Margin:Int = 100;

	private var _scaleTween:MultiVarTween;

	override public function create():Void
	{
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		super.create();

		// Initialize Cameras
		_camUI = new FlxCamera(0,0,FlxG.width,FlxG.height, 1);
		_camUIAry = [_camUI];
		_camUI.bgColor = 0xff131c1b;
		FlxG.cameras.reset(_camUI);

		_camScene = new FlxCamera(Cam_Margin, Cam_Margin, FlxG.width-2*Cam_Margin, FlxG.height-2*Cam_Margin);
		_camSceneAry = [_camScene];
		_camScene.scroll.make(100,100);
		_camScene.bgColor = 0xffb4ffb0;
		FlxG.cameras.add(_camScene);

		// Initialize GUI
		_lbState = createUIText(10, 40, "----");
		add(_lbState);

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

		// Test Case
		_object.offset.make(50,50);
		_refObject.offset.make(50,50);

		_object.velocity.x = 150;
		_object.velocity.y = 100;
		_refObject.velocity.x = 150;
		_refObject.velocity.y = 100;

		// _object.scale.make(0.5, 0.5);
		// _refObject.scale.make(0.5, 0.5);

		// _object.angularVelocity = 200;
		// _refObject.angularVelocity = 200;

		_scaleTween = new MultiVarTween(null, FlxTween.PINGPONG);
		var props:Dynamic = {};
		props.x = 2.0;
		props.y = 2.0;
		_scaleTween.tween(_object.scale, props , 1);
		//addTween(_scaleTween);
	}
	
	override public function update():Void
	{
		super.update();
		trace(_object.x);

		if(_object.onScreen(_camScene))
			_lbState.text = "In Camera";
		else
			_lbState.text = "Out of Camera";

		// Simple bounce
		if(_object.x <= 0 || _object.x+_object.width>=FlxG.width)
			_object.velocity.x = -_object.velocity.x;
		if(_object.y <=0 || _object.y+_object.height>=FlxG.height)
			_object.velocity.y = -_object.velocity.y;


		if(_refObject.x <= 0 || _refObject.x+_refObject.width>=FlxG.width)
			_refObject.velocity.x = -_refObject.velocity.x;
		if(_refObject.y <=0 || _refObject.y+_refObject.height>=FlxG.height)
			_refObject.velocity.y = -_refObject.velocity.y;
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
}