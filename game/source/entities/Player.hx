package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;

class Player extends FlxSprite
{
	public var placedBomb:Bomb;
	
	private static inline var TILE_SIZE:Int = 16;
	private static inline var MAX_SPEED:Float = 2;
	
	private var speedLevel:Float = 1;
	private var bombLevel:Int = 1;
	private var powerLevel:Int = 1;
	private var kick:Bool = false;
	private var toss:Bool = false;
	private var punch:Bool = false;
	
	private var bombCount:Int = 0;
	
	private var soundItemCollect:FlxSound;
	private var soundBombDrop:FlxSound;
	
	private var dead:Bool = false;
	private var deadVx:Float = 0;
	private var deadVy:Float = 0;
	
	private var controller:PlayerController;
	
	public function new(c:PlayerController) 
	{
		super();
		
		controller = c;
		
		loadGraphic("assets/images/players/brad.png", true, false, 16, 32);
		
		height = 16;
		width = 16;
		offset = FlxPoint.get(0, 16);
		
		facing = FlxObject.DOWN;
		
		animation.add("idle-up", [0], 10, false);
		animation.add("idle-left", [3], 10, false);
		animation.add("idle-down", [6], 10, false);
		animation.add("idle-right", [11], 10, false);
		
		animation.add("dead-up", [14], 10, false);
		animation.add("dead-left", [13], 10, false);
		animation.add("dead-down", [12], 10, false);
		animation.add("dead-right", [15], 10, false);
		
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
		
		controller.update();
		
		if (!dead)
		{
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
		
			if (controller.justPressed(PlayerController.BOMB_BUTTON) && placedBomb == null && bombCount < bombLevel)
			{
				placedBomb = Reg.PS.addBomb(this);
				placedBomb.setPower(powerLevel);
				placedBomb.setBomber(this);
				
				++bombCount;
				
				soundBombDrop.play();
			}
			else if (controller.justPressed(PlayerController.BOMB_BUTTON) && toss && placedBomb != null)
			{
				placedBomb.pickUp();
			}
			else if (controller.justReleased(PlayerController.BOMB_BUTTON) && placedBomb != null && placedBomb.getHeld())
			{
				placedBomb.toss(2);
				placedBomb = null;
			}
			
			if (controller.justPressed(PlayerController.ACTION_BUTTON) && punch && (placedBomb == null || !placedBomb.getHeld()))
			{
				var testObj:FlxObject = new FlxObject(x, y);
				
				switch (facing)
				{
					case FlxObject.DOWN:
						testObj.y += 16;
					case FlxObject.UP:
						testObj.y -= 16;
					case FlxObject.LEFT:
						testObj.x -= 16;
					case FlxObject.RIGHT:
						testObj.x += 16;
				}
				
				var target:Bomb = Reg.PS.getBomb(testObj);
				
				if (target != null)
				{
					if ((facing == FlxObject.DOWN && target.y - y < 18) ||
					    (facing == FlxObject.UP && y - target.y < 18) ||
						(facing == FlxObject.LEFT && x - target.x < 18) ||
						(facing == FlxObject.RIGHT && target.x - x < 18))
					{
						target.toss(2, facing);
					}
				}
			}
		}
		else
		{
			moveDead();
			
			if (controller.justPressed(PlayerController.BOMB_BUTTON) && placedBomb == null && bombCount < bombLevel)
			{
				placedBomb = Reg.PS.addBomb(this);
				placedBomb.setPower(powerLevel);
				placedBomb.setBomber(this);
				
				++bombCount;
				
				soundBombDrop.play();
				
				placedBomb.toss(4);
				placedBomb = null;
			}
		}
	}
	
	public function getKick():Bool
	{
		return kick;
	}
	
	public function getDead():Bool
	{
		return dead;
	}
	
	public function bombExploded():Void
	{
		--bombCount;
	}
	
