package;

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
import org.flixel.FlxGroup;
import org.flixel.FlxTypedGroup;
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRect;
import org.flixel.FlxObject;

class GameState extends FlxState
{
	public static var Mode_GamePadOnly:Int = 0;
	public static var Mode_AnalogToMove_GamePadToShoot:Int = 1;
	public static var Mode_AnalogToMove_Analog2ToShoot:Int = 2;
	public static var Mode_Count:Int = 3;

	public static var CurCtrlMode:Int = Mode_AnalogToMove_GamePadToShoot;

	public var controller:Controller;

	public var GameArea : FlxSprite;
	public var GameAreaRect : FlxRect;

	public var Ship : FlxSprite;
	public var ShipAim : Int;

	public var Bullets : FlxTypedGroup<FlxSprite>;

	public var txtChangeCtrl : FlxText;

	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff555544;
		#else
		FlxG.camera.bgColor = {rgb: 0x555544, a: 0xff};
		#end		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		controller = new Controller(CurCtrlMode);
		add(controller);

		GameAreaRect = new FlxRect(20, 20, FlxG.width - 40, FlxG.height - 140);
		GameArea = new FlxSprite(GameAreaRect.x, GameAreaRect.y);
		GameArea.makeGraphic(Std.int(GameAreaRect.width), Std.int(GameAreaRect.height), 0xff88ff34);
		add(GameArea);

		Ship = new FlxSprite(0,0, "assets/ship.png");
		Ship.x = FlxG.width * 0.5 - Ship.width * 0.5;
		Ship.y = FlxG.height * 0.5 - Ship.height * 0.5;
		ShipAim = 0;
		add(Ship);

		Bullets = new FlxTypedGroup<FlxSprite>();
		add(Bullets);

		txtChangeCtrl = new FlxText(0, 0, FlxG.width, "Click/Touch Here or Press Enter to Change Control");
		add(txtChangeCtrl);
	}
	
	override public function update():Void
	{
		super.update();

		// Force ship inside game area
		keepTheShip();

		// Change Control Mode
		// The device related code is just for the test, You won't need something like this in a real game
		#if !FLX_NO_KEYBOARD
		if(FlxG.keys.justPressed("ENTER"))
			ChangeControl();
		#end

		#if !FLX_NO_TOUCH
		for (touch in FlxG.touchManager.touches) {
			if(touch.justReleased() && touch.y < 20){
				ChangeControl();
				break;
			}
		}
		#end

		#if !FLX_NO_MOUSE
		if(FlxG.mouse.justReleased() && FlxG.mouse.y < 20)
			ChangeControl();
		#end

		// Update ship aim
		if(controller.Pressed_UP)
			ShipAim |= FlxObject.UP;
		else 
			ShipAim &= ~FlxObject.UP;

		if(controller.Pressed_DOWN)
			ShipAim |= FlxObject.DOWN;
		else 
			ShipAim &= ~FlxObject.DOWN;

		if(controller.Pressed_LEFT)
			ShipAim |= FlxObject.LEFT;
		else 
			ShipAim &= ~FlxObject.LEFT;

		if(controller.Pressed_RIGHT)
			ShipAim |= FlxObject.RIGHT;
		else 
			ShipAim &= ~FlxObject.RIGHT;

		// Update ship rotatiom
		if(ShipAim == FlxObject.UP | FlxObject.LEFT){
				Ship.angle = -135;
		} 
		else if(ShipAim == FlxObject.UP | FlxObject.RIGHT){
				Ship.angle = -45;
		} 
		else if(ShipAim == FlxObject.DOWN | FlxObject.LEFT){
				Ship.angle = 135;
		} 
		else if(ShipAim == FlxObject.DOWN | FlxObject.RIGHT){
				Ship.angle = 45;
		} 
		else if(ShipAim == FlxObject.UP){
				Ship.angle = -90;
		} 
		else if(ShipAim == FlxObject.DOWN){
				Ship.angle = 90;
		} 
		else if(ShipAim == FlxObject.LEFT){
				Ship.angle = 180;
		} 
		else if(ShipAim == FlxObject.RIGHT){
				Ship.angle = 0;
		}

		// Uncommit the lines to break the limit of 8-direction
		// You must have a left analog there
		//if(controller.analogL != null && controller.analogL.pressed())
		//	Ship.angle = controller.AnalogL_Angle;

		// Check shoot action
		if(controller.JustPressed_Action)
			shoot(0);
		else if(controller.JustReleased_Action)
			shoot(1);

		// Move the ship if any direction key down
		if(controller.Pressed_UP || controller.Pressed_DOWN || controller.Pressed_LEFT || controller.Pressed_RIGHT)
			Ship.velocity.make(
				150 * Math.cos(Ship.angle * Math.PI / 180), 
				150 * Math.sin(Ship.angle * Math.PI / 180));
		else
			Ship.velocity.make(0, 0);

		// Terminate bullets
		for (bul in Bullets.members) {
			if(bul!=null && bul.alive){
				var bulRect:FlxRect = new FlxRect(bul.x, bul.y, bul.width, bul.height);
				if(!GameAreaRect.overlaps(bulRect))
					bul.kill();
			}
		}
	}	

	public function keepTheShip(){
		if(Ship.x < GameArea.x)
			Ship.x = GameArea.x;
		if(Ship.x + Ship.width > GameArea.x + GameArea.width)
			Ship.x = GameArea.x + GameArea.width - Ship.width;
		if(Ship.y < GameArea.y)
			Ship.y = GameArea.y;
		if(Ship.y + Ship.height > GameArea.y + GameArea.height)
			Ship.y = GameArea.y + GameArea.height - Ship.width;
	}

	public function shoot(type:Int){
		var bul:FlxSprite = Bullets.recycle(FlxSprite);
		if(type == 0)
			bul.loadGraphic("assets/bul0.png");
		else 
			bul.loadGraphic("assets/bul1.png");
		bul.reset(Ship.getMidpoint().x, Ship.getMidpoint().y);
		bul.velocity.x = 200 * Math.cos(Ship.angle * Math.PI / 180);
		bul.velocity.y = 200 * Math.sin(Ship.angle * Math.PI / 180);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	public function ChangeControl(){
		CurCtrlMode++;
		while(CurCtrlMode<0)	CurCtrlMode+=Mode_Count;
		while(CurCtrlMode>=Mode_Count)	CurCtrlMode-=Mode_Count;
		FlxG.switchState(new GameState());
	}
}