package;

import entities.Bomb;
import entities.Collectible;
import entities.CollectibleShadow;
import entities.Explosion;
import entities.Player;
import entities.SoftWall;
import entities.TiledLevel;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.util.FlxPoint;
import flixel.util.FlxSort;

class PlayState extends FlxState
{
	public var players:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	
	public var sortGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	
	private var explosions:FlxTypedGroup<Explosion> = new FlxTypedGroup<Explosion>();	
	private var bombs:FlxTypedGroup<Bomb> = new FlxTypedGroup<Bomb>();
	private var softwalls:FlxTypedGroup<SoftWall> = new FlxTypedGroup<SoftWall>();
	private var collectibles:FlxTypedGroup<Collectible> = new FlxTypedGroup<Collectible>();
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
		add(sortGroup); // display group for players, collectibles
		level.loadObjects(this);
		
		for (p in players)
		{
			sortGroup.add(p);
		}
		
		FlxG.sound.play("assets/music/game-main-intro.wav", 1, false, true, startMusicLoop);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		FlxG.collide(players, level.foregroundTiles, overlapPlayerWall);
		FlxG.collide(players, softwalls, overlapPlayerWall);
		
		FlxG.collide(bombs, level.foregroundTiles, overlapBombWall);
		FlxG.collide(bombs, softwalls, overlapBombWall);
		FlxG.collide(bombs, bombs, overlapBombBomb);
		
		FlxG.overlap(players, bombs, overlapPlayerBomb);
		
		FlxG.overlap(players, collectibles, overlapPlayerCollectible);
		
		FlxG.overlap(explosions, softwalls, overlapExplosionWall);
		FlxG.overlap(explosions, bombs, overlapExplosionBomb);
		FlxG.overlap(explosions, players, overlapExplosionPlayer);
		FlxG.overlap(explosions, collectibles, overlapExplosionCollectible);
		
		sortGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
	}
	
	public function addBomb(bomber:Player):Bomb
	{
		var bomb:Bomb = bombs.recycle(Bomb);
		
		bomb.x = 16 * Math.round(bomber.x / 16);
		bomb.y = 16 * Math.round(bomber.y / 16);
		
		return bomb;
	}
	
	public function addCollectible():Collectible
	{
		return collectibles.recycle(Collectible);
	}
	
	public function addExplosion():Explosion
	{
		return explosions.recycle(Explosion);
	}
	
	public function addSoftWall():SoftWall
	{
		return softwalls.recycle(SoftWall);
	}
	
	public function getWidth():Int
	{
		return level.fullWidth;
	}
	
	public function getHeight():Int
	{
		return level.fullHeight;
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
	
	public function bombCollideTest(obj:FlxObject):Bool
	{
		var retVal:Bool = false;
		
		for (w in bombs)
		{
			if (!w.alive || w == obj)
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
	
	public function inBoundsTest(obj:FlxObject):Bool
	{
		var retVal:Bool = false;
		
		if (obj.x > 0 && obj.y > 0 && obj.x < level.fullWidth && obj.y < level.fullHeight)
		{
			retVal = true;
		}
		
		return retVal;
	}
	
	private function startMusicLoop():Void
	{
		FlxG.sound.playMusic("assets/music/game-main-loop.wav");
	}
	
	private function overlapPlayerCollectible(p:Player, shadow:CollectibleShadow)
	{
		p.collect(shadow.collectible.getType());
		shadow.collectible.explode();
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
	
	private function overlapExplosionCollectible(e:Explosion, shadow:CollectibleShadow)
	{
		if (e.alive && e.x == shadow.x && e.y == shadow.y)
		{
			shadow.collectible.explode();
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
	
	private function overlapBombBomb(b1:Bomb, b2:Bomb)
	{
		b1.x = 16 * Math.round(b1.x / 16);
		b1.y = 16 * Math.round(b1.y / 16);
		b1.stopSlide();
		
		b2.x = 16 * Math.round(b2.x / 16);
		b2.y = 16 * Math.round(b2.y / 16);
		b2.stopSlide();
	}
	
	private function overlapBombWall(b:Bomb, w:FlxObject)
	{
		b.x = 16 * Math.round(b.x / 16);
		b.y = 16 * Math.round(b.y / 16);
		b.stopSlide();
	}
	
	private function overlapPlayerWall(p:Player, w:FlxObject)
	{
		p.x = Math.round(p.x);
		p.y = Math.round(p.y);
		
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
		var dx:Float = p.x - b.x;
		var dy:Float = p.y - b.y;
			
		if (p.placedBomb != b)
		{
			if (dy == 0 && Math.abs(dx) < 16)
			{
				p.x = 16 * Math.round(p.x / 16);
			}
			else if (dx == 0 && Math.abs(dy) < 16)
			{
				p.y = 16 * Math.round(p.y / 16);
			}
			
			if (p.getKick())
			{
				if (dx > 0 && p.facing == FlxObject.LEFT)
				{
					b.slide(FlxObject.LEFT);
				}
				else if (dx < 0 && p.facing == FlxObject.RIGHT)
				{
					b.slide(FlxObject.RIGHT);
				}
				else if (dy > 0 && p.facing == FlxObject.UP)
				{
					b.slide(FlxObject.UP);
				}
				else if (dy < 0 && p.facing == FlxObject.DOWN)
				{
					b.slide(FlxObject.DOWN);
				}
			}
		}
	}
}