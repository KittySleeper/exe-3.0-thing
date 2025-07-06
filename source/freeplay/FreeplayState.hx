package freeplay;

#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import sys.FileSystem;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxSkewedSprite;

using StringTools;

class FreeplayState extends MusicBeatState
{
	// constants for changing visuals options easily
	static final BOX_HEIGHT = 415;
	static final BOX_SCALE_SELECTED = 0.58;
	static final BOX_SCALE_UNSELECTED = 0.465;
	static final TRANSITION_DURATION = 0.25;
	static final SCROLL_SPEED = 1;
	
	// ui(aka visuals) stuff
	var fadeSprite:FlxSprite;
	var textGroup:FlxTypedGroup<FlxText>;
	var boxGroup:SkewSpriteGroup;
	var bg:FlxBackdrop;
	var scrollingBg:FlxBackdrop;
	var charText:FlxText;
	var scoreText:FlxText;
	
	// game ahh backend stuff
	var curCharSelected:Int = 0;
	var curSongSelected:Int = 0;
	var canControl:Bool = true;
	var isSelectingSong:Bool = false;
	var characters:Array<String>;
	var unlockedChars:Array<String>;

	// control things (hold scrolling)
	var holdTime:Float = 0;
    var holdDelay:Float = 0.5; // delay before autoscrolling
    var holdInterval:Float = 0; // if someone wants to add interval between scrolling

	// choosing save thing
	public static var lastCharSelected:Int = 0;
	public static var lastSongSelected:Int = 0;
	public static var wasSelectingSong:Bool = false;

	override function create()
	{
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		CharSongList.init();
		
		characters = CharSongList.characters;
		unlockedChars = CharSongList.charactersUnlocked;

		curCharSelected = lastCharSelected;
		curSongSelected = lastSongSelected;
		isSelectingSong = wasSelectingSong;

		createVisuals();
		setupTexts();

		boxGroup.y = -curCharSelected * BOX_HEIGHT; // for the balance of the world

		updateSelection();

		if (isSelectingSong) {
			highlightSelectedSong();
		}
		
		#if desktop
		DiscordClient.changePresence("In Freeplay Menu", null);
		#end

		super.create();
	}

	function createVisuals()
	{
		bg = new FlxBackdrop(Paths.image('backgroundlool'));
		bg.screenCenter();
		bg.scale.set(0.35, 0.35);
		bg.repeatAxes = X;
		add(bg);
		
		scrollingBg = new FlxBackdrop(Paths.image('fp stuff/sidebar'));
		add(scrollingBg);
		
		add(new FlxSprite(300).makeGraphic(10, 720, FlxColor.BLACK));
		
		boxGroup = new SkewSpriteGroup();
		boxGroup.x = -335;
		add(boxGroup);
		
		for (i in 0...characters.length) 
			createCharacterBox(i);
		
		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);
		
		fadeSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		fadeSprite.alpha = 0;
		add(fadeSprite);
	}
	
	function createCharacterBox(index:Int)
	{
		// Cocks
		var box = new FlxSkewedSprite(0, index * BOX_HEIGHT);
		box.loadGraphic(Paths.image('FreeBox'));
		box.ID = index;
		box.scale.set(BOX_SCALE_UNSELECTED, BOX_SCALE_UNSELECTED);
		box.antialiasing = ClientPrefs.globalAntialiasing;
		boxGroup.add(box);
		
		// Character song art
		var art = new FlxSkewedSprite(0, index * BOX_HEIGHT);
		art.ID = index;
		art.antialiasing = ClientPrefs.globalAntialiasing;
		art.scale.set(BOX_SCALE_UNSELECTED, BOX_SCALE_UNSELECTED);
		
		if (unlockedChars.contains(characters[index])) {
			var artPath = 'fp stuff/arts/${characters[index].toLowerCase()}';
			art.loadGraphic(FileSystem.exists('assets/images/$artPath') ? 
				Paths.image(artPath) : Paths.image('fp stuff/arts/placeholder'));
		} else {
			art.loadGraphic(Paths.image('fp stuff/arts/locked'));
		}
		
		boxGroup.add(art);
	}

	function isSongUnlocked(songId:String):Bool
	{
		if (!unlockedChars.contains(characters[curCharSelected])) 
			return false;
		
		if (FlxG.save.data.unlockedSongs != null && 
			FlxG.save.data.unlockedSongs.contains(songId)) 
			return true;
			
		return false;
	}

	function setupTexts()
	{
		scoreText = new FlxText(10, 69, FlxG.width, "");
		scoreText.setFormat("Sonic CD Menu Font Regular", 18, FlxColor.WHITE, CENTER);
		add(scoreText);
		
		charText = new FlxText(7, 0, FlxG.width, "???");
		charText.setFormat("Sonic CD Menu Font Regular", 36, FlxColor.WHITE, CENTER);
		add(charText);
		
		refreshSongList();
	}
	
	function refreshSongList()
	{
		textGroup.clear();
		
		var songs = CharSongList.getSongsByChar(characters[curCharSelected]);
		var startY = FlxG.height / 2 - (30 * songs.length) / 2;
		
		for (i in 0...songs.length) {
			var isUnlocked = isSongUnlocked(songs[i]);
			var songName = isUnlocked ? songs[i].replace("-", " ") : "???";
			var textColor = isUnlocked ? FlxColor.WHITE : FlxColor.GRAY;
				
			var text = new FlxText(350, startY + (i * 30), FlxG.width, songName);
			text.setFormat("Sonic CD Menu Font Regular", 34, textColor, CENTER);
			text.ID = i;
			textGroup.add(text);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// for bg infinity scrolling anim
		scrollingBg.y -= SCROLL_SPEED;
		bg.x -= SCROLL_SPEED / 2;
		
		if (canControl) handleInput(elapsed);
	}
	
	function handleInput(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
        var downP = controls.UI_DOWN_P;
        var up = controls.UI_UP;
        var down = controls.UI_DOWN;
		var back = controls.BACK;
        var accepted = controls.ACCEPT;

		if (upP) changeSelection(-1);
		if (downP) changeSelection(1);
		
		if (back) {
			saveSelectionState();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (isSelectingSong) exitSongSelection();
			else MusicBeatState.switchState(new MainMenuState());
		}
		
		if (accepted) {
			if (isSelectingSong) selectSong();
			else enterSongSelection();
		}

		if (!isSelectingSong && (up || down))
        {
            holdTime += elapsed;
            
            if (holdTime > holdDelay)
            {
                var change:Int = 0;
                if (up) change = -1;
                if (down) change = 1;
                
                if (holdTime > holdDelay + holdInterval)
                {
                    changeSelection(change);
                    holdTime = holdDelay;
                }
            }
        }
        else
        {
            holdTime = 0;
        }
	}
	
	function changeSelection(change:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		if (isSelectingSong) {
			curSongSelected = (curSongSelected + change + 
				CharSongList.getSongsByChar(characters[curCharSelected]).length) % 
				CharSongList.getSongsByChar(characters[curCharSelected]).length;
			highlightSelectedSong();
		} else {
			canControl = false;
			var prevSelected = curCharSelected;
			
			curCharSelected = FlxMath.wrap(curCharSelected + change, 0, characters.length - 1);
			
			var distance = change;
			
			if ((prevSelected == 0 && change < 0) || 
				(prevSelected == characters.length - 1 && change > 0)) {
				distance = change > 0 ? -characters.length + 1 : characters.length - 1;
			}
			
			FlxTween.tween(boxGroup, {
				y: -curCharSelected * BOX_HEIGHT
			}, TRANSITION_DURATION, {
				ease: FlxEase.expoOut,
				onComplete: function(_) {
					canControl = true;
				}
			});

			updateSelection();
		}

		saveSelectionState();
	}
	
	function updateSelection()
	{
		// update character info (on above)
		charText.text = unlockedChars.contains(characters[curCharSelected]) ? 
			characters[curCharSelected] : "???";
		
		// cocks appearing code
		boxGroup.forEach(sprite -> {
			final isSelected = sprite.ID == curCharSelected;
			FlxTween.tween(sprite, {alpha: isSelected ? 1 : 0.5}, TRANSITION_DURATION);
			FlxTween.tween(sprite.scale, {x: isSelected ? BOX_SCALE_SELECTED : BOX_SCALE_UNSELECTED}, 
				TRANSITION_DURATION, {ease: FlxEase.expoOut});
		});
		
		refreshSongList();
	}

	function saveSelectionState()
	{
		lastCharSelected = curCharSelected;
		lastSongSelected = curSongSelected;
		wasSelectingSong = isSelectingSong;
	}
	
	function enterSongSelection()
	{
		isSelectingSong = true;
		saveSelectionState();
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		highlightSelectedSong();
	}
	
	function exitSongSelection()
	{
		isSelectingSong = false;
		saveSelectionState();
		scoreText.text = "";
		textGroup.forEach(text -> {
			FlxTween.cancelTweensOf(text);
			text.alpha = 1;
		});
	}
	
	function highlightSelectedSong()
	{
		textGroup.forEach(text -> {
			FlxTween.cancelTweensOf(text);
			
			if (text.ID == curSongSelected) {
				var songs = CharSongList.getSongsByChar(characters[curCharSelected]);
				var songId = songs[text.ID];
				
				if (isSongUnlocked(songId)) {
					FlxTween.tween(text, {alpha: 0.5}, 0.5, {type: PINGPONG});
					scoreText.text = "Score: " + Highscore.getScore(songId, 2);
				} else {
					text.alpha = 1;
					scoreText.text = "Locked";
				}
			} else {
				text.alpha = 1;
			}
		});
	}
	
	function selectSong()
	{
		var songs = CharSongList.getSongsByChar(characters[curCharSelected]);
		var songId = songs[curSongSelected];
		
		if (!isSongUnlocked(songId)) {
			canControl = false;
			FlxG.sound.play(Paths.sound('deniedMOMENT'), 1, false, () -> canControl = true);
			return;
		}

		saveSelectionState();
		
		canControl = false;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		final song = CharSongList.getSongsByChar(characters[curCharSelected])[curSongSelected].toLowerCase();
		PlayState.SONG = Song.loadFromJson(song, song);
		
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		
		// custom transitions ass vars
		switch (song) {
			case 'sunshine': CustomShapeTransition.shape = "oval";
			case 'cycles': CustomShapeTransition.shape = "X";
			default:
				FlxTween.tween(fadeSprite, {alpha: 1}, 0.4);
				new FlxTimer().start(0.8, _ -> LoadingState.loadAndSwitchState(new PlayState()));
				return;
		}
		
		LoadingState.loadAndSwitchState(new PlayState());
	}
}