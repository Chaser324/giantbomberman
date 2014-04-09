package entities;

class PlayerPatrick extends Player
{

	public function new() 
	{
		super();
		graphicPath = "assets/images/players/patrick.png";
		playerName = "Patrick";
		initAnimations();
	}
	
}