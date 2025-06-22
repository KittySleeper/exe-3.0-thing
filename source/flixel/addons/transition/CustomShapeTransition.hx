package flixel.addons.transition;

import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import shaders.BlueMaskShader;

class CustomShapeTransition extends MusicBeatSubstate
{
    public static var finishCallback:Void->Void;
    public static var shape:String = 'circle';
    public static var nextCamera:FlxCamera;
    
    var time:Float;
    var maxScale:Float = 6;
    var trans:FlxSprite;
    var top:FlxSprite;
    var bot:FlxSprite;
    var rig:FlxSprite;
    var lef:FlxSprite;
    var width:Int;
    var height:Int;
    var isTransIn:Bool;
    var fullBlackScreen:FlxSprite;
    var persistent:Bool = false;

    public function new(duration:Float, isTransIn:Bool)
    {
        this.time = duration;
        this.isTransIn = isTransIn;
        super();
    }

    override function create()
    {
        cameras = [nextCamera != null ? nextCamera : FlxG.camera];
        var cam = cameras[0];
        var zoom = Math.max(cam.zoom, 0.001);
        width = Math.ceil(FlxG.width / zoom);
        height = Math.ceil(FlxG.height / zoom);

        switch (shape) {
          case 'X':
            time = 0.8;
            maxScale = 10;

          case 'oval':
            time = 0.9;
            maxScale = 10;
        }

        fullBlackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        fullBlackScreen.scale.set(width, height);
        fullBlackScreen.updateHitbox();
        fullBlackScreen.screenCenter();
        fullBlackScreen.scrollFactor.set();
        
        if (isTransIn) {
            fullBlackScreen.alpha = 1;
            add(fullBlackScreen);
        } else {
            fullBlackScreen.alpha = 0;
        }

        var head = Paths.image('transitions/$shape').bitmap;
        var black = new BitmapData(width, height, true, FlxColor.BLACK);
        var border = new BitmapData(width * 2, height * 2, true, FlxColor.BLACK);

        var shader = new BlueMaskShader();
        shader.mask.input = head;
        
        trans = new FlxSprite().loadGraphic(black);
        trans.setGraphicSize(width, height);
        trans.shader = shader;
        trans.screenCenter();
        trans.scrollFactor.set();
        add(trans);

        top = new FlxSprite().loadGraphic(border);
        top.scrollFactor.set();
        add(top);

        bot = new FlxSprite().loadGraphic(border);
        bot.scrollFactor.set();
        add(bot);

        lef = new FlxSprite().loadGraphic(border);
        lef.scrollFactor.set();
        add(lef);

        rig = new FlxSprite().loadGraphic(border);
        rig.scrollFactor.set();
        add(rig);

        updatePositions();
        
        if (isTransIn) {
            trans.scale.set(0, 0);
            FlxTween.tween(trans.scale, {x: maxScale, y: maxScale}, time, {
                ease: FlxEase.quadOut,
                onComplete: finish
            });
            
            remove(fullBlackScreen);
        } else {
            trans.scale.set(maxScale, maxScale);
            FlxTween.tween(trans.scale, {x: 0, y: 0}, time, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    add(fullBlackScreen);
                    FlxTween.tween(fullBlackScreen, {alpha: 1}, 0.1, {
                        onComplete: finish
                    });
                }
            });
        }
        
        super.create();
    }

    function updatePositions()
    {
        trans.updateHitbox();
        trans.screenCenter();
        
        if (lef != null) {
            lef.x = trans.x - lef.width;
            lef.y = trans.y - (lef.height - trans.height) / 2;
        }
        if (rig != null) {
            rig.x = trans.x + trans.width;
            rig.y = trans.y - (rig.height - trans.height) / 2;
        }
        if (bot != null) {
            bot.y = trans.y + trans.height;
            bot.x = trans.x - (bot.width - trans.width) / 2;
        }
        if (top != null) {
            top.y = trans.y - top.height;
            top.x = trans.x - (top.width - trans.width) / 2;
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        updatePositions();
    }

    function finish(_)
    {
        if (isTransIn) {
            close();
        }
        
        if (finishCallback != null) {
            finishCallback();
            finishCallback = null;
        }
    }
    
    override function destroy()
    {
        if (isTransIn && fullBlackScreen != null) {
            fullBlackScreen.destroy();
        }
        super.destroy();
    }
}