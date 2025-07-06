package stages;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;
import openfl.Lib;

import stages.objects.FatalPopup;

class LaunchBaseStage extends BaseStage
{
    var base:FlxSprite;
	var domain:FlxSprite;
	var domain2:FlxSprite;
	var trueFatal:FlxSprite;
	// mechanic shit + moving funne window for fatal error
	var windowX:Float = Lib.application.window.x;
	var windowY:Float = Lib.application.window.y;
	var Xamount:Float = 0;
	var Yamount:Float = 0;
	var IsWindowMoving:Bool = false;
	var IsWindowMoving2:Bool = false;
	var errorRandom:FlxRandom = new FlxRandom(666); // so that every time you play the song, the error popups are in the same place

	// window moving screen mechanics values
	var X_SPEED_MULTIPLIER:Float = 1.5;
    var Y_SPEED_MULTIPLIER:Float = 2.0;
    
    var STEP_BOOST_MULTIPLIER:Float = 3.4;

    override function create()
    {
        FlxG.mouse.visible = true;
		FlxG.mouse.unload();
		FlxG.mouse.load(Paths.image("cursors/fatal_mouse").bitmap, 1.5, 0);

		GameOverSubstate.characterName = 'bf-fatal-death';
		GameOverSubstate.deathSoundName = 'fatal-death';
		GameOverSubstate.loopSoundName = 'starved-loop';

		base = new FlxSprite(-200, 100);
		base.frames = Paths.getSparrowAtlas('fatal/launchbase', 'exe');
		base.animation.addByIndices('base', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
		base.animation.play('base');
        base.scale.set(5, 5);
		base.antialiasing = false;
		base.scrollFactor.set(1, 1);
		add(base);

		domain2 = new FlxSprite(100, 200);
		domain2.frames = Paths.getSparrowAtlas('fatal/domain2', 'exe');
		domain2.animation.addByIndices('theand', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
		domain2.animation.play('theand');
        domain2.scale.set(4, 4);
		domain2.antialiasing = false;
		domain2.scrollFactor.set(1, 1);
		domain2.visible = false;
		add(domain2);

		domain = new FlxSprite(100, 200);
		domain.frames = Paths.getSparrowAtlas('fatal/domain', 'exe');
		domain.animation.addByIndices('begin', 'idle', [0, 1, 2, 3, 4], "", 12, true);
		domain.animation.play('begin');
		domain.scale.set(4, 4);
		domain.antialiasing = false;
		domain.scrollFactor.set(1, 1);
		domain.visible = false;
		add(domain);

		trueFatal = new FlxSprite(250, 200);
		trueFatal.frames = Paths.getSparrowAtlas('fatal/truefatalstage', 'exe');
		trueFatal.animation.addByIndices('piss', 'idle', [0, 1, 2, 3], "", 12, true);
		trueFatal.animation.play('piss');
		trueFatal.scale.set(4, 4);
		trueFatal.antialiasing = false;
		trueFatal.scrollFactor.set(1, 1);
		trueFatal.visible = false;
		add(trueFatal);
    }

    override function createPost()
    {
		game.healthBarBG.xAdd -= 2;
		game.healthBarBG.yAdd++;
		for (note in cast(game.unspawnNotes, Array<Dynamic>)) {
			if (!note.mustPress) {
				note.reloadNote(null, "fatal");
			} else {
				note.reloadNote(null, 'week6');
			}
		}
		game.opponentStrums.forEach(function(spr:StrumNote)
		{
			spr.set_texture("fatal");
		});
        game.playerStrums.forEach(function(spr:StrumNote)
		{
			spr.set_texture("week6");
		});
    }

    override function update(elapsed:Float)
    {
        if (PlayState.SONG.song.toLowerCase() == 'fatality' && IsWindowMoving)
		{
			var thisX:Float = Math.sin(Xamount * (Xamount)) * 100;
			var thisY:Float = Math.sin(Yamount * (Yamount)) * 100;
			var yVal = Std.int(windowY + thisY);
			var xVal = Std.int(windowX + thisX);
			Lib.application.window.move(xVal, yVal);

			Yamount = Yamount + (0.001 * Y_SPEED_MULTIPLIER);
            Xamount = Xamount + (0.0005 * X_SPEED_MULTIPLIER);
		}
    }

    override function eventCalled(eventName:String, value1:String, value2:String)
    {
        switch (eventName)
        {
            case 'Fatality Popup':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;

				var type:Int = Std.parseInt(value2);
				if (Math.isNaN(type) || type<1)
					type = 1;
				for(idx in 0...value){
					doPopup(type);
				}

			case 'Clear Popups':
				FatalPopup.cleanup();
        }
    }

    // rewritten neb code by justx
	function doPopup(type:Int)
	{
		var popup = new FatalPopup(0, 0, type);
		popup.x = errorRandom.int(0, Std.int(FlxG.width - popup.width));
		popup.y = errorRandom.int(0, Std.int(FlxG.height - popup.height));
		popup.cameras = [camIDK];
		add(popup);
	}

    override function stepHit()
    {
        if (PlayState.SONG.song.toLowerCase() == 'fatality')
		{
			switch (curStep)
			{
				case 255, 1983:
					fatalTransitionStatic();
				case 256:
					fatalTransistionThing();
				case 1984:
                    Xamount += 2 * STEP_BOOST_MULTIPLIER;
                    Yamount += 2 * STEP_BOOST_MULTIPLIER;
                    fatalTransistionThingDos();
                    windowX = Lib.application.window.x;
                    windowY = Lib.application.window.y;
                    IsWindowMoving2 = true;
					IsWindowMoving2 = true;
				case 2208:
					IsWindowMoving = false;
					IsWindowMoving2 = false;
				case 2230:
					shakescreen();
					camGame.shake(0.02, 0.8);
					camHUD.shake(0.02, 0.8);
				case 2240:
					IsWindowMoving = true;
					IsWindowMoving2 = false;
				case 2528:
					shakescreen();
					IsWindowMoving = true;
					IsWindowMoving2 = true;
					Yamount += 3 * STEP_BOOST_MULTIPLIER;
                    Xamount += 3 * STEP_BOOST_MULTIPLIER;
					camGame.shake(0.02, 2);
					camHUD.shake(0.02, 2);
				case 2530:
					shakescreen();
				case 2535:
					shakescreen();
				case 2540:
					shakescreen();
				case 2545:
					shakescreen();
				case 2550:
					shakescreen();
				case 2555:
					shakescreen();
				case 2560:
					IsWindowMoving = false;
					IsWindowMoving2 = false;
				    windowGoBack();
			}
		}
    }

    function shakescreen()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int(-10, 10), Lib.application.window.y + FlxG.random.int(-8, 8));
		}, 50);
	}

    function windowGoBack()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			var xLerp:Float = FlxMath.lerp(windowX, Lib.application.window.x, 0.95);
			var yLerp:Float = FlxMath.lerp(windowY, Lib.application.window.y, 0.95);
			Lib.application.window.move(Std.int(xLerp), Std.int(yLerp));
		}, 20);
	}

    function fatalTransistionThing()
	{
		base.visible = false;
		domain.visible = true;
		domain2.visible = true;
	}

	function fatalTransitionStatic()
	{
		// placeholder for now, waiting for cool static B) (cool static added)
		var daStatic = new BGSprite('statix', 0, 0, 1.0, 1.0, ['statixx'], true);
		daStatic.screenCenter();
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.cameras = [camIDK];
		add(daStatic);
		FlxG.sound.play(Paths.sound('staticBUZZ'));
		new FlxTimer().start(0.20, function(tmr:FlxTimer)
		{
			remove(daStatic);
		});
	}

	function fatalTransistionThingDos()
	{
		if (!ClientPrefs.middleScroll)
		{
			game.playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x -= 222;
			});
			game.opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x += 10000;
			});
		}

		FatalPopup.cleanup();

		dadGroup.x += 600;
		dadGroup.y -= 90;

		boyfriendGroup.x -= 580;
		boyfriendGroup.y += 150;

		domain.visible = false;
		domain2.visible = false;
		trueFatal.visible = true;
	}
}