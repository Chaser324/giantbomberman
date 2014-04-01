package entities;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class Player extends FlxSprite
{
	private static inline var TILE_SIZE:Int = 16;
	
	private var speed:Int = 2;
	private var lastX:Float;
	private var lastY:Float;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/players/brad.png", true, false, 16, 32);
		
		height = 16;
		width = 16;
		offset = new FlxPoint(0, 16);
		
		animation.add("idle", [6], 5, false);
		animation.add("walk-up", [0, 1, 0, 2], 5, true);
		animation.add("walk-left", [3, 4, 3, 5], 5, true);
		animation.add("walk-down", [6, 7, 6, 8], 5, true);
		animation.add("walk-right", [11, 9, 11, 10], 5, true);
	}
	
	public function collidedWithLevel():Void
	{
		x = lastX;
		y = lastY;
	}
	
	override public function update():Void
	{
		super.update();
		
		lastX = x;
		lastY = y;
		
		if (FlxG.keys.pressed.LEFT)
		{
			x -= speed;
			animation.play("walk-left");
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			x += speed;
			animation.play("walk-right");
		}
		else if (FlxG.keys.pressed.UP)
		{
			y -= speed;
			animation.play("walk-up");
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			y += speed;
			animation.play("walk-down");
		}
		else {
			animation.play("idle");
		}
	}
	
}