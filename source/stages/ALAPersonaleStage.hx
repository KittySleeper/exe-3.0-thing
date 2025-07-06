package stages;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ALAPersonaleStage extends BaseStage
{
    var SpinAmount:Float = 0;
	var IsNoteSpinning:Bool = false;
	var isPlayersSpinning:Bool = false;

    var whiteFuck:FlxSprite;

    override function create()
    {
		whiteFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
		add(whiteFuck);
    }

    override function update(elapsed:Float)
    {
        if (PlayState.SONG.song.toLowerCase() == 'personel') {
            if (IsNoteSpinning)
            {
                var thisX:Float = Math.sin(SpinAmount * (SpinAmount / 2)) * 100;
                var thisY:Float = Math.sin(SpinAmount * (SpinAmount)) * 100;
                game.playerStrums.forEach(function(str:FlxSprite)
                {
					str.angle = str.angle + SpinAmount;
                    SpinAmount = SpinAmount + 0.0003;
				});
                game.opponentStrums.forEach(function(str:FlxSprite)
                {
					str.angle = str.angle + SpinAmount;
                    SpinAmount = SpinAmount + 0.0003;
				});
            }

            if (isPlayersSpinning)
            {
                dadGroup.angle = dadGroup.angle + SpinAmount;
                SpinAmount = SpinAmount + 0.00003;
                boyfriendGroup.angle = boyfriendGroup.angle + SpinAmount;
                SpinAmount = SpinAmount + 0.00003;
            }
        }
    }

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == 'personel')
		{
			switch (curStep)
			{
				case 32:
					camGame.alpha = 1;
				case 288:
					defaultCamZoom = 1.2;
					FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.3);
				case 416:
					defaultCamZoom = 1.6;
					FlxTween.tween(FlxG.camera, {zoom: 1.6}, 0.3);
				case 543:
					defaultCamZoom = 1.0;
					FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.3);
				case 799:
					defaultCamZoom = 0.9;
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.3);
				case 1069, 1087, 1098, 1101, 1134, 1151, 1163, 1167:
					game.playerStrums.forEach(function(str:FlxSprite)
                    {
						str.angle = str.angle + 35;
					});
					game.opponentStrums.forEach(function(str:FlxSprite)
                    {
						str.angle = str.angle + 35;
					});
				case 1199:
					IsNoteSpinning = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.6}, 0.3);
					defaultCamZoom = 1.6;
				case 1263:
					IsNoteSpinning = false;
				case 1311:
					IsNoteSpinning = true;
					isPlayersSpinning = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.3);
					defaultCamZoom = 1.2;
				case 1401:
					IsNoteSpinning = false;
					FlxTween.tween(FlxG.camera, {zoom: 1.8}, 0.3);
					defaultCamZoom = 1.8;
				case 1403:
					defaultCamZoom = 0.9;
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 21.2);
					isPlayersSpinning = false;
					dadGroup.angle = 0;
					boyfriendGroup.angle = 0;
					game.playerStrums.forEach(function(str:FlxSprite)
                    {
						FlxTween.tween(str, {angle: 0}, 0.5, {ease: FlxEase.circOut});
					});
					game.opponentStrums.forEach(function(str:FlxSprite)
                    {
						FlxTween.tween(str, {angle: 0}, 0.5, {ease: FlxEase.circOut});
					});
				case 1695, 1888:
					game.superZoomShit = true;
                    game.supersuperZoomShit = false;
				case 1872, 1936:
					game.superZoomShit = false;
					game.supersuperZoomShit = true;
                case 1975:
                    game.superZoomShit = false;
					game.supersuperZoomShit = false;
			}
		}
    }
}