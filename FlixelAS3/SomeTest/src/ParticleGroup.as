package
{
	import org.flixel.*;
	
	public class ParticleGroup extends FlxState
	{
		[Embed("../img/mudParticle.png")]public const IMGmudPart:Class;
		
		public var emtGroup:FlxGroup;
		
		public function ParticleGroup()
		{
			super();
		}
		
		override public function create():void
		{	
			emtGroup = new FlxGroup();
			addEmitter(FlxG.width/2, FlxG.height/2);
			add(emtGroup);
		}
		
		override public function update():void
		{
			super.update();
			
			if (FlxG.mouse.pressed())
			{
				addEmitter(FlxG.mouse.x, FlxG.mouse.y);
			}
		}
		
		public function addEmitter(x:Number, y:Number):void
		{
			var breakEmt:FlxEmitter = new FlxEmitter(x, y);
			breakEmt.makeParticles(IMGmudPart, 10, 0, true, 0);
			breakEmt.gravity = 100;
			breakEmt.setYSpeed(40, 100);
			breakEmt.setXSpeed(-40, 40);
			breakEmt.start(true, 2.5, 0.1);
			emtGroup.add(breakEmt);
		}
	}
}