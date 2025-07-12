package stages;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ChorizonStage extends BaseStage
{
    // fuckles
	var fucklesBGPixel:BGSprite;
	var fucklesFGPixel:BGSprite;
	var fucklesAmyBg:FlxSprite;
	var fucklesVectorBg:FlxSprite;
	var fucklesKnuxBg:FlxSprite;
	var fucklesEspioBg:FlxSprite;
	var fucklesCharmyBg:FlxSprite;
	var fucklesMightyBg:FlxSprite;
	var fucklesFuckedUpBg:FlxSprite;
	var fucklesFuckedUpFg:BGSprite;
	var fucklesTheHealthHog:Array<Float>;

    var whiteFuck:FlxSprite;

    var fucklesBeats:Bool = true;

    override function create()
    {
        //HOLY FUCKLES ITS KNUCKLES
		GameOverSubstate.deathSoundName = 'chaotix-death';
		GameOverSubstate.loopSoundName = 'chaotix-loop';
		GameOverSubstate.endSoundName = 'chaotix-retry';
		GameOverSubstate.characterName = 'bf-chaotix-death';

		game.defaultCamZoom = 0.87;
		PlayState.isPixelStage = true;

        dadGroup.y += 70;
        boyfriendGroup.y += 70;
        gfGroup.x += 360;
        gfGroup.y += 585;

		fucklesBGPixel = new BGSprite('chaotix/horizonsky', -1450, -725, 1.2, 0.9);
		add(fucklesBGPixel);

		fucklesFuckedUpBg = new FlxSprite(-1300, -500);
		fucklesFuckedUpBg.frames = Paths.getSparrowAtlas('chaotix/corrupt_background', 'exe');
		fucklesFuckedUpBg.animation.addByPrefix('idle', 'corrupt background', 24, true);
		fucklesFuckedUpBg.animation.play('idle');
		fucklesFuckedUpBg.scale.x = 1;
		fucklesFuckedUpBg.scale.y = 1;
		fucklesFuckedUpBg.visible = false;
		fucklesFuckedUpBg.antialiasing = false;
		add(fucklesFuckedUpBg);

		fucklesFGPixel = new BGSprite('chaotix/horizonFg', -550, -735, 1, 0.9);
		add(fucklesFGPixel);

		fucklesFuckedUpFg = new BGSprite('chaotix/horizonFuckedUp', -550, -735, 1, 0.9);
		fucklesFuckedUpFg.visible = false;
		add(fucklesFuckedUpFg);

		fucklesAmyBg = new FlxSprite(1195, 630);
		fucklesAmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_amy', 'exe');
		fucklesAmyBg.animation.addByPrefix('idle', 'amy bobbing', 24);
		fucklesAmyBg.animation.addByPrefix('fear', 'amy fear', 24, true);
		fucklesAmyBg.scale.x = 6;
		fucklesAmyBg.scale.y = 6;
		fucklesAmyBg.antialiasing = false;


		fucklesCharmyBg = new FlxSprite(1000, 500);
		fucklesCharmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_charmy', 'exe');
		fucklesCharmyBg.animation.addByPrefix('idle', 'charmy bobbing', 24);
		fucklesCharmyBg.animation.addByPrefix('fear', 'charmy fear', 24, true);
		fucklesCharmyBg.scale.x = 6;
		fucklesCharmyBg.scale.y = 6;
		fucklesCharmyBg.antialiasing = false;


		fucklesMightyBg = new FlxSprite(590, 650);
		fucklesMightyBg.frames = Paths.getSparrowAtlas('chaotix/BG_mighty', 'exe');
		fucklesMightyBg.animation.addByPrefix('idle', 'mighty bobbing', 24);
		fucklesMightyBg.animation.addByPrefix('fear', 'mighty fear', 24, true);
		fucklesMightyBg.scale.x = 6;
		fucklesMightyBg.scale.y = 6;
		fucklesMightyBg.antialiasing = false;


		fucklesEspioBg = new FlxSprite(1400, 660);
		fucklesEspioBg.frames = Paths.getSparrowAtlas('chaotix/BG_espio', 'exe');
		fucklesEspioBg.animation.addByPrefix('idle', 'espio bobbing', 24);
		fucklesEspioBg.animation.addByPrefix('fear', 'espio fear', 24, true);
		fucklesEspioBg.scale.x = 6;
		fucklesEspioBg.scale.y = 6;
		fucklesEspioBg.antialiasing = false;


		fucklesKnuxBg = new FlxSprite(-60, 645);
		fucklesKnuxBg.frames = Paths.getSparrowAtlas('chaotix/BG_knuckles', 'exe');
		fucklesKnuxBg.animation.addByPrefix('idle', 'knuckles bobbing', 24);
		fucklesKnuxBg.animation.addByPrefix('fear', 'knuckles fear', 24, true);
		fucklesKnuxBg.scale.x = 6;
		fucklesKnuxBg.scale.y = 6;
		fucklesKnuxBg.antialiasing = false;


		fucklesVectorBg = new FlxSprite(-250, 615);
		fucklesVectorBg.frames = Paths.getSparrowAtlas('chaotix/BG_vector', 'exe');
		fucklesVectorBg.animation.addByPrefix('idle', 'vector bobbing', 24);
		fucklesVectorBg.animation.addByPrefix('fear', 'vector fear', 24, true);
		fucklesVectorBg.scale.x = 6;
		fucklesVectorBg.scale.y = 6;
		fucklesVectorBg.antialiasing = false;

		add(fucklesAmyBg);
		add(fucklesCharmyBg);
		add(fucklesMightyBg);
		add(fucklesEspioBg);
		add(fucklesKnuxBg);
		add(fucklesVectorBg);

		whiteFuck = new FlxSprite(-600, 0).makeGraphic(FlxG.width * 6, FlxG.height * 6, FlxColor.BLACK);
		whiteFuck.alpha = 0;
		add(whiteFuck);
    }

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == 'my-horizon')
		{
			switch (curStep)
			{
				case 896:
                    game.supersuperZoomShit = false;
					FlxTween.tween(camHUD, {alpha: 0}, 2.2);
				case 908:
					dad.playAnim('transformation', true);
					dad.specialAnim = true;
					game.camZooming = false;
					game.cinematicBars(true);
				case 924:
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.5}, 12, {ease: FlxEase.cubeInOut});

					FlxTween.tween(whiteFuck, {alpha: 1}, 6, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
						{
							remove(fucklesFGPixel);
							remove(fucklesBGPixel);
							fucklesBGPixel.destroy();
							fucklesFGPixel.destroy();
							fucklesFuckedUpBg.visible = true;
							fucklesFuckedUpFg.visible = true;
						}
					});
				case 975:
					game.cinematicBars(false);
				case 992:
					literallyMyHorizon();
				case 1120, 1248, 1376, 1504, 1632, 1760, 1888, 2016, 2048, 2054, 2060:
					fucklesHealthRandomize();
					camHUD.shake(0.005, 1);
				case 1121, 1761:
					game.superZoomShit = true;
				case 1503, 2015:
					game.superZoomShit = false;
				case 128, 640, 1505, 2080:
					game.supersuperZoomShit = true;
				case 512, 1759, 2336:
					game.supersuperZoomShit = false;
				case 2208, 2222, 2240, 2254, 2320, 2324, 2328:
					fucklesFinale();
					camHUD.shake(0.003, 1);
				case 2337:
					game.camZooming = false;
			}
		}
    }

    override function beatHit()
    {
        if (fucklesBeats) {
			fucklesEspioBg.animation.play('idle');
			fucklesMightyBg.animation.play('idle');
			fucklesCharmyBg.animation.play('idle');
			fucklesAmyBg.animation.play('idle');
			fucklesKnuxBg.animation.play('idle');
			fucklesVectorBg.animation.play('idle');
		} else {
			fucklesAmyBg.animation.play('fear');
			fucklesCharmyBg.animation.play('fear');
			fucklesMightyBg.animation.play('fear');
			fucklesEspioBg.animation.play('fear');
			fucklesKnuxBg.animation.play('fear');
			fucklesVectorBg.animation.play('fear');
		}
    }

    function literallyMyHorizon()
	{
		dad.specialAnim = false;
		FlxG.camera.flash(FlxColor.BLACK, 1);
        dadGroup.y += 40;
		game.camZooming = true;
		FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom}, 1.5, {ease: FlxEase.cubeInOut});
		FlxTween.tween(camHUD, {alpha: 1}, 1.0);
		fucklesBeats = false;
		fucklesDeluxe();
		FlxTween.tween(whiteFuck, {alpha: 0}, 1.5, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
				remove(whiteFuck);
				whiteFuck.destroy();
			}
		});
		camHUD.zoom += 2;

		//ee oo ee oo ay oo ay oo ee au ee ah
	}

    function fucklesHealthRandomize()
	{
		if (game.fucklesMode)
			game.health = FlxG.random.float(0.5, 2);
		trace('fuck your health!');
		// randomly sets health between max and 0.5,
		// this im gonna use for stephits and basically
		// have it go fucking insane in some parts and disable the drain and reenable when needed
	}

    // ok might not do this lmao

	var fuckedMode:Bool = false;

	function fucklesFinale()
	{
		if (game.fucklesMode)
			fuckedMode = true;
		if (fuckedMode)
		{
			game.health -= 0.1;
			if (game.health <= 0.01)
			{
				game.health = 0.01;
				fuckedMode = false;
			}
		}
		trace('dont die lol');
	}

    function fucklesDeluxe()
	{
		game.health = 2;
		game.fucklesMode = true;

		game.timeBarBG.visible = false;
		game.timeBar.visible = false;
		game.timeTxt.visible = false;
		game.scoreTxt.visible = false;

		game.opponentStrums.forEach(function(spr:FlxSprite)
		{
			spr.x += 10000;
		});
	}
}