package entities;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class PlayerSelect extends FlxSprite
{
	public var controller:PlayerController;
	public var selectedPlayer:Player;
	public var selectionConfirmed:Bool = false;

	public function new() 
	{
		super();
		
		loadGraphic("assets/images/spotlight.png", true, false, 24, 64);
		height = 16;
		width = 16;
		
		offset = FlxPoint.get(4, 48);
	}
	
	override public function revive():Void
	{
		super.revive();
		
		selectedPlayer = null;
		selectionConfirmed = false;
	}
	
	override public function update():Void
	{
		super.update();
		
		if (controller != null)
		{
			if (!selectionConfirmed)
			{
				if (controller.pressed(PlayerController.LEFT_BUTTON))
				{
					x -= 2;
				}
				else if (controller.pressed(PlayerController.RIGHT_BUTTON))
				{
					x += 2;
				}
				
				if (controller.pressed(PlayerController.UP_BUTTON))
				{
					y -= 2;
				}
				else if (controller.pressed(PlayerController.DOWN_BUTTON))
				{
					y += 2;
				}
				
				if (controller.justPressed(PlayerController.CANCEL_BUTTON))
				{
					kill();
				}
			}
			
			if (selectedPlayer != null)
			{
				if (controller.justPressed(PlayerController.CONFIRM_BUTTON) && !selectionConfirmed)
				{
					if (FlxG.overlap(this, selectedPlayer) == false)
					{
						selectedPlayer = null;
					}
					else
					{
						selectedPlayer.solid = false;
						selectedPlayer.controller = controller;
						selectionConfirmed = true;
						color = 0x00ff00;
						x = selectedPlayer.x;
						y = selectedPlayer.y + 1;
					}
				}
				else if (controller.justPressed(PlayerController.CANCEL_BUTTON) && selectionConfirmed)
				{
					selectedPlayer.solid = true;
					selectedPlayer.controller = null;
					selectionConfirmed = false;
					color = 0xffffff;
				}
			}
		}
	}	
}