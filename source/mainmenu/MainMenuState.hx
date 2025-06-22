package mainmenu;

#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	
	var menuItems:Array<Dynamic> = [
		{
			name: "story_mode",
			onPress: function()
			{
				LoadingState.loadAndSwitchState(new StoryMenuState());
			}
		},
		{
			name: "freeplay",
			onPress: function()
			{
				MusicBeatState.switchState(new FreeplayState());
			}
		},
		{
			name: "encore",
			onPress: function()
			{
				MusicBeatState.switchState(new EncoreState());
			}
		},
		{
			name: "sound_test",
			onPress: function()
			{
				MusicBeatState.switchState(new SoundTestMenu());
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
	var debugKeys:Array<FlxKey>;

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		FlxG.sound.playMusic(Paths.music('freakyMenu'));

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('Main_Menu_Spritesheet_Animation');
		bg.animation.addByPrefix('a', 'BG instance 1');
		bg.animation.play('a', true);
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
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

	var canMove:Bool = true;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canMove)
		{
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}

			if (controls.BACK)
			{
				canMove = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				canMove = false;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				for (i => obj in menuObjects.members)
					if (i != curSelected)
						FlxTween.tween(obj, {alpha: 0}, 0.4, {onComplete: function(tween){obj.kill();}});
					else
						FlxFlicker.flicker(obj, 1, 0.04, false, true);

				new FlxTimer().start(1, function(timer) {
					menuItems[curSelected].onPress();
				});
			} else if (FlxG.keys.anyJustPressed(debugKeys)) {
				canMove = false;
				MusicBeatState.switchState(new editors.MasterEditorMenu());
		    }
	    }
	}

	function changeSelection(amt:Int = 0)
	{
		menuObjects.members[curSelected].animation.play("idle");
		curSelected = FlxMath.wrap(curSelected + amt, 0, menuItems.length - 1);
		menuObjects.members[curSelected].animation.play("select");
	}
}