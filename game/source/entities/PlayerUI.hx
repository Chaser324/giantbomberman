package entities;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class PlayerUI extends FlxGroup
{
	private var face:FlxSprite;
	private var wins:FlxText;

	public function new(p:Player)
	{
		super();
		
		face = new FlxSprite(p.playerNumber * 32 + 16, 0);
		face.loadGraphic(p.getGraphicPath(), true, false, 16, 16);
		face.height = 16;
		face.width = 16;
		face.solid = false;
		face.animation.frameIndex = 48;
		
		wins = new FlxText(face.x + 16, 2, 16, Std.string(p.wins), 8);
		
		add(face);
		add(wins);
		
		Reg.PS.sortGroup.add(face);
		Reg.PS.sortGroup.add(wins);
	}	
}