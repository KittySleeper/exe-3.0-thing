package stages;

import flixel.FlxG;
import flixel.tweens.FlxTween;

class AngelIslandStage extends BaseStage
{
    var fgTrees:BGSprite;
    override function create()
    {
        var sky:BGSprite = new BGSprite('PolishedP1/BGSky', -600, -200, 1, 1);
		sky.setGraphicSize(Std.int(sky.width * 1.4));
		add(sky);

		var midTrees1:BGSprite = new BGSprite('PolishedP1/TreesMidBack', -600, -200, 0.7, 0.7);
		midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
		add(midTrees1);

		var treesmid:BGSprite = new BGSprite('PolishedP1/TreesMid', -600, -200,  0.7, 0.7);
		midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
		add(treesmid);

		var treesoutermid:BGSprite = new BGSprite('PolishedP1/TreesOuterMid1', -600, -200, 0.7, 0.7);
		treesoutermid.setGraphicSize(Std.int(treesoutermid.width * 1.4));
		add(treesoutermid);

		var treesoutermid2:BGSprite = new BGSprite('PolishedP1/TreesOuterMid2', -600, -200,  0.7, 0.7);
		treesoutermid2.setGraphicSize(Std.int(treesoutermid2.width * 1.4));
		add(treesoutermid2);

		var lefttrees:BGSprite = new BGSprite('PolishedP1/TreesLeft', -600, -200,  0.7, 0.7);
		lefttrees.setGraphicSize(Std.int(lefttrees.width * 1.4));
		add(lefttrees);

		var righttrees:BGSprite = new BGSprite('PolishedP1/TreesRight', -600, -200, 0.7, 0.7);
		righttrees.setGraphicSize(Std.int(righttrees.width * 1.4));
		add(righttrees);

		var outerbush:BGSprite = new BGSprite('PolishedP1/OuterBush', -600, -150, 1, 1);
		outerbush.setGraphicSize(Std.int(outerbush.width * 1.4));
		add(outerbush);

		var outerbush2:BGSprite = new BGSprite('PolishedP1/OuterBushUp', -600, -200, 1, 1);
		outerbush2.setGraphicSize(Std.int(outerbush2.width * 1.4));
		add(outerbush2);

		var grass:BGSprite = new BGSprite('PolishedP1/Grass', -600, -150, 1, 1);
		grass.setGraphicSize(Std.int(grass.width * 1.4));
		add(grass);

		var deadegg:BGSprite = new BGSprite('PolishedP1/DeadEgg', -600, -200, 1, 1);
		deadegg.setGraphicSize(Std.int(deadegg.width * 1.4));
		deadegg.isGore = true;
		add(deadegg);

		var deadknux:BGSprite = new BGSprite('PolishedP1/DeadKnux', -600, -200, 1, 1);
		deadknux.setGraphicSize(Std.int(deadknux.width * 1.4));
		deadknux.isGore = true;
		add(deadknux);

		var deadtailz:BGSprite = new BGSprite('PolishedP1/DeadTailz', -700, -200, 1, 1);
		deadtailz.setGraphicSize(Std.int(deadtailz.width * 1.4));
		deadtailz.isGore = true;
		add(deadtailz);

		var deadtailz1:BGSprite = new BGSprite('PolishedP1/DeadTailz1', -600, -200, 1, 1);
		deadtailz1.setGraphicSize(Std.int(deadtailz1.width * 1.4));
		deadtailz1.isGore = true;
		add(deadtailz1);

		var deadtailz2:BGSprite = new BGSprite('PolishedP1/DeadTailz2', -600, -400, 1, 1);
		deadtailz2.setGraphicSize(Std.int(deadtailz2.width * 1.4));
		deadtailz2.isGore = true;
		add(deadtailz2);

		fgTrees = new BGSprite('PolishedP1/TreesFG', -610, -200, 1.1, 1.1);
		fgTrees.setGraphicSize(Std.int(fgTrees.width * 1.45));
    }

    override function createPost()
	{
		add(fgTrees);
    }

    override function stepHit()
    {
        if(PlayState.SONG.song.toLowerCase() == 'too-slow'){
			switch(curStep){
				case 764:
					FlxG.camera.flash(FlxColor.RED, 3);
				case 1305:

			}
		}
		if (PlayState.SONG.song.toLowerCase() == 'too-slow-encore')
		{
			switch (curStep)
			{
				case 384:
					game.camGame.alpha = 0;
				case 400:
					game.camGame.alpha = 1;
					game.defaultCamZoom = 0.9;
				case 415, 687, 751, 1055:
					game.camZooming = false;
					game.supersuperZoomShit = true;
				case 416:
					game.defaultCamZoom = 0.65;
				case 544, 672, 800, 1056, 1312, 1440, 1504:
					game.camOther.flash(FlxColor.RED, 0.5);
				case 675, 736, 1313:
					game.camZooming = true;
					game.supersuperZoomShit = false;
				case 928:
					FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.7);
					game.cinematicBars(true);
					game.defaultCamZoom = 1.0;
					game.supersuperZoomShit = false;
					FlxTween.tween(game.camHUD, {alpha: 0}, 0.7);
				case 1039:
					game.cinematicBars(false);
					FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1.4);
					game.defaultCamZoom = 0.6;
					FlxTween.tween(game.camHUD, {alpha: 1}, 1.4);
				case 1472, 1478, 1484, 1490, 1496:
					game.defaultCamZoom += 0.15;
				case 1505:
					game.camZooming = false;
					game.supersuperZoomShit = true;
					game.defaultCamZoom = 0.6;
				/*case 1664:
					game.camFollow.x = gf.x;
					game.camFollow.y = gf.y;
					game.isCameraOnForcedPos = true;*/
				case 1888:
					game.camZooming = false;
					game.supersuperZoomShit = false;
			}
		}
    }
}