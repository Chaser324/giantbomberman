package;

import entities.Player;
import entities.TiledLevel;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

class PlayState extends FlxState
{
	public var players:Array<Player>;
	
	private var level:TiledLevel;
	
	override public function create():Void
	{
		super.create();
		
		Reg.PS = this;
		
		FlxG.mouse.visible = false;
		
		players = new Array<Player>();
		players.push(new Player(0,0));
		
		level = new TiledLevel("assets/levels/box-city.tmx");
		
		add(level.backgroundTiles);
		add(level.foregroundTiles);
		level.loadObjects(this);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		level.collideWithLevel(players[0]);
	}
}