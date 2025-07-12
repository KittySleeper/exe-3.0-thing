package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.FixedScaleAdjustSizeScaleMode;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.app.Application;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import StageData;
import FunkinLua;
import Conductor.Rating;

import stages.objects.Floor;

import shaders.*;
import shaders.WiggleEffect.WiggleEffectType;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideo as MP4Handler;
import hxvlc.flixel.FlxVideoSprite as MP4Sprite;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	var noteRows:Array<Array<Array<Note>>> = [[],[],[]];

	var targetHP:Float = 1;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great!', 0.9], //From 80% to 89%
		['Sick!!', 1], //From 90% to 99%
		['Perfect!!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isEncoreMode:Bool = false;
	public static var isSoundTest:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var superZoomShit:Bool = false;
	public var supersuperZoomShit:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	var iconOffset:Int = 26;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camIDK:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var curStepText:FlxText;
	var curBeatText:FlxText;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	// for the credits at beginning of song lol!
	var creditsText:FlxTypedGroup<FlxText>;
	var creditoText:FlxText;
	var box:FlxSprite;

	// - dialogs shit
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;

	// - healthbar based things for mechanic use (like my horizon lol)
	var healthMultiplier:Float = 1; // fnf
	var healthDrop:Float = 0;
	var dropTime:Float = 0;

	// - song start intro bullshit
	var blackFuck:FlxSprite;
	var whiteFuck:FlxSprite;
	var startCircle:FlxSprite;
	var startText:FlxSprite;

	//fuckles moment
	public var fucklesMode:Bool = false; 
	public var fucklesDrain:Float = 0;

	//for fof mechanics
	public var fearNo:Float = 0;

	// variables for stuff (strumline spins, zoom bools, etc...) shit
	public static var isFixedAspectRatio:Bool = false;
	var originalWidth:Int = 1280;
	var originalHeight:Int = 720;
	var originalScaleMode:BaseScaleMode;
	var wasFullscreen:Bool;

	var bfIsLeft:Bool = false;
	// - dodge mechanic bullshit
	var canDodge:Bool = false;
	var dodging:Bool = false;
	// - jumpscare things
	var balling:FlxSprite = new FlxSprite(0, 0);
	// - flying shit
	var flyState:String = '';
	var flightChar:Character;
	var flightCameraOffset:FlxPoint = FlxPoint.get(0, 0);
	var flightTween:FlxTween;
	var flightState:String = '';
	var flightGroup:FlxSpriteGroup;
	var forceCameraToFlight:Bool = false;
	var floaty:Float = 0;
	var floaty2:Float = 0;
	// - ring counter bullshit
	var ringCounter:FlxSprite;
	var counterNum:FlxText;
	var cNum:Int = 0;
	// needlemouse shit
	var conkCreet:BGSprite;
	var needleBuildings:BGSprite;
	var needleMoutains:BGSprite;
	var needleSky:BGSprite;
	var needleRuins:BGSprite;
	var needleFg:FlxSprite;
	// keeps it all nice n fair n shit
	// fleetways shit
	var wall:FlxSprite;
	var porker:FlxSprite;
	var thechamber:FlxSprite;
	var floor:FlxSprite;
	var fleetwaybgshit:FlxSprite;
	var emeraldbeam:FlxSprite;
	var emeraldbeamyellow:FlxSprite;
	var pebles:FlxSprite;
	var warning:FlxSprite;
	var dodgething:FlxSprite;
	// Preload vars so no null obj ref
	var daNoteStatic:FlxSprite;
	var preloaded:Bool = false;

	public var drainMisses:Float = 0; // EEE OOO EH OO EE AAAAAAAAA

	public static var isFear:Bool = false;

	// x-terion shit
	var xterionFloor:Floor;
	var xterionSky:BGSprite;
	// slash shit slhop slhop slhop slhop (mariostarterbrothers)
	var slashBg:BGSprite;
	var slashFloor:BGSprite;
	var slashAssCracks:FlxSprite;
	var slashLava:FlxSprite;
	// - fov shit
	var slashBgPov:BGSprite;
	var slashFloorPov:BGSprite;
	var slashLavaPov:FlxSprite;
	// curse shit lololololol
	var curseStatic:FlxSprite;
	var hexTimer:Float = 0;
	var hexes:Float = 0;
	var fucklesSetHealth:Float = 0;
	var barbedWires:FlxTypedGroup<WireSprite>;
	var wireVignette:FlxSprite;
	// hjog shit dlskafj;lsa
	var hogBg:BGSprite;
	var hogMotain:BGSprite;
	var hogWaterFalls:FlxSprite;
	var hogFloor:FlxSprite;
	var hogLoops:FlxSprite;
	var hogTrees:BGSprite;
	var hogRocks:BGSprite;
	var hogOverlay:BGSprite;
	// satanos stage shit
	var satBackground:BGSprite;
	var satFloor:BGSprite;
	var satFgPlant:FlxSprite;
	var satFgTree:FlxSprite;
	var satFgFlower:FlxSprite;
	var satBgTree:BGSprite;
	var satBgFlower:BGSprite;
	var satBgPlant:BGSprite;

	public var ringsNumbers:Array<SonicNumber> = [];
	public var minNumber:SonicNumber;
	public var sonicHUD:FlxSpriteGroup;
	public var scoreNumbers:Array<SonicNumber> = [];
	public var missNumbers:Array<SonicNumber> = [];
	public var secondNumberA:SonicNumber;
	public var secondNumberB:SonicNumber;
	public var millisecondNumberA:SonicNumber;
	public var millisecondNumberB:SonicNumber;

	var hudStyle:String = 'sonic2';

	public var sonicHUDStyles:Map<String, String> = [
		"fatality" => "sonic3",
		"prey" => "soniccd",
		"you-cant-run" => "sonic1",
		"our-horizon" => "chaotix",
		"my-horizon" => "chaotix",
		"b4cksl4sh" => "sonic1"
		// defaults to sonic2 if its in sonicHUDSongs but not in here
	];

	// Nah they ain't fr using 2 games :skull:
	var noteLink:Bool = true;
	var file15Ready:Bool;
	var file25Ready:Bool;
	var fileHealth:Float;
	var fileTime:Float;

	//for pausing when substate is open
	var creditsAppearTimer:FlxTimer;

	//lazy to import this shit
	var startTween1:flixel.tweens.misc.VarTween;
	var startTween2:flixel.tweens.misc.VarTween;
	var startTween3:flixel.tweens.misc.VarTween;
	var creditTween1:FlxTween;
	var creditTween2:FlxTween;
	var creditTween3:FlxTween;
	var creditTween4:FlxTween;

	var startTimer1:FlxTimer;
	var startTimer2:FlxTimer;
	var creditTimer1:FlxTimer;
	var creditTimer2:FlxTimer;
	var creditPauseTime:Float = 0;

	// i have no idea what this is for -Niall
	// nebs modchart shit
	var curShader:ShaderFilter;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		originalWidth = FlxG.width;
    	originalHeight = FlxG.height;
    	originalScaleMode = FlxG.scaleMode;
		wasFullscreen = FlxG.fullscreen;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camIDK = new FlxCamera();
		camOther = new FlxCamera();
		
		camHUD.bgColor.alpha = 0;
		camIDK.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camIDK, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		CustomShapeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = '';

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			var diff = StoryMenuState.curDifficulty.replace("-", "");
			detailsText = "Story Mode: " + "Sonic.EXE Week";
			storyDifficultyText = " (" + diff.charAt(0).toUpperCase() + diff.substr(1) + ")";
		}
		else if (isEncoreMode)
		{
			detailsText = "Encore Mode: ";
		}
		else if (isSoundTest)
		{
			detailsText = "Sound Test";
		}
		else
		{
			detailsText = "Freeplay";
		}

		topBar = new FlxSprite(0, -170).makeGraphic(1280, 170, FlxColor.BLACK);
		topBar.cameras = [camIDK];
		
		bottomBar = new FlxSprite(0, 720).makeGraphic(1280, 170, FlxColor.BLACK);
		bottomBar.cameras = [camIDK];

		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		blackFuck.cameras = [camIDK];

		startCircle = new FlxSprite();
		startCircle.cameras = [camIDK];

		startText = new FlxSprite();
		startText.cameras = [camIDK];

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('dadStage/stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('dadStage/stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('dadStage/stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('dadStage/stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('dadStage/stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'angel-island': new stages.AngelIslandStage(); //too slow

			default:

		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camIDK];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{

		}

		switch (SONG.song.toLowerCase())
		{
			case 'fatality' | "milk" | "b4cksl4sh" | "burning" | "sunshine":
				isFixedAspectRatio = true;
			default:
				isFixedAspectRatio = false;
		}

		if (isFixedAspectRatio)
		{
			var screen = Lib.application.window.display;
			var screenWidth = screen.bounds.width;
			var screenHeight = screen.bounds.height;

			Lib.application.window.resizable = false;
			FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode();
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
			Lib.application.window.resize(960, 720);
			var winX = Std.int((screenWidth - 960) / 2);
			var winY = Std.int((screenHeight - 720) / 2);
			Lib.application.window.move(winX, winY);
			FlxG.fullscreen = false;
		}

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 200; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		var bgSize:Float = 1;
		var bgSkin:String = 'healthBar';
		if (curStage == 'fatal-launch-base')
		{
			bgSkin = "fatalHealth";
			bgSize = 1.5;
		}

		healthBarBG = new AttachedSprite(bgSkin);
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.setGraphicSize(Std.int(healthBarBG.width * bgSize));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		// healthBar
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'targetHP', 0, 2);
		healthBar.scrollFactor.set();
		
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		if (SONG.song.toLowerCase() == 'chaos')
		{
			dodgething = new FlxSprite(0, 600);
			dodgething.frames = Paths.getSparrowAtlas('spacebar_icon', 'exe');
			dodgething.animation.addByPrefix('a', 'spacebar', 24, false, true);
			dodgething.scale.set(.5, .5);
			dodgething.screenCenter();
			dodgething.x -= 60;
			dodgething.visible = false;
			add(dodgething);
		}

		if (sonicHUDStyles.exists(Paths.formatToSongPath(curSong))) {
			sonicHUD = new FlxSpriteGroup();
			hudStyle = sonicHUDStyles.get(Paths.formatToSongPath(curSong));
			
			var hudFolder = hudStyle;
			if (hudStyle == 'soniccd')
				hudFolder = 'sonic1';
			var scoreLabel:FlxSprite = new FlxSprite(15, 25).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/score"));
			scoreLabel.setGraphicSize(Std.int(scoreLabel.width * 3));
			scoreLabel.updateHitbox();
			scoreLabel.x = 15;
			scoreLabel.antialiasing = false;
			scoreLabel.scrollFactor.set();
			sonicHUD.add(scoreLabel);

			var timeLabel:FlxSprite = new FlxSprite(15, 70).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/time"));
			timeLabel.setGraphicSize(Std.int(timeLabel.width * 3));
			timeLabel.updateHitbox();
			timeLabel.x = 15;
			timeLabel.antialiasing = false;
			timeLabel.scrollFactor.set();
			sonicHUD.add(timeLabel);

			var ringsLabel:FlxSprite = new FlxSprite(15, 115).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/rings"));
			ringsLabel.setGraphicSize(Std.int(ringsLabel.width * 3));
			ringsLabel.updateHitbox();
			ringsLabel.x = 15;
			ringsLabel.antialiasing = false;
			ringsLabel.scrollFactor.set();
			/*if (SONG.isRing)
				sonicHUD.add(ringsLabel);*/

			var missLabel:FlxSprite = new FlxSprite(15, 160).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/misses"));
			missLabel.setGraphicSize(Std.int(missLabel.width * 3));
			//if (!SONG.isRing)
				missLabel.y = ringsLabel.y;
			missLabel.updateHitbox();
			missLabel.x = 15;
			missLabel.antialiasing = false;
			missLabel.scrollFactor.set();
			sonicHUD.add(missLabel);

			// score numbers
			if (hudFolder == 'sonic3')
			{
				for (i in 0...7)
				{
					var number = new SonicNumber(0, 0, 0);
					number.folder = hudFolder;
					number.setGraphicSize(Std.int(number.width * 3));
					number.updateHitbox();
					number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
					number.y = scoreLabel.y;
					scoreNumbers.push(number);
					sonicHUD.add(number);
				}
			}
			else
			{
				for (i in 0...7)
				{
					var number = new SonicNumber(0, 0, 0);
					number.folder = hudFolder;
					number.setGraphicSize(Std.int(number.width * 3));
					number.updateHitbox();
					number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
					number.y = scoreLabel.y;
					scoreNumbers.push(number);
					sonicHUD.add(number);
				}
			}

			// ring numbers
			for (i in 0...3)
			{
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width * 3));
				number.updateHitbox();
				number.x = ringsLabel.x + ringsLabel.width + (6 * 3) + ((9 * i) * 3);
				number.y = ringsLabel.y;
				ringsNumbers.push(number);
				/*if (SONG.isRing)
					sonicHUD.add(number);*/
			}

			// miss numbers
			for (i in 0...4)
			{
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width * 3));
				number.updateHitbox();
				number.x = missLabel.x + missLabel.width + (6 * 3) + ((9 * i) * 3);
				number.y = missLabel.y;
				missNumbers.push(number);
				sonicHUD.add(number);
			}

			// time numbers
			minNumber = new SonicNumber(0, 0, 0);
			minNumber.folder = hudFolder;
			minNumber.setGraphicSize(Std.int(minNumber.width * 3));
			minNumber.updateHitbox();
			minNumber.x = timeLabel.x + timeLabel.width;
			minNumber.y = timeLabel.y;
			sonicHUD.add(minNumber);

			// time colons
			var timeColon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/colon"));
			timeColon.setGraphicSize(Std.int(timeColon.width * 3));
			timeColon.updateHitbox();
			timeColon.x = 170;
			timeColon.y = timeLabel.y;
			timeColon.antialiasing = false;
			timeColon.scrollFactor.set();
			sonicHUD.add(timeColon);

			secondNumberA = new SonicNumber(0, 0, 0);
			secondNumberA.folder = hudFolder;
			secondNumberA.setGraphicSize(Std.int(secondNumberA.width * 3));
			secondNumberA.updateHitbox();
			secondNumberA.x = 186;
			secondNumberA.y = timeLabel.y;
			sonicHUD.add(secondNumberA);

			secondNumberB = new SonicNumber(0, 0, 0);
			secondNumberB.folder = hudFolder;
			secondNumberB.setGraphicSize(Std.int(secondNumberB.width * 3));
			secondNumberB.updateHitbox();
			secondNumberB.x = 213;
			secondNumberB.y = timeLabel.y;
			sonicHUD.add(secondNumberB);

			var timeQuote:FlxSprite = new FlxSprite(0, 0);
			if (hudFolder == 'chaotix')
			{
				timeQuote.loadGraphic(Paths.image("sonicUI/" + hudFolder + "/quote"));
				timeQuote.setGraphicSize(Std.int(timeQuote.width * 3));
				timeQuote.updateHitbox();
				timeQuote.x = secondNumberB.x + secondNumberB.width;
				timeQuote.y = timeLabel.y;
				timeQuote.antialiasing = false;
				timeQuote.scrollFactor.set();
				sonicHUD.add(timeQuote);

				millisecondNumberA = new SonicNumber(0, 0, 0);
				millisecondNumberA.folder = hudFolder;
				millisecondNumberA.setGraphicSize(Std.int(millisecondNumberA.width * 3));
				millisecondNumberA.updateHitbox();
				millisecondNumberA.x = timeQuote.x + timeQuote.width + (2 * 3);
				millisecondNumberA.y = timeLabel.y;
				sonicHUD.add(millisecondNumberA);

				millisecondNumberB = new SonicNumber(0, 0, 0);
				millisecondNumberB.folder = hudFolder;
				millisecondNumberB.setGraphicSize(Std.int(millisecondNumberB.width * 3));
				millisecondNumberB.updateHitbox();
				millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
				millisecondNumberB.y = timeLabel.y;
				sonicHUD.add(millisecondNumberB);
			}

			switch (hudFolder)
			{
				case 'chaotix':
					minNumber.x = timeLabel.x + timeLabel.width + (4 * 3);
					timeColon.x = minNumber.x + minNumber.width + (2 * 3);
					secondNumberA.x = timeColon.x + timeColon.width + (4 * 3);
					secondNumberB.x = secondNumberA.x + secondNumberA.width + 3;
					timeQuote.x = secondNumberB.x + secondNumberB.width;
					millisecondNumberA.x = timeQuote.x + timeQuote.width + (2 * 3);
					millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
				default:
			}
			
			add(sonicHUD);

			if (!ClientPrefs.downScroll)
			{
				for (member in sonicHUD.members)
					member.y = FlxG.height - member.height - member.y;
			}

			sonicHUD.cameras = [camHUD];

			 switch (SONG.song.toLowerCase())
			{
				case "you-can't-run" | "you-can't-run-encore":
			        sonicHUD.visible = false;
		    }
		}

		if (sonicHUD != null && sonicHUD.visible)
		{
			healthBar.x += 150;
			iconP1.x += 150;
			iconP2.x += 150;
			healthBarBG.x += 150;
			remove(scoreTxt);
			remove(timeBarBG);
			remove(timeTxt);
			remove(timeBar);
		}

		updateSonicScore();
		updateSonicMisses();

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		barbedWires = new FlxTypedGroup<WireSprite>();
		for (shit in 0...6)
		{
			var wow = shit + 1;
			var wire:WireSprite = new WireSprite().loadGraphic(Paths.image('barbedWire/' + wow));
			wire.scrollFactor.set();
			wire.antialiasing = ClientPrefs.globalAntialiasing;
			wire.setGraphicSize(FlxG.width, FlxG.height);
			wire.updateHitbox();
			wire.screenCenter(XY);
			wire.alpha = 0;
			wire.extraInfo.set("inUse", false);
			wire.cameras = [camIDK];
			barbedWires.add(wire);
		}

		wireVignette = new FlxSprite().loadGraphic(Paths.image('black_vignette', 'exe'));
		wireVignette.scrollFactor.set();
		wireVignette.antialiasing = ClientPrefs.globalAntialiasing;
		wireVignette.setGraphicSize(FlxG.width, FlxG.height);
		wireVignette.updateHitbox();
		wireVignette.screenCenter(XY);
		wireVignette.alpha = 0;
		wireVignette.cameras = [camIDK];

		add(barbedWires);
		add(wireVignette);

		songStartCardAppear();

		startCallback();
		RecalculateRating();

		// Add curStep and curBeat display
		if (chartingMode) {
			var curStepText = new FlxText(20, 20, 200, "curStep: " + curStep, 20);
			curStepText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			curStepText.antialiasing = ClientPrefs.globalAntialiasing;
			curStepText.cameras = [camOther];
			curStepText.borderSize = 1.25;
			add(curStepText);

			var curBeatText = new FlxText(20, 50, 200, "curBeat: " + curBeat, 20);
			curBeatText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			curBeatText.antialiasing = ClientPrefs.globalAntialiasing;
			curBeatText.cameras = [camOther];
			curBeatText.borderSize = 1.25;
			add(curBeatText);

			if (!ClientPrefs.downScroll) {
				curStepText.y += 500;
				curBeatText.y += 500;
			}

			// Update this texts in update()
			this.curStepText = curStepText;
			this.curBeatText = curBeatText;
		}

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		CoolUtil.precacheMusic("breakfast");

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);
		stagesFunc(function(stage:BaseStage) stage.createPost());

		if (isFixedAspectRatio)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (!ClientPrefs.middleScroll) spr.x -= 82;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x -= 72;
			});
		}

		FlxG.sound.music.onComplete = function() {
			FlxG.sound.music.stop();
			FlxG.sound.music.volume = 0;
		};

		preloaded = false;
		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			if (!preloaded) {
				precacheList.set("hitStatic1", "sound");

				daNoteStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("hitStatic", 'exe'));
				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic');
				daNoteStatic.animation.addByPrefix('static', "staticANIMATION", 24, false);
				daNoteStatic.cameras = [camHUD];
				daNoteStatic.visible = false;
				add(daNoteStatic);
				preloaded = true;
			}
		});

		super.create();

		//cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sparrow': 
					Paths.getSparrowAtlas(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'video': 
					Paths.video(key);
			}
		}
		Paths.clearUnusedMemory();

		switch (SONG.song.toLowerCase())
		{
			case 'sunshine':
				CustomShapeTransition.shape = "oval";
			case 'cycles':
				CustomShapeTransition.shape = "X";
			default:
				CustomShapeTransition.shape = "head";
		}

		CustomShapeTransition.nextCamera = camOther;
	}

	private function songStartCardAppear()
	{
		var daSong:String = Paths.formatToSongPath(curSong);

		if (daSong == 'fatality' || daSong == 'sunshine') return;

		switch (daSong)
		{
			case 'forestall-desire':
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 645;
					});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 645;
				});
				trace("mhm");
				startCountdown();
			case 'personel':
				camGame.alpha = 0;
				startCountdown();
			case 'soulless':
				camGame.alpha = 0;
				camHUD.alpha = 0;
				startCountdown();
			case 'milk':
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/Sunky', 'exe'));
				startCircle.scale.x = 0;
				startCircle.screenCenter();
				startCircle.antialiasing = ClientPrefs.globalAntialiasing;
				add(startCircle);
				startTimer1 = new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle.scale, {x: 1}, 0.2, {ease: FlxEase.elasticOut});
					FlxG.sound.play(Paths.sound('flatBONK', 'exe'));
				});

				startTimer2 = new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					startTween1 = FlxTween.tween(blackFuck, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(blackFuck);
							blackFuck.destroy();
						}
					});
					startTween2 = FlxTween.tween(startCircle, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(startCircle);
							startCircle.destroy();
						}
					});
				});

			case 'my-horizon', 'our-horizon':
				var delay:Float = 1;
				var fadeOutTime:Float = 2;
				var startDelay:Float = 0.3;

				add(blackFuck);

				startCircle.loadGraphic(Paths.image('StartScreens/' + daSong + '_title_card', 'exe'));
    			startCircle.frames = Paths.getSparrowAtlas('StartScreens/' + daSong + '_title_card', 'exe');
        		startCircle.animation.addByPrefix('idle', daSong + '_title', 24, false);
				startCircle.alpha = 0;
				startCircle.antialiasing = false;
				add(startCircle);

				startTimer1 = new FlxTimer().start(delay, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
				});

				startTimer2 = new FlxTimer().start(2.2, function(tmr:FlxTimer)
				{
					startTween1 = FlxTween.tween(blackFuck, {alpha: 0}, fadeOutTime, {
						onComplete: function(twn:FlxTween)
						{
							remove(blackFuck);
							blackFuck.destroy();
							startCircle.animation.play('idle');
						}
					});
					startTween2 = FlxTween.tween(startCircle, {alpha: 1}, 4.25, {
						onComplete: function(twn:FlxTween)
						{
							remove(startCircle);
							startCircle.destroy();
						}
					});
				});

				new FlxTimer().start(startDelay, function(tmr:FlxTimer)
				{
					startCountdown();
				});

			case 'chaos':
				cinematicBars(true);
				FlxG.camera.zoom = defaultCamZoom;
				camHUD.visible = false;
				dad.visible = false;
				boyfriend.visible = false;
				dad.setPosition(600, 400);
				snapCamFollowToPos(900, 700);
				// camFollowPos.setPosition(900, 700);
				FlxG.camera.focusOn(camFollowPos.getPosition());
				new FlxTimer().start(0.5, function(lol:FlxTimer)
				{
					if (true) // unclocked fleetway
					{
						new FlxTimer().start(1, function(lol:FlxTimer)
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.5}, 3, {ease: FlxEase.cubeOut});
							FlxG.sound.play(Paths.sound('robot', 'exe'));
							FlxG.camera.flash(FlxColor.RED, 0.2);
						});
						new FlxTimer().start(2, function(lol:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('sonic', 'exe'));
							thechamber.animation.play('a');
						});

						new FlxTimer().start(6, function(lol:FlxTimer)
						{
							startCountdown();
							FlxG.sound.play(Paths.sound('beam', 'exe'));
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
							FlxG.camera.shake(0.02, 0.2);
							FlxG.camera.flash(FlxColor.WHITE, 0.2);
							floor.animation.play('b');
							fleetwaybgshit.animation.play('b');
							pebles.animation.play('b');
							emeraldbeamyellow.visible = true;
							emeraldbeam.visible = false;
						});
					}
					else
						lol.reset();
				});

			default:
				startCountdown();

				add(blackFuck);

				startCircle.loadGraphic(Paths.image('StartScreens/Circle-'+ daSong, 'exe'));
				startCircle.antialiasing = ClientPrefs.globalAntialiasing;
				startCircle.x += 900;
				add(startCircle);

				startText.loadGraphic(Paths.image('StartScreens/Text-' + daSong, 'exe'));
				startText.antialiasing = ClientPrefs.globalAntialiasing;
				startText.x -= 1200;
				add(startText);

				startTimer1 = new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: !isFixedAspectRatio ? 0 : -80}, 0.5);
					FlxTween.tween(startText, {x: !isFixedAspectRatio ? 0 : -100}, 0.5);
				});

				startTimer2 = new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					startTween1 = FlxTween.tween(blackFuck, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(blackFuck);
							blackFuck.destroy();
						}
					});
					startTween2 = FlxTween.tween(startCircle, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(startCircle);
							startCircle.destroy();
						}
					});
					startTween3 = FlxTween.tween(startText, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							remove(startText);
							startText.destroy();
						}
					});
				});
		}
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			if(opponentVocals != null) opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.smoothing = true;
		#if mobile
		video.onFormatSetup.add(function():Void
		{
			if (video != null)
			{
				FlxG.scaleMode = new MobileScaleMode();
			}
		});
		#end
		video.load(filepath);
		video.play();
		video.onEndReached.add(() -> {
			video.dispose();
			startAndEnd();
			return;
		});
		FlxG.addChildBelowMouse(video);
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	public function chromaVideo(name:String) {
		#if VIDEOS_ALLOWED
		var preloadKey:String = name;
		if(!precacheList.exists(preloadKey)) {
			precacheList.set(preloadKey, 'video');
			Paths.video(name);
		}

		var filepath:String = Paths.video(name);
		#if sys
		var exists:Bool = FileSystem.exists(filepath);
		#else
		var exists:Bool = OpenFlAssets.exists(filepath);
		#end

		if(!exists) {
			trace('Couldnt find video file: ' + name);
			return;
		}

		var video:MP4Sprite = new MP4Sprite();
		video.scrollFactor.set();
		video.cameras = [camIDK];
		video.antialiasing = ClientPrefs.globalAntialiasing;
		video.shader = new GreenScreenShader();
		
		video.bitmap.onEndReached.add(() -> {
			remove(video);
			video.destroy();
		}, true);
		
		add(video);
		if(video.load(filepath)) {
			video.play();
		} else {
			remove(video);
			video.destroy();
			trace('Failed to load video: ' + name);
		}
		#else
		trace('Video playback not supported on this platform');
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return false;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			if (curStage == 'starved') {
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!ClientPrefs.middleScroll) spr.x -= 322;
					spr.y -= 35;
					spr.alpha = 0.65;
				});

				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 10000;
				});

				healthBar.angle += 90;
				healthBar.screenCenter();
				healthBar.x += 500;

				iconP1.x += 1050;
				iconP2.x += 1050;

				healthBarBG.angle += 90;
				healthBarBG.x += 500;

				timeBar.y = scoreTxt.y - 40;
				timeBarBG.y = scoreTxt.y - 40;
				timeTxt.y = scoreTxt.y - 52;

				healthBar.alpha = 0.75;
				healthBarBG.alpha = 0.75;
				scoreTxt.alpha = 0.75;
			}

			startedCountdown = true;

			var timerInterval = Conductor.crochet / 1000 / playbackRate;
			var countdownTicks = 5;
			switch(Paths.formatToSongPath(curSong)) 
			{
				case 'sunshine':
					timerInterval *= 2; //increase this multiplier to slow down more
					countdownTicks = 8; //increase ticks to match slower countdown
			}
			Conductor.songPosition = -Conductor.crochet * countdownTicks;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}

			startTimer = new FlxTimer().start(timerInterval, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (Paths.formatToSongPath(curSong))
				{
					case 'sunshine':
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'exe'));
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'exe'));
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'exe'));

						ready.scale.x = 0.5; // i despise all coding.
						set.scale.x = 0.5;
						go.scale.x = 0.7;
						ready.scale.y = 0.5;
						set.scale.y = 0.5;
						go.scale.y = 0.7;
						ready.screenCenter();
						set.screenCenter();
						go.screenCenter();
						ready.cameras = [camIDK];
						set.cameras = [camIDK];
						go.cameras = [camIDK];

						switch (swagCounter)
						{
							case 0:
								insert(members.indexOf(notes), ready);
								FlxTween.tween(ready.scale, {x: .9, y: .9}, Conductor.crochet / 500, {
									onComplete: function(_) {
										remove(ready);
										ready.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('ready', 'exe'));
							case 1:
								insert(members.indexOf(notes), set);
								FlxTween.tween(set.scale, {x: .9, y: .9}, Conductor.crochet / 500, {
									onComplete: function(_) {
										remove(set);
										set.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('set', 'exe'));
							case 2:
								insert(members.indexOf(notes), go);
								FlxTween.tween(go.scale, {x: 1.1, y: 1.1}, Conductor.crochet / 500, {
									onComplete: function(_) {
										remove(go);
										go.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('go', 'exe'));
							case 3:
								canPause = true;
						}

					case "fatality":
						switch (swagCounter)
						{
							case 0:
								FlxG.sound.play(Paths.sound('Fatal_3', 'exe'));
								var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_3", "exe"));
								three.scrollFactor.set();
								three.setGraphicSize(Std.int(three.width * daPixelZoom));
								three.updateHitbox();
								three.screenCenter();

								insert(members.indexOf(notes), three);
								FlxTween.tween(three, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(three);
										three.destroy();
									}
								});
							case 1:
								FlxG.sound.play(Paths.sound('Fatal_2', 'exe'));
								var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_2", "exe"));
								ready.scrollFactor.set();
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
								ready.updateHitbox();

								ready.screenCenter();
								insert(members.indexOf(notes), ready);
								FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(ready);
										ready.destroy();
									}
								});
							case 2:
								FlxG.sound.play(Paths.sound('Fatal_1', 'exe'));
								var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_1", "exe"));
								set.scrollFactor.set();

								set.setGraphicSize(Std.int(set.width * daPixelZoom));

								set.screenCenter();
								insert(members.indexOf(notes), set);
								FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(set);
										set.destroy();
									}
								});
							case 3:
								FlxG.sound.play(Paths.sound('Fatal_go', 'exe'));
								var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_go", "exe"));
								go.scrollFactor.set();

								go.setGraphicSize(Std.int(go.width * daPixelZoom));

								go.updateHitbox();

								go.screenCenter();
								insert(members.indexOf(notes), go);
								FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(go);
										go.destroy();
									}
								});
							case 4:
						}
						
					default:
						switch (swagCounter) 
						{
							case 0:
								//FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
							case 1:
								/*countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
								countdownReady.cameras = [camHUD];
								countdownReady.scrollFactor.set();
								countdownReady.updateHitbox();

								if (PlayState.isPixelStage)
									countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								insert(members.indexOf(notes), countdownReady);
								FlxTween.tween(countdownReady, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});*/
								//FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
							case 2:
								/*countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownSet.cameras = [camHUD];
								countdownSet.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								insert(members.indexOf(notes), countdownSet);
								FlxTween.tween(countdownSet, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});*/
								//FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
							case 3:
								/*countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownGo.cameras = [camHUD];
								countdownGo.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								insert(members.indexOf(notes), countdownGo);
								FlxTween.tween(countdownGo, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});*/
								//FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
							case 4:
						}
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				stagesFunc(function(stage:BaseStage) stage.countdownTick(swagCounter));
				swagCounter += 1;
				// generateSong('fresh');
			}, countdownTicks);
		}
		return true;
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		switch (SONG.song.toLowerCase()) //ass code
		{
			case 'fight-or-flight':
				scoreTxt.text = 'Sacrifices: ' + songMisses 
					+ ' | Accuracy: ' + ratingName
					+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
			default:
				scoreTxt.text = 'Score: ' + songScore
					+ ' | Misses: ' + songMisses
					+ ' | Rating: ' + ratingName
					+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
		}

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
		}
		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		vocals.onComplete = function() {
			if (vocals != null) {
				vocals.stop();
				vocals.volume = 0;
			}
		};

		opponentVocals.onComplete = function() {
			if (opponentVocals != null) {
				opponentVocals.stop();
				opponentVocals.volume = 0;
			}
		};

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		creditsText = new FlxTypedGroup<FlxText>();
		// in here, specify your song name and then its credits, then go to the next switch
		switch (SONG.song.toLowerCase())
		{
			default:
				box = new FlxSprite(0, -1000).loadGraphic(Paths.image("box"));
				box.cameras = [camIDK];
				box.setGraphicSize(Std.int(box.height * 0.8));
				box.screenCenter(X);
				add(box);

				var texti:String;
				var size:String;

				if (FileSystem.exists(Paths.json(curSong.toLowerCase() + "/credits")))
				{
					texti = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("TIME")[0];
					size = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("SIZE")[1];
				}
				else
				{
					texti = "CREDITS\nunfinished";
					size = '28';
				}

				creditoText = new FlxText(0, -1000, 0, texti, 28);
				creditoText.cameras = [camIDK];
				creditoText.setFormat(Paths.font("PressStart2P.ttf"), Std.parseInt(size), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				creditoText.setGraphicSize(Std.int(creditoText.width * 0.8));
				creditoText.updateHitbox();
				creditoText.screenCenter(X);
				creditsText.add(creditoText);
		}
		add(creditsText);

		// this is the timing of the box coming in, specify your song and IF NEEDED, change the amount of time it takes to come in
		// if you want to add it to start at the beginning of the song, type " | ", then add your song name
		// poop fart ahahahahahah
		switch (SONG.song.toLowerCase())
		{
			default:
				var timei:String;

				if (FileSystem.exists(Paths.json(curSong.toLowerCase() + "/credits")))
				{
					timei = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("TIME")[1];
				}
				else
				{
					timei = "2.35";
				}

				FlxG.log.add('BTW THE TIME IS ' + Std.parseFloat(timei));

				creditsAppearTimer = new FlxTimer().start(Std.parseFloat(timei), function(tmr:FlxTimer)
				{
					tweenCredits();
				});
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	function tweenCredits()
	{
		creditTween1 = FlxTween.tween(creditoText, {y: FlxG.height - 625}, 0.5, {ease: FlxEase.circOut});
		creditTween2 = FlxTween.tween(box, {y: 0}, 0.5, {ease: FlxEase.circOut});
		
		creditTimer1 = new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			creditTween3 = FlxTween.tween(creditoText, {y: -1000}, 0.5, {ease: FlxEase.circOut});
			creditTween4 = FlxTween.tween(box, {y: -1000}, 0.5, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					remove(creditsText);
					remove(box);
				}
			});
		});
		
		creditTimer2 = new FlxTimer().start(3.5, function(tmr:FlxTimer)
		{
			remove(creditsText);
			remove(box);
		});
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try {
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch(e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var pixelStage = isPixelStage;
				if(SONG.song.toLowerCase() == "you-can't-run") {
					var pixelStart = Conductor.stepToSeconds(528);
					var pixelEnd = Conductor.stepToSeconds(783);
					pixelStage = (daStrumTime >= pixelStart && daStrumTime <= pixelEnd);
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.isPixelNote = pixelStage;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.row = Conductor.secsToRow(daStrumTime);
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				var idx = swagNote.gfNote?2:gottaHitNote?0:1;
				if (noteRows[idx][swagNote.row]==null)
					noteRows[idx][swagNote.row]=[];

				noteRows[idx][swagNote.row].push(swagNote);

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
				isPixelStage = pixelStage;
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			
			case 'sonicspook':
				CoolUtil.precacheSound('jumpscare', 'exe');
				CoolUtil.precacheSound('datOneSound', 'exe');
				
				var atlas:FlxAtlasFrames = Paths.getSparrowAtlas('sonicJUMPSCARE', 'exe');
				if(atlas != null) {
					var tempSprite = new FlxSprite();
					tempSprite.frames = atlas;
					tempSprite.animation.addByPrefix('preload', 'staticANIMATION', 24, false);
					
					tempSprite.draw();
					tempSprite.destroy();
				}

				precacheList.set('sonicJUMPSCARE', 'image');
            	precacheList.set('sonicJUMPSCARE', 'sparrow');

			case 'TooSlowFlashinShit':
				precacheList.set('sppok', 'sound');
				precacheList.set('staticBUZZ', 'sound');
				Paths.image("daSTAT", 'exe');
				Paths.image('simplejump', 'exe');

			case 'static':
				precacheList.set('staticBUZZ', 'sound');
				Paths.image("daSTAT", 'exe');

			 case 'Chroma Video':
				if(event.value1 != null && event.value1 != '') {
					var videoName:String = event.value1;
					
					precacheList.set(videoName, 'video');
					
					Paths.video(videoName);
				}

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('dadStage/spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('dadStage/smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('dadStage/smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);

		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState) {
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
    	if (paused) {
        	FlxG.sound.music?.pause();
        	vocals?.pause();
			opponentVocals?.pause();

        	FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
    	}

    	super.openSubState(SubState);
	}

	public var canResync:Bool = true;
	override function closeSubState()
	{
		stagesFunc(function(stage:BaseStage) stage.closeSubState());

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong && canResync)
			{
				resyncVocals();
			}

			if (curShader != null)
			{
				camGame.filters = [curShader];
				camHUD.filters = [curShader];
				camIDK.filters = [curShader];
			}
			else
			{
				camGame.filters = [];
				camHUD.filters = [];
				camIDK.filters = [];
			}

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;

			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused && SONG != null && iconP2 != null)
		{
			var songName:String = SONG.song != null ? SONG.song.replace("-", " ") : "";
			if (isStoryMode)
				DiscordClient.changePresence(detailsPausedText, songName + storyDifficultyText, iconP2.getCharacter());
			else
				DiscordClient.changePresence(detailsPausedText, songName, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.pitch = playbackRate;
		}
		vocals.play();
		opponentVocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		if (chartingMode) {
			if (curStepText != null) curStepText.text = "curStep: " + curStep;
			if (curBeatText != null) curBeatText.text = "curBeat: " + curBeat;
		}
		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			
		}

		wireVignette.alpha = FlxMath.lerp(wireVignette.alpha, hexes / 6, elapsed / (1 / 60) * 0.2);
		if (hexes > 0)
		{
			var hpCap = 1.6 - ((hexes - 1) * 0.3);
			if (hpCap < 0)
				hpCap = 0;
			var loss = 0.005 * (elapsed / (1 / 120));
			var newHP = health - loss;
			if (newHP < hpCap)
			{
				loss = health - hpCap;
				newHP = health - loss;
			}
			if (loss < 0)
				loss = 0;
			if (newHP > hpCap)
				health -= loss;
		}

		if (hexes > 0)
		{
			hexTimer += elapsed;
			if (hexTimer >= 5)
			{
				hexTimer = 0;
				hexes--;
				updateWires();
			}
		}

		// fuckles shit for his stuff
		if (fucklesMode)
		{
			fucklesDrain = 0.0005; // copied from exe 2.0 lol sorry
			if (drainMisses > 0)
				health -= (fucklesDrain * (elapsed / (1 / 120))) * drainMisses;
			else
				drainMisses = 0;
		}

		if(fucklesMode)
		{
			var newTarget:Float = FlxMath.lerp(targetHP, health, 0.1*(elapsed/(1/60)));
			if (Math.abs(newTarget - health)<.002)
				newTarget = health;

			targetHP = newTarget;

		} else
		    targetHP = health;

		// health -= heatlhDrop;
		if (dropTime > 0)
		{
			dropTime -= elapsed;
			health -= healthDrop * (elapsed / (1 / 120));
			if (iconP1.alpha == 1) iconP1.alpha = 0.75;
    		else iconP1.alpha = 1;
		}

		if (dropTime <= 0)
		{
			healthDrop = 0;
			dropTime = 0;
			iconP1.alpha = 1;
		}

		if (bfIsLeft)
			targetHP = 2 - health;

		if (flightChar != null && flightGroup != null && flightState != '') {
			switch(flightState) {
				case 'hover' | 'hovering':
					flightGroup.y += Math.sin(floaty) * 1.5;
				case 'fly' | 'flying':
					flightGroup.y += Math.sin(floaty) * 1.5;
					flightGroup.x += Math.cos(floaty) * 1.5;
				case 'sHover' | 'sHovering':
					flightGroup.y += Math.sin(floaty2) * 0.5;
			}
			
			floaty += 0.03;
			floaty2 += 0.01;
				
			if (forceCameraToFlight) {
				var isFlightCharSection = false;
				var extraX:Float = 0;
				var extraY:Float = 0;
				
				if (SONG.notes[curSection] != null) {
					if (SONG.notes[curSection].mustHitSection && flightChar == boyfriend) {
						isFlightCharSection = true;
						extraX = -100;
						extraY = -100;
					}
					else if (!SONG.notes[curSection].mustHitSection && flightChar == dad) {
						isFlightCharSection = true;
						extraX = 150;
						extraY = -100;
					}
					else if (SONG.notes[curSection].gfSection && flightChar == gf) {
						isFlightCharSection = true;
					}
				}
				
				if (isFlightCharSection) {
					camFollow.set(
						flightChar.getMidpoint().x + extraX,
						flightChar.getMidpoint().y + extraY
					);
					camFollow.x += flightChar.cameraPosition[0] + flightCameraOffset.x;
					camFollow.y += flightChar.cameraPosition[1] + flightCameraOffset.y;
				}
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		if(FlxG.keys.justPressed.M && !endingSong && !inCutscene) {
			openDebugMenu();
			FlxG.sound.play(Paths.sound("secretSound"));
        }

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		switch (curStage)
		{
			case 'starved':
				iconOffset = 270;

				iconP1.y = healthBar.y
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				+ (150 * iconP1.scale.x - 150) / 2
				- iconOffset;
					iconP2.y = healthBar.y
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (150 * iconP2.scale.x) / 2
				- iconOffset;
			default:
				iconP1.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				+ (150 * iconP1.scale.x - 150) / 2
				- iconOffset;
					iconP2.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (150 * iconP2.scale.x) / 2
				- iconOffset * 2;
		}

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			canResync = false;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if (SONG.song.toLowerCase() == 'endless' && curStep >= 898)
					{
						songPercent = 0;
						timeTxt.text = 'Infinity';
					}
					else if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					else
						timeTxt.text = SONG.song;

					var curMS:Float = Math.floor(curTime);
					var curSex:Int = Math.floor(curMS / 1000);
					if (curSex < 0)
						curSex = 0;

					var curMins = Math.floor(curSex / 60);
					curMS %= 1000;
					curSex %= 60;

					if (sonicHUD != null) {
						minNumber.number = curMins;

						var sepSex = Std.string(curSex).split("");
						if (curSex < 10)
						{
							secondNumberA.number = 0;
							secondNumberB.number = curSex;
						}
						else
						{
							secondNumberA.number = Std.parseInt(sepSex[0]);
							secondNumberB.number = Std.parseInt(sepSex[1]);
						}
						if (millisecondNumberA != null && millisecondNumberB != null)
						{
							curMS = Math.round(curMS / 10);
							if (curMS < 10)
							{
								millisecondNumberA.number = 0;
								millisecondNumberB.number = Math.floor(curMS);
							}
							else
							{
								var sepMSex = Std.string(curMS).split("");
								millisecondNumberA.number = Std.parseInt(sepMSex[0]);
								millisecondNumberB.number = Std.parseInt(sepMSex[1]);
							}
						}
					}
				}
			}
		}

		if (camZooming || superZoomShit || supersuperZoomShit)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			var focus:Character = boyfriend;
            if(SONG.notes[curSection] != null) {
				if (gf != null && SONG.notes[curSection].gfSection)
				{
					focus = gf;
				} else if (!SONG.notes[curSection].mustHitSection)
				{
					focus = dad;
				}
			}

			switch (focus.curCharacter)
			{
				case "scorched":
					FlxG.camera.zoom = FlxMath.lerp(0.5, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				case "starved":
					FlxG.camera.zoom = FlxMath.lerp(1.35, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				case "beast_chaotix":
					FlxG.camera.zoom = FlxMath.lerp(1.2, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				case "fatal-sonic", "fatal-glitched":
					FlxG.camera.zoom = FlxMath.lerp(0.4, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				default:
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}

			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		camIDK.zoom = camOther.zoom;
		camIDK.x = camOther.x;
		camIDK.y = camOther.y;

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strum:StrumNote = null;
					if (daNote.noteData >= 0 && daNote.noteData < strumGroup.length)
						strum = strumGroup.members[daNote.noteData];

					if (strum == null)
						return; // Skip this note if the strum is missing

					var strumX:Float = strum.x;
					var strumY:Float = strum.y;
					var strumAngle:Float = strum.angle;
					var strumDirection:Float = strum.direction;
					var strumAlpha:Float = strum.alpha;
					var strumScroll:Bool = strum.downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += (3 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom) * songSpeed;
								} else {
									daNote.y -= 18 + (songSpeed - 1);
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strum.sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openDebugMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		FlxG.sound.music?.pause();
		vocals?.pause();
		opponentVocals?.pause();

		var colorSwap:ColorSwap = new ColorSwap();
		colorSwap.hue = -1;
		colorSwap.brightness = -0.5;
		colorSwap.saturation = -1;

		if (curShader != null)
		{
			camGame.filters = [curShader, new ShaderFilter(colorSwap.shader)];
			camHUD.filters = [curShader, new ShaderFilter(colorSwap.shader)];
			camIDK.filters = [curShader, new ShaderFilter(colorSwap.shader)];
		}
		else
		{
			camGame.filters = [new ShaderFilter(colorSwap.shader)];
			camHUD.filters = [new ShaderFilter(colorSwap.shader)];
			camIDK.filters = [new ShaderFilter(colorSwap.shader)];
		}

		openSubState(new PracticeSubState());
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		FlxG.sound.music?.pause();
		vocals?.pause();
		opponentVocals?.pause();

		var colorSwap:ColorSwap = new ColorSwap();
		colorSwap.hue = -1;
		colorSwap.brightness = -0.5;
		colorSwap.saturation = -1;

		if (curShader != null)
		{
			camGame.filters = [curShader, new ShaderFilter(colorSwap.shader)];
			camHUD.filters = [curShader, new ShaderFilter(colorSwap.shader)];
			camIDK.filters = [curShader, new ShaderFilter(colorSwap.shader)];
		}
		else
		{
			camGame.filters = [new ShaderFilter(colorSwap.shader)];
			camHUD.filters = [new ShaderFilter(colorSwap.shader)];
			camIDK.filters = [new ShaderFilter(colorSwap.shader)];
		}

		PauseSubState.transCamera = camOther;
		openSubState(new PauseSubState());

		#if desktop
		if (isStoryMode)
			DiscordClient.changePresence(detailsPausedText, SONG.song.replace("-", " ") + storyDifficultyText, iconP2.getCharacter());
		else
			DiscordClient.changePresence(detailsPausedText, SONG.song.replace("-", " "), iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		canResync = false;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				if (SONG.song.toLowerCase() != 'fight-or-flight' || SONG.song.toLowerCase() != 'prey')
				{
					persistentDraw = true;
				}
				else
				{
					FlxG.camera.zoom = 1;
					persistentDraw = false;
				}

				canResync = false;

				vocals.stop();
				opponentVocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				openSubState(new GameOverSubstate());

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song.replace('-', ' ') + storyDifficultyText, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				var oldBoyfriend = boyfriend;
				var oldDad = dad;
				var oldGf = gf;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}

				if (flightChar != null) {
					if (flightChar == oldBoyfriend) {
						flightChar = boyfriend;
						flightGroup = boyfriendGroup;
					} else if (flightChar == oldDad) {
						flightChar = dad;
						flightGroup = dadGroup;
					} else if (flightChar == oldGf) {
						flightChar = gf;
						flightGroup = gfGroup;
					}
					
					if (flightChar == boyfriend)
						flightCameraOffset.set(boyfriendCameraOffset[0], boyfriendCameraOffset[1]);
					else if (flightChar == dad)
						flightCameraOffset.set(opponentCameraOffset[0], opponentCameraOffset[1]);
					else if (flightChar == gf)
						flightCameraOffset.set(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
				}

				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Lyrics':
				var split = value1.split("--");
				var text = value1;
				var color = FlxColor.WHITE;
				if(split.length > 1){
					text = split[0];
					color = FlxColor.fromString(split[1]);
				}
				var duration:Float = Std.parseFloat(value2);
				if (Math.isNaN(duration) || duration <= 0)
					duration = text.length * 0.5;

				writeLyrics(text, duration, color);

			case 'Notes Spin':
				var angle:Float = (value1 != null && value1 != "") ? Std.parseFloat(value1) : 360;
				var duration:Float = (value2 != null && value2 != "") ? Std.parseFloat(value2) : 0.2;

				opponentStrums.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, angle, duration, {ease: FlxEase.quintOut});
				});
				playerStrums.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, angle, duration, {ease: FlxEase.quintOut});
				});
				strumLineNotes.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, angle, duration, {ease: FlxEase.quintOut});
				});

			case 'Chroma Video':
				if(!ClientPrefs.lowQuality) chromaVideo(value1);

			case 'RedVG':
				// ty maliciousbunny, i stole this from you but eh you wrote it in v2 so its fiiiiiiiiiiiine
				var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
				vg.alpha = 0;
				vg.cameras = [camHUD];
				add(vg);

				// now that we can pause it, why not just yknow

				FlxTween.tween(vg, {alpha: 1}, 0.85, {type: FlxTweenType.PINGPONG});

			case 'static':
				doStaticSign(0, false);

			case 'sonicspook':
				doSunikScaryAss();

			case 'TooSlowFlashinShit':
				switch (Std.parseFloat(value1))
				{
					case 1:
						doStaticSign(0);
					case 2:
						doSimpleJump();
				}

			case 'Character Fly':
				flightTween?.cancel();
				
				var targetGroup:FlxSpriteGroup = dadGroup;
				var x:Float = DAD_X;
				var y:Float = DAD_Y;
				var char:Character = dad;
				
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						char = boyfriend;
						targetGroup = boyfriendGroup;
						x = BF_X;
						y = BF_Y;
						flightCameraOffset.set(boyfriendCameraOffset[0], boyfriendCameraOffset[1]);
					case 'gf' | 'girlfriend' | '1':
						char = gf;
						targetGroup = gfGroup;
						x = GF_X;
						y = GF_Y;
						flightCameraOffset.set(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
					default:
						flightCameraOffset.set(opponentCameraOffset[0], opponentCameraOffset[1]);
				}

				flightChar = char;
				flightGroup = targetGroup;
				flightState = value1;
				forceCameraToFlight = true;
				
				if (value1 != null)
					flightTween = FlxTween.tween(targetGroup, {x: x, y: y}, 0.2, {
						onComplete: (_) -> {
							targetGroup.setPosition(x, y);
							forceCameraToFlight = true;
						}
					});
				else
					forceCameraToFlight = false;

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2));
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if (forceCameraToFlight && flightChar != null) {
			var isFlightCharSection = false;
			var extraX:Float = 0;
			var extraY:Float = 0;
			
			if (SONG.notes[curSection] != null) {
				if (SONG.notes[curSection].mustHitSection && flightChar == boyfriend) {
					isFlightCharSection = true;
					extraX = -100;
					extraY = -100;
				}
				else if (!SONG.notes[curSection].mustHitSection && flightChar == dad) {
					isFlightCharSection = true;
					extraX = 150;
					extraY = -100;
				}
				else if (SONG.notes[curSection].gfSection && flightChar == gf) {
					isFlightCharSection = true;
				}
			}
			
			if (isFlightCharSection) {
				camFollow.set(
					flightChar.getMidpoint().x + extraX,
					flightChar.getMidpoint().y + extraY
				);
				camFollow.x += flightChar.cameraPosition[0] + flightCameraOffset.x;
				camFollow.y += flightChar.cameraPosition[1] + flightCameraOffset.y;
				return;
			}
		}

		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		//SYBAU -JustX
		/*if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}*/

		if(SONG.song.toLowerCase()=='fatality' && curStage == "fatal-launch-base"){
			#if windows
			try{
				Sys.command('${Sys.getCwd()}\\assets\\exe\\FatalError.exe');
			}catch(e:Dynamic) {
				trace("A fatal error has ACTUALLY occured lol: " + e);
			}
			#end
			FlxG.mouse.visible = false;
			FlxG.mouse.unload();
		}

		flightTween?.cancel();
		flightChar = null;
		flightGroup = null;
		flightState = '';
		forceCameraToFlight = false;
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		supersuperZoomShit = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode && !practiceMode && !cpuControlled) {
				var songIndex = storyPlaylist.indexOf(Paths.formatToSongPath(SONG.song));
				if (songIndex >= 0 && songIndex >= FlxG.save.data.storyProgress) {
					FlxG.save.data.storyProgress = songIndex + 1;
					FlxG.save.flush();
				}
				trace('Song completed: $songIndex');
				trace(FlxG.save.data.storyProgress);
			}

			if (isSoundTest && !practiceMode && !cpuControlled) {
				var songName = Paths.formatToSongPath(Paths.formatToSongPath(SONG.song));
				CharSongList.unlockSong(songName);
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();

					FlxTransitionableState.skipNextTransOut = false;

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomShapeTransition.nextCamera = null;
					}
					canResync = false;
					MusicBeatState.switchState(new StoryMenuState());

					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = StoryMenuState.curDifficulty;

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					canResync = false;
					
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else if (isEncoreMode)
			{
				trace('WENT BACK TO ENCORE??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomShapeTransition.nextCamera = null;
				}
				canResync = false;
				MusicBeatState.switchState(new EncoreState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
			else if (isSoundTest)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					trace('WENT BACK TO SOUND TEST??');

					FlxTransitionableState.skipNextTransOut = false;

					cancelMusicFadeTween();
					canResync = false;
					MusicBeatState.switchState(new SoundTestMenu());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				} else {
					trace('LOADING NEXT SONG ST');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]));

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					canResync = false;
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomShapeTransition.nextCamera = null;
				}
				canResync = false;
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	function updateSonicScore()
	{
		var seperatedScore:Array<String> = Std.string(songScore).split("");
		if (seperatedScore.length < scoreNumbers.length)
		{
			for (idx in seperatedScore.length...scoreNumbers.length)
			{
				if (hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd')
				{
					seperatedScore.unshift('');
				}
				else
				{
					seperatedScore.unshift('0');
				}
			}
		}
		if (seperatedScore.length > scoreNumbers.length)
			seperatedScore.resize(scoreNumbers.length);

		for (idx in 0...seperatedScore.length)
		{
			if (seperatedScore[idx] != '' || idx == scoreNumbers.length - 1)
			{
				var val = Std.parseInt(seperatedScore[idx]);
				if (Math.isNaN(val))
					val = 0;
				scoreNumbers[idx].number = val;
				scoreNumbers[idx].visible = true;
			}
			else
				scoreNumbers[idx].visible = false;
		}
	}

	function updateSonicMisses()
	{
		var seperatedScore:Array<String> = Std.string(songMisses).split("");
		if (seperatedScore.length < missNumbers.length)
		{
			for (idx in seperatedScore.length...missNumbers.length)
			{
				if (hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd')
				{
					seperatedScore.unshift('');
				}
				else
				{
					seperatedScore.unshift('0');
				}
			}
		}
		if (seperatedScore.length > missNumbers.length)
			seperatedScore.resize(missNumbers.length);

		for (idx in 0...seperatedScore.length)
		{
			if (seperatedScore[idx] != '' || idx == missNumbers.length - 1)
			{
				var val = Std.parseInt(seperatedScore[idx]);
				if (Math.isNaN(val))
					val = 0;
				missNumbers[idx].number = val;
				missNumbers[idx].visible = true;
			}
			else
				missNumbers[idx].visible = false;
		}
	}

	function updateSonicRings()
	{
		var seperatedScore:Array<String> = Std.string(cNum).split("");
		if (seperatedScore.length < ringsNumbers.length)
		{
			for (idx in seperatedScore.length...ringsNumbers.length)
			{
				if (hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd')
				{
					seperatedScore.unshift('');
				}
				else
				{
					seperatedScore.unshift('0');
				}
			}
		}
		if (seperatedScore.length > ringsNumbers.length)
			seperatedScore.resize(ringsNumbers.length);

		for (idx in 0...seperatedScore.length)
		{
			if (seperatedScore[idx] != '' || idx == ringsNumbers.length - 1)
			{
				var val = Std.parseInt(seperatedScore[idx]);
				if (Math.isNaN(val))
					val = 0;
				ringsNumbers[idx].number = val;
				ringsNumbers[idx].visible = true;
			}
			else
				ringsNumbers[idx].visible = false;
		}
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		switch (daRating.name)
		{
			case "shit": // shit
				drainMisses++;
				drainMisses -= 0.0025;
				fearNo += 2;
				updateSonicMisses();
			case "bad": // bad
				drainMisses -= 1/75;
				fearNo++;
			case "good": // good
				drainMisses -= 1/50;
			case "sick": // sick
				drainMisses -= 1/25;
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			updateSonicScore();
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x + 40;
		comboSpr.y += 20;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo && combo > 0 && combo % 10 == 0);
		comboSpr.x += ClientPrefs.comboOffset[4];
		comboSpr.y -= ClientPrefs.comboOffset[5];
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;

		var cHealth:Float = health;
		switch (daNote.noteType)
		{
			case "Static Note":
				if (preloaded && daNoteStatic != null) {
					daNoteStatic.animation.play('static', true);
					daNoteStatic.visible = true;
					daNoteStatic.alpha = 1;
					
					FlxG.camera.shake(0.005, 0.005);
					FlxG.sound.play(Paths.sound("hitStatic1"));
					
					new FlxTimer().start(0.38, function(trol:FlxTimer) {
						daNoteStatic.alpha = 0;
						daNoteStatic.visible = false;
					});
				}
				// if game coudnt preload static ass
				else {
					var fallbackStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("hitStatic", 'exe'));
					fallbackStatic.frames = Paths.getSparrowAtlas('hitStatic');
					fallbackStatic.animation.addByPrefix('static', "staticANIMATION", 24, false);
					fallbackStatic.cameras = [camHUD];
					fallbackStatic.visible = false;
					add(fallbackStatic);
				}

			// prevents from miss counts
			case "Phantom Note", "Hex Note":
				songMisses -= 1;

			default:
				if (cNum <= 0 && !fucklesMode)
					health -= daNote.missHealth;
				fearNo += 5;
				songMisses++;
				if (fucklesMode)
					drainMisses++;
				updateSonicMisses();
				/*if (curSong == "cycles")
				{
					fileHealth = health;
				}*/
		}
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if (cNum > 0)
		{
			songMisses--;
			cNum--;
			updateSonicRings();
			health = cHealth;
		}

		if(char != null && char.hasMissAnimations)
		{
			if(char.animTimer <= 0 && !char.voicelining){
				var daAlt = '';
				if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
				char.playAnim(animToPlay, true);
			}
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, anim:Bool = true):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) { 
				songScore -= 10;
				updateSonicScore();
			}

			if(!endingSong) {
				songMisses++;
				if (fucklesMode)
					drainMisses++;
				updateSonicMisses();
			}
			totalPlayed++;
			RecalculateRating(true);

			var cHealth:Float = health;
			if (isFear && cNum == 0)
				health -= 0.15;
			fearNo += 5;
			if (cNum == 0)
				health -= 0.15;
			/*if (curSong == "cycles")
			{
				fileHealth = health;
			}*/
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if (cNum > 0)
			{
				cNum--;
				updateSonicRings();
				health = cHealth;
			}

			if(boyfriend.hasMissAnimations && anim) {
				if(boyfriend.animTimer <= 0 && !boyfriend.voicelining)
					boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			char.holdTimer = 0;

			if(char.voicelining) char.voicelining = false;

			if(char != null && !char.voicelining)
			{
				if (!note.isSustainNote
					&& noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row] != null
					&& noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row].length > 1)
				{
					// potentially have jump anims?
					var chord = noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row];
					var animNote = chord[0];
					var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))] + altAnim;
					if (char.mostRecentRow != note.row) {
						char.playAnim(realAnim, true);
					}

					if (note != animNote) {
						char.playGhostAnim(chord.indexOf(note) - 1, animToPlay, true);
					}

					char.mostRecentRow = note.row;
				}
				else {
					char.playAnim(animToPlay, true);
				}
			}
		}

		if (SONG.needsVoices) {
			vocals.volume = 1;
			if(opponentVocals.length <= 0) vocals.volume = 1;
		}

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		iconP2.scale.set(1.15, 1.15);

		if (SONG.song.toLowerCase() == 'fight-or-flight')
			fearNo += 0.15;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}

						case 'Hex Note':
							hexes++;
							FlxG.sound.play(Paths.sound("hitWire"));
							camIDK.flash(0xFFAA0000, 0.35, null, true);
							hexTimer = 0;
							updateWires();
							if (hexes > barbedWires.members.length)
							{
								trace("die.");
								health = -10000; // you are dead
							}

						case 'Phantom Note':
							trace("xdeez nuts lmao");
							healthDrop += 0.00025;
							dropTime = 10;
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			} 

			if (!fucklesMode)
			{
			    health += note.hitHealth * healthGain;
			}

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + note.animSuffix;

				var char:Character = boyfriend;
				char.holdTimer = 0;
				if(note.gfNote)
				{
					if(gf != null)
						char = gf;

				}
				else if(char.animTimer <= 0 && !char.voicelining)
				{
					if (!note.isSustainNote && noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row]!=null && noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row].length > 1)
					{
						// potentially have jump anims?
						var chord = noteRows[note.gfNote ? 2 : note.mustPress ? 0 : 1][note.row];
						var animNote = chord[0];
						var realAnim = singAnimations[Std.int(Math.abs(note.noteData))] + note.animSuffix;
						if (char.mostRecentRow != note.row)
							char.playAnim(realAnim, true);


						if (note != animNote)
							char.playGhostAnim(chord.indexOf(note) - 1, animToPlay, true);

						char.mostRecentRow = note.row;
					}
					else
						char.playAnim(animToPlay, true);

					if(note.noteType == 'Hey!') {
						if(char.animOffsets.exists('hey')) {
							char.playAnim('hey', true);
							char.specialAnim = true;
							char.heyTimer = 0.6;
						}

						if(gf != null && gf.animOffsets.exists('cheer')) {
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = 0.6;
						}
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			iconP1.scale.set(1.15, 1.15);

			if (isFear)
			{
				fearNo -= 0.1;
				//trace(fearNo);
			}

			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'BloodSplash';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		skin = splashTextureChanges(skin);
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	function splashTextureChanges(skin:String):String
	{
		switch (Paths.formatToSongPath(curSong))
		{
			case 'too-fest':
				if (curStep > 912 && curStep < 1167)
				{
					skin = 'hitmarker';
					FlxG.sound.play(Paths.sound("hitmarker"));
				}
			case 'endless', 'endless-og':
				if (curStep > 895)
					skin = 'endlessNoteSplashes';
				else
					skin = 'noteSplashes';
		}
		return skin;
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		if (curStage == 'fatal-launch-base')
		{
			FlxG.mouse.unload();
			FlxG.mouse.visible = false;
		}

		if (isFixedAspectRatio)
		{
			var screen = Lib.application.window.display;
			var screenWidth = screen.bounds.width;
			var screenHeight = screen.bounds.height;

			isFixedAspectRatio = false;

			Lib.application.window.resizable = true;
			
			FlxG.scaleMode = new flixel.FlxScaleMode();
			FlxG.resizeGame(originalWidth, originalHeight);
			Lib.application.window.resize(originalWidth, originalHeight);
			FlxG.camera.setSize(1280, 720);
	
			var winX = Std.int((screenWidth - originalWidth) / 2);
			var winY = Std.int((screenHeight - originalHeight) / 2);
			Lib.application.window.move(winX, winY);
			FlxG.fullscreen = wasFullscreen;
		}

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		if (curBeat % 2 == 0 && superZoomShit)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}

		if (curBeat % 1 == 0 && supersuperZoomShit)
		{
			FlxG.camera.zoom += 0.06 * camZoomingMult;
			camHUD.zoom += 0.08 * camZoomingMult;
		}

		switch (curStage)
		{

		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function cinematicBars(appear:Bool) //IF (TRUE) MOMENT?????
	{
		if (appear)
		{
			add(topBar);
			add(bottomBar);
			FlxTween.tween(topBar, {y: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 550}, 0.5, {ease: FlxEase.quadOut});
		}
		else
		{
			FlxTween.tween(topBar, {y: -170}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 720}, 0.5, {ease: FlxEase.quadOut, onComplete: function(fuckme:FlxTween)
			{
				remove(topBar);
				remove(bottomBar);
			}});
		}
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	var lyricText:FlxText;
	var lyricTween:FlxTween;

	function writeLyrics(text:String, duration:Float, color:FlxColor)
	{
		if (lyricText != null) {
			var old:FlxText = cast lyricText;
			FlxTween.tween(old, {alpha: 0}, 0.2, {onComplete: function(twn:FlxTween)
			{
				remove(old);
				old.destroy();
			}});
			lyricText = null;
		}
		if (lyricTween != null){
			lyricTween.cancel();
			lyricTween=null;
		}
		if (text.trim() != '' && duration > 0 && color.alphaFloat > 0) {
			lyricText = new FlxText(0, 0, FlxG.width, text);
			switch (SONG.song.toLowerCase()) {
				default:
                    lyricText.setFormat(Paths.font("vcr.ttf"), 24, color, CENTER, OUTLINE, FlxColor.BLACK);
			}
			lyricText.alpha = 0;
			lyricText.antialiasing = ClientPrefs.globalAntialiasing;
			lyricText.screenCenter(XY);
			lyricText.y += 250;
			lyricText.cameras = [camIDK];
			add(lyricText);
			lyricTween = FlxTween.tween(lyricText, {alpha: color.alphaFloat}, 0.2, {onComplete: function(twn:FlxTween)
			{
				lyricTween = FlxTween.tween(lyricText, {alpha: 0}, 0.2, {startDelay: duration, onComplete: function(twn:FlxTween)
				{
					remove(lyricText);
					lyricText.destroy();
					lyricText = null;
					if(lyricTween == twn)lyricTween = null;
				}});
			}});
		}
	}

	function updateWires()
	{
		for (wireIdx in 0...barbedWires.members.length)
		{
			var wire = barbedWires.members[wireIdx];
			wire.screenCenter();
			var flag:Bool = wire.extraInfo.get("inUse");
			if ((wireIdx + 1) <= hexes)
			{
				if (!flag)
				{
					if (wire.tweens.exists("disappear"))
					{
						wire.tweens.get("disappear").cancel();
						wire.tweens.remove("disappear");
					}
					wire.alpha = 1;
					wire.shake(0.01, 0.05);
					wire.extraInfo.set("inUse", true);
				}
			}
			else
			{
				if (wire.tweens.exists("disappear"))
				{
					wire.tweens.get("disappear").cancel();
					wire.tweens.remove("disappear");
				}
				if (flag)
				{
					wire.extraInfo.set("inUse", false);
					wire.tweens.set("disappear", FlxTween.tween(wire, {
						alpha: 0,
						y: ((FlxG.height - wire.height) / 2) + 75
					}, 0.2, {
						ease: FlxEase.quadIn,
						onComplete: function(tw:FlxTween)
						{
							if (wire.tweens.get("disappear") == tw)
							{
								wire.tweens.remove("disappear");
								wire.alpha = 0;
							}
						}
					}));
				}
			}
		}
	}

	function doSunikScaryAss()
	{
		trace('JUMPSCARE aaaa');

		var daJumpscare:FlxSprite = new FlxSprite();
		daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE', 'exe');
		daJumpscare.animation.addByPrefix('jump', "sonicSPOOK", 24, false);
		daJumpscare.animation.play('jump',true);
		daJumpscare.scale.set(1.1, 1.1);
		daJumpscare.updateHitbox();
		daJumpscare.screenCenter();
		daJumpscare.y += 370;

		daJumpscare.cameras = [camHUD];

		FlxG.sound.play(Paths.sound('jumpscare', 'exe'), 1);
		FlxG.sound.play(Paths.sound('datOneSound', 'exe'), 1);

		add(daJumpscare);

		daJumpscare.animation.play('jump');

		daJumpscare.animation.finishCallback = function(pog:String)
		{
			trace('ended jump');
			daJumpscare.visible = false;
		}
	}

	function doSimpleJump()
	{
		trace('SIMPLE JUMPSCARE');

		var simplejump:FlxSprite;
		simplejump = new FlxSprite(0, 0).loadGraphic(Paths.image("simplejump", 'exe'));
		simplejump.setGraphicSize(FlxG.width, FlxG.height);
		simplejump.screenCenter();
		simplejump.cameras = [camIDK];
		FlxG.camera.shake(0.0025, 0.50);

		add(simplejump);

		FlxG.sound.play(Paths.sound('sppok'), 1);

		new FlxTimer().start(0.2, (_) ->
		{
			trace('ended simple jump');
			remove(simplejump);
			simplejump.destroy();
		});

		// now for static

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("daSTAT", 'exe'));
		daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'exe');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camIDK];
		daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (daStatic.alpha != 0)
			daStatic.alpha = FlxG.random.float(0.1, 0.5);

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = (_) ->
		{
			trace('ended static');
			remove(daStatic);
			daStatic.destroy();
		}
	}

	function doStaticSign(lestatic:Int = 0, leopa:Bool = true)
	{
		trace('static MOMENT HAHAHAH ' + lestatic);

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("daSTAT", 'exe'));
		daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'exe');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camIDK];

		switch (lestatic)
		{
			case 0:
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		}
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (leopa)
		{
			if (daStatic.alpha != 0)
				daStatic.alpha = FlxG.random.float(0.1, 0.5);
		}
		else
			daStatic.alpha = 1;

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = (_) ->
		{
			trace('ended static');
			remove(daStatic);
			daStatic.destroy();
		}
	}

	function fucklesDeluxe()
	{
		health = 2;
		// songMisses = 0;
		fucklesMode = true;

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		scoreTxt.visible = false;

		opponentStrums.forEach(function(spr:FlxSprite)
		{
			spr.x += 10000;
		});
	}

	function reloadTheNotesPls()
	{
		playerStrums.forEach(function(spr:StrumNote)
		{
			spr.reloadNote();
		});
		opponentStrums.forEach(function(spr:StrumNote)
		{
			spr.reloadNote();
		});
		notes.forEach(function(spr:Note)
		{
			spr.reloadNote();
		});
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
