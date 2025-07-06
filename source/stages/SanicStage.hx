package stages;

import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;

class SanicStage extends BaseStage 
{
    var weedVis:WeedVision;
    var weedSpinningTime:Bool = false;
    
    override function create() 
    {
        var bg:BGSprite = new BGSprite('sanicbg', -370, -130, 1.0, 1.0);
        bg.setGraphicSize(Std.int(bg.width * 1.2));
        add(bg);

        if (ClientPrefs.flashing)
            weedVis = new WeedVision();
    }

    override function update(elapsed:Float)
    {
        if(weedVis != null && ClientPrefs.flashing)
		{
			if(weedSpinningTime)
				weedVis.hue += elapsed * 2;
			else
				weedVis.hue = FlxMath.lerp(weedVis.hue, 3, CoolUtil.boundTo(elapsed * 2.4, 0, 1));
		}
    }

    override function stepHit() 
    {
        if (PlayState.SONG.song.toLowerCase() == 'too-fest') {
            switch (curStep)
            {
                case 5, 9, 12, 15, 634, 639, 642, 646, 650, 654, 710, 716, 774, 780, 838, 845, 895, 900, 905, 910, 1472, 1476, 1480, 1484:
                    PlayState.instance.triggerEventNote('Notes Spin', '360', '0.2');
                case 64, 69, 73, 77, 383, 389, 393, 397, 448, 452, 456, 460, 512, 516, 520, 524, 576, 580, 584, 588, 664, 698, 729, 760, 790, 857:
                    festSpinOppenet();
                case 128, 132, 136, 140, 408, 410, 412, 472, 474, 476, 536, 538, 540, 600, 602, 604, 682, 745, 808, 825, 872, 888:
                    festSpinPlayer();
                case 912:
                    if (ClientPrefs.flashing && weedVis != null) {
                        game.curShader = new ShaderFilter(weedVis);
                        camGame.filters = [game.curShader];
                        camHUD.filters = [game.curShader];
                        camIDK.filters = [game.curShader];
                    }
                    weedSpinningTime = true;
                case 1167:
                    weedSpinningTime = false;
            }
        }
    }

    override function beatHit()
    {
        if (curBeat % 4 == 0 && weedSpinningTime)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;

			PlayState.instance.triggerEventNote('Notes Spin', '360', '1.2');
		}
    }

    function festSpinPlayer()
	{
		game.playerStrums.forEach(function(tospin:FlxSprite)
		{
			FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
		});
	}

	function festSpinOppenet()
	{
	    game.opponentStrums.forEach(function(tospin:FlxSprite)
		{
			FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
		});
	}
}