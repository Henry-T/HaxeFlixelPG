package ;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxButton;
import org.flixel.system.input.FlxAnalog;
import org.flixel.system.input.FlxGamePad;

/* Controller can be added to a FlxState
 * Contains GUI of FlxAnalog and FlxGamePad
 * Wrap up all devices including mouse, touch and keyboard as universe game logic input
 * Besides you don't need to concern about FLX_NO_*** flags in game logic, for them are handled here
 */
class Controller extends FlxGroup {

	// analog on bottom left corner of screen
	// for pressed test
	public var analogL:FlxAnalog;

	// analog on bottom right corner of screen
	// for justPressed,justReleased and muiti FlxAnalog test
	public var analogR:FlxAnalog;

	// gamePad with four direction buttons and a A button
	// for gamePad multi-key pressed at the same time test
	public var gamePad:FlxGamePad;

	// Bool assess to input state
	public var Pressed_UP:Bool;
	public var Pressed_DOWN:Bool;
	public var Pressed_LEFT:Bool;
	public var Pressed_RIGHT:Bool;
	public var Pressed_Action:Bool;
	public var JustPressed_UP:Bool;
	public var JustPressed_DOWN:Bool;
	public var JustPressed_LEFT:Bool;
	public var JustPressed_RIGHT:Bool;
	public var JustPressed_Action:Bool;
	public var JustReleased_UP:Bool;
	public var JustReleased_DOWN:Bool;
	public var JustReleased_LEFT:Bool;
	public var JustReleased_RIGHT:Bool;
	public var JustReleased_Action:Bool;

	public var AnalogL_Angle:Float;

	public function new(ctrlMode:Int){
		super();
		
		switch (ctrlMode) {
			case GameState.Mode_GamePadOnly:
				gamePad = new FlxGamePad(FlxGamePad.FULL, FlxGamePad.A);
				add(gamePad);
			case GameState.Mode_AnalogToMove_GamePadToShoot:
				analogL = new FlxAnalog(50, FlxG.height-50);
				gamePad = new FlxGamePad(FlxGamePad.NONE, FlxGamePad.A);
				add(analogL);
				add(gamePad);
			case GameState.Mode_AnalogToMove_Analog2ToShoot:
				analogL = new FlxAnalog(50, FlxG.height-50);
				analogR = new FlxAnalog(FlxG.width-50, FlxG.height-50);
				add(analogL);
				add(analogR);
		}
	}
	
	public override function update(){
		super.update();

		// Clear bool accessors from last update
		Pressed_UP = false;
		Pressed_DOWN = false;
		Pressed_LEFT = false;
		Pressed_RIGHT = false;
		Pressed_Action = false;
		JustPressed_UP = false;
		JustPressed_DOWN = false;
		JustPressed_LEFT = false;
		JustPressed_RIGHT = false;
		JustPressed_Action = false;
		JustReleased_UP = false;
		JustReleased_DOWN = false;
		JustReleased_LEFT = false;
		JustReleased_RIGHT = false;
		JustReleased_Action = false;

		updateKeyboard();
		updateGamePad();
		updateAnalogL();
		updateAnalogR();

		if(keyboard_Pressed_UP || gamePad_Pressed_UP || analog_Pressed_UP)
			Pressed_UP = true;
		if(keyboard_Pressed_DOWN || gamePad_Pressed_DOWN || analog_Pressed_DOWN)
			Pressed_DOWN = true;
		if(keyboard_Pressed_LEFT || gamePad_Pressed_LEFT || analog_Pressed_LEFT)
			Pressed_LEFT = true;
		if(keyboard_Pressed_RIGHT || gamePad_Pressed_RIGHT || analog_Pressed_RIGHT)
			Pressed_RIGHT = true;
		if(keyboard_Pressed_Action || gamePad_Pressed_Action || analog_Pressed_Action)
			Pressed_Action = true;


		if(keyboard_JustPressed_UP || analog_JustPressed_UP)
			JustPressed_UP = true;
		if(keyboard_JustPressed_DOWN || analog_JustPressed_DOWN)
			JustPressed_DOWN = true;
		if(keyboard_JustPressed_LEFT || analog_JustPressed_LEFT)
			JustPressed_LEFT = true;
		if(keyboard_JustPressed_RIGHT || analog_JustPressed_RIGHT)
			JustPressed_RIGHT = true;
		if(keyboard_JustPressed_Action || gamePad_JustPressed_Action || analog_JustPressed_Action)
			JustPressed_Action = true;


		if(keyboard_JustReleased_UP || analog_JustReleased_UP)
			JustReleased_UP = true;
		if(keyboard_JustReleased_DOWN || analog_JustReleased_DOWN)
			JustReleased_DOWN = true;
		if(keyboard_JustReleased_LEFT || analog_JustReleased_LEFT)
			JustReleased_LEFT = true;
		if(keyboard_JustReleased_RIGHT || analog_JustReleased_RIGHT)
			JustReleased_RIGHT = true;
		if(keyboard_JustReleased_Action || gamePad_JustReleased_Action || analog_JustReleased_Action)
			JustReleased_Action = true;

		postUpdateGamePad();
	}

