package
{
	import org.flixel.*;
	
	public class ParticleTest extends FlxState
	{
		public var emt:FlxEmitter;
		
		[Embed(source="../img/particle.png")]
		public const IMGpart:Class;
		
		public function ParticleTest()
		{
			super();
		}
		
		override public function create():void
		{
			emt = new FlxEmitter();
			emt.width = 100;
			emt.height = 100;
			// image amount bakeRotCount multiPiece colled
			emt.makeParticles(IMGpart, 50, 0, false, 0);
			emt.x = FlxG.width/2;
			emt.y = FlxG.height/2;
			emt.start(false, 2.5, 0.01);
			emt.setXSpeed(0,500);
			emt.setYSpeed(-20,20);
			
			add(emt);
		}
	}
}