	public function explode():Void
	{
		dead = true;
		solid = false;
		
		bombLevel = 1;
		powerLevel = 1;
		speedLevel = 2;
		
		var targetPoint:FlxPoint = FlxPoint.get();
		
		switch (facing)
		{
			case FlxObject.LEFT:
				animation.play("dead-left");
				targetPoint.x = Reg.PS.getWidth() - 32;
				targetPoint.y = y;
			case FlxObject.RIGHT:
				animation.play("dead-right");
				targetPoint.x = 16;
				targetPoint.y = y;
			case FlxObject.DOWN:
				animation.play("dead-down");
				targetPoint.x = x;
				targetPoint.y = 16;
			case FlxObject.UP:
				animation.play("dead-up");
				targetPoint.x = x;
				targetPoint.y = Reg.PS.getHeight() - 16;
		}
		
		var tweenOptions:TweenOptions = {type: FlxTween.ONESHOT}
		var tween:FlxTween = FlxTween.linearMotion(this, x, y, targetPoint.x, targetPoint.y, 0.5, true, tweenOptions);
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
	
	private function moveDead():Void
	{
		if (!controller.pressed(PlayerController.LEFT_BUTTON) && 
		    !controller.pressed(PlayerController.RIGHT_BUTTON) &&
			!controller.pressed(PlayerController.UP_BUTTON) &&
			!controller.pressed(PlayerController.DOWN_BUTTON))
		{
			deadVx = 0;
			deadVy = 0;
		}
		
		if (controller.justPressed(PlayerController.LEFT_BUTTON))
		{
			if (facing == FlxObject.UP || facing == FlxObject.DOWN)
			{
				deadVx = -1 * speedLevel;
				deadVy = 0;
			}
		}
		else if (controller.justPressed(PlayerController.RIGHT_BUTTON))
		{
			if (facing == FlxObject.UP || facing == FlxObject.DOWN)
			{
				deadVx = speedLevel;
				deadVy = 0;
			}
		}
		else if (controller.justPressed(PlayerController.UP_BUTTON))
		{
			if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
			{
				deadVx = 0;
				deadVy = -1 * speedLevel;
			}
		}
		else if (controller.justPressed(PlayerController.DOWN_BUTTON))
		{
			if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
			{
				deadVx = 0;
				deadVy = speedLevel;
			}
		}
		
		if (y < 32 && deadVy < 0)
		{
			if (facing == FlxObject.RIGHT)
			{
				deadVx = -1 * deadVy;
				deadVy = 0;
				
				x = 32;
				y = 16;
			}
			else if (facing == FlxObject.LEFT)
			{
				deadVx = deadVy;
				deadVy = 0;
				
				x = Reg.PS.getWidth() - 48;
				y = 16;
			}
		}
		else if (y > Reg.PS.getHeight() - 32 && deadVy > 0)
		{
			if (facing == FlxObject.RIGHT)
			{
				deadVx = deadVy;
				deadVy = 0;
				
				x = 32;
				y = Reg.PS.getHeight() - 16;
			}
			else if (facing == FlxObject.LEFT)
			{
				deadVx = -1 * deadVy;
				deadVy = 0;
				
				x = Reg.PS.getWidth() - 48;
				y = Reg.PS.getHeight() - 16;
			}
		}
		else if (x < 32 && deadVx < 0)
		{
			if (facing == FlxObject.DOWN)
			{
				deadVy = -1 * deadVx;
				deadVx = 0;
				
				x = 16;
				y = 32;
			}
			else if (facing == FlxObject.UP)
			{
				deadVy = deadVx;
				deadVx = 0;
				
				x = 16;
				y = Reg.PS.getHeight() - 32;
			}
		}
		else if (x > Reg.PS.getWidth() - 48 && deadVx > 0)
		{
			if (facing == FlxObject.DOWN)
			{
				deadVy = deadVx;
				deadVx = 0;
				
				x = Reg.PS.getWidth() - 32;
				y = 32;
			}
			else if (facing == FlxObject.UP)
			{
				deadVy = -1 * deadVx;
				deadVx = 0;
				
				x = Reg.PS.getWidth() - 32;
				y = Reg.PS.getHeight() - 32;
			}
		}
		
		if (x == 16)
		{
			facing = FlxObject.RIGHT;
			animation.play("dead-right");
		}
		else if (x == Reg.PS.getWidth() - 32)
		{
			facing = FlxObject.LEFT;
			animation.play("dead-left");
		}
		else if (y == Reg.PS.getHeight() - 16)
		{
			facing = FlxObject.UP;
			animation.play("dead-up");
		}
		else if (y == 16)
		{
			facing = FlxObject.DOWN;
			animation.play("dead-down");
		}
		
		x += deadVx;
		y += deadVy;
	}
	
	private function move():Void
	{
		if (controller.pressed(PlayerController.LEFT_BUTTON))
		{
			x -= speedLevel;
			animation.play("walk-left");
			facing = FlxObject.LEFT;
		}
		else if (controller.pressed(PlayerController.RIGHT_BUTTON))
		{
			x += speedLevel;
			animation.play("walk-right");
			facing = FlxObject.RIGHT;
		}
		else if (controller.pressed(PlayerController.UP_BUTTON))
		{
			y -= speedLevel;
			animation.play("walk-up");
			facing = FlxObject.UP;
		}
		else if (controller.pressed(PlayerController.DOWN_BUTTON))
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