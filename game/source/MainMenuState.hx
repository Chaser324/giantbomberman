package;

import flash.display.BlendMode;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class MainMenuState extends FlxState
{
	private var logo:FlxSprite;
	private var pattern:FlxSprite;
	private var bomb:FlxSprite;
	private var pressStart:FlxSprite;
	private var overlay:FlxSprite;
	
	private var stingerSound:FlxSound;
	
	private var bombTween:FlxTween;
	private var bombScaleTween:FlxTween;
	private var logoTween:FlxTween;
	private var logoTrail:FlxTrail;
	
	private var sparkEmitter:FlxEmitter;
	
	private var started:Bool = false;
	
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
			//spark.visible = false;
			sparkEmitter.add(spark);
		}
		
		add(pattern);
		add(bomb);
		add(sparkEmitter);
		add(pressStart);
		add(logoTrail);
		add(logo);
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
		
		if ((FlxG.keys.justPressed.ANY || FlxG.gamepads.anyButton()) && !started)
		{
			started = true;
			somethingPressed();
		}
	}
	
	private function somethingPressed():Void
	{
		var tweenOptions:TweenOptions = { type: FlxTween.ONESHOT, ease: FlxEase.backIn, startDelay: 1.5 };
		
		bombTween.cancel();
		logoTrail.kill();
		
		bomb.scale.x = 1;
		bomb.scale.y = 1;
		bomb.angle = 0;
		
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
		FlxG.switchState(new PlayState());
	}
}