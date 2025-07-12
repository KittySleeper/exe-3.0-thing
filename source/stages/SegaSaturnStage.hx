package stages;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.filters.ShaderFilter;
import shaders.VCRDistortionShader;

class SegaSaturnStage extends BaseStage
{
    var flooooor:FlxSprite;
    var vcr:VCRDistortionShader;

    override function create()
    {
        GameOverSubstate.characterName = 'bf-td-part1';
		GameOverSubstate.loopSoundName = 'sunshine-loop';

		flooooor = new FlxSprite().loadGraphic(Paths.image("TailsBG", 'exe'));
		flooooor.setGraphicSize(Std.int(flooooor.width * 1.4));
		add(flooooor);
    }

    override function createPost()
    {
		vcr = new VCRDistortionShader();

        game.curShader = new ShaderFilter(vcr);

		var daStatic:BGSprite = new BGSprite('daSTAT', 0, 0, 1.0, 1.0, ['staticFLASH'], true);
		daStatic.cameras = [camIDK];
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.alpha = 0.05;
		add(daStatic);

        if (ClientPrefs.shaders) {
            camGame.filters = [game.curShader];
            camHUD.filters = [game.curShader];
            camIDK.filters = [game.curShader];
        }
    }

    override function update(elapsed:Float)
    {
        if(vcr != null) {
			vcr.iTime.value[0] = Conductor.songPosition / 1000;
		}
    }
}