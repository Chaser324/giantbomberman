package entities;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;


class Collectible extends FlxGroup
{
	public static inline var TYPE_NONE:Int = -1;
	public static inline var TYPE_BOMB:Int = 0;
	public static inline var TYPE_SPEED:Int = 1;
	public static inline var TYPE_POWER:Int = 2;
	public static inline var TYPE_MAX:Int = 3;
	
	public var shadow:FlxSprite;
	public var icon:FlxSprite;
	
	private var type:Int;
	
	private var iconTween:FlxTween;

	public function new()
	{
		super();
		
		shadow = new CollectibleShadow(this);
		shadow.loadGraphic("assets/images/items.png", true, false, 16, 16);
		shadow.animation.frameIndex = 3;
		shadow.height = 16;
		shadow.width = 16;
		
		icon = new FlxSprite();
		icon.loadGraphic("assets/images/items.png", true, false, 16, 16);
		icon.height = 16;
		icon.width = 16;
		icon.offset.y = 2;
		icon.solid = false;
		
		add(shadow);
		add(icon);
		
		Reg.PS.sortGroup.add(shadow);
		Reg.PS.sortGroup.add(icon);
		
		startTween();
	}
	
	override public function revive():Void
	{
		super.revive();
		
		shadow.revive();
		icon.revive();
	}
	
	public function setPosition(X:Float, Y:Float):Void
	{
		shadow.x = X;
		shadow.y = Y;
		
		icon.x = X;
		icon.y = Y;
	}
	
	public function setType(t:Int):Void
	{
		type = t;
		icon.animation.frameIndex = t;
	}
	
	public function getType():Int
	{
		return type;
	}
	
	public function explode():Void
	{
		kill();
	}
	
	private function startTween(t:FlxTween = null):Void
	{
		if (iconTween != null && iconTween.finished == false)
		{
			iconTween.finish();
		}
		
		icon.offset.y = 3;
		
		var tweenOptions:TweenOptions = {type: FlxTween.PINGPONG, ease: FlxEase.quadInOut}
		iconTween = FlxTween.tween(icon.offset, { y: 7 }, 0.5, tweenOptions);
	}
	
}