package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import hxvlc.flixel.FlxVideo;
import hxvlc.util.Handle;
import openfl.display.FPS;
import openfl.utils.Assets as OpenFlAssets;
import lime.app.Application;
#if sys
import sys.FileSystem;
#end

//@:nullSafety
class Intro extends MusicBeatState
{
	static final IntroVideoPH = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

	var video:Null<FlxVideo>;
	var versionInfo:Null<FlxText>;
	var canSkip:Bool = false;
	var fatal:Bool = false;

	override function create():Void
	{
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;

		if (FlxG.save.data.firstBoot == null || FlxG.save.data.firstBoot == true) {
			FlxG.save.data.firstBoot == true;
			FlxG.switchState(new WarningState());
			return;
		}

		setupUI();

		fatal = FlxG.random.bool(0.25) && FlxG.save.data.canGetFatal == null 
			|| FlxG.save.data.canGetFatal != null && Paths.getTextFromFile("data/containFatalError.cnt") != "Fatal_Prevention_Measures = false";
		
		trace(Paths.getTextFromFile("data/containFatalError.cnt"));

		canSkip = FlxG.save.data.seenIntro && !fatal;

		if (fatal) {
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
		}

		if(FlxG.save.data != null && FlxG.save.data.fullscreen) {
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

		setupVideoAsync(fatal);
		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (video != null && canSkip && (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end)) {
			video.dispose();
			FlxG.removeChild(video);
			if (!fatal) {
				if (!FlxG.save.data.seenIntro) {
					FlxG.save.data.seenIntro = true;
					FlxG.save.flush();
				}
				MusicBeatState.switchState(new TitleState());
			}
		}
		super.update(elapsed);
	}

	private function setupUI():Void
	{
		if(FlxG.save.data.volume != null) {
			FlxG.sound.volume = FlxG.save.data.volume;
		}

		if (FlxG.save.data.seenIntro == null) 
			FlxG.save.data.seenIntro = false;

		if (FlxG.save.data.seenIntro) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		} else {
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
			FlxG.sound.volume = 10;
		}

		#if desktop
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end

		#if !VIDEOS_ALLOWED
		FlxG.switchState(TitleState);
		break;
		#end

		#if (debug && VIDEOS_ALLOWED)
		versionInfo = new FlxText(10, FlxG.height - 10, 0, 'LibVLC ${Handle.version}', 17);
		versionInfo.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		versionInfo.font = Paths.font("chaotix.ttf");
		versionInfo.active = false;
		versionInfo.alignment = JUSTIFY;
		versionInfo.antialiasing = ClientPrefs.globalAntialiasing;
		versionInfo.y -= versionInfo.height;
		add(versionInfo);
		#end
	}

	private function setupVideoAsync(isFatal:Bool):Void
	{
		Handle.initAsync(function(success:Bool):Void
		{
			if (!success) return;

			video = new FlxVideo();
			video.smoothing = true;
			
			#if mobile
			video.onFormatSetup.add(function():Void {
				if (video != null) FlxG.scaleMode = new MobileScaleMode();
			});
			#end
			
			video.onEndReached.add(() -> {
				video.dispose();
				FlxG.removeChild(video);
				if (isFatal) {
					FlxG.save.data.canGetFatal = false;
					FlxG.save.flush();
					Sys.exit(1);
				} else {
					if (!FlxG.save.data.seenIntro) {
						FlxG.save.data.seenIntro = true;
						FlxG.save.flush();
					}
					FlxG.save.data.firstBoot == false;
					FlxG.save.flush();
					MusicBeatState.switchState(new TitleState());
				}
			});

			FlxG.addChildBelowMouse(video);

			try {
				var videoName = isFatal ? "fatal1" : "HaxeFlixelIntro";
				video.load(Paths.video(videoName));
			} catch (e:Dynamic) {
				if (isFatal) {
					trace("Fatal video not found!");
					Sys.exit(1);
				} else {
					video.load(IntroVideoPH);
				}
			}

			new FlxTimer().start(0.001, (_) -> video.play());
		});
	}
}