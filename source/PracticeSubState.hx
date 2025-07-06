package;

import flixel.ui.FlxBar;
import Controls.Control;
import flixel.math.FlxMath;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;

class PracticeSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = ['Skip Time', 'Botplay', 'Practice Mode'];
	var curSelected:Int = 0;

	var bottomPause:FlxSprite;
	var topPause:FlxSprite;
    var warningThingy:FlxSprite;
	var actualText:FlxSprite;

	var practiceText:FlxText;

	var coolDown:Bool = true;

	var skipTimeActive:Bool = false;
	var skipTimeText:FlxText;
	var skipTimeBG:FlxSprite;
	var curSkipTime:Float = 0;
	var skipTimeInstructions:FlxText;

	var blinkTween:FlxTween;
	var menuSprites:Array<FlxSprite> = [];
	var blinkEnabled:Bool = true;

	override function create()
	{
		super.create();

        warningThingy = new FlxSprite().loadGraphic(Paths.image("pauseStuff/practice/instructions"));
		warningThingy.alpha = 0;
        add(warningThingy);

		bottomPause = new FlxSprite(-1280, 0).loadGraphic(Paths.image('pauseStuff/practice/side'));
		add(bottomPause);

		topPause = new FlxSprite(1280, 0).loadGraphic(Paths.image("pauseStuff/practice/head"));
		add(topPause);

		for (i in 0...menuItems.length)
		{
			actualText = new FlxSprite(-400 + (40 * i), (FlxG.height * 0.57) + (i * 110)).loadGraphic(Paths.image(StringTools.replace("pauseStuff/practice/" + menuItems[i], " ", "")));
			actualText.ID = i;
			menuSprites.push(actualText);
			add(actualText);
			FlxTween.tween(actualText, {x: 15 + (i * 120)}, 0.2, {ease: FlxEase.quadOut});
		}

		skipTimeBG = new FlxSprite().makeGraphic(380, 100, FlxColor.BLACK);
		skipTimeBG.alpha = 0.7;
		skipTimeBG.visible = false;
		add(skipTimeBG);

		skipTimeText = new FlxText(0, 0, 0, "", 32);
		skipTimeText.setFormat(Paths.font("PressStart2P.ttf"), 32, FlxColor.WHITE, CENTER);
		skipTimeText.visible = false;
		add(skipTimeText);

		skipTimeInstructions = new FlxText(0, 0, 0, "LEFT/RIGHT: Adjust\nENTER: Confirm", 20);
		skipTimeInstructions.setFormat(Paths.font("PressStart2P.ttf"), 20, FlxColor.WHITE, CENTER);
		skipTimeInstructions.visible = false;
		add(skipTimeInstructions);

		practiceText = new FlxText(20, FlxG.height - 40, 0, "PRACTICE MODE", 32);
        practiceText.scrollFactor.set();
        practiceText.setFormat(Paths.font('vcr.ttf'), 32);
        practiceText.x = FlxG.width - (practiceText.width + 20);
        practiceText.updateHitbox();
        practiceText.visible = PlayState.instance.practiceMode;
        add(practiceText);

		coolDown = false;
		new FlxTimer().start(0.2, function(lol:FlxTimer)
		{
			coolDown = true;
			changeSelection();
		});

		FlxTween.tween(warningThingy, {alpha: 1}, 0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(bottomPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(topPause, {x: !PlayState.isFixedAspectRatio ? 0 : -300}, 0.2, {ease: FlxEase.quadOut});

		new FlxTimer().start(0.5, function(_) {
			startBlinking();
		});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

		if (back)
        {
            closePracticeMenu();
        }

		if (coolDown)
		{
			if (upP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}
			if (downP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}

			if (accepted)
			{
				var daSelected:String = menuItems[curSelected];
				
				if (skipTimeActive)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					applySkipTime();
				}
				else
				{
					switch (daSelected)
					{
						case "Skip Time": 
							if (Conductor.songPosition < -1) return;
							skipTimeActive = true;
							curSkipTime = Conductor.songPosition;
							updateSkipTimeText();
							showSkipTimeControls();
							FlxG.sound.play(Paths.sound('scrollMenu'));
							
						case "Botplay":
							toggleBotplay();
							
						case "Practice Mode":
							togglePracticeMode();
					}
				}
			}
		}

		if (skipTimeActive)
		{
			handleSkipTimeControls(elapsed);
		}
	}

	function startBlinking():Void
	{
		blinkTween?.cancel();
		
		blinkTween = FlxTween.tween(menuSprites[curSelected], {alpha: 0.5}, 0.5, {
			type: FlxTweenType.PINGPONG,
			ease: FlxEase.quadInOut,
			loopDelay: 0.1,
			onComplete: function(twn:FlxTween) {
				if (blinkEnabled) startBlinking();
			}
		});
	}

	function showSkipTimeControls():Void
	{
		var selectedSprite = menuSprites[curSelected];
		skipTimeBG.x = selectedSprite.x + selectedSprite.width + 20;
		skipTimeBG.y = selectedSprite.y - 10;
		skipTimeBG.visible = true;
		
		skipTimeText.x = skipTimeBG.x + skipTimeBG.width/2 - skipTimeText.width/2;
		skipTimeText.y = skipTimeBG.y + 15;
		skipTimeText.visible = true;
		
		skipTimeInstructions.x = skipTimeBG.x + skipTimeBG.width/2 - skipTimeInstructions.width/2;
		skipTimeInstructions.y = skipTimeBG.y + skipTimeText.height + 20;
		skipTimeInstructions.visible = true;
	}

	function hideSkipTimeControls():Void
	{
		skipTimeBG.visible = false;
		skipTimeText.visible = false;
		skipTimeInstructions.visible = false;
		skipTimeActive = false;
	}

	function handleSkipTimeControls(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			hideSkipTimeControls();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		
		var timeAdjust:Int = 0;
		if (FlxG.keys.justPressed.LEFT) timeAdjust = -1000;
		if (FlxG.keys.justPressed.RIGHT) timeAdjust = 1000;
		
		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.pressed.LEFT) timeAdjust = -5000;
			if (FlxG.keys.pressed.RIGHT) timeAdjust = 5000;
		}
		
		if (timeAdjust != 0)
		{
			curSkipTime += timeAdjust;
			curSkipTime = Math.max(0, Math.min(curSkipTime, FlxG.sound.music.length));
			updateSkipTimeText();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
	}

	function updateSkipTimeText():Void
	{
		var current = formatTime(curSkipTime);
		var total = formatTime(FlxG.sound.music.length);
		skipTimeText.text = '$current / $total';
		skipTimeText.x = skipTimeBG.x + skipTimeBG.width/2 - skipTimeText.width/2;
	}

	function formatTime(time:Float):String
	{
		var minutes = Math.floor(time / 60000);
		var seconds = Math.floor((time % 60000) / 1000);
		return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
	}

	function applySkipTime():Void
	{
		hideSkipTimeControls();
		
		if (curSkipTime < Conductor.songPosition)
		{
			PlayState.startOnTime = curSkipTime;
			PauseSubState.restartSong(true);
		}
		else
		{
			PlayState.instance.clearNotesBefore(curSkipTime);
			PlayState.instance.setSongTime(curSkipTime);
			closePracticeMenu();
		}
	}

	function toggleBotplay():Void
	{
		PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
		PlayState.changedDifficulty = true;

		var botplayTxt = PlayState.instance.botplayTxt;
        botplayTxt.visible = PlayState.instance.cpuControlled;
        botplayTxt.alpha = 1;
        PlayState.instance.botplaySine = 0;

		playRandomSound();
	}

	function togglePracticeMode():Void
	{
		PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
		PlayState.changedDifficulty = true;
		practiceText.visible = PlayState.instance.practiceMode;
		playRandomSound();
	}

	function playRandomSound()
    {
        switch (FlxG.random.int(1,7)) {
            case 1: FlxG.sound.play(Paths.sound("FartHD"));
            case 2: FlxG.sound.play(Paths.sound("vineboom"));
            case 3: FlxG.sound.play(Paths.sound("secretSound"));
            case 4: FlxG.sound.play(Paths.sound("Ring"));
            case 5: FlxG.sound.play(Paths.sound("yay"));
            case 6: FlxG.sound.play(Paths.sound("waowaowaowaowao"));
            case 7: FlxG.sound.play(Paths.sound("switch"));
        }
    }

	function closePracticeMenu():Void
	{
		blinkEnabled = true;
    	blinkTween?.cancel();

		FlxG.sound.play(Paths.sound("unpause"));

		for (i in 0...menuSprites.length)
		{
			var options = menuSprites[i];
			FlxTween.tween(options, {x: -options.width - 100}, 0.2, {ease: FlxEase.quadOut});
		}

		FlxTween.tween(topPause, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(bottomPause, {x: -1280}, 0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(warningThingy, {alpha: 0}, 0.2, {
			ease: FlxEase.quadOut,
			onComplete: (_) -> { 
				close(); 
			}
		});
	}

	function changeSelection(change:Int = 0):Void
	{
		if (menuSprites.length > 0) {
			for (spr in menuSprites) {
				spr.alpha = 1.0;
			}
		}

		curSelected += change;

		if (change == 1 || change == -1) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		blinkTween?.cancel();

		if (skipTimeActive) {
			hideSkipTimeControls();
		}

		startBlinking();
	}
}