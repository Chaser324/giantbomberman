package;

import entities.Bomb;
import entities.Collectible;
import entities.CollectibleShadow;
import entities.Explosion;
import entities.Player;
import entities.PlayerController;
import entities.PlayerUI;
import entities.SoftWall;
import entities.TiledLevel;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	public var players:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	
	public var sortGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	
	private var ui:FlxTypedGroup<PlayerUI> = new FlxTypedGroup<PlayerUI>();
	private var explosions:FlxTypedGroup<Explosion> = new FlxTypedGroup<Explosion>();	
	private var bombs:FlxTypedGroup<Bomb> = new FlxTypedGroup<Bomb>();
	private var softwalls:FlxTypedGroup<SoftWall> = new FlxTypedGroup<SoftWall>();
	private var collectibles:FlxTypedGroup<Collectible> = new FlxTypedGroup<Collectible>();
	private var level:TiledLevel;
	
	private var message:FlxSprite;
	
	private var roundComplete:Bool = false;
	private var matchComplete:Bool = false;
	private var resultText:String;
	
	private var phase:Int = 0;
	
	override public function create():Void
	{
		super.create();
		
		Reg.PS = this;
		
		FlxG.mouse.visible = false;
		
		for (p in players)
		{
			p.revive();
			ui.add(new PlayerUI(p));
			p.setFixed(true);
		}
		
		level = new TiledLevel("assets/levels/box-city.tmx");
		
		add(level.backgroundTiles);
		add(level.foregroundTiles);
		add(softwalls);
		add(explosions);
		add(bombs);
		add(ui);
		add(sortGroup); // display group for players, collectibles
		level.loadObjects(this);
		
		FlxG.sound.play("assets/music/game-main-intro.wav", 1, false, true, startMusicLoop);
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		switch(phase)
		{
			case 0:
				message = new FlxSprite();
				message.loadGraphic("assets/images/game-ready.png");
				message.x = (FlxG.width / 2) - (message.frameWidth / 2);
				message.y = (FlxG.height / 2) - (message.frameHeight / 2) - 50;
				
				add(message);
				
				var tweenOptions:TweenOptions = { type: FlxTween.ONESHOT, ease: FlxEase.bounceOut, complete: nextPhaseTween };
				FlxTween.tween(message, { y: message.y + 50 }, 0.7, tweenOptions);
				
				++phase;
			case 2:
				FlxTimer.start(2, nextPhaseTimer, 1);
				++phase;
			case 4:
				message.loadGraphic("assets/images/game-fight.png");
				message.x = (FlxG.width / 2) - (message.frameWidth / 2);
				message.y = (FlxG.height / 2) - (message.frameHeight / 2);
				message.scale.x = 0.5;
				message.scale.y = 0.5;
				
				var tweenOptions:TweenOptions = { type: FlxTween.ONESHOT, ease: FlxEase.elasticOut, complete: nextPhaseTween };
				FlxTween.tween(message.scale, { x: 1, y: 1 }, 0.7, tweenOptions);
				
				++phase;
			case 6:
				FlxTimer.start(0.5, nextPhaseTimer, 1);
				++phase;
			case 8:
				remove(message);
				++phase;
				
				for (p in players)
				{
					p.setFixed(false);
				}
			case 9:
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
				
				var winner:Player = null;
				var livingCount:Int = 0;
				for (p in players)
				{
					if (!p.getDead())
					{
						++livingCount;
						winner = p;
					}
				}
				
				if (livingCount == 0)
				{
					roundComplete = true;
					resultText = "DRAW";
					++phase;
				}
				else if (livingCount == 1)
				{
					roundComplete = true;
					winner.wins += 1;
					
					resultText = winner.playerName + " WINS ROUND";
					
					++phase;
					
					if (winner.wins == 3)
					{
						resultText = winner.playerName + " WINS MATCH";
						matchComplete = true;
					}	
				}
				
				sortGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
			case 10:
				var winText:FlxText = new FlxText(0, 100, FlxG.width, resultText, 25);
				winText.font = "assets/fonts/slicker.ttf";
				winText.antialiasing = false;
				winText.borderStyle = FlxText.BORDER_SHADOW;
				winText.borderColor = 0x000000;
				winText.borderSize = 5;
				winText.alignment = "center";
				add(winText);
				
				for (p in players)
				{
					p.setFixed(true);
				}
				
				remove(bombs);
				remove(explosions);
				
				FlxTimer.start(3, nextPhaseTimer, 1);
				++phase;
			case 12:
				switchState();
		}
	}
	
	public function setPlayers(pArray:Array<Player>)
	{
		for (p in pArray)
		{
			var p2:Player = new Player();
			
			p2.setGraphicPath(p.getGraphicPath());
			p2.controller = p.controller;
			p2.playerName = p.playerName;
			p2.wins = p.wins;
			p2.playerNumber = p.playerNumber;
			
			players.add(p2);
			sortGroup.add(p2);
		}
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
			retVal = layerCast.overlapsPoint(FlxPoint.get(obj.x + 8, obj.y + 8));
			
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
			
			retVal = w.overlapsPoint(FlxPoint.get(obj.x + 8, obj.y + 8));
			
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
			
			retVal = w.overlapsPoint(FlxPoint.get(obj.x + 8, obj.y + 8));
			
			if (retVal)
			{
				break;
			}
		}
		
		return retVal;
	}
	
	public function getBomb(obj:FlxObject):Bomb
	{
		var retVal:Bomb = null;
		
		for (w in bombs)
		{
			if (!w.alive || w == obj)
			{
				continue;
			}
			
			if (w.overlapsPoint(FlxPoint.get(obj.x + 8, obj.y + 8)))
			{
				retVal = w;
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
			FlxPoint.get(p.x, p.y),
			FlxPoint.get(p.x + 8, p.y),
			FlxPoint.get(p.x + 16, p.y),
			FlxPoint.get(p.x + 16, p.y + 8),
			FlxPoint.get(p.x + 16, p.y + 16),
			FlxPoint.get(p.x + 8, p.y + 16),
			FlxPoint.get(p.x, p.y + 16),
			FlxPoint.get(p.x, p.y + 8),
		];
		
		for (point in testPoints)
		{
			if (e.pixelsOverlapPoint(point))
			{
				p.explode();
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
	
	private function nextPhaseTween(t:FlxTween):Void
	{
		++phase;
	}
	
	private function nextPhaseTimer(t:FlxTimer):Void
	{
		++phase;
	}
	
	private function switchState():Void
	{
		if (!matchComplete)
		{
			var ps:PlayState = new PlayState();
			ps.setPlayers(players.members);
			FlxG.switchState(ps);
		}
		else
		{
			FlxG.resetGame();
		}
	}
}