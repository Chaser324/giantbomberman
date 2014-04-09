package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;

class PlayerController extends FlxObject
{
	public static inline var UP_BUTTON:Int = 0;
	public static inline var DOWN_BUTTON:Int = 1;
	public static inline var LEFT_BUTTON:Int = 2;
	public static inline var RIGHT_BUTTON:Int = 3;
	public static inline var BOMB_BUTTON:Int = 4;
	public static inline var ACTION_BUTTON:Int = 5;
	public static inline var CANCEL_BUTTON:Int = 6;
	public static inline var CONFIRM_BUTTON:Int = 7;
	
	private var gamepad:FlxGamepad = null;
	private var gamepadLastX:Float = 0;
	private var gamepadLastY:Float = 0;
	private var gamepadX:Float = 0;
	private var gamepadY:Float = 0;

	public function new(g:FlxGamepad = null) 
	{
		super();
		
		if (g != null)
		{
			gamepad = g;
			gamepad.deadZone = 0.8;
		}
	}
	
	override public function update():Void
	{
		super.update();
		
		if (gamepad != null)
		{
			gamepadLastX = gamepadX;
			gamepadLastY = gamepadY;
#if flash
			gamepadX = gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X);
			gamepadY = gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y);
#else
			gamepadX = gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X) + gamepad.hat.x;
			gamepadY = gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y) + gamepad.hat.y;
#end
		}
	}
	
	public function getID():Int
	{
		if (gamepad != null)
		{
			return gamepad.id;
		}
		else
		{
			return -1;
		}
	}
	
	public function pressed(button:Int):Bool
	{
		if (gamepad == null)
		{
			switch(button)
			{
				case UP_BUTTON:
					return FlxG.keys.pressed.UP;
				case DOWN_BUTTON:
					return FlxG.keys.pressed.DOWN;
				case LEFT_BUTTON:
					return FlxG.keys.pressed.LEFT;
				case RIGHT_BUTTON:
					return FlxG.keys.pressed.RIGHT;
				case BOMB_BUTTON:
					return FlxG.keys.pressed.Z || FlxG.keys.pressed.ENTER || FlxG.keys.pressed.Y;
				case ACTION_BUTTON:
					return FlxG.keys.pressed.X;
				case CANCEL_BUTTON:
					return FlxG.keys.pressed.ESCAPE;
				case CONFIRM_BUTTON:
					return FlxG.keys.pressed.Z || FlxG.keys.pressed.ENTER || FlxG.keys.pressed.Y;
				default:
					return false;
			}
		}
		else
		{
			switch(button)
			{
				case BOMB_BUTTON:
					return gamepad.pressed(XboxButtonID.A);
				case ACTION_BUTTON:
					return gamepad.pressed(XboxButtonID.X);
				case CANCEL_BUTTON:
					return gamepad.pressed(XboxButtonID.B);
				case CONFIRM_BUTTON:
					return gamepad.pressed(XboxButtonID.A) || gamepad.pressed(XboxButtonID.START);
#if flash
				case LEFT_BUTTON:
					return gamepad.pressed(XboxButtonID.DPAD_LEFT) || gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X) < 0;
				case RIGHT_BUTTON:
					return gamepad.pressed(XboxButtonID.DPAD_RIGHT) || gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X) > 0;
				case UP_BUTTON:
					return gamepad.pressed(XboxButtonID.DPAD_UP) || gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y) < 0;
				case DOWN_BUTTON:
					return gamepad.pressed(XboxButtonID.DPAD_DOWN) || gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y) > 0;
#else
				case LEFT_BUTTON:
					return gamepad.hat.x < 0 || gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X) < 0;
				case RIGHT_BUTTON:
					return gamepad.hat.x > 0 || gamepad.getXAxis(XboxButtonID.LEFT_ANALOGUE_X) > 0;
				case UP_BUTTON:
					return gamepad.hat.y < 0 || gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y) < 0;
				case DOWN_BUTTON:
					return gamepad.hat.y > 0 || gamepad.getYAxis(XboxButtonID.LEFT_ANALOGUE_Y) > 0;
