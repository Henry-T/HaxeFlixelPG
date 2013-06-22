package
{
	import org.flixel.*;

	public class BreakerTest extends FlxState
	{
		[Embed("../img/mudParticle.png")]public const IMGmudPart:Class;
		
		public var breakBtn:FlxButton;
		public var emtState:FlxText;
		public var partCnt:FlxText;
		public var breakEmt:FlxEmitter;
		
		public function BreakerTest()
		{
		}
		
		override public function create():void
		{
			breakBtn = new FlxButton(0,0,"Break!", onBreak);
			this.add(breakBtn);
			
			emtState = new FlxText(0, 300,100);
			this.add(emtState);
			partCnt = new FlxText(0, 320, 100);
			this.add(partCnt);
			
			breakEmt = new FlxEmitter(FlxG.width/2, FlxG.height/2);
			breakEmt.makeParticles(IMGmudPart, 500, 0, true, 0);
			breakEmt.gravity = 100;
			breakEmt.setYSpeed(40, 100);
			breakEmt.setXSpeed(-40, 40);
			//breakEmt.start(false, 2.5, 0.1);
			this.add(breakEmt);
		}
		
		public function onBreak():void
		{
			//breakEmt.start(true, 2.5, 0.1);
			
			// multi explosions in one update with one emitter
			for(var i:Number=0;i<10;i++)
			{
				breakEmt.x = FlxG.random() * FlxG.width;
				breakEmt.y = FlxG.random() * FlxG.height;
				for(var j:Number = 0;j<4;j++)
					breakEmt.emitParticle();
			}
		}
		
		override public function update():void
		{
			super.update();
			
			emtState.text = breakEmt.on.toString();
			partCnt.text = breakEmt.length.toString();
		}
	}
}