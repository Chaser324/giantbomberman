package;

import entities.Bomb;
import entities.Explosion;
import entities.Player;
import entities.TiledLevel;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

class PlayState extends FlxState
{
	public var players:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	
	private var explosions:FlxTypedGroup<Explosion> = new FlxTypedGroup<Explosion>();	
	private var bombs:FlxTypedGroup<Bomb> = new FlxTypedGroup<Bomb>();
	
	private var level:TiledLevel;
	
	override public function create():Void
	{
		super.create();
		
		Reg.PS = this;
		
		FlxG.mouse.visible = false;
		
		players.add(new Player(0,0));
		
		level = new TiledLevel("assets/levels/box-city.tmx");
		
		add(level.backgroundTiles);
		add(level.foregroundTiles);
		add(explosions);
		add(bombs);
		add(players);
		level.loadObjects(this);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		FlxG.collide(level.foregroundTiles, players, overlapPlayerWall);
		FlxG.overlap(players, bombs, overlapPlayerBomb);
	}
	
	public function addBomb(bomber:Player):Bomb
	{
		var bomb:Bomb = bombs.recycle(Bomb);
		
		bomb.x = 16 * Math.round(bomber.x / 16);
		bomb.y = 16 * Math.round(bomber.y / 16);
		
		bomber.placedBomb = bomb;
		
		return bomb;
	}
	
	public function addExplosion():Explosion
	{
		return explosions.recycle(Explosion);
	}
	
	public function wallCollideTest(obj:FlxObject):Bool
	{
		return FlxG.overlap(level.foregroundTiles, obj);
	}
	
	private function overlapPlayerWall(w:FlxObject, p:Player)
	{
		var dx:Float = p.x % 16;
		var dy:Float = p.y % 16;
		
		if (dx > 0 && dx < 7)
		{
			p.x -= 1;
		}
		else if (dx < 16 && dx > 9)
		{
			p.x += 1;
		}
		
		if (dy > 0 && dy < 7)
		{
			p.y -= 1;
		}
		else if (dy < 16 && dy > 9)
		{
			p.y += 1;
		}
	}
	
	private function overlapPlayerBomb(p:Player, b:Bomb):Void
	{
		if (p.placedBomb != b)
		{
			var dx:Float = p.x - b.x;
			var dy:Float = p.y - b.y;
			
			if (dy == 0 && Math.abs(dx) < 16)
			{
				p.x = 16 * Math.round(p.x / 16);
			}
			else if (dx == 0 && Math.abs(dy) < 16)
			{
				p.y = 16 * Math.round(p.y / 16);
			}
		}
	}
}