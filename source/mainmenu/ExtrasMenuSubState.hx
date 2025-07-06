package mainmenu;

import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxCamera;

class ExtrasMenuSubState extends MusicBeatSubstate
{
	var menuItems:Array<Dynamic> = [
		{
			name: "garden",
			onPress: function()
			{
				MusicBeatState.switchState(new DAGardenState());
			}
		},
		{
			name: "skins",
			onPress: function()
			{
				MusicBeatState.switchState(new SkinsMenuState());
			}
		},
		{
			name: "temp",
			onPress: function()
			{
				FlxG.resetState();
			}
		}
	];
	var menuObjects:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup();

	var curSelected:Int = 0;
	var canPress:Bool = false;

	override public function new()
	{
		trace("extra time!");

		super();
		this.camera = FlxG.cameras.add(new FlxCamera(), false);
		this.camera.bgColor = 0xFF;

		add(menuObjects);

		for (i => item in menuItems)
		{
			var obj = new FlxSprite(FlxG.width * 5, 45 + (i * 100));
			obj.frames = Paths.getSparrowAtlas("mainmenu/extras/extras_" + item.name);
			obj.animation.addByPrefix("idle", item.name + " basic");
			obj.animation.addByPrefix("select", item.name + " white");
			obj.animation.play("idle");
			FlxTween.tween(obj, {x: 530 + (i * 75)}, 1 + (i * 0.25), {ease: FlxEase.expoInOut});
			menuObjects.add(obj);
		}

		new FlxTimer().start(0.1, function(timer)
		{ // stupid initalizing
			canPress = true;
		});

		changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P && canPress) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P && canPress) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			for (i => obj in menuObjects.members)
				if (i != curSelected)
					FlxTween.tween(obj, {alpha: 0}, 0.4, {onComplete: function(tween)
					{
						obj.kill();
					}});
				else
					FlxFlicker.flicker(obj, 1, 0.04, false, true);

			new FlxTimer().start(1, function(timer)
			{
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
