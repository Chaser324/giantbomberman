package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Bomb extends FlxSprite
{
	private static inline var TICKS:Int = 4;
	private static inline var TICK_TIME:Float = 0.5;
	
	private var power:Int = 2;
	private var bomber:Player = null;
	
	private var elapsed:Float = 0;
	
	private var tween:FlxTween;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/bomb.png", true, false, 16, 16);
		
		height = 16;
		width = 16;
		
		immovable = true;
		
		offset.x = -1;
		
		var tweenOptions:TweenOptions = {type: FlxTween.PINGPONG}
		tween = FlxTween.multiVar(offset, { x: 1 }, 0.1, tweenOptions);
	}
	
	override public function revive():Void
	{
		super.revive();
		
		elapsed = 0;
	}
	
	override public function update():Void
	{
		super.update();
		
		elapsed += FlxG.elapsed;
		
		var frame:Int = Math.floor(elapsed / TICK_TIME);
		
		if (frame < TICKS)
		{
			tween.duration = 0.1 / frame;
			animation.frameIndex = frame;
		}
		else
		{
			explode();
		}
	}
	
	public function setPower(level:Int):Void
	{
		power = level + 1;
	}
	
	public function setBomber(p:Player):Void
	{
		bomber = p;
	}
	
	public function explode():Void
	{
		FlxG.cameras.flash(0xffffffff,0.2);
		FlxG.cameras.shake(0.005, 0.2);
		
		explodeDir(0, 0, FlxObject.NONE);
		explodeDir(0, -1, FlxObject.UP);
		explodeDir(0, 1, FlxObject.DOWN);
		explodeDir(-1, 0, FlxObject.LEFT);
		explodeDir(1, 0, FlxObject.RIGHT);
		
		bomber.bombExploded();
		
		kill();
	}
	
	private function explodeDir(dx:Float, dy:Float, dir:Int):Void
	{
		var explosion:Explosion;
		var explosionStack:Array<Explosion> = new Array<Explosion>();
		
		for (i in 1...power)
		{
			explosion = Reg.PS.addExplosion();
			explosion.x = x + (i * dx * 16);
			explosion.y = y + (i * dy * 16);
			explosion.setFrame(dir, false);
			
			if (Reg.PS.wallCollideTest(explosion))
			{
				explosion.kill();
				break;
			}
			else if (Reg.PS.softWallCollideTest(explosion))
			{
				explosionStack.push(explosion);
				break;
			}
			else
			{
				explosionStack.push(explosion);
			}
		}
		
		if (explosionStack.length > 0)
		{
			explosion = explosionStack.pop();
			explosion.setFrame(dir, true);
		}
	}
}