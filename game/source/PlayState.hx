package;

import entities.TiledLevel;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var level:TiledLevel;
	
	override public function create():Void
	{
		level = new TiledLevel("assets/levels/box-city.tmx");
		
		add(level.backgroundTiles);
		add(level.foregroundTiles);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
	}	
}