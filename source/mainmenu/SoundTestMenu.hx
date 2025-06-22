package mainmenu;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;
import flixel.system.FlxSound;
#if desktop
import Discord.DiscordClient;
#end

class SoundTestMenu extends MusicBeatState
{
	// now we can change PCM and DA values very easily
	static final PCM_MAX:Int = 99;
	static final DA_MAX:Int = 99;
	
	var interactable:Bool = true;
	var inCameo:Bool = false;
	var soundCooldown:Bool = true;
	var isPCMSelected:Bool = true;
	
	var secretCodeProgress:Int = 0;
	var pcmValue:Int = 0;
	var daValue:Int = 0;
	
	var bg:FlxSprite;
	var overlay:FlxSprite;
	var titleText:FlxText;
	var pcmLabel:FlxText;
	var daLabel:FlxText;
	var pcmValueText:FlxText;
	var daValueText:FlxText;
	var cameoImage:FlxSprite;
	
	final peakSongs:Map<String, Array<String>> = [
		"12 25" => ["endless"],
		"7 7" => ["cycles", "fate"],
		"8 21" => ["chaos"],
		"4 20" => ["too-fest"],
		"8 17" => ["my-horizon"],
		"19 63" => ["round-a-bout"],
		"66 6" => ["sunshine", "soulless"],
		"40 3" => ["prey", "fight-or-flight"]
	];
	
	final cameoSecrets:Map<String, CameoData> = [
		"41 1" => { image: "Razencro", music: "Razencro" },
		"1 13" => { image: "divide" },
		"9 10" => { image: "Sunkeh" },
		"6 6" => { image: "GamerX" },
		"32 8" => { image: "Marstarbro", music: "Marstarbro" },
		"6 12" => { image: "a small error" }
	];
	
	final SECRET_CODE = ["P", "E", "R", "S", "O", "N", "E", "L"];

	override function create()
	{
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		
		#if desktop
		DiscordClient.changePresence('In Sound Test', null);
		#end

		FlxG.sound.playMusic(Paths.music('breakfast'), true);
		
		bg = new FlxSprite(-100).loadGraphic(Paths.image('backgroundST'));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		createStUI();
		
		FlxG.camera.zoom = 1.05;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.6, {ease: flixel.tweens.FlxEase.elasticOut});
		
		// discord white theme be like
		overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		overlay.alpha = 1;
		add(overlay);
		FlxTween.tween(overlay, {alpha: 0}, 0.5);
		
		cameoImage = new FlxSprite();
		cameoImage.visible = false;
		add(cameoImage);
		
