package;

import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	public static var curDifficulty:String = '';

	var scoreText:FlxText;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	//EXE Menu
	var ezbg:FlxSprite;

	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var leftArrow2:FlxSprite;
	var rightArrow2:FlxSprite;

	var curdiff:Int = 2;

	var real:Int = 0;

	var oneclickpls:Bool = true;

	var bfIDLELAWL:Boyfriend;

	var redBOX:FlxSprite;

	var selection:Bool = false;

	var songArray = ['too-slow', 'you-cant-run', 'triple-trouble'];

	var staticscreen:FlxSprite;
	var portrait:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		if (FlxG.save.data.storyProgress == null) {
			FlxG.save.data.storyProgress = 0;
			FlxG.save.flush();
		}

		FlxG.sound.playMusic(Paths.music('storymodemenumusic'));

		var bg:FlxSprite = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('SMMStatic', 'exe');
		bg.animation.addByPrefix('idlexd', "damfstatic", 24);
		bg.animation.play('idlexd');
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(Std.int(bg.width));
		bg.updateHitbox();
		add(bg);

		var greyBOX:FlxSprite = new FlxSprite(-5, 0).loadGraphic(Paths.image('sm stuff/greybox'));
		greyBOX.antialiasing = ClientPrefs.globalAntialiasing;
		greyBOX.setGraphicSize(Std.int(bg.width));
		greyBOX.updateHitbox();
		add(greyBOX);

		bfIDLELAWL = new Boyfriend(-100, 0);
		bfIDLELAWL.scale.x = .4;
		bfIDLELAWL.scale.y = .4;
		bfIDLELAWL.screenCenter();
		bfIDLELAWL.antialiasing = ClientPrefs.globalAntialiasing;
		bfIDLELAWL.y += 50;
		bfIDLELAWL.animation.play('idle', true);
		add(bfIDLELAWL);

		real = FlxG.save.data.storyProgress;
    	if (real >= songArray.length) real = songArray.length - 1;

		portrait = new FlxSprite(445, 79).loadGraphic(Paths.image('sm stuff/arts/' + songArray[real]));
		portrait.setGraphicSize(Std.int(portrait.width * 0.275));
		portrait.antialiasing = ClientPrefs.globalAntialiasing;
		portrait.updateHitbox();
		add(portrait);

		staticscreen = new FlxSprite(445, 0);
		staticscreen.frames = Paths.getSparrowAtlas('screenstatic', 'exe');
		staticscreen.animation.addByPrefix('screenstaticANIM', "screenSTATIC", 24);
		staticscreen.animation.play('screenstaticANIM');
		staticscreen.y += 79;
		staticscreen.alpha = 0.3;
		staticscreen.antialiasing = ClientPrefs.globalAntialiasing;
		staticscreen.setGraphicSize(Std.int(staticscreen.width * 0.275));
		staticscreen.updateHitbox();
		add(staticscreen);

		var yellowBOX:FlxSprite = new FlxSprite(-10, 0).loadGraphic(Paths.image('sm stuff/yellowbox'));
		yellowBOX.antialiasing = ClientPrefs.globalAntialiasing;
		yellowBOX.setGraphicSize(Std.int(bg.width));
		yellowBOX.updateHitbox();
		add(yellowBOX);

		redBOX = new FlxSprite(0, 0).loadGraphic(Paths.image('sm stuff/redbox'));
		redBOX.antialiasing = ClientPrefs.globalAntialiasing;
		redBOX.setGraphicSize(Std.int(bg.width));
		redBOX.updateHitbox();
		add(redBOX);

		sprDifficulty = new FlxSprite(550, 600);
		sprDifficulty.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('encore', 'NORMAL');
		sprDifficulty.animation.play('normal');
		add(sprDifficulty);

		leftArrow = new FlxSprite(sprDifficulty.x - 150, sprDifficulty.y);
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.8));
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(sprDifficulty.x + 230, sprDifficulty.y);
		rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.8));
		rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
		add(rightArrow);

		leftArrow2 = new FlxSprite(325, 136 + 5);
		leftArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
		leftArrow2.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow2.setGraphicSize(Std.int(leftArrow2.width * 0.8));
		leftArrow2.animation.addByPrefix('idle', "arrow left");
		leftArrow2.animation.addByPrefix('press', "arrow push left");
		leftArrow2.animation.play('idle');
		add(leftArrow2);

		rightArrow2 = new FlxSprite(820, 136 + 5);
		rightArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
		rightArrow2.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow2.setGraphicSize(Std.int(rightArrow2.width * 0.8));
		rightArrow2.animation.addByPrefix('idle', "arrow right");
		rightArrow2.animation.addByPrefix('press', "arrow push right");
		rightArrow2.animation.play('idle');
		add(rightArrow2);

		sprDifficulty.offset.x = 70;
		sprDifficulty.y = leftArrow.y + 10;

		if(FlxG.save.data.storyDifficulty == null) {
			FlxG.save.data.storyDifficulty = '';
		}

		helloMaDiff(FlxG.save.data.storyDifficulty);

		super.create();
	}

	function helloMaDiff(diff:String)
	{
		curDifficulty = diff;
		
		switch(diff) {
			case '-easy': 
				curdiff = 1;
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case '-hard': 
				curdiff = 3;
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
			default: 
				curdiff = 2;
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
		}
	}

	function changediff(diff:Int = 1)
	{
		if (curdiff + diff < 1) return;
		if (curdiff + diff > 3) return;
		if (FlxG.save.data.storyProgress > 0 && FlxG.save.data.storyProgress != 3) return;

		curdiff += diff;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		switch(curdiff) {
			case 1:
				curDifficulty = '-easy';
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 2: 
				curDifficulty = '';
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 3: 
				curDifficulty = '-hard';
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}
		
		FlxG.save.data.storyDifficulty = curDifficulty;
		FlxG.save.flush();

		sprDifficulty.alpha = 0;
		sprDifficulty.y = leftArrow.y - 15;
		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 10, alpha: 1}, 0.07);
	}

	function changeAct(diff:Int = 1)
	{
		var newIndex:Int = real + diff;
		
		if (newIndex < 0) newIndex = 0;
		if (newIndex > FlxG.save.data.storyProgress) newIndex = FlxG.save.data.storyProgress;
		if (newIndex >= songArray.length) newIndex = songArray.length - 1;

		if (newIndex != real) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			real = newIndex;
			portrait.loadGraphic(Paths.image('sm stuff/arts/' + songArray[real]));
			
			FlxTween.cancelTweensOf(staticscreen);
			staticscreen.alpha = 1;
			FlxTween.tween(staticscreen, {alpha: 0.3}, 1);
		}
	}

	function changeSelec()
	{
		selection = !selection;

		if (selection)
		{
			leftArrow.setPosition(345, 145);
			rightArrow.setPosition(839, 145);
			leftArrow2.setPosition(550 - 160 - 5, 600 - 2);
			rightArrow2.setPosition(550 + 230 - 15, 600 - 2);
		}
		else
		{
			leftArrow2.setPosition(325, 136 + 5);
			rightArrow2.setPosition(820, 136 + 5);
			leftArrow.setPosition(550 - 150, 600);
			rightArrow.setPosition(550 + 230, 600);
		}
	}

	override public function update(elapsed:Float)
	{
		if (controls.UI_LEFT && oneclickpls)
		{
			if (selection && real > 0) 
				leftArrow.animation.play('press');
			else if (!selection && curdiff > 1)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');
		}
		else
		{
			leftArrow.animation.play('idle');
		}

		if (controls.UI_LEFT_P && oneclickpls)
		{
			if (selection && real > 0)
				changeAct(-1);
			else if (!selection && curdiff > 1)
				changediff(-1);
		}

		if (controls.UI_RIGHT && oneclickpls)
		{
			if (selection && real < FlxG.save.data.storyProgress && real < songArray.length - 1)
				rightArrow.animation.play('press');
			else if (!selection && curdiff < 3)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');
		}
		else
		{
			rightArrow.animation.play('idle');
		}

		if (controls.UI_RIGHT_P && oneclickpls)
		{
			if (selection && real < FlxG.save.data.storyProgress && real < songArray.length - 1)
				changeAct(1);
			else if (!selection && curdiff < 3)
				changediff(1);
		}

		if ((controls.UI_UP_P && oneclickpls && !selection) || 
			(controls.UI_DOWN_P && oneclickpls && selection))
		{
			changeSelec();
		}

		if (controls.BACK && oneclickpls)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (oneclickpls)
			{
				oneclickpls = false;

				FlxG.sound.play(Paths.sound('confirmMenu'));

				switch(sprDifficulty.animation.curAnim.name)
				{
					case 'easy':
						curDifficulty = '-easy';
					case 'hard':
						curDifficulty = '-hard';
				}

				PlayState.SONG = Song.loadFromJson(songArray[real].toLowerCase() + curDifficulty, songArray[real].toLowerCase());
				PlayState.isStoryMode = true;
				PlayState.isEncoreMode = false;
				PlayState.isSoundTest = false;
				PlayState.storyPlaylist = songArray;
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if (ClientPrefs.flashing)
			{
				FlxFlicker.flicker(redBOX, 1, 0.06, false, false, function(flick:FlxFlicker) {});
			}
		}

		super.update(elapsed);
	}
}