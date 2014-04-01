package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class Bomb extends FlxSprite
{
	private static inline var TICKS:Int = 4;
	private static inline var TICK_TIME:Float = 0.5;
	
	private var power:Int = 3;
	
	private var elapsed:Float = 0;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/bomb.png", true, false, 16, 16);
		
		height = 16;
		width = 16;
		
		immovable = true;
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
			animation.frameIndex = frame;
		}
		else
		{
			explode();
		}
	}
	
	public function explode():Void
	{
		var explosion:Explosion = Reg.PS.addExplosion();
		explosion.x = x;
		explosion.y = y;
		explosion.setFrame(FlxObject.NONE, false);
		
		// UP
		var explosionStack:Array<Explosion> = new Array<Explosion>();
		for (i in 1...power)
		{
			explosion = Reg.PS.addExplosion();
			explosion.x = x;
			explosion.y = y - (i * 16);
			explosion.setFrame(FlxObject.UP, false);
			
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
			explosion.setFrame(FlxObject.UP, true);
		}
		
		// DOWN
		explosionStack = new Array<Explosion>();
		for (i in 1...power)
		{
			explosion = Reg.PS.addExplosion();
			explosion.x = x;
			explosion.y = y + (i * 16);
			explosion.setFrame(FlxObject.DOWN, false);
			
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
			explosion.setFrame(FlxObject.DOWN, true);
		}
		
		// LEFT
		explosionStack = new Array<Explosion>();
		for (i in 1...power)
		{
			explosion = Reg.PS.addExplosion();
			explosion.x = x - (i * 16);
			explosion.y = y;
			explosion.setFrame(FlxObject.LEFT, false);
			
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
			explosion.setFrame(FlxObject.LEFT, true);
		}
		
		
		// RIGHT
		explosionStack = new Array<Explosion>();
		for (i in 1...power)
		{
			explosion = Reg.PS.addExplosion();
			explosion.x = x + (i * 16);
			explosion.y = y;
			explosion.setFrame(FlxObject.RIGHT, false);
			
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
			explosion.setFrame(FlxObject.RIGHT, true);
		}
		
		kill();
	}
}