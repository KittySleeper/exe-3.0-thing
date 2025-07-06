package stages;

import flixel.tweens.FlxTween;

class SunkyStage extends BaseStage
{
    public var sunkerTimebarNumber:Int;

    var cereal:FlxSprite;
	var munch:FlxSprite;
	var pose:FlxSprite;
	var sunker:FlxSprite;
	var spoOoOoOky:FlxSprite;

    override function create()
    {
        var bg:BGSprite = new BGSprite('sunky/sunky BG', -300, -500, 0.9, 0.9);
		add(bg);

		var balls:BGSprite = new BGSprite('sunky/ball', 20, -500, 0.9, 0.9);
		balls.screenCenter(X);
		add(balls);

		var stage:BGSprite = new BGSprite('sunky/stage', 125, -500, 1.0, 1.0);
		stage.setGraphicSize(Std.int(stage.width * 1.1));
		add(stage);


		cereal = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/cereal", 'exe'));
		cereal.cameras = [camIDK];
		cereal.screenCenter(Y);
		add(cereal);

		munch = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/sunkyMunch", 'exe'));
		munch.cameras = [camIDK];
		munch.screenCenter(Y);
		add(munch);

		pose = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/sunkyPose", 'exe'));
		pose.cameras = [camIDK];
		pose.screenCenter(Y);
		add(pose);

		sunker = new FlxSprite(200, 0).loadGraphic(Paths.image("sunky/sunker", 'exe'));
		sunker.cameras = [camIDK];
		sunker.frames = Paths.getSparrowAtlas('sunky/sunker', 'exe');
		sunker.animation.addByPrefix('ya', 'sunker');
		sunker.animation.play('ya');
		sunker.setGraphicSize(Std.int(sunker.width * 5));
		sunker.updateHitbox();
		sunker.visible = false;
		add(sunker);

		if (PlayState.isFixedAspectRatio)
		{
			var funnyAspect:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sunky/4_3 shit", 'exe'));
			funnyAspect.screenCenter();
			funnyAspect.cameras = [camIDK];
			add(funnyAspect);
		}

		spoOoOoOky = new FlxSprite(0, 0).loadGraphic(Paths.image("sunky/sunkage", 'exe'));
		spoOoOoOky.screenCenter();
		spoOoOoOky.visible = false;
		spoOoOoOky.cameras = [camIDK];
		add(spoOoOoOky);
    }

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == 'milk')
		{
			switch (curStep)
			{
				case 64:
					FlxG.camera.zoom += 0.06;
					camHUD.zoom += 0.08;
				case 80:
					FlxG.camera.zoom += 0.06;
					camHUD.zoom += 0.08;
				case 96:
					game.supersuperZoomShit = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 6.5);
				case 119:
					game.supersuperZoomShit = false;
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
				case 132:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 2.5);
					camGame.shake(0.2, 0.85);
					camHUD.shake(0.2, 0.85);

					sunker.visible = true;
					sunker.alpha = 0;
					FlxTween.tween(sunker, {alpha: 1}, 1.5);
				case 144:
					FlxTween.cancelTweensOf(FlxG.camera);

					FlxTween.cancelTweensOf(sunker);
					sunker.alpha = 0;
					sunker.visible = false;

					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
					game.superZoomShit = true;
				case 352:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 1.9);
					game.superZoomShit = false;
				case 367:
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
				case 404:
					game.superZoomShit = true;
				case 528:
					switch(FlxG.random.int(1, 3)){
						case 1:
							FlxTween.tween(cereal, {x: 1350}, 12.5);
						case 2:
							FlxTween.tween(munch, {x: 1350}, 12.5);
						case 3:
							FlxTween.tween(pose, {x: 1350}, 12.5);
					}
				case 639:
					game.superZoomShit = false;
					FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.5);
					defaultCamZoom = 1.3;
				case 651:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 0.5);
					defaultCamZoom = 1.9;
				case 656:
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
					defaultCamZoom = 0.9;
					game.superZoomShit = true;
				case 752:
					cereal.y = -1000;
					cereal.x = 500;
					munch.y = -1000;
					munch.x = 500;
					pose.y = -1000;
					pose.x = 500;
				case 784:
					switch(FlxG.random.int(1, 3)){
						case 1:
							FlxTween.tween(cereal, {y: 1150}, 9.8);
						case 2:
							FlxTween.tween(munch, {y: 1150}, 9.8);
						case 3:
							FlxTween.tween(pose, {y: 1150}, 9.8);
					}
				case 879:
					FlxTween.cancelTweensOf(cereal);
					FlxTween.cancelTweensOf(munch);
					FlxTween.cancelTweensOf(pose);
					cereal.y = -1000;
					cereal.x = 500;
				case 911:
					cereal.y = -1000;
					cereal.x = -700;
					munch.y = -1000;
					munch.x = -700;
					pose.y = -1000;
					pose.x = -700;
					switch(FlxG.random.int(1, 3)) {
						case 1:
							FlxTween.tween(cereal, {y: 1050}, 10.8);
							FlxTween.tween(cereal, {x: 1350}, 10.8);
						case 2:
							FlxTween.tween(munch, {y: 1050}, 9.8);
							FlxTween.tween(munch, {x: 1350}, 10.8);
						case 3:
							FlxTween.tween(pose, {y: 1050}, 9.8);
							FlxTween.tween(pose, {x: 1350}, 10.8);
					}
				case 1423:
					camGame.alpha = 0;
				case 1439:
					spoOoOoOky.x -= 100;
					spoOoOoOky.visible = true;
					spoOoOoOky.alpha = 0;
					FlxTween.tween(spoOoOoOky, {alpha: 1}, 1.5);
				case 1455:
					FlxTween.cancelTweensOf(spoOoOoOky);
					spoOoOoOky.alpha = 0;
					camGame.alpha = 1;
			}
		}
    }

    override function beatHit()
    {
        if (curBeat % 4 == 0)
		{
			var prevInt:Int = sunkerTimebarNumber;

			sunkerTimebarNumber = FlxG.random.int(1, 9, [sunkerTimebarNumber]);

			switch(sunkerTimebarNumber){
				case 1:
					game.timeBar.createFilledBar(0x00FF0000, 0xFFFF0000);
					game.timeBar.updateBar();
				case 2:
					game.timeBar.createFilledBar(0x001BFF00, 0xFF1BFF00);
					game.timeBar.updateBar();
				case 3:
					game.timeBar.createFilledBar(0x0000C9FF, 0xFF00C9FF);
					game.timeBar.updateBar();
				case 4:
					game.timeBar.createFilledBar(0x00FC00FF, 0xFFFC00FF);
					game.timeBar.updateBar();
				case 5:
					game.timeBar.createFilledBar(0x00FFD100, 0xFFFFD100);
					game.timeBar.updateBar();
				case 6:
					game.timeBar.createFilledBar(0x000011FF, 0xFF0011FF);
					game.timeBar.updateBar();
				case 7:
					game.timeBar.createFilledBar(0x00C9C9C9, 0xFFC9C9C9);
					game.timeBar.updateBar();
				case 8:
					game.timeBar.createFilledBar(0x0000FFE3, 0xFF00FFE3);
					game.timeBar.updateBar();
				case 9:
					game.timeBar.createFilledBar(0x006300FF, 0xFF6300FF);
					game.timeBar.updateBar();
			}
		}
    }
}