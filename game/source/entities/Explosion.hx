package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Explosion extends FlxSprite
{
	private static inline var LIFETIME:Float = 0.5;
	
	private var elapsed:Float = 0;

	public function new(X:Int, Y:Int)
	{
		super(X,Y);
		
		loadGraphic("assets/images/fire.png", true, false, 16, 16);
		
		height = 16;
		width = 16;
		
		var frameRate:Int = Math.floor(4 / LIFETIME);
		
		animation.add("top", [0, 1, 2, 3], frameRate, false);
		animation.add("vertical", [4, 5, 6, 7], frameRate, false);
		animation.add("left", [8, 9, 10, 11], frameRate, false);
		animation.add("bottom", [12, 13, 14, 15], frameRate, false);
		animation.add("horizontal", [16, 17, 18, 19], frameRate, false);
		animation.add("right", [20, 21, 22, 23], frameRate, false);
		animation.add("center", [24, 25, 26, 27], frameRate, false);
		
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
		
		if (elapsed > LIFETIME)
		{
			kill();
		}
	}
	
	public function setFrame(dir:Int, end:Bool)
	{
		switch(dir)
		{
			case FlxObject.NONE:
				animation.play("center");
			case FlxObject.UP:
				if (end)
				{
					animation.play("top");
				}
				else
				{
					animation.play("vertical");
				}
			case FlxObject.DOWN:
				if (end)
				{
					animation.play("bottom");
				}
				else
				{
					animation.play("vertical");
				}
			case FlxObject.RIGHT:
				if (end)
				{
					animation.play("right");
				}
				else
				{
					animation.play("horizontal");
				}
			case FlxObject.LEFT:
				if (end)
				{
					animation.play("left");
				}
				else
				{
					animation.play("horizontal");
				}
		}
	}
	
}