package entities;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class SoftWall extends FlxSprite
{
	public var collectible:Int = Collectible.TYPE_NONE;

	public function new() 
	{
		super();
		
		height = 16;
		width = 16;
		
		immovable = true;
		
		if (FlxRandom.chanceRoll(25))
		{
			collectible = FlxRandom.intRanged(0, Collectible.TYPE_MAX - 1);
		}
	}
	
	public function setImage(imagePath:String, index:Int)
	{
		loadGraphic(imagePath, true, false, 16, 16);
		animation.frameIndex = index;
	}
	
	public function explode():Void
	{
		if (collectible != Collectible.TYPE_NONE)
		{
			var c:Collectible = Reg.PS.addCollectible();
			c.setPosition(x, y);
			c.setType(collectible);
		}
		
		kill();
	}
	
}