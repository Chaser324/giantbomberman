package entities;
import flixel.FlxSprite;

class SoftWall extends FlxSprite
{

	public function new() 
	{
		super();
		
		height = 16;
		width = 16;
		
		immovable = true;
	}
	
	public function setImage(imagePath:String, index:Int)
	{
		loadGraphic(imagePath, true, false, 16, 16);
		animation.frameIndex = index;
	}
	
	public function explode():Void
	{
		kill();
	}
	
}