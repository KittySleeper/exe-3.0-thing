package;

import flixel.graphics.FlxGraphic;
import sys.FileSystem;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
// import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

import hxcodec.VideoHandler;

using StringTools;

class Intro extends MusicBeatState
{
	override public function create()
	{
		FlxG.save.bind('exenew', 'kittysleeper');

		var fatalBool:Bool = FlxG.random.bool(25) && FlxG.save.data.canGetFatal == null || FlxG.save.data.canGetFatal != null && Paths.getTextFromFile("data/containFatalError.cnt") != "Fatal_Prevention_Measures = false";

		trace(Paths.getTextFromFile("data/containFatalError.cnt"));

		if (FlxG.save.data.firstBoot == null || FlxG.save.data.firstBoot == true)
		{
			FlxG.switchState(new WarningState());
		}
		else
		{
			var div:FlxSprite;
			div = new FlxSprite();
			div.loadGraphic(Paths.image("cameostuff/divide"));
			div.alpha = 0;
			add(div);

			FlxG.mouse.visible = false;

			var video = new VideoHandler();
			video.canSkip = false;
			video.finishCallback = function()
			{
				if (fatalBool) {
					FlxG.save.data.canGetFatal = false;
					FlxG.save.flush();
					Sys.exit(1);
				}
				FlxG.sound.muteKeys = TitleState.muteKeys;
				FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
				FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
				FlxTween.tween(div, {alpha: 1}, 3.4, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(div, {alpha: 0}, 3.4, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								MusicBeatState.switchState(new TitleState());
							}
						});
					}
				});
			}

			video.playVideo(Paths.video(if (fatalBool) 'fatal1' else 'HaxeFlixelIntro'));
		}
	}
}