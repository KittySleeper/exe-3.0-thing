package;

import flixel.ui.FlxBar;
import Controls.Control;
import flixel.math.FlxMath;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
    var menuButtons:FlxTypedGroup<FlxSprite>;
    var menuTexts:FlxTypedGroup<FlxSprite>;

    var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
    var curSelected:Int = 0;

    var pauseMusic:FlxSound;

    var selectionHighlights:FlxTypedGroup<FlxSprite>;
    var bottomPanel:FlxSprite;
    var topPanel:FlxSprite;
    var timeBar:FlxBar;
    var timeBarBG:AttachedSprite;
    var iconP1:HealthIcon;
    var iconP2:HealthIcon;
    var botplayText:FlxText;
    var blueballedTxt:FlxText;

    // for preventing crashes
    var activeTweens:Array<FlxTween> = [];
    var activeTimers:Array<FlxTimer> = [];

	public static var transCamera:FlxCamera;

    var canInteract:Bool = false;
    var isClosing:Bool = false;

    static final MENU_START_X:Int = 400;
    static final MENU_START_Y:Int = 70;
    static final MENU_SPACING_Y:Int = 100;
    static final MENU_ANIM_OFFSET:Int = 480;

	public static var songName:String = '';

    override function create()
    {
		super.create();

        FlxG.sound.play(Paths.sound("pause"));

        pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
        pauseMusic.volume = 0;
        pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
        FlxG.sound.list.add(pauseMusic);

        createTopPanel();
        createBottomPanel();
        createInfoTexts();
        createSelectionHighlight();

        menuButtons = new FlxTypedGroup<FlxSprite>();
        menuTexts = new FlxTypedGroup<FlxSprite>();
        add(menuButtons);
        add(menuTexts);

        for (i in 0...menuItems.length) {
            createMenuItem(i);
        }

        createTimeBar();

        var timer = new FlxTimer().start(0.2, function(_) {
            canInteract = true;
            changeSelection();
        });
        activeTimers.push(timer);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    function createTopPanel()
    {
        topPanel = new FlxSprite(-1000, 0).loadGraphic(Paths.image("pauseStuff/pauseTop"));
        topPanel.antialiasing = ClientPrefs.globalAntialiasing;
        add(topPanel);
        
        var tween = FlxTween.tween(topPanel, {x: 0}, 0.2, {ease: FlxEase.quadOut});
        activeTweens.push(tween);
    }

    function createBottomPanel()
    {
        var panelX = PlayState.isFixedAspectRatio ? 589 - 300 : 589;
        bottomPanel = new FlxSprite(1280, 33).loadGraphic(Paths.image('pauseStuff/bottomPanel'));
        bottomPanel.antialiasing = ClientPrefs.globalAntialiasing;
        add(bottomPanel);
        
        var tween = FlxTween.tween(bottomPanel, {x: panelX}, 0.2, {ease: FlxEase.quadOut});
        activeTweens.push(tween);
    }

    function createInfoTexts()
    {
        //personal func cuz yes
        botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
        botplayText.scrollFactor.set();
        botplayText.setFormat(Paths.font('vcr.ttf'), 32);
        botplayText.x = FlxG.width - (botplayText.width + 20);
        botplayText.updateHitbox();
        botplayText.visible = PlayState.instance.cpuControlled;
        add(botplayText);
    }

    function createSelectionHighlight()
    {
        selectionHighlights = new FlxTypedGroup<FlxSprite>();
        add(selectionHighlights);
        
        for (i in 0...menuItems.length) {
            var highlight = new FlxSprite().loadGraphic(Paths.image('pauseStuff/graybut'));
            highlight.antialiasing = ClientPrefs.globalAntialiasing;
            highlight.x = FlxG.width - MENU_START_X + 25;
            highlight.y = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * i;
            highlight.ID = i;
            selectionHighlights.add(highlight);
        }
    }

    function createMenuItem(index:Int)
    {
        var text = new FlxSprite();
        text.loadGraphic(Paths.image('pauseStuff/${menuItems[index].replace(" ", "")}'));
        text.x = FlxG.width - MENU_START_X + (index + 1) * MENU_ANIM_OFFSET;
        text.y = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * index;
        text.ID = index;

        var button = new FlxSprite();
        button.loadGraphic(Paths.image("pauseStuff/blackbut"));
        button.x = text.x;
        button.antialiasing = ClientPrefs.globalAntialiasing;
        button.y = text.y + text.height + 10; //position button below text with 10px spacing
        button.ID = index;
        menuButtons.add(button);
        menuTexts.add(text);
        
        var tween = FlxTween.tween(text, {
            x: FlxG.width - MENU_START_X - 80 * index
        }, 0.2, {
            ease: FlxEase.quadOut,
            onUpdate: function(_) {
                button.x = text.x;
            }
        });
        activeTweens.push(tween);
    }

    function createTimeBar()
    {
        timeBarBG = new AttachedSprite('timeBar');
        timeBarBG.x = 200;
        timeBarBG.y = 200;
        timeBarBG.scrollFactor.set();
        timeBarBG.alpha = 0;
        timeBarBG.visible = !ClientPrefs.hideHud;
        timeBarBG.color = FlxColor.BLACK;
        timeBarBG.xAdd = -4;
        timeBarBG.yAdd = -4;
        add(timeBarBG);

        timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, 
                            Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), 
                            PlayState.instance, 'songPercent', 0, 1);
        timeBar.scrollFactor.set();
        timeBar.createFilledBar(0xFF000000, FlxColor.RED);
        timeBar.numDivisions = 400;
        timeBar.alpha = 0;
        timeBar.visible = !ClientPrefs.hideHud;
        add(timeBar);

        timeBarBG.sprTracker = timeBar;

        iconP1 = new HealthIcon(PlayState.instance.boyfriend.healthIcon, false);
        iconP1.x = -1000;
        iconP1.angle = 100;
        iconP1.y = timeBar.y - (iconP1.height / 2);
        iconP1.visible = !ClientPrefs.hideHud;
        add(iconP1);

		iconP2 = new HealthIcon('face', false);
        iconP2.y = timeBar.y - 75;

        if (PlayState.instance.healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (PlayState.instance.healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

        var percent = 100 - timeBar.percent;
		var tween1 = FlxTween.tween(iconP1, {
			x: timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - (iconP2.width - 26)),
			angle: 0
		}, 0.8, {ease: FlxEase.circOut});
        
        var tween2 = FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
        
        activeTweens.push(tween1);
        activeTweens.push(tween2);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(pauseMusic.volume < 0.5) {
            pauseMusic.volume += 0.01 * elapsed;
        }

        if(canInteract && !isClosing)
        {
            handleInput();
        }
    }

    function handleInput()
    {
        if (controls.UI_UP_P) changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);
        
        if (controls.ACCEPT) selectMenuItem();
    }

    function changeSelection(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
        
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        for (button in menuButtons) {
            animateButton(button);
        }
        
        for (text in menuTexts) {
            animateText(text);
        }
        
        animateHighlight();
    }

    function animateButton(button:FlxSprite)
    {
        FlxTween.cancelTweensOf(button);
        var targetY = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * button.ID;
        
        if(button.ID == curSelected) {
            var tween = FlxTween.tween(button, {y: targetY - 20}, 0.2, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    var pingPong = FlxTween.tween(button, {y: button.y + 5}, 1, {
                        ease: FlxEase.quadInOut, 
                        type: FlxTween.PINGPONG
                    });
                    activeTweens.push(pingPong);
                }
            });
            activeTweens.push(tween);
        } else {
            var tween = FlxTween.tween(button, {y: targetY}, 0.2, {ease: FlxEase.quadOut});
            activeTweens.push(tween);
        }
    }

    function animateText(text:FlxSprite)
    {
        FlxTween.cancelTweensOf(text);
        var targetY = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * text.ID + 5;
        
        if(text.ID == curSelected) {
            var tween = FlxTween.tween(text, {y: targetY - 20}, 0.2, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    var pingPong = FlxTween.tween(text, {y: text.y + 5}, 1, {
                        ease: FlxEase.quadInOut, 
                        type: FlxTween.PINGPONG
                    });
                    activeTweens.push(pingPong);
                }
            });
            activeTweens.push(tween);
        } else {
            var tween = FlxTween.tween(text, {y: targetY}, 0.2, {ease: FlxEase.quadOut});
            activeTweens.push(tween);
        }
    }

    function animateHighlight()
    {
        for (highlight in selectionHighlights) {
            var button = menuButtons.members[highlight.ID];
            if (button == null) continue;
            
            FlxTween.cancelTweensOf(highlight);
            highlight.x = button.x;
        }
    }
    function selectMenuItem()
    {
        var selected = menuItems[curSelected];

        switch(selected)
        {
            case "Resume":
                closeMenu();
                
            case "Restart Song":
                restartSong();
                
            case "Exit to menu":
                pauseMusic.stop();
                exitToMenu();
        }
    }

    function closeMenu()
    {
        isClosing = true;
        canInteract = false;

        FlxG.sound.play(Paths.sound("unpause"));

        for (highlight in selectionHighlights) {
            var tween = FlxTween.tween(highlight, {x: highlight.x + MENU_ANIM_OFFSET * (highlight.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
            activeTweens.push(tween);
        }

        for (button in menuButtons) {
            var tween = FlxTween.tween(button, {x: button.x + MENU_ANIM_OFFSET * (button.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
            activeTweens.push(tween);
        }
        
        for (text in menuTexts) {
            var tween = FlxTween.tween(text, {x: text.x + MENU_ANIM_OFFSET * (text.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
            activeTweens.push(tween);
        }

        var tween1 = FlxTween.tween(iconP1, {
            x: -1000,
            angle: 100
        }, 0.8, {ease: FlxEase.circOut});
        
        var tween2 = FlxTween.tween(timeBar, {alpha: 0}, 0.2, {ease: FlxEase.circOut});
        
        var tween3 = FlxTween.tween(topPanel, {x: -1000}, 0.2, {ease: FlxEase.quadOut});
        
        var tween4 = FlxTween.tween(bottomPanel, {x: 1280}, 0.2, {
            ease: FlxEase.quadOut,
            onComplete: function(_) {
                close();
            }
        });
        
        activeTweens.push(tween1);
        activeTweens.push(tween2);
        activeTweens.push(tween3);
        activeTweens.push(tween4);
    }

    public static function restartSong(noTrans:Bool = false)
    {
        PlayState.instance.paused = true;
        FlxG.sound.music.volume = 0;
        PlayState.instance.vocals.volume = 0;
        PlayState.instance.opponentVocals.volume = 0;

        if (noTrans)
        {
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.resetState();
        }
        else
        {
            MusicBeatState.resetState();
        }
    }

    function exitToMenu()
    {
        PlayState.deathCounter = 0;
        PlayState.seenCutscene = false;
        PlayState.chartingMode = false;
        
        if (PlayState.isStoryMode) {
            MusicBeatState.switchState(new StoryMenuState());
        } else if (PlayState.isEncoreMode) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            MusicBeatState.switchState(new EncoreState());
        } else if (PlayState.isSoundTest) {
            MusicBeatState.switchState(new SoundTestMenu());
        } else {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            MusicBeatState.switchState(new FreeplayState());
        }

        PlayState.instance.practiceMode = false;
        PlayState.changedDifficulty = false;
        PlayState.instance.cpuControlled = false;
    }

    override function destroy()
    {
        for (tween in activeTweens) {
            if (tween != null && tween.active) {
                tween.cancel();
            }
        }
        
        for (timer in activeTimers) {
            if (timer != null && timer.active) {
                timer.cancel();
            }
        }
        
        activeTweens = [];
        activeTimers = [];
        
        if (pauseMusic != null) {
            pauseMusic.stop();
            pauseMusic.destroy();
            pauseMusic = null;
        }
        
        super.destroy();
    }
}