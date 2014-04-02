package entities;
import flixel.FlxSprite;

class CollectibleShadow extends FlxSprite
{
	
	public var collectible:Collectible;

	public function new(c:Collectible) 
	{
		super();
		
		collectible = c;
	}
}