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

        taskManger = new AntTaskManager(false,finish);
        taskManger.addTask(this, playtween,null,false);
        taskManger.addPause(4,false);
        taskManger.addTask(this, playtween2,null,false);
        taskManger.addPause(5,false);
 
    }

    public function playtween():Bool
    {
        Actuate.tween (sprite, 4 , { y :200 } );
        return true;
    }
 
    public function playtween2():Bool
    {
        Actuate.tween (sprite, 5 , { y :0 } );
        return true;
    }
 
    public function finish():Void
    {trace("jah"); FlxG.shake();}
}