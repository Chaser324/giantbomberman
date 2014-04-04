package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.util.FlxPoint;

class Player extends FlxSprite
{
	public var placedBomb:Bomb;
	
	private static inline var TILE_SIZE:Int = 16;
	private static inline var MAX_SPEED:Float = 2;
	
	private var speedLevel:Float = 1;
	private var bombLevel:Int = 1;
	private var powerLevel:Int = 1;
	private var kick:Bool = true;
	private var toss:Bool = true;
	
	private var bombCount:Int = 0;
	
	private var soundItemCollect:FlxSound;
	private var soundBombDrop:FlxSound;
	
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
		
		soundItemCollect = FlxG.sound.load("assets/sounds/item-collect.wav");
		soundBombDrop = FlxG.sound.load("assets/sounds/bomb-drop.wav");
	}
	
	override public function update():Void
	{
		super.update();
		
		move();
		
		if (placedBomb != null && placedBomb.getHeld() == false)
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
		
		if (FlxG.keys.justPressed.Z && placedBomb == null && bombCount < bombLevel)
		{
			placedBomb = Reg.PS.addBomb(this);
			placedBomb.setPower(powerLevel);
			placedBomb.setBomber(this);
			
			++bombCount;
			
			soundBombDrop.play();
		}
		else if (FlxG.keys.justPressed.Z && toss && placedBomb != null)
		{
			placedBomb.pickUp();
		}
		else if (FlxG.keys.justReleased.Z && placedBomb != null && placedBomb.getHeld())
		{
			placedBomb.toss();
			placedBomb = null;
		}
	}
	
	public function getKick():Bool
	{
		return kick;
	}
	
	public function bombExploded():Void
	{
		--bombCount;
	}
	
	public function collect(collectible:Int):Void
	{
		switch (collectible)
		{
			case Collectible.TYPE_BOMB:
				++bombLevel;
			case Collectible.TYPE_POWER:
				++powerLevel;
			case Collectible.TYPE_SPEED:
				speedLevel = Math.min(MAX_SPEED, speedLevel + 0.2);
		}
		
		soundItemCollect.play();
	}
	
	private function move():Void
	{
		if (FlxG.keys.pressed.LEFT)
		{
			x -= speedLevel;
			animation.play("walk-left");
			facing = FlxObject.LEFT;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			x += speedLevel;
			animation.play("walk-right");
			facing = FlxObject.RIGHT;
		}
		else if (FlxG.keys.pressed.UP)
		{
			y -= speedLevel;
			animation.play("walk-up");
			facing = FlxObject.UP;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			y += speedLevel;
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