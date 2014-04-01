package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class Player extends FlxSprite
{
	public var placedBomb:Bomb;
	
	private static inline var TILE_SIZE:Int = 16;
	
	private var speed:Int = 1;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/players/brad.png", true, false, 16, 32);
		
		height = 16;
		width = 16;
		offset = new FlxPoint(0, 16);
		
		facing = FlxObject.DOWN;
		
		animation.add("idle-up", [0], 10, false);
		animation.add("idle-left", [3], 10, false);
		animation.add("idle-down", [6], 10, false);
		animation.add("idle-right", [11], 10, false);
		animation.add("walk-up", [0, 1, 0, 2], 10, true);
		animation.add("walk-left", [3, 4, 3, 5], 10, true);
		animation.add("walk-down", [6, 7, 6, 8], 10, true);
		animation.add("walk-right", [11, 9, 11, 10], 10, true);
	}
	
	override public function update():Void
	{
		super.update();
		
		move();
		
		if (placedBomb != null)
		{
			if (FlxG.overlap(this, placedBomb) == false)
			{
				placedBomb = null;
			}
			else if (placedBomb.x == x && placedBomb.y - y == 16)
			{
				placedBomb = null;
			}
			else if (placedBomb.y == y && placedBomb.x - x == 16)
			{
				placedBomb = null;
			}
		}
		
		if (FlxG.keys.justPressed.Z && placedBomb == null)
		{
			Reg.PS.addBomb(this);
		}
	}
	
	private function move():Void
	{
		if (FlxG.keys.pressed.LEFT)
		{
			x -= speed;
			animation.play("walk-left");
			facing = FlxObject.LEFT;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			x += speed;
			animation.play("walk-right");
			facing = FlxObject.RIGHT;
		}
		else if (FlxG.keys.pressed.UP)
		{
			y -= speed;
			animation.play("walk-up");
			facing = FlxObject.UP;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			y += speed;
			animation.play("walk-down");
			facing = FlxObject.DOWN;
		}
		else
		{
			switch (facing)
			{
				case FlxObject.LEFT:
					animation.play("idle-left");
				case FlxObject.RIGHT:
					animation.play("idle-right");
				case FlxObject.UP:
					animation.play("idle-up");
				case FlxObject.DOWN:
					animation.play("idle-down");
			}
		}
	}
	
}