		super.create();
	}

	function createStUI()
	{
		titleText = new FlxText(0, 80, 0, "SOUND TEST", 36);
		titleText.setFormat("Sonic CD Menu Font Regular", 36, FlxColor.fromRGB(0, 163, 255), CENTER);
		titleText.setBorderStyle(SHADOW, FlxColor.BLACK, 3);
		titleText.screenCenter(X);
		add(titleText);
		
		final yPos = FlxG.height / 2 - 50;
		final xOffset = 215;
		
		pcmLabel = createLabel("PCM NO.", FlxG.width / 2 - xOffset - 120, yPos);
		daLabel = createLabel("DA NO.", FlxG.width / 2 + xOffset - 100, yPos);
		
		pcmValueText = createValueText(pcmValue, pcmLabel.x + 180, yPos);
		daValueText = createValueText(daValue, daLabel.x + 150, yPos);
		
		add(pcmLabel);
		add(daLabel);
		add(pcmValueText);
		add(daValueText);
		
		updateSelection();
	}
	
	function createLabel(text:String, x:Float, y:Float):FlxText
	{
		final label = new FlxText(x, y, 0, text, 28);
		label.setFormat("Sonic CD Menu Font Regular", 28, FlxColor.fromRGB(174, 179, 251));
		label.setBorderStyle(SHADOW, FlxColor.fromRGB(106, 110, 159), 3);
		return label;
	}
	
	function createValueText(value:Int, x:Float, y:Float):FlxText
	{
		final text = new FlxText(x, y, 0, value < 10 ? '0$value' : '$value', 28);
		text.setFormat("Sonic CD Menu Font Regular", 28, FlxColor.WHITE);
		text.setBorderStyle(SHADOW, FlxColor.GRAY, 3);
		return text;
	}

	function updateSelection()
	{
		pcmLabel.color = isPCMSelected ? FlxColor.YELLOW : FlxColor.fromRGB(174, 179, 251);
		daLabel.color = !isPCMSelected ? FlxColor.YELLOW : FlxColor.fromRGB(174, 179, 251);
		
		pcmValueText.text = pcmValue < 10 ? '0$pcmValue' : '$pcmValue';
		daValueText.text = daValue < 10 ? '0$daValue' : '$daValue';
	}

	function changeValue(delta:Int)
	{
		if (isPCMSelected) {
			pcmValue = FlxMath.wrap(pcmValue + delta, 0, PCM_MAX);
		} else {
			daValue = FlxMath.wrap(daValue + delta, 0, DA_MAX);
		}
		updateSelection();
	}

	function tryPlaySound()
	{
		final combo = '$pcmValue $daValue';
		
		if (peakSongs.exists(combo)) {
			startSong(peakSongs.get(combo));
			return;
		}
		
		if (cameoSecrets.exists(combo)) {
			showCameo(cameoSecrets.get(combo));
			return;
		}
		
		playErrorSound();
	}

	function startSong(songArray:Array<String>)
	{
		interactable = false;
		
		PlayState.SONG = Song.loadFromJson(songArray[0], songArray[0]);
		PlayState.storyPlaylist = songArray;
		PlayState.storyDifficulty = 1;
		PlayState.storyWeek = 1;
		PlayState.isStoryMode = false;
		PlayState.isEncoreMode = false;
		PlayState.isSoundTest = true;
		
		var confirmSound = FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxTween.tween(overlay, {alpha: 1}, 0.4, {
			onComplete: _ -> {
				confirmSound.onComplete = () -> {
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		});
	}

	function showCameo(data:CameoData)
	{
		interactable = false;
		inCameo = true;
		
		cameoImage.loadGraphic(Paths.image('cameostuff/${data.image}'));
		cameoImage.setSize(1280, 720);
		cameoImage.screenCenter();
		cameoImage.antialiasing = ClientPrefs.globalAntialiasing;
		cameoImage.visible = true;
		
		FlxTween.tween(overlay, {alpha: 1}, 0.4, {
			onComplete: _ -> {
				FlxTween.tween(overlay, {alpha: 0}, 0.3);
				if (data.music != null) {
					FlxG.sound.playMusic(Paths.music('cameostuff/${data.music}'));
				}
			}
		});
	}

	function playErrorSound()
	{
		if (!soundCooldown) return;
		
		soundCooldown = false;
		FlxG.sound.play(Paths.sound('deniedMOMENT'));
		
		new FlxTimer().start(0.4, _ -> {
			soundCooldown = true;
		});
	}

	override function update(elapsed:Float)
	{
		if (!interactable) {
			if (inCameo && controls.BACK) {
				FlxG.sound.music.stop();
				FlxG.resetState();
				return;
			}

			super.update(elapsed);
			return;
		}
		
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			isPCMSelected = !isPCMSelected;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			updateSelection();
		}
		
		if (controls.UI_UP_P) {
			changeValue(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		if (controls.UI_DOWN_P) {
			changeValue(1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		if (controls.ACCEPT) {
			tryPlaySound();
		}
		
		if (controls.BACK) {
			interactable = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(overlay, {alpha: 1}, 0.4, {
				onComplete: _ -> LoadingState.loadAndSwitchState(new MainMenuState())
			});
		}
		
		// Nothing personel kid
		if (interactable) checkSecretCode();
		
		super.update(elapsed);
	}
	
	function checkSecretCode()
	{
		if (secretCodeProgress >= SECRET_CODE.length) return;
		
		var expectedKey = SECRET_CODE[secretCodeProgress];
		var keyPressed = false;
		var correctKey = false;
		
		for (key in FlxG.keys.getIsDown()) {
			if (key.justPressed) {
				keyPressed = true;
				var pressedKey = key.ID.toString();
				if (pressedKey == expectedKey) {
					correctKey = true;
					break;
				}
			}
		}
		
		if (correctKey) {
			secretCodeProgress++;
			if (secretCodeProgress == SECRET_CODE.length) {
				startSong(["personel"]);
			}
		} else if (keyPressed) {
			for (key in SECRET_CODE) {
				for (k in FlxG.keys.getIsDown()) {
					if (k.justPressed && k.ID.toString() == key) {
						secretCodeProgress = 0;
						return;
					}
				}
			}
		}
	}
}

typedef CameoData = {
	image:String,
	?music:String
}