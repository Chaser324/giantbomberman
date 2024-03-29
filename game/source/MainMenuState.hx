package;

import entities.Player;
import entities.PlayerAlex;
import entities.PlayerBrad;
import entities.PlayerController;
import entities.PlayerDrew;
import entities.PlayerJeff;
import entities.PlayerPatrick;
import entities.PlayerRorie;
import entities.PlayerRyan;
import entities.PlayerSelect;
import entities.PlayerVinny;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.input.gamepad.XboxButtonID;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

class MainMenuState extends FlxState
{
	private var logo:FlxSprite;
	private var pattern:FlxSprite;
	private var bomb:FlxSprite;
	private var pressStart:FlxSprite;
	private var overlay:FlxSprite;
	
	private var players:FlxTypedGroup<Player>;
	private var playerSelectors:FlxTypedGroup<PlayerSelect> = new FlxTypedGroup<PlayerSelect>();
	private var sortGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	
	private var stingerSound:FlxSound;
	
	private var bombTween:FlxTween;
	private var bombScaleTween:FlxTween;
	private var logoTween:FlxTween;
	private var logoTrail:FlxTrail;
	
	private var sparkEmitter:FlxEmitter;
	
	private var phase:Int = 0;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = false;
		
		bgColor = 0xff282581;
		
		logo = new FlxSprite();
		logo.loadGraphic("assets/images/title-logo.png");
		logo.x = (FlxG.width / 2) - (logo.frameWidth / 2);
		logo.y = 15;
		logo.angle = -5;
		
		bomb = new FlxSprite();
		bomb.loadGraphic("assets/images/title-bomb.png");
		bomb.x = (FlxG.width / 2) - (bomb.frameWidth / 2);
		bomb.y = (FlxG.height / 2) - (bomb.frameHeight / 2);
		
		pressStart = new FlxSprite();
		pressStart.loadGraphic("assets/images/title-press.png");
		pressStart.x = (FlxG.width / 2) - (pressStart.frameWidth / 2);
		pressStart.y = 180;
		
		overlay = new FlxSprite();
		overlay.makeGraphic(FlxG.width, FlxG.height);
		overlay.alpha = 0;
		
		pattern = new FlxSprite();
		pattern.loadGraphic("assets/images/title-pattern.png");
		
		logoTrail = new FlxTrail(logo, "assets/images/title-logo.png", 10, 3, 0.4, 0.05);
		
		var tweenOptions:TweenOptions = { type: FlxTween.PINGPONG, ease: FlxEase.quadInOut};
		logoTween = FlxTween.tween(logo, { angle: 5 }, 3, tweenOptions);
		
		tweenOptions = { type: FlxTween.LOOPING, ease: FlxEase.backInOut, loopDelay: 5, startDelay: 5 };
		bombTween = FlxTween.tween(bomb, { angle: 359 }, 1.5, tweenOptions);
		
		sparkEmitter = new FlxEmitter(pressStart.x, pressStart.y, 30);
		sparkEmitter.setXSpeed(0.5, 20.0);
		sparkEmitter.setYSpeed( -10.5, -20.0);
		sparkEmitter.setAlpha(0.8, 1, 0.0, 0.2);
		sparkEmitter.setSize(pressStart.frameWidth, pressStart.frameHeight);
		
		for (i in 0...sparkEmitter.maxSize)
		{
			var spark:FlxParticle = new FlxParticle();
			spark.makeGraphic(4, 4, 0xffd9df29);
			sparkEmitter.add(spark);
		}
		
		add(pattern);
		add(bomb);
		add(sparkEmitter);
		add(pressStart);
		add(logoTrail);
		add(logo);
		add(sortGroup);
		add(overlay);
		
		sparkEmitter.start(false, 1, .05);
		
