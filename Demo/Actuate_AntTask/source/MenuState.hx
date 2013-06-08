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
import org.flixel.FlxU;

import org.flixel.addons.taskManager.AntTask;
import org.flixel.addons.taskManager.AntTaskManager;
import motion.Actuate;

class MenuState extends FlxState
{
	private var sprite:FlxSprite;
	var taskManger:AntTaskManager;
 
    override public function create():Void
    {
        super.create();
 
        sprite = new FlxSprite(12,12);
        add(sprite);

        // You don't need to construct AntTask instance, just call addTask()
        taskManger = new AntTaskManager(false,finish);
        // I add the first param to addTask()
        // it is the object playtween() belongs to here
        taskManger.addTask(this, playtween, null, false);
        taskManger.addPause(4);
        taskManger.addTask(this, playtween2,null, false);
        taskManger.addPause(5);
    }
    public function playtween():Bool
    {
    	Actuate.tween (sprite, 4 , { y :200 } );
    	// Reture true to let AntTaskManager know this task is finished
    	return true;	
	}
 
    public function playtween2():Bool
    {
    	Actuate.tween (sprite, 5 , { y :0 } );
    	// Reture true here too.
    	return true;
    }
 
    public function finish():Void
    {
    	trace("jah"); FlxG.shake();
    }

    override public function destroy():Void
    {super.destroy();}
 
    override public function update():Void
    {super.update();}
}