package;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

class Main extends Sprite {	
	public function new () {
		super ();
		
		if (this.hasEventListener(Event.ADDED_TO_STAGE))
			initialize(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		
	}
	
	private function initialize(e:Event) { 
		if (e != null)
			this.removeEventListener(Event.ADDED_TO_STAGE, initialize);
		
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		
	}
	
	private function onMouseUp(e:MouseEvent):Void 
	{
		
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		
	}
	
	
	
}