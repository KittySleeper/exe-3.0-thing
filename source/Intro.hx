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

#if (hxCodec == "2.6.0")
import vlc.MP4Handler as VideoHandler;
#elseif (hxCodec >= "2.6.1")
import hxcodec.VideoHandler;
#elseif (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as VideoHandler;
#end

using StringTools;

class Intro extends MusicBeatState
{
	var div:FlxSprite;

	override public function create()
	{
		FlxG.save.bind('exenew', 'kittysleeper');

		if (FlxG.save.data.firstBoot == null || FlxG.save.data.firstBoot == true)
		{
			FlxG.switchState(new WarningState());
		}
		else
		{
			div = new FlxSprite();
			div.loadGraphic(Paths.image("cameostuff/divide"));
			div.alpha = 0;
			add(div);

			FlxG.mouse.visible = false;

			var video = new VideoHandler();
			video.canSkip = false;
			#if (hxCodec >= "2.6.0")
			video.finishCallback = function()
			{
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
			video.playVideo(Paths.video('HaxeFlixelIntro'));
			#elseif (hxCodec >= "3.0.0")
			video.onEndReached.add(function()
			{
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
			});
			video.play(Paths.video('HaxeFlixelIntro'));
		#end
		}
	}
}
