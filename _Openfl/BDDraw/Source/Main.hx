package;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

class Main extends Sprite {	
	var sprite:Sprite;
	var bd:BitmapData;

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
		
		sprite = new Sprite();
		sprite.graphics.lineStyle(4, 0xff0000, 1);
		sprite.graphics.drawCircle(50, 50, 50);
		bd = new BitmapData(stage.stageWidth, stage.stageHeight);
		bd.draw(sprite, new flash.geom.Matrix(1,0,0,1, 100,100));
		var bitmap:Bitmap = new Bitmap(bd);
		stage.addChild(bitmap);

		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		
	}
	
	private function onMouseUp(e:MouseEvent):Void 
	{
		
	}

	private function onMouseDown(e:MouseEvent):Void 
	{
		bd.fillRect(bd.rect, 0x0);
		bd.draw(sprite, new flash.geom.Matrix(1,0,0,1,mouseX, mouseY));
		bd.applyFilter(bd, bd.rect, new flash.geom.Point(), new flash.filters.BlurFilter(3,3));
	}
	
	private function onMouseMove(e:MouseEvent):Void{
		bd.draw(sprite, new flash.geom.Matrix(1,0,0,1,mouseX, mouseY));
		bd.applyFilter(bd, bd.rect, new flash.geom.Point(), new flash.filters.BlurFilter(3,3));
		bd.colorTransform(bd.rect, new flash.geom.ColorTransform(1,1,1, 0.9));
	}
	
	
}