package
{
	import org.flixel.*;

	public class ScrollBg extends FlxState
	{
		[Embed("../img/scrollBg.png")]public const IMGscroll:Class;
		
		public var img:FlxSprite;
		public var img2:FlxSprite;
		
		public function ScrollBg()
		{
			super();
		}
		
		override public function create():void
		{
			img = new FlxSprite();
			img.loadGraphic(IMGscroll);
			add(img);
			
			img2 = new FlxSprite();
			img2.loadGraphic(IMGscroll);
			img2.x = -550;
			add(img2);
		}
		
		override public function update():void
		{
			img.x += 3;
			if(img.x >= 550)
				img.x -= 550 * 2;
			
			img2.x += 3;
			if(img2.x >= 550)
				img2.x -= 550 * 2;
		}
	}
}