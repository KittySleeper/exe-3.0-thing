package stages;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

class FoFStage extends BaseStage
{
	var deadHedgehog:BGSprite;
	var mcdonaldTowers:BGSprite;
	var burgerKingCities:BGSprite;
	var wendysLight:FlxSprite;
	var pizzaHutStage:BGSprite;
	// - the fear mechanic
	var fearUi:FlxSprite;
	var fearUiBg:FlxSprite;
	var fearTween:FlxTween;
	var fearTimer:FlxTimer;

    var fearNo:Float;
	var fearBar:FlxBar;

    override function create()
    {
        // fhjdslafhlsa dead hedgehogs

		/*———————————No hedgehogs?———————————
		⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
		⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
		⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
		⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
		⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
		⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
		⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
		—————————————————————————————*/

		GameOverSubstate.deathSoundName = 'starved-death';
		GameOverSubstate.loopSoundName = 'starved-loop';
		GameOverSubstate.endSoundName = 'starved-retry';
		GameOverSubstate.characterName = 'bf-starved-die';

		burgerKingCities = new BGSprite('starved/city', -100, 0, 1, 0.9);
		burgerKingCities.setGraphicSize(Std.int(burgerKingCities.width * 1.5));
		add(burgerKingCities);

		mcdonaldTowers = new BGSprite('starved/towers', -100, 0, 1, 0.9);
		mcdonaldTowers.setGraphicSize(Std.int(mcdonaldTowers.width * 1.5));
		add(mcdonaldTowers);

		pizzaHutStage = new BGSprite('starved/stage', -100, 0, 1, 0.9);
		pizzaHutStage.setGraphicSize(Std.int(pizzaHutStage.width * 1.5));
		add(pizzaHutStage);

		// sonic died
		deadHedgehog = new BGSprite('starved/sonicisfuckingdead', 0, 100, 1, 0.9);
		deadHedgehog.setGraphicSize(Std.int(deadHedgehog.width * 0.65));
		deadHedgehog.isGore=true;
		add(deadHedgehog);

		// hes still dead

		wendysLight = new BGSprite('starved/light', 0, 0, 1, 0.9);
		wendysLight.setGraphicSize(Std.int(wendysLight.width * 1.2));

        // nabbed this code from starlight lmao
		if (PlayState.SONG.song.toLowerCase() == 'fight-or-flight')
		{
			fearUi = new FlxSprite().loadGraphic(Paths.image('fearbar'));
			fearUi.scrollFactor.set();
			fearUi.screenCenter();
			fearUi.x += 580;
			fearUi.y -= 50;

			fearUiBg = new FlxSprite(fearUi.x, fearUi.y).loadGraphic(Paths.image('fearbarBG'));
			fearUiBg.scrollFactor.set();
			fearUiBg.screenCenter();
			fearUiBg.x += 580;
			fearUiBg.y -= 50;
			add(fearUiBg);

			fearBar = new FlxBar(fearUi.x + 30, fearUi.y + 5, BOTTOM_TO_TOP, 21, 275, this, 'fearNo', 0, 100);
			fearBar.scrollFactor.set();
			fearBar.visible = true;
			fearBar.numDivisions = 1000;
			fearBar.createFilledBar(0x00000000, 0xFFFF0000);
			trace('bar added.');

			add(fearBar);
			add(fearUi);
		}
    }

    override function update(elapsed:Float)
    {
		fearNo = game.fearNo;

        // fear shit for starved
		if (PlayState.SONG.song.toLowerCase() == 'fight-or-flight')
		{
			PlayState.isFear = true;
			fearBar.filledCallback = function()
			{
				game.health = 0;
			}
			// this is such a shitcan method i really should come up with something better tbf
			var healthLoss = 0.0;
			if (fearNo >= 90 && fearNo < 99)
				healthLoss = 0.35;
			else if (fearNo >= 80 && fearNo < 89)
				healthLoss = 0.20;
			else if (fearNo >= 70 && fearNo < 79)
				healthLoss = 0.17;
			else if (fearNo >= 60 && fearNo < 69)
				healthLoss = 0.13;
			else if (fearNo >= 50 && fearNo < 59)
				healthLoss = 0.1;
			game.health -= healthLoss * elapsed;

			if (game.health <= 0.01 && !controls.RESET)
			{
				game.health = 0.01;
			}
		}
    }

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == 'fight-or-flight')
		{
			switch (curStep)
			{
				case 1184, 1471:
					starvedLights(true);
				case 1439, 1728:
					starvedLights(false);
			}
		}
    }

    function starvedLights(hungry:Bool)
	{
		switch (hungry) 
		{
			case true:
				//i fucking LOVE those BLAMMED LIGHTS !! !!
				FlxTween.tween(burgerKingCities, {alpha: 0}, 1);
				FlxTween.tween(mcdonaldTowers, {alpha: 0}, 1);
				FlxTween.tween(pizzaHutStage, {alpha: 0}, 1);
				FlxTween.color(deadHedgehog, 1, FlxColor.WHITE, FlxColor.RED);
				FlxTween.color(boyfriendGroup, 1, FlxColor.WHITE, FlxColor.RED);
			case false:
				//i fucking HATE those BLAMMED LIGHTS !! !!
				FlxTween.tween(burgerKingCities, {alpha: 1}, 1.5);
				FlxTween.tween(mcdonaldTowers, {alpha: 1}, 1.5);
				FlxTween.tween(pizzaHutStage, {alpha: 1}, 1.5);
				FlxTween.color(deadHedgehog, 1, FlxColor.RED, FlxColor.WHITE);
				FlxTween.color(boyfriendGroup, 1, FlxColor.RED, FlxColor.WHITE); //????? will it work lol? (update it totally worked :DDDD)
		}
	}
}