	private function updateGamePad(){
		if(gamePad == null)	return;
		gamePad_Pressed_UP = (gamePad.buttonUp != null && gamePad.buttonUp.status == FlxButton.PRESSED);
		gamePad_Pressed_DOWN = (gamePad.buttonDown != null && gamePad.buttonDown.status == FlxButton.PRESSED);
		gamePad_Pressed_LEFT = (gamePad.buttonLeft != null && gamePad.buttonLeft.status == FlxButton.PRESSED);
		gamePad_Pressed_RIGHT = (gamePad.buttonRight != null && gamePad.buttonRight.status == FlxButton.PRESSED);
		gamePad_Pressed_Action = (gamePad.buttonA != null && gamePad.buttonA.status == FlxButton.PRESSED);

		gamePad_Released_UP = (gamePad.buttonUp != null && gamePad.buttonUp.status != FlxButton.PRESSED);
		gamePad_Released_DOWN = (gamePad.buttonDown != null && gamePad.buttonDown.status != FlxButton.PRESSED);
		gamePad_Released_LEFT = (gamePad.buttonLeft != null && gamePad.buttonLeft.status != FlxButton.PRESSED);
		gamePad_Released_RIGHT = (gamePad.buttonRight != null && gamePad.buttonRight.status != FlxButton.PRESSED);
		gamePad_Released_Action = (gamePad.buttonA != null && gamePad.buttonA.status != FlxButton.PRESSED);

		gamePad_JustPressed_Action = (gamePad.buttonA != null && gamePad.buttonA.status == FlxButton.PRESSED && gamePad_Action_LastStatus != FlxButton.PRESSED);
		gamePad_JustReleased_Action = (gamePad.buttonA != null && gamePad.buttonA.status != FlxButton.PRESSED && gamePad_Action_LastStatus == FlxButton.PRESSED);
	}

	private function postUpdateGamePad(){
		if(gamePad == null)	return;
		gamePad_Action_LastStatus = gamePad.buttonA.status;
	}

	private function updateAnalogL(){
		if(analogL == null)	return;
		var angle : Float = AnalogL_Angle = analogL.getAngle();
		var pressed : Bool = analogL.pressed();
		var justPressed : Bool = analogL.justPressed();
		var justReleased : Bool = analogL.justReleased();

		analog_Pressed_UP = pressed && angle > -150 && angle < -30;
		analog_Pressed_DOWN = pressed && angle > 30 && angle < 150;
		analog_Pressed_LEFT = pressed && (angle > 120 || angle < -120);
		analog_Pressed_RIGHT = pressed && angle > -60 && angle < 60;

		analog_JustPressed_UP = justPressed && angle > 30 && angle < 150;
		analog_JustPressed_DOWN = justPressed && angle > -150 && angle < -30;
		analog_JustPressed_LEFT = justPressed && (angle > 120 || angle < -120);
		analog_JustPressed_RIGHT =justPressed && angle > -60 && angle < -60;

		analog_JustReleased_UP = justReleased && angle > 30 && angle < 150;
		analog_JustReleased_DOWN = justReleased && angle > -150 && angle < -30;
		analog_JustReleased_LEFT = justReleased && (angle > 120 || angle < -120);
		analog_JustReleased_RIGHT =justReleased && angle > -60 && angle < -60;
	}

