package mainmenu;

import flixel.text.FlxText;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

class DAGardenState extends MusicBeatState {
    var songsList:Array<String> = ["too-slow", "you-cant-run", "triple-trouble"];
    var stupidObjects:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup();
    var curSelected:Int = 0;

    var inst:FlxSound;
    var voices:FlxSound;

    var songName:FlxText;

    override public function new() {
        super();

        for (stupidSongArray in CharSongList.songData.iterator())
            for (stupidSong in stupidSongArray)
                songsList.push(stupidSong);

        add(stupidObjects);

        for (i => song in songsList) {
            var obj = new FlxSprite(6400, i * 250).loadGraphic(Paths.image("mainmenu/extras/garden/songs/" + song));
            if (obj.graphic == null) obj.loadGraphic(Paths.image("mainmenu/extras/garden/songs/locked"));
            obj.setGraphicSize(560, 220);
            obj.updateHitbox();
            FlxTween.tween(obj, {x: FlxG.width * 0.55}, 1 + (i * 0.25), {ease: FlxEase.expoInOut});
            stupidObjects.add(obj);
        }

        var stupidBox = new FlxSprite().loadGraphic(Paths.image("mainmenu/extras/garden/box"));
        stupidBox.scrollFactor.set();
        stupidBox.screenCenter(Y);
        add(stupidBox);

        var stupidDisk = new FlxSprite(stupidBox.width * 0.4, 170);
        stupidDisk.frames = Paths.getSparrowAtlas("mainmenu/extras/garden/disk");
        stupidDisk.animation.addByPrefix("spin", "record", 10);
        stupidDisk.animation.play("spin");
        stupidDisk.scrollFactor.set();
        add(stupidDisk);

        songName = new FlxText(0, 120, stupidBox.width, "too-gay", 35);
        songName.alignment = CENTER;
        songName.scrollFactor.set();
        add(songName);

        changeSelection();
    }

    override public function update(elapsed) {
        super.update(elapsed);

        if (controls.UI_UP_P)
            changeSelection(-1);
        if (controls.UI_DOWN_P)
            changeSelection(1);

        if (controls.ACCEPT || inst != null && voices.time != inst.time)
            playSong();
        if (FlxG.keys.justPressed.P)
            stopSong();

        for (i => obj in stupidObjects.members) {
            if (i == curSelected) {
                obj.alpha = FlxMath.lerp(obj.alpha, 1, 0.35 * elapsed * 60);
                camera.scroll.y = FlxMath.lerp(camera.scroll.y, obj.getGraphicMidpoint().y - 300, 0.35 * elapsed * 60); //stupid ik shush
            } else {
                obj.alpha = FlxMath.lerp(obj.alpha, 0.5, 0.35 * elapsed * 60);
            }
        }

        if (controls.BACK) {
            stopSong();
            MusicBeatState.switchState(new MainMenuState());
        }
    }

    function changeSelection(amt:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + amt, 0, songsList.length - 1);
        songName.text = songsList[curSelected].toUpperCase().replace("-", " ");
        trace(songsList[curSelected]);
    }

    function stopSong() {
        inst?.stop();
        voices?.stop();

        FlxG.autoPause = true;
    }

    function playSong() {
        FlxG.sound.music.fadeOut(0.2, 0);
        stopSong();

        inst = FlxG.sound.play(Paths.inst(songsList[curSelected]), 0);
        voices = FlxG.sound.play(Paths.voices(songsList[curSelected]), 0);

        inst.fadeIn(0.2, 1);
        voices.fadeIn(0.2, 1);
        voices.time = inst.time;

        FlxG.autoPause = false;
    }
}