		stingerSound = FlxG.sound.load("assets/sounds/title-stinger.wav");
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		switch (phase)
		{
			case 0:
				if ((FlxG.keys.justPressed.ANY || FlxG.gamepads.anyButton()))
				{
					++phase;
					
					pressStart.loadGraphic("assets/images/title-confirm.png");
					pressStart.x = (FlxG.width / 2) - (pressStart.frameWidth / 2);
					pressStart.y = FlxG.height - pressStart.frameHeight;
					
					sparkEmitter.setPosition(pressStart.x, pressStart.y);
					sparkEmitter.setSize(pressStart.frameWidth, pressStart.frameHeight);
					
					if (players == null)
					{
						players = new FlxTypedGroup<Player>();
						players.add(new PlayerAlex());
						players.add(new PlayerBrad());
						players.add(new PlayerDrew());
						players.add(new PlayerJeff());
						players.add(new PlayerPatrick());
						players.add(new PlayerRorie());
						players.add(new PlayerRyan());
						players.add(new PlayerVinny());
						
						for (i in 0...players.length)
						{
							players.members[i].x = i * 32 + 45;
							players.members[i].y = (i % 2) * 20 + 150;
							
							sortGroup.add(players.members[i]);
						}
					}
					
					for (p in players)
					{
						p.revive();
						p.setFixed(true);
					}
				}
			case 1:
				checkForNewPlayers();
				
				FlxG.overlap(playerSelectors, players, selectorPlayerOverlap);				
				sortGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
				
				var allConfirmed:Bool = false;
				for (s in playerSelectors)
				{
					if (s.alive && s.selectionConfirmed)
					{
						allConfirmed = true;
					}
					else
					{
						allConfirmed = false;
						break;
					}
				}
				
				if (allConfirmed)
				{
					++phase;
				}
			case 2:
				checkForNewPlayers();
				
				var allConfirmed:Bool = false;
				var startConfirmed:Bool = false;
				for (s in playerSelectors)
				{
					if (s.alive && s.controller.justPressed(PlayerController.CONFIRM_BUTTON))
					{
						startConfirmed = true;
					}
					
					if (s.alive && s.selectionConfirmed)
					{
						allConfirmed = true;
					}
					else
					{
						allConfirmed = false;
						break;
					}
				}
				
				if (!allConfirmed)
				{
					--phase;
				}
				else if (allConfirmed && startConfirmed)
				{
					++phase;
				}
			case 3:
				startGame();
				++phase;
		}
	}
	
	private function selectorPlayerOverlap(s:PlayerSelect, p:Player)
	{
		s.selectedPlayer = p;
		
		if (s.last.x == s.x && s.last.y == s.y)
		{
			s.x = p.x;
			s.y = p.y + 1;
		}
	}
	
	private function checkForNewPlayers():Void
	{
		if (FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.ESCAPE)
		{
			var alreadyAdded:Bool = false;
			for (s in playerSelectors)
			{
				if (s.alive && s.controller.getID() == -1)
				{
					alreadyAdded = true;
					break;
				}
			}
			
			if (!alreadyAdded)
			{
				var p:PlayerSelect = playerSelectors.recycle(PlayerSelect);
				
				p.controller = new PlayerController();
				p.animation.frameIndex = playerSelectors.members.indexOf(p);
				p.x = p.animation.frameIndex * 32 + 45;
				p.y = 110;
				
				sortGroup.add(p);
			}
		}
		
		for (g in FlxG.gamepads.getActiveGamepads())
		{
			if (g.anyJustPressed([XboxButtonID.A, XboxButtonID.START]) && !g.justPressed(XboxButtonID.B))
			{
				var alreadyAdded:Bool = false;
				for (s in playerSelectors)
				{
					if (s.alive && s.controller.getID() == g.id)
					{
						alreadyAdded = true;
						break;
					}
				}
				
				if (!alreadyAdded)
				{
					var p:PlayerSelect = playerSelectors.recycle(PlayerSelect);
					
					p.controller = new PlayerController(g);
					p.animation.frameIndex = playerSelectors.members.indexOf(p);
					p.x = p.animation.frameIndex * 32 + 45;
					p.y = 110;
					
					sortGroup.add(p);
				}
			}
		}
	}
	
	private function startGame():Void
	{
		var tweenOptions:TweenOptions = { type: FlxTween.ONESHOT, ease: FlxEase.backIn, startDelay: 1.5 };
		
		bombTween.cancel();
		logoTrail.kill();
		
		bomb.scale.x = 1;
		bomb.scale.y = 1;
		bomb.angle = 0;
		
		for (p in players)
		{
			FlxTween.tween(p.scale, { x: 0, y: 0 }, 1, tweenOptions);
			FlxTween.tween(p, { x: FlxG.width / 2, y: FlxG.height / 2 }, 1, tweenOptions);
		}
		
		for (p in playerSelectors)
		{
			FlxTween.tween(p.scale, { x: 0, y: 0 }, 1, tweenOptions);
			FlxTween.tween(p, { x: FlxG.width / 2, y: FlxG.height / 2 }, 1, tweenOptions);
		}
		
		FlxTween.tween(bomb.scale, { x: 0, y: 0 }, 1, tweenOptions);
		FlxTween.tween(bomb, { angle: 359 }, 1, tweenOptions);
		FlxTween.tween(pressStart.scale, { x: 0, y: 0 }, 1, tweenOptions);
		FlxTween.tween(logo.scale, { x: 0, y: 0 }, 1, tweenOptions);
		
		FlxTween.tween(pressStart, { y: FlxG.height / 2 }, 1, tweenOptions);
		FlxTween.tween(logo, { y: FlxG.height / 2 }, 1, tweenOptions);
		
		FlxTween.tween(overlay, { alpha: 1 }, 0.8, tweenOptions);
		
		stingerSound.play();
		
		FlxTimer.start(4.5, nextScene, 1);
	}
	
	private function nextScene(timer:FlxTimer):Void
	{
		var selectedPlayers:Array<Player> = new Array<Player>();
		
		for (p in players)
		{
			if (p.hasController())
			{
				p.playerNumber = selectedPlayers.length;
				selectedPlayers.push(p);
			}
		}
		
		var ps:PlayState = new PlayState();
		ps.setPlayers(selectedPlayers);
		FlxG.switchState(ps);
	}
}