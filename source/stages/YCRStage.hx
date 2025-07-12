package stages;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class YCRStage extends BaseStage
{
    var pickle:FlxSprite;
	var fgTrees:BGSprite;
	var genesis:FlxTypedGroup<FlxSprite>;

    // HOLY FUCK I AM HAVING SEXUAL INTERCOURSE WITH YOUR MOM!!!!!!!!!!
    override function create()
    {
        genesis = new FlxTypedGroup<FlxSprite>();
		var sky:BGSprite = new BGSprite('run/sky', -600, -200, 1.0, 1.0);
		genesis.add(sky);

		var grassback:BGSprite = new BGSprite('run/GrassBack', -600, -200, 1.0, 1.0);
		genesis.add(grassback);

		var trees:BGSprite = new BGSprite('run/trees', -600, -200, 1.0, 1.0);
		genesis.add(trees);

		var grass:BGSprite = new BGSprite('run/Grass', -600, -200, 1.0, 1.0);
		genesis.add(grass);

		var treesfront:BGSprite = new BGSprite('run/TreesFront', -600, -200, 1.0, 1.0);
		genesis.add(treesfront);

		var topoverlay:BGSprite = new BGSprite('run/TopOverlay', -600, -200, 1.0, 1.0);
		genesis.add(topoverlay);

		pickle = new FlxSprite(321.5, 122.65).loadGraphic(Paths.image("run/GreenHill", 'exe'));
		pickle.visible = false;
		pickle.scrollFactor.set(1, 1);
		pickle.active = false;
        pickle.scale.set(8, 9);
		add(genesis);
		add(pickle);
    }

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == "you-can't-run")
        {
            switch(curStep)
            {
				case 16, 785:
					game.supersuperZoomShit = false;
					game.superZoomShit = true;
				case 128, 144, 912:
					game.superZoomShit = false;
					game.supersuperZoomShit = true;
				case 141, 527, 1425:
					game.superZoomShit = false;
					game.supersuperZoomShit = false;
                case 528:
                    greenHillMoment(true);
                case 784:
                    greenHillMoment(false);
            }
        }
    }

    function greenHillMoment(yay:Bool)
    {
        switch(yay)
        {
            case true:
                defaultCamZoom = 0.9;
				game.scoreTxt.visible = false;
				game.timeBar.visible = false;
				game.timeBarBG.visible = false;
				game.timeTxt.visible = false;

                PlayState.isPixelStage = true;

				game.reloadTheNotesPls();

				pickle.visible = true;
				genesis.visible = false;

				dadGroup.x -= 175;
				dadGroup.y += 370;
				boyfriend.setPosition(530 + 145, 170 + 200);
				gf.x = 400;
				gf.y = 130;

				game.healthBar.x += 150;
				game.iconP1.x += 150;
				game.iconP2.x += 150;
				game.healthBarBG.x += 150;
                game.sonicHUD.visible = true;
			case false:
				game.scoreTxt.visible = !ClientPrefs.hideHud;
				game.timeBar.visible = !ClientPrefs.hideHud;
				game.timeBarBG.visible = !ClientPrefs.hideHud;
				game.timeTxt.visible = !ClientPrefs.hideHud;
				game.sonicHUD.visible = false;
				defaultCamZoom = 0.65;

                PlayState.isPixelStage = false;

				game.reloadTheNotesPls();

				pickle.visible = false;
				genesis.visible = true;

                dadGroup.x += 175;
				dadGroup.y -= 370;
				boyfriend.y -= 15;
				
				game.healthBar.x -= 150;
				game.iconP1.x -= 150;
				game.iconP2.x -= 150;
				game.healthBarBG.x -= 150;
        }
    }
}
