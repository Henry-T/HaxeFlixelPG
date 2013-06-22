package
{
	import org.flixel.*;
	
	public class TileBreaker extends FlxState
	{
		// *link tile to a particle file
		// *breaking tile with particle shooting out
		// *rectangle breaker for collection
		
		[Embed("../img/mudParticle.png")]public const IMGmudPart:Class;
		[Embed("../img/tile1.png")]public const IMGtile1:Class;
		
		public var breakEmt:FlxEmitter;
		public var tile:FlxTilemap;
		public var breaker:FlxSprite;
		
		public function TileBreaker()
		{
		}
		
		override public function create():void
		{
			tile = new FlxTilemap();
			var data:Array = new Array(
							   0,0,0,0,0,0,0,0,0,0,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,1,1,1,1,1,1,1,1,1,0,
							   0,0,0,0,0,0,0,0,0,0,0);
			tile.loadMap(FlxTilemap.arrayToCSV(data,11), IMGtile1, 10, 10, FlxTilemap.OFF);
			tile.follow();
			add(tile);
			
			breaker = new FlxSprite();
			breaker.makeGraphic(20, 20, 0xaaaaaaaa);
			add(breaker);
			
			breakEmt = new FlxEmitter(100, 100);
			breakEmt.makeParticles(IMGmudPart, 100, 0, true, 0);
			breakEmt.gravity = 100;
			breakEmt.setYSpeed(40, 100);
			breakEmt.setXSpeed(-40, 40);
			add(breakEmt);
		}
		
		override public function update():void
		{
			super.update();
			
			breakEmt.x = Math.floor(FlxG.mouse.x / 20) * 20;
			breakEmt.y = Math.floor(FlxG.mouse.y / 20) * 20;
			
			FlxG.overlap(breaker, tile, onBreak);
		}
		
		public function onBreak(b:FlxSprite, t:FlxTilemap):void
		{
			var x:Number = Math.floor(FlxG.mouse.x / 20);
			var y:Number = Math.floor(FlxG.mouse.y / 20);
			
			if(tile.getTile(x,y) != 0)
			{
				tile.setTile(x,y,0);
				for(var i:Number=0;i<4;i++)
				{
					breakEmt.emitParticle();
				}
			}
		}
	}
}