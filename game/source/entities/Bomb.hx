package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;

class Bomb extends FlxSprite
{
	private static inline var TICKS:Int = 4;
	private static inline var TICK_TIME:Float = 0.75;
	
	private var power:Int = 2;
	private var bomber:Player = null;
	
	private var elapsed:Float = 0;
	
	private var tween:FlxTween;
	private var tossTween:FlxTween;
	
	private var soundExplode:FlxSound;
	
	private var held:Bool = false;
	private var tossed:Bool = false;
	private var tossTarget:FlxPoint;
	private var tossDirection:Int;
	
	private var vx:Float = 0;
	private var vy:Float = 0;
	
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
		
		soundExplode = FlxG.sound.load("assets/sounds/bomb-explode.wav");
	}
	
	override public function revive():Void
	{
		super.revive();
		
		elapsed = 0;
		vx = 0;
		vy = 0;
		
		held = false;
		tossed = false;
		solid = true;
	}
	
	override public function update():Void
	{
		super.update();
		
		if (!held && !tossed)
		{
			x += vx;
			y += vy;
			
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
		else if (held)
		{
			y = bomber.y - 8;
			
			switch(bomber.facing)
			{
				case FlxObject.LEFT:
					x = bomber.x - 4;
				case FlxObject.RIGHT:
					x = bomber.x + 4;
				case FlxObject.UP:
					x = bomber.x;
				case FlxObject.DOWN:
					x = bomber.x;
			}
		}
		else if (tossed)
		{
			if (tossTween.percent == 1)
			{
				if (Reg.PS.wallCollideTest(this) || Reg.PS.softWallCollideTest(this) || !Reg.PS.inBoundsTest(this) || Reg.PS.bombCollideTest(this))
				{
					if (!Reg.PS.inBoundsTest(this))
					{
						switch(tossDirection)
						{
							case FlxObject.LEFT:
								x = Reg.PS.getWidth();
							case FlxObject.RIGHT:
								x = 0;
							case FlxObject.UP:
								y = Reg.PS.getHeight();
							case FlxObject.DOWN:
								y = 0;
						}
						
						tossTarget.x = x;
						tossTarget.y = y;
					}
					
					switch(tossDirection)
					{
						case FlxObject.LEFT:
							tossTarget.x -= 16;
						case FlxObject.RIGHT:
							tossTarget.x += 16;
						case FlxObject.UP:
							tossTarget.y -= 16;
						case FlxObject.DOWN:
							tossTarget.y += 16;
					}
					
					var tweenOptions:TweenOptions = {type: FlxTween.ONESHOT}
					tossTween = FlxTween.cubicMotion(this, x, y, x + (tossTarget.x - x) * .25, y - 10, x + (tossTarget.x - x) * .75, y - 10, tossTarget.x, tossTarget.y, 0.1, tweenOptions);
				}
				else
				{
					tossed = false;
					solid = true;
					offset.x = -1;
					tween.active = true;
				}
			}
		}
	}
	
	public function pickUp():Void
	{
		held = true;
		solid = false;
		
		animation.frameIndex = 0;
		
		offset.x = 0;
		tween.active = false;
	}
	
	public function toss():Void
	{
		held = false;
		tossed = true;
		tossDirection = bomber.facing;
		
		tossTarget = new FlxPoint();
		tossTarget.x = 16 * Math.round(bomber.x / 16);
		tossTarget.y = 16 * Math.round(bomber.y / 16);
		
		switch(tossDirection)
		{
			case FlxObject.LEFT:
				tossTarget.x -= 2 * 16;
			case FlxObject.RIGHT:
				tossTarget.x += 2 * 16;
			case FlxObject.UP:
				tossTarget.y -= 2 * 16;
			case FlxObject.DOWN:
				tossTarget.y += 2 * 16;
		}
		
		var tweenOptions:TweenOptions = {type: FlxTween.ONESHOT}
		tossTween = FlxTween.cubicMotion(this, x, y, x + (tossTarget.x - x) * .25, y - 15, x + (tossTarget.x - x) * .75, y - 15, tossTarget.x, tossTarget.y, 0.2, tweenOptions);
	}
	
	public function setPower(level:Int):Void
	{
		power = level + 1;
	}
	
	public function setBomber(p:Player):Void
	{
		bomber = p;
	}
	
	public function getHeld():Bool
	{
		return held;
	}
	
	public function explode():Void
	{
		FlxG.cameras.flash(0xffffffff,0.2);
		FlxG.cameras.shake(0.005, 0.2);
		
		x = 16 * Math.round(x / 16);
		y = 16 * Math.round(y / 16);
		
		explodeDir(0, 0, FlxObject.NONE);
		explodeDir(0, -1, FlxObject.UP);
		explodeDir(0, 1, FlxObject.DOWN);
		explodeDir(-1, 0, FlxObject.LEFT);
		explodeDir(1, 0, FlxObject.RIGHT);
		
		bomber.bombExploded();
		
		soundExplode.play();
		
		kill();
	}
	
	public function slide(dir:Int):Void
	{
		immovable = false;
		switch (dir)
		{
			case FlxObject.RIGHT:
				vx = 2;
				vy = 0;
			case FlxObject.LEFT:
				vx = -2;
				vy = 0;
			case FlxObject.UP:
				vx = 0;
				vy = -2;
			case FlxObject.DOWN:
				vx = 0;
				vy = 2;
		}
	}
	
	public function stopSlide():Void
	{
		vx = 0;
		vy = 0;
		immovable = true;
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