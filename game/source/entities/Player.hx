package entities;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	private static inline var TILE_SIZE:Int = 16;
	
	private var speed:Int = 2;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
		
		makeGraphic(TILE_SIZE, TILE_SIZE, 0xffff0000);
	}
	
	override public function update():Void
	{
		super.update();
	}
	
}