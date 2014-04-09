package entities;

class PlayerAlex extends Player
{
	public function new() 
	{
		super();
		graphicPath = "assets/images/players/alex.png";
		playerName = "Alex";
		initAnimations();
	}
	
}