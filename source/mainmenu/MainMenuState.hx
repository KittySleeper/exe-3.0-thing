package mainmenu;

import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	
	var menuItems:Array<Dynamic> = [
		{
			name: "story_mode",
			onPress: function()
			{
				FlxG.switchState(new StoryMenuState());
			}
		},
		{
			name: "freeplay",
			onPress: function()
			{
				FlxG.switchState(new FreeplayState());
			}
		},
		{
			name: "encore",
			onPress: function()
			{
				FlxG.switchState(new EncoreState());
			}
		},
		{
			name: "sound_test",
			onPress: function()
			{
				FlxG.switchState(new SoundTestMenu());
			}
		},
		{
			name: "options",
			onPress: function()
			{
				LoadingState.loadAndSwitchState(new options.OptionsState());
			}
		},
		{
			name: "extras",
			onPress: function()
			{
				FlxG.state.openSubState(new ExtrasMenuSubState());
			}
		}
	];
	var menuObjects:FlxTypedSpriteGroup<FlxSprite>;

	var curSelected:Int = 0;
	var canPress:Bool = true;

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.sound.playMusic(Paths.music('storymodemenumusic'));

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('Main_Menu_Spritesheet_Animation');
		bg.animation.addByPrefix('a', 'BG instance 1');
		bg.animation.play('a', true);
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		add(menuObjects = new FlxTypedSpriteGroup());

		for (i => item in menuItems)
		{
			var obj = new FlxSprite(FlxG.width * 5, 45 + (i * 100));
			obj.frames = Paths.getSparrowAtlas("mainmenu/main/menu_" + item.name);
			obj.animation.addByPrefix("idle", item.name + " basic");
			obj.animation.addByPrefix("select", item.name + " white");
			obj.animation.play("idle");
			FlxTween.tween(obj, {x: 530 + (i * 75)}, 1 + (i * 0.25), {ease: FlxEase.expoInOut});
			menuObjects.add(obj);
		}

		changeSelection();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P && canPress)
			changeSelection(-1);
		if (controls.UI_DOWN_P && canPress)
			changeSelection(1);

        if (controls.ACCEPT && canPress) {
			canPress = false;

			for (i => obj in menuObjects.members)
				if (i != curSelected)
					FlxTween.tween(obj, {alpha: 0}, 0.4, {onComplete: function(tween){obj.kill();}});
				else
					FlxFlicker.flicker(obj, 1, 0.04, false, true);

			new FlxTimer().start(1, function(timer) {
				menuItems[curSelected].onPress();
			});
		}
	}

	function changeSelection(amt:Int = 0)
	{
		menuObjects.members[curSelected].animation.play("idle");
		curSelected = FlxMath.wrap(curSelected + amt, 0, menuItems.length - 1);
		menuObjects.members[curSelected].animation.play("select");
	}
}