#end
				default:
					return false;
			}
		}
	}
	
	public function justPressed(button:Int):Bool
	{
		if (gamepad == null)
		{
			switch(button)
			{
				case UP_BUTTON:
					return FlxG.keys.justPressed.UP;
				case DOWN_BUTTON:
					return FlxG.keys.justPressed.DOWN;
				case LEFT_BUTTON:
					return FlxG.keys.justPressed.LEFT;
				case RIGHT_BUTTON:
					return FlxG.keys.justPressed.RIGHT;
				case BOMB_BUTTON:
					return FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Y;
				case ACTION_BUTTON:
					return FlxG.keys.justPressed.X;
				case CANCEL_BUTTON:
					return FlxG.keys.justPressed.ESCAPE;
				case CONFIRM_BUTTON:
					return FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Y;
				default:
					return false;
			}
		}
		else
		{
			switch(button)
			{
				case BOMB_BUTTON:
					return gamepad.justPressed(XboxButtonID.A);
				case ACTION_BUTTON:
					return gamepad.justPressed(XboxButtonID.X);
				case CANCEL_BUTTON:
					return gamepad.justPressed(XboxButtonID.B);
				case CONFIRM_BUTTON:
					return gamepad.justPressed(XboxButtonID.A) || gamepad.justPressed(XboxButtonID.START);
#if flash
				case LEFT_BUTTON:
					return gamepad.justPressed(XboxButtonID.DPAD_LEFT) || (gamepadLastX == 0 && gamepadX < 0);
				case RIGHT_BUTTON:
					return gamepad.justPressed(XboxButtonID.DPAD_RIGHT) || (gamepadLastX == 0 && gamepadX > 0);
				case UP_BUTTON:
					return gamepad.justPressed(XboxButtonID.DPAD_UP) || (gamepadLastY == 0 && gamepadY < 0);
				case DOWN_BUTTON:
					return gamepad.justPressed(XboxButtonID.DPAD_DOWN) || (gamepadLastY == 0 && gamepadY > 0);
#else
				case LEFT_BUTTON:
					return (gamepadLastX == 0 && gamepadX < 0);
				case RIGHT_BUTTON:
					return (gamepadLastX == 0 && gamepadX > 0);
				case UP_BUTTON:
					return (gamepadLastY == 0 && gamepadY < 0);
				case DOWN_BUTTON:
					return (gamepadLastY == 0 && gamepadY > 0);
#end
				default:
					return false;
			}
		}
	}
	
	public function justReleased(button:Int):Bool
	{
		if (gamepad == null)
		{
			switch(button)
			{
				case UP_BUTTON:
					return FlxG.keys.justReleased.UP;
				case DOWN_BUTTON:
					return FlxG.keys.justReleased.DOWN;
				case LEFT_BUTTON:
					return FlxG.keys.justReleased.LEFT;
				case RIGHT_BUTTON:
					return FlxG.keys.justReleased.RIGHT;
				case BOMB_BUTTON:
					return FlxG.keys.justReleased.Z || FlxG.keys.justReleased.ENTER || FlxG.keys.justReleased.Y;
				case ACTION_BUTTON:
					return FlxG.keys.justReleased.X;
				case CANCEL_BUTTON:
					return FlxG.keys.justReleased.ESCAPE;
				case CONFIRM_BUTTON:
					return FlxG.keys.justReleased.Z || FlxG.keys.justReleased.ENTER || FlxG.keys.justReleased.Y;
				default:
					return false;
			}
		}
		else
		{
			switch(button)
			{
				case BOMB_BUTTON:
					return gamepad.justReleased(XboxButtonID.A);
				case ACTION_BUTTON:
					return gamepad.justReleased(XboxButtonID.X);
				case CANCEL_BUTTON:
					return gamepad.justReleased(XboxButtonID.B);
				case CONFIRM_BUTTON:
					return gamepad.justReleased(XboxButtonID.A) || gamepad.justReleased(XboxButtonID.START);
#if flash
				case LEFT_BUTTON:
					return gamepad.justReleased(XboxButtonID.DPAD_LEFT) || (gamepadX == 0 && gamepadLastX < 0);
				case RIGHT_BUTTON:
					return gamepad.justReleased(XboxButtonID.DPAD_RIGHT) || (gamepadX == 0 && gamepadLastX > 0);
				case UP_BUTTON:
					return gamepad.justReleased(XboxButtonID.DPAD_UP) || (gamepadY == 0 && gamepadLastY < 0);
				case DOWN_BUTTON:
					return gamepad.justReleased(XboxButtonID.DPAD_DOWN) || (gamepadY == 0 && gamepadLastY > 0);
#else
				case LEFT_BUTTON:
					return (gamepadX == 0 && gamepadLastX < 0);
				case RIGHT_BUTTON:
					return (gamepadX == 0 && gamepadLastX > 0);
				case UP_BUTTON:
					return (gamepadY == 0 && gamepadLastY < 0);
				case DOWN_BUTTON:
					return (gamepadY == 0 && gamepadLastY > 0);
#end
				default:
					return false;
			}
		}
	}
	
}