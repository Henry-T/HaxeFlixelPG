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

class SnakeBody extends FlxSprite{
	public var Id:Int;
	public function new(id:Int){
		super(0,0,null);
		this.offset.make(-1, -1);
		Id = id;
		if(Id == 0)
			makeGraphic(MenuState.tileSize-2,MenuState.tileSize-2,0xff00ff00);
		else 
			makeGraphic(MenuState.tileSize-2,MenuState.tileSize-2,0xffffffff);
	}

	public override function update(){
		super.update();

		x = Math.floor(Id%MenuState.areaWidth)*MenuState.tileSize;
		y =	Math.floor(Id/MenuState.areaWidth)*MenuState.tileSize;
	}
}

class MenuState extends FlxState
{
	public static var tileSize:Int = 32;
	public static var areaWidth:Int = 20;
	public static var areaHeight:Int = 15;
	public static var baseSpeed:Float = 0.3;
	public static var speedStep:Float = 0.02;
	public static var toughCound:Int = 2;

	public var curToughCnt:Int;
	public var curSpeedStep:Float;
	public var curFood:Int;
	public var foodSpr:FlxSprite;
	public var data:Array<Int>;

	// 0-Right 1-Down 2-Left 3-Up
	public var curDir:Int; // keep last dir until key pressed

	private var stepTimer:Float;

	public var curHead:Int;

	private var lastTail:Int;	// tail pos before most recent move 

	var snakeSprAry:Array<SnakeBody>;

	override public function create():Void
	{
		super.create();
		FlxG.bgColor = 0xff000000;
		//FlxG.camera.bgColor = 0xff0000ff;
		data = [0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0];

		curDir = 1;
		stepTimer = 0;

		snakeSprAry = [];
		for (i in 0...6) {
			var body = new MenuState.SnakeBody(i);
			snakeSprAry.push(body);
			add(body);
		}
		curHead = 4;
		lastTail = -1;

		curFood = 45;
		foodSpr = new FlxSprite(0,0,null);
		foodSpr.ID = 45;
		foodSpr.makeGraphic(tileSize,tileSize,0xff880000);
		add(foodSpr);

		curSpeedStep = baseSpeed;

		curToughCnt = 0;

	}
	
	override public function update():Void
	{
		super.update();

		// update food position
		foodSpr.x = Math.floor(foodSpr.ID%MenuState.areaWidth)*MenuState.tileSize;
		foodSpr.y =	Math.floor(foodSpr.ID/MenuState.areaWidth)*MenuState.tileSize;


		// update step
		stepTimer += FlxG.elapsed;
		if(stepTimer > curSpeedStep){
			stepTimer = 0;
			// make a move 
			var res:Bool  = makeMove();
			if(!res){
				FlxG.switchState(new MenuState());
			}
		}

		// update curHead

		var res2:Bool = tryEat();
		if(res2)
		{
			curToughCnt++;
			if(curToughCnt >= toughCound)
			{
				curToughCnt == 0;
				curSpeedStep -= speedStep;
			}
		}

		// check control
		if(FlxG.keys.RIGHT && snakeSprAry[0].Id + 1 != snakeSprAry[1].Id)
			curDir = 0;
		else if(FlxG.keys.DOWN && snakeSprAry[0].Id + areaWidth != snakeSprAry[1].Id)
			curDir = 1;
		else if(FlxG.keys.LEFT && snakeSprAry[0].Id - 1 != snakeSprAry[1].Id)
			curDir = 2;
		else if(FlxG.keys.UP && snakeSprAry[0].Id - areaWidth != snakeSprAry[1].Id)
			curDir = 3;
	}

	function tryEat():Bool{
		// check collision
		if(snakeSprAry[0].Id == foodSpr.ID){
			// kill food nothing to do here!

			// add tail
			var tail = new MenuState.SnakeBody(lastTail);
			snakeSprAry.push(tail);
			tail.x = Math.floor(tail.Id%MenuState.areaWidth)*MenuState.tileSize;
			tail.y = Math.floor(tail.Id/MenuState.areaWidth)*MenuState.tileSize;
			add(tail);

			// create new food
			while(snakeSprAry[0].Id == foodSpr.ID){
				foodSpr.ID = Math.floor(Math.random() * data.length);
			}
			foodSpr.x = Math.floor(foodSpr.ID%MenuState.areaWidth)*MenuState.tileSize;
			foodSpr.y =	Math.floor(foodSpr.ID/MenuState.areaWidth)*MenuState.tileSize;
			return true;
		}
		return false;
	}

	function makeMove():Bool{
		// move each body part
		var i:Int = snakeSprAry.length;
		while(i > 0){
			i--;
			var curBody:SnakeBody = cast(snakeSprAry[i], SnakeBody);
			
			// save last tail
			if(i == snakeSprAry.length-1){
				lastTail = curBody.Id;
			}
			// move body part
			if(i != 0){
				curBody.Id = snakeSprAry[i-1].Id;
			}
			else{
				// for the head
				if(curDir == 0){
					if(curBody.Id%areaWidth==areaWidth-1)
						return false;
					curBody.Id +=1;
				}
				else if(curDir == 1){
					if(Math.floor(curBody.Id/areaWidth)==areaHeight-1)
						return false;
					curBody.Id += areaWidth;
				}
				else if(curDir == 2){
					if(curBody.Id%areaWidth==0)
						return false;
					curBody.Id -= 1;
				}
				else if(curDir == 3){
					if(Math.floor(curBody.Id/areaWidth)==0)
						return false;
					curBody.Id -= areaWidth;
				}
			}
		}

		for (b in snakeSprAry) {
			if(b != snakeSprAry[0] && b.Id == snakeSprAry[0].Id)
				return false;
		}

		return true;
	}
}
