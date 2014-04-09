package entities;

class PlayerDrew extends Player
{

	public function new() 
	{
		super();
		graphicPath = "assets/images/players/drew.png";
		playerName = "Drew";
		initAnimations();
	}
	
}