	private function updateAnalogR(){
		if(analogR == null)	return;

		var angle : Float = analogR.getAngle();
		var pressed : Bool = analogR.pressed();
		var justPressed : Bool = analogR.justPressed();
		var justReleased : Bool = analogR.justReleased();

		analog_Pressed_Action = pressed;
		analog_JustPressed_Action = justPressed;
		analog_JustReleased_Action = justReleased;
	}

	private function updateKeyboard(){
		#if !FLX_NO_KEYBOARD
		keyboard_Pressed_UP = FlxG.keys.UP;
		keyboard_Pressed_DOWN = FlxG.keys.DOWN;
		keyboard_Pressed_LEFT = FlxG.keys.LEFT;
		keyboard_Pressed_RIGHT = FlxG.keys.RIGHT;
		keyboard_Pressed_Action = FlxG.keys.J;
		keyboard_JustPressed_UP = FlxG.keys.justPressed("UP");
		keyboard_JustPressed_DOWN = FlxG.keys.justPressed("DOWN");
		keyboard_JustPressed_LEFT = FlxG.keys.justPressed("LEFT");
		keyboard_JustPressed_RIGHT = FlxG.keys.justPressed("RIGHT");
		keyboard_JustPressed_Action = FlxG.keys.justPressed("SPACE");
		keyboard_JustReleased_UP = FlxG.keys.justReleased("UP");
		keyboard_JustReleased_DOWN = FlxG.keys.justReleased("DOWN");
		keyboard_JustReleased_LEFT = FlxG.keys.justReleased("LEFT");
		keyboard_JustReleased_RIGHT = FlxG.keys.justReleased("RIGHT");
		keyboard_JustReleased_Action = FlxG.keys.justReleased("SPACE");
		#end
	}

	private var gamePad_Pressed_UP : Bool;
	private var gamePad_Pressed_DOWN : Bool;
	private var gamePad_Pressed_LEFT : Bool;
	private var gamePad_Pressed_RIGHT : Bool;
	private var gamePad_Pressed_Action : Bool;
	private var gamePad_Released_UP : Bool;
	private var gamePad_Released_DOWN : Bool;
	private var gamePad_Released_LEFT : Bool;
	private var gamePad_Released_RIGHT : Bool;
	private var gamePad_Released_Action : Bool;
	private var gamePad_JustPressed_Action : Bool;
	private var gamePad_JustReleased_Action : Bool;
	// If you want to get just pressed and released state of a FlxGamePad button (a FlxButton in fact)
	// You need to compare two button status between updates on your own. Like the following:
	private var gamePad_Action_LastStatus : Int;

	private var keyboard_Pressed_UP : Bool;
	private var keyboard_Pressed_DOWN : Bool;
	private var keyboard_Pressed_LEFT : Bool;
	private var keyboard_Pressed_RIGHT : Bool;
	private var keyboard_Pressed_Action : Bool;
	private var keyboard_JustPressed_UP : Bool;
	private var keyboard_JustPressed_DOWN : Bool;
	private var keyboard_JustPressed_LEFT : Bool;
	private var keyboard_JustPressed_RIGHT : Bool;
	private var keyboard_JustPressed_Action : Bool;
	private var keyboard_JustReleased_UP : Bool;
	private var keyboard_JustReleased_DOWN : Bool;
	private var keyboard_JustReleased_LEFT : Bool;
	private var keyboard_JustReleased_RIGHT : Bool;
	private var keyboard_JustReleased_Action : Bool;

	private var analog_Pressed_UP : Bool;
	private var analog_Pressed_DOWN : Bool;
	private var analog_Pressed_LEFT : Bool;
	private var analog_Pressed_RIGHT : Bool;
	private var analog_Pressed_Action : Bool;
	private var analog_JustPressed_UP : Bool;
	private var analog_JustPressed_DOWN : Bool;
	private var analog_JustPressed_LEFT : Bool;
	private var analog_JustPressed_RIGHT : Bool;
	private var analog_JustPressed_Action : Bool;
	private var analog_JustReleased_UP : Bool;
	private var analog_JustReleased_DOWN : Bool;
	private var analog_JustReleased_LEFT : Bool;
	private var analog_JustReleased_RIGHT : Bool;
	private var analog_JustReleased_Action : Bool;

	
}