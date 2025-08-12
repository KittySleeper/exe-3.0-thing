package stages;

import flixel.FlxSprite;

class CurseOfX extends BaseStage
{
	var curseStatic:FlxSprite;
	var curseFloor:FlxSprite;
	var curseSky:FlxSprite;
	var curseTrees:FlxSprite;
	var curseTreesTwo:FlxSprite;
	var curseFountain:FlxSprite;

override public function create() {
					defaultCamZoom = 0.60;

					curseSky = new FlxSprite(-300, -150);
					curseSky.loadGraphic(Paths.image('curse/background', 'exe'));
					curseSky.scrollFactor.set(1, 1);
					curseSky.antialiasing = true;
					curseSky.scale.set(1.5, 1.5);
					add(curseSky);

					curseTrees = new FlxSprite(-300, -150);
					curseTrees.loadGraphic(Paths.image('curse/treesfarback', 'exe'));
					curseTrees.scrollFactor.set(1, 1);
					curseTrees.antialiasing = true;
					curseTrees.scale.set(1.5, 1.5);
					add(curseTrees);

					curseTreesTwo = new FlxSprite(-300, -150);
					curseTreesTwo.loadGraphic(Paths.image('curse/treesback', 'exe'));
					curseTreesTwo.scrollFactor.set(1, 1);
					curseTreesTwo.antialiasing = true;
					curseTreesTwo.scale.set(1.5, 1.5);
					add(curseTreesTwo);

					curseFountain = new FlxSprite(350, 0);
					curseFountain.frames = Paths.getSparrowAtlas('curse/goofyahfountain', 'exe');
					curseFountain.animation.addByPrefix('fotan', "fountainlol", 24, true);
					curseFountain.animation.play('fotan');
					curseFountain.scale.x = 1.4;
					curseFountain.scale.y = 1.4;
					add(curseFountain);

					curseFloor = new FlxSprite(-250, 700);
					curseFloor.loadGraphic(Paths.image('curse/floor', 'exe'));
					curseFloor.scrollFactor.set(1, 1);
					curseFloor.antialiasing = true;
					curseFloor.scale.set(1.5, 1.5);
					add(curseFloor);

					curseStatic = new FlxSprite(0, 0);
					curseStatic.frames = Paths.getSparrowAtlas('curse/staticCurse', 'exe');
					curseStatic.animation.addByPrefix('stat', "menuSTATICNEW instance 1", 24, true);
					curseStatic.animation.play('stat');
					curseStatic.alpha = 0.25;
					curseStatic.screenCenter();
					curseStatic.scale.x = 4;
					curseStatic.scale.y = 4;
					curseStatic.visible = false;
					//curseStatic.blend = LIGHTEN;
					add(curseStatic);
 }
}
