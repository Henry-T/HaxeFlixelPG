package
{
	import org.flixel.*;
	
	public class HitFrame extends FlxState
	{
		[Embed("../img/peg.png")]public const IMGpeg:Class;
		[Embed("../img/tile1.png")]public const IMGtgt:Class;
		
		public var peg:FlxSprite;
		public var pegAll:FlxSprite;
		public var pegHit:FlxSprite;
		public var target:FlxSprite;
		
		public function HitFrame()
		{
			super();
		}
		
		override public function create():void
		{
			pegAll = new FlxSprite();
			pegAll.makeGraphic(80, 80, 0x33ffffff);
			pegAll.x = 100;
			pegAll.y = 100;
			add(pegAll);
			
			pegHit = new FlxSprite();
			pegHit.makeGraphic(30, 60, 0x55ff00000);
			pegHit.x = 150;
			pegHit.y = 120;
			add(pegHit);
			
			target = new FlxSprite();
			target.loadGraphic(IMGtgt);
			target.x = 160;
			target.y = 160;
			target.drag.x = 200;
			add(target);
			
			peg = new FlxSprite();
			peg.loadGraphic(IMGpeg, true, false, 80,80);
			peg.addAnimation("idle", [0,1,2,3], 10, true);
			peg.addAnimation("hit", [8,9,10,11,12,13,14,15], 10, false);
			peg.play("idle");
			this.add(peg);
			
			peg.x = 100;
			peg.y = 100;
		}
		
		override public function update():void
		{
			super.update();
			
			if(peg.frame <=3 && peg.frame>=0)
			{
				if(FlxG.keys.SPACE)
				{
					peg.play("hit", true);
				}
			}
			if(peg.frame == 15)
			{
				peg.play("idle");
			}
			
			if(peg.frame == 12)
			{
				if(pegHit.overlaps(target))
				{
					target.velocity.x = 300;
				}
			}
			
			if(target.velocity.x == 0)
			{
				target.x = 160;
			}
		}
	}
}