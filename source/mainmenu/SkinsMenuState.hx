package mainmenu;

import sys.io.File;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import sys.Http;

class SkinsMenuState extends MusicBeatState {
    var curSelected:Int = 0;
    var skinsList:Array<String>;

    var characterName:FlxText;
    var characterRender:FlxSprite;

    override public function create() {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        var skinsHttpData = new Http("https://raw.githubusercontent.com/KittySleeper/exe-3.0-thing/refs/heads/main/DlcContent/skins/SkinsData");
        skinsHttpData.onError = function(e) {trace("Skins Database Failed To Load! " + e);}
        skinsHttpData.onData = function(data:String) {
            skinsList = data.split("\n");
            trace("Skins Database Loaded: " + skinsList);
        }
        skinsHttpData.request();

        var coolBG = new FlxSprite().loadGraphic(Paths.image("backgroundlool"));
        coolBG.setGraphicSize(FlxG.width, FlxG.height);
        coolBG.updateHitbox();
        coolBG.screenCenter();
        add(coolBG);

        characterRender = new FlxSprite();
        characterRender.screenCenter();
        add(characterRender);

        characterName = new FlxText(0, FlxG.height * 0.65, FlxG.width, "Loading...", 30);
        characterName.alignment = CENTER;
        add(characterName);

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.UI_LEFT_P)
            changeSelection(-1);
        if (controls.UI_RIGHT_P)
            changeSelection(1);

        if (controls.ACCEPT) {
            trace("Download Started");

            var contentZip = new Http('https://raw.githubusercontent.com/KittySleeper/exe-3.0-thing/main/DlcContent/skins/${skinsList[curSelected].toLowerCase()}/content.zip');
            contentZip.onError = function(e) {trace("Failed To Load Content: " + e);}
            contentZip.onBytes = function(bytes:haxe.io.Bytes) {
                if (!sys.FileSystem.exists("./.temp"))
                    sys.FileSystem.createDirectory("./.temp");

                File.saveBytes('./.temp/SKIN_${skinsList[curSelected].toUpperCase()}.zip', bytes);
                CoolUtil.unzipFile('./.temp/SKIN_${skinsList[curSelected].toUpperCase()}.zip', "./mods");
            }
            contentZip.request();
        }

        if (controls.BACK)
            FlxG.switchState(new MainMenuState());
    }

    public function changeSelection(amt:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + 1, 0, skinsList.length - 2);

        characterName.text = skinsList[curSelected];

        var skinBitmap = new Http('https://raw.githubusercontent.com/KittySleeper/exe-3.0-thing/refs/heads/main/DlcContent/skins/${skinsList[curSelected].toLowerCase()}/icon.png');
        skinBitmap.onError = function(e) {trace("Skin Failed To Load! " + e);}
        skinBitmap.onBytes = function(byte) {
            trace("Skin Loaded!");
            characterRender.loadGraphic(BitmapData.fromBytes(byte));
            characterRender.scale.set(0.5, 0.5);
            characterRender.updateHitbox();
            characterRender.screenCenter();
        }
        skinBitmap.request();
    }
}