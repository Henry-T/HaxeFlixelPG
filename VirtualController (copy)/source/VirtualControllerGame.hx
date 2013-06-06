package;

import nme.Lib;
import org.flixel.FlxGame;
	
class VirtualControllerGame extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = 1;//stageWidth / 640;
		var ratioY:Float = 1;//stageHeight / 480;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), GameState, ratio, 30, 30);
	}
}
