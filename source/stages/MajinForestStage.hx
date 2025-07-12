package stages;

import flixel.tweens.FlxTween;

class MajinForestStage extends BaseStage
{
    var fgmajin:BGSprite;
    var fgmajin2:BGSprite;

    override function create()
    {
        var SKY:BGSprite = new BGSprite('FunInfiniteStage/sonicFUNsky', -600, -200, 1.0, 1.0);
		add(SKY);

		var bush:BGSprite = new BGSprite('FunInfiniteStage/Bush 1', -42, 171, 1.0, 1.0);
		add(bush);

		var pillars2:BGSprite = new BGSprite('FunInfiniteStage/Majin Boppers Back', 182, -100, 1.0, 1.0, ['MajinBop2 instance 1'], true);
		add(pillars2);

		var bush2:BGSprite = new BGSprite('FunInfiniteStage/Bush2', 132, 354, 1.0, 1.0);
		add(bush2);

		var pillars1:BGSprite = new BGSprite('FunInfiniteStage/Majin Boppers Front', -169, -167, 1.0, 1.0, ['MajinBop1 instance 1'], true);
		add(pillars1);

		var floor:BGSprite = new BGSprite('FunInfiniteStage/floor BG', -340, 660, 1.0, 1.0);
		add(floor);

		fgmajin = new BGSprite('FunInfiniteStage/majin FG1', 1126, 903, 1.0, 1.0, ['majin front bopper1'], true);

		fgmajin2 = new BGSprite('FunInfiniteStage/majin FG2', -393, 871, 1.0, 1.0, ['majin front bopper2'], true);
    }

    override function createPost()
    {
        add(fgmajin);
		add(fgmajin2);
    }

    override function stepHit()
    {
        if(PlayState.SONG.song.toLowerCase() == 'endless' || PlayState.SONG.song.toLowerCase() == 'endless-og') {
			switch(curStep) {
				case 882:
					for (note in cast(game.unspawnNotes, Array<Dynamic>)) {
						note.reloadNote(null, "noteSkins/Majin_Notes");
					}

				case 886:
					FlxTween.tween(camHUD, {alpha: 0}, 0.5);

				case 900:
					game.opponentStrums.forEach(function(spr:StrumNote)
					{
						spr.set_texture("noteSkins/Majin_Notes");
					});
                    game.playerStrums.forEach(function(spr:StrumNote)
					{
						spr.set_texture("noteSkins/Majin_Notes");
					});
					FlxTween.tween(camHUD, {alpha: 1}, 0.5);
			}
		}
    }
}