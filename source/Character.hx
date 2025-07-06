package;

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var vocals_file:String;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	// Восстановленные поля
	public var voicelining:Bool = false;
	public var mostRecentRow:Int = 0;
	public var ghostIdx:Int = 0;
	public var ghostAnim:String = '';
	public var debugMode:Bool = false;
	public var skipDance:Bool = false;
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false;
	public var stunned:Bool = false;
	public var danced:Bool = false;
	public var danceEveryNumBeats:Int = 2;
	public var singDuration:Float = 4;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var vocalsFile:String = '';
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var originalFlipX:Bool = false;
	public var animationsArray:Array<AnimArray> = [];
	public var animationNotes:Array<Dynamic> = [];
	public var animTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var holdTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var noAntialiasing:Bool = false;

	public var animGhosts:Array<FlxSprite> = [];
	public var ghostTweens:Array<FlxTween> = [];
	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;
	public var healthIcon:String = 'face';
	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var hasMissAnimations:Bool = false;

	public static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?isChibiChar:Bool = false)
	{
		super(x, y);

		for(i in 0...4){
			var ghost = new FlxSprite();
			ghost.visible = false;
			ghost.antialiasing = ClientPrefs.globalAntialiasing;
			ghost.alpha = 0.6;
			animGhosts.push(ghost);
			ghostTweens.push(null);
		}

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		
		switch (curCharacter)
		{
			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';
				scale.set(1, 1);

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json');
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				
				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
				
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				#end
				{
					spriteType = "packer";
				}
				
				#if MODS_ALLOWED
				var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
				var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
				
				if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				#end
				{
					spriteType = "texture";
				}

				switch (spriteType){
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);
				}
				
				imageFile = json.image;
				jsonScale = json.scale;
				singDuration = json.sing_duration;
				vocalsFile = json.vocals_file != null ? json.vocals_file : '';
				noAntialiasing = json.no_antialiasing;
				
				if(json.scale != 1) {
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;
				healthIcon = json.healthicon;
				flipX = !!json.flip_x;
				originalFlipX = flipX;
				
				if(noAntialiasing) {
					antialiasing = false;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2) {
					healthColorArray = json.healthbar_colors;
				}

				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop;
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}

				if (isChibiChar) {
					scale.set(scale.x / 3, scale.y / 3);
					updateHitbox();
					origin.set();

					x -= width * .5;
					y -= height;

					for (anim in animOffsets.keys()) {
						animOffsets[anim][0] *= scale.x;
						animOffsets[anim][1] *= scale.y;
					}
				}
		}
		
		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) {
			hasMissAnimations = true;
		}
		
		recalculateDanceIdle();
		dance();

		if (isPlayer) flipX = !flipX;

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				playAnim("shoot1");
		}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(animTimer > 0) 
			{
				animTimer -= elapsed;
				if(animTimer<=0){
					animTimer=0;
					dance();
				}
			}
			
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && (animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer'))
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		for (ghost in animGhosts)
			ghost.update(elapsed);

		super.update(elapsed);
	}

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && animTimer <= 0 && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}
	public function playGhostAnim(GhostIdx = 0, AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0){
		if (GhostIdx < 0 || GhostIdx >= animGhosts.length) return;
		var ghost = animGhosts[GhostIdx];
		ghost.scale.set(scale.x, scale.y);
		ghost.updateHitbox();
		ghost.frames = frames;
		ghost.animation.copyFrom(animation);
		ghost.antialiasing = antialiasing;
		ghost.x = x;
		ghost.y = y;
		ghost.flipX = flipX;
		ghost.flipY = flipY;
		ghost.alpha = alpha * 0.6;
		ghost.visible = true;
		ghost.color = FlxColor.fromRGB(healthColorArray[0], healthColorArray[1], healthColorArray[2]);
		ghost.animation.play(AnimName, Force, Reversed, Frame);
		if (GhostIdx < ghostTweens.length && ghostTweens[GhostIdx] != null) {
			ghostTweens[GhostIdx].cancel();
		}

		if (GhostIdx < ghostTweens.length) {
			ghostTweens[GhostIdx] = FlxTween.tween(ghost, {alpha: 0}, 0.75, {
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					ghost.visible = false;
					ghostTweens[GhostIdx] = null;
				}
			});
		}

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			ghost.offset.set(daOffset[0], daOffset[1]);
		else
			ghost.offset.set(0, 0);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	override function draw(){
		for(ghost in animGhosts){
			if(ghost.visible)
				ghost.draw();
		}
		
		super.draw();
	}
}