package;

import entities.Bomb;
import entities.Explosion;
import entities.Player;
import entities.SoftWall;
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
import flixel.util.FlxPoint;

class PlayState extends FlxState
{
	public var players:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	
	private var explosions:FlxTypedGroup<Explosion> = new FlxTypedGroup<Explosion>();	
	private var bombs:FlxTypedGroup<Bomb> = new FlxTypedGroup<Bomb>();
	private var softwalls:FlxTypedGroup<SoftWall> = new FlxTypedGroup<SoftWall>();
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
		add(softwalls);
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
		FlxG.collide(softwalls, players, overlapPlayerWall);
		FlxG.overlap(players, bombs, overlapPlayerBomb);
		
		FlxG.overlap(explosions, softwalls, overlapExplosionWall);
		FlxG.overlap(explosions, bombs, overlapExplosionBomb);
		FlxG.overlap(explosions, players, overlapExplosionPlayer);
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
	
	public function addSoftWall():SoftWall
	{
		return softwalls.recycle(SoftWall);
	}
	
	public function wallCollideTest(obj:FlxObject):Bool
	{
		var retVal:Bool = false;
		
		for (layer in level.foregroundTiles)
		{
			var layerCast:FlxObject = cast(layer, FlxObject);
			retVal = layerCast.overlapsPoint(new FlxPoint(obj.x + 8, obj.y + 8));
			
			if (retVal)
			{
				break;
			}
		}
		
		return retVal;
	}
	
	public function softWallCollideTest(obj:FlxObject):Bool
	{
		var retVal:Bool = false;
		
		for (w in softwalls)
		{
			if (!w.alive)
			{
				continue;
			}
			
			retVal = w.overlapsPoint(new FlxPoint(obj.x + 8, obj.y + 8));
			
			if (retVal)
			{
				break;
			}
		}
		
		return retVal;
	}
	
	private function overlapExplosionPlayer(e:Explosion, p:Player)
	{
		var testPoints:Array<FlxPoint> = [
			new FlxPoint(p.x, p.y),
			new FlxPoint(p.x + 8, p.y),
			new FlxPoint(p.x + 16, p.y),
			new FlxPoint(p.x + 16, p.y + 8),
			new FlxPoint(p.x + 16, p.y + 16),
			new FlxPoint(p.x + 8, p.y + 16),
			new FlxPoint(p.x, p.y + 16),
			new FlxPoint(p.x, p.y + 8),
		];
		
		for (point in testPoints)
		{
			if (e.pixelsOverlapPoint(point))
			{
				p.kill();
				break;
			}
		}
	}
	
	private function overlapExplosionBomb(e:Explosion, b:Bomb)
	{
		if (e.x == b.x && e.y == b.y)
		{
			e.kill();
			b.explode();
		}
	}
	
	private function overlapExplosionWall(e:Explosion, w:SoftWall)
	{
		if (e.x == w.x && e.y == w.y)
		{
			e.alive = false;
			w.explode();
		}
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