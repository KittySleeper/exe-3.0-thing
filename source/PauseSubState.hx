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

    var selectionHighlight:FlxSprite;
    var bottomPanel:FlxSprite;
    var topPanel:FlxSprite;
    var timeBar:FlxBar;
    var timeBarBG:AttachedSprite;
    var iconP1:HealthIcon;
    var iconP2:HealthIcon;
    var botplayText:FlxText;
    var levelInfo:FlxText;
    var levelDifficulty:FlxText;
    var blueballedTxt:FlxText;

	public static var transCamera:FlxCamera;

    var canInteract:Bool = false;
    var isClosing:Bool = false;

    static final MENU_START_X:Int = 400;
    static final MENU_START_Y:Int = 70;
    static final MENU_SPACING_Y:Int = 100;
    static final MENU_ANIM_OFFSET:Int = 480;

	public static var songName:String = '';

    public function new(x:Float, y:Float)
    {
		super();

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

        new FlxTimer().start(0.2, function(_) {
            canInteract = true;
            changeSelection();
        });

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    function createTopPanel()
    {
        topPanel = new FlxSprite(-1000, 0).loadGraphic(Paths.image("pauseStuff/pauseTop"));
        add(topPanel);
        FlxTween.tween(topPanel, {x: 0}, 0.2, {ease: FlxEase.quadOut});
    }

    function createBottomPanel()
    {
        var panelX = PlayState.isFixedAspectRatio ? 589 - 230 : 589;
        bottomPanel = new FlxSprite(1280, 33).loadGraphic(Paths.image('pauseStuff/bottomPanel'));
        add(bottomPanel);
        FlxTween.tween(bottomPanel, {x: panelX}, 0.2, {ease: FlxEase.quadOut});
    }

    function createInfoTexts()
    {
        levelInfo = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
        levelInfo.scrollFactor.set();
        levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
        levelInfo.updateHitbox();
        levelInfo.x = FlxG.width - (levelInfo.width + 20);
        levelInfo.alpha = 0;
        //add(levelInfo);

        levelDifficulty = new FlxText(20, 15 + 32, 0, CoolUtil.difficultyString(), 32);
        levelDifficulty.scrollFactor.set();
        levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
        levelDifficulty.updateHitbox();
        levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
        levelDifficulty.alpha = 0;
        //add(levelDifficulty);

        blueballedTxt = new FlxText(20, 15 + 64, 0, "Blueballed: " + PlayState.deathCounter, 32);
        blueballedTxt.scrollFactor.set();
        blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
        blueballedTxt.updateHitbox();
        blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
        blueballedTxt.alpha = 0;
        add(blueballedTxt);

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
        selectionHighlight = new FlxSprite().loadGraphic(Paths.image('pauseStuff/graybut'));
        selectionHighlight.x = FlxG.width - MENU_START_X + MENU_ANIM_OFFSET;
        selectionHighlight.y = FlxG.height / 2 + MENU_START_Y;
        add(selectionHighlight);
        FlxTween.tween(selectionHighlight, {x: selectionHighlight.x - MENU_ANIM_OFFSET}, 0.2, {ease: FlxEase.quadOut});
    }

    function createMenuItem(index:Int)
    {
        var button = new FlxSprite(FlxG.width + MENU_START_X + 80 * index, 
                                  FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * index);
        button.loadGraphic(Paths.image("pauseStuff/blackbut"));
        button.x += (index + 1) * MENU_ANIM_OFFSET;
        button.ID = index;
        menuButtons.add(button);
        
        FlxTween.tween(button, {x: button.x - MENU_ANIM_OFFSET * (index + 1)}, 0.2, {ease: FlxEase.quadOut});

        var text = new FlxSprite(button.x + 25, button.y + 25);
        text.loadGraphic(Paths.image('pauseStuff/${menuItems[index].replace(" ", "")}'));
        text.ID = index;
        text.x += (index + 1) * MENU_ANIM_OFFSET;
        text.y = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * index + 5;
        menuTexts.add(text);
        
        FlxTween.tween(text, {
            x: FlxG.width - MENU_START_X - 80 * index + 25
        }, 0.2, {ease: FlxEase.quadOut});
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

        iconP1 = new HealthIcon(PlayState.instance.boyfriend.curCharacter, false);
        iconP1.x = -1000;
        iconP1.angle = 100;
        iconP1.y = timeBar.y - (iconP1.height / 2);
        iconP1.visible = !ClientPrefs.hideHud;
        add(iconP1);

		iconP2 = new HealthIcon('face', false);
        iconP2.y = timeBar.y - 75;
        //add(iconP2);

        var percent = 100 - timeBar.percent;
		FlxTween.tween(iconP1, {
			x: timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - (iconP2.width - 26)),
			angle: 0
		}, 0.8, {ease: FlxEase.circOut});
        FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
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

        handleDebugCommands();
    }

    function handleInput()
    {
        if (controls.UI_UP_P) changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);
        
        if (controls.ACCEPT) selectMenuItem();
    }

    function handleDebugCommands()
    {
        if(FlxG.keys.justPressed.P) {
            openSubState(new PracticeSubState());
            FlxG.sound.play(Paths.sound("secretSound"));
        }

        if(FlxG.keys.justPressed.B) {
            playRandomSound();
            #if debug
            toggleBotplay();
            #else
            Sys.exit(0);
            #end
        }
    }

    function playRandomSound()
    {
        switch (FlxG.random.int(1,7)) {
            case 1: FlxG.sound.play(Paths.sound("FartHD"));
            case 2: FlxG.sound.play(Paths.sound("vineboom"));
            case 3: FlxG.sound.play(Paths.sound("secretSound"));
            case 4: FlxG.sound.play(Paths.sound("Ring"));
            case 5: FlxG.sound.play(Paths.sound("yay"));
            case 6: FlxG.sound.play(Paths.sound("waowaowaowaowao"));
            case 7: FlxG.sound.play(Paths.sound("switch"));
        }
    }

    #if debug
    function toggleBotplay()
    {
        PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
        PlayState.instance.practiceMode = true;
        botplayText.visible = PlayState.instance.cpuControlled;
    }
    #end

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
            FlxTween.tween(button, {y: targetY - 20}, 0.2, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    FlxTween.tween(button, {y: button.y + 5}, 1, {
                        ease: FlxEase.quadInOut, 
                        type: FlxTween.PINGPONG
                    });
                }
            });
        } else {
            FlxTween.tween(button, {y: targetY}, 0.2, {ease: FlxEase.quadOut});
        }
    }

    function animateText(text:FlxSprite)
    {
        FlxTween.cancelTweensOf(text);
        var targetY = FlxG.height / 2 + MENU_START_Y + MENU_SPACING_Y * text.ID + 5;
        
        if(text.ID == curSelected) {
            FlxTween.tween(text, {y: targetY - 20}, 0.2, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    FlxTween.tween(text, {y: text.y + 5}, 1, {
                        ease: FlxEase.quadInOut, 
                        type: FlxTween.PINGPONG
                    });
                }
            });
        } else {
            FlxTween.tween(text, {y: targetY}, 0.2, {ease: FlxEase.quadOut});
        }
    }

    function animateHighlight()
    {
        var selectedButton = menuButtons.members[curSelected];
        if (selectedButton == null) return;
        
        FlxTween.cancelTweensOf(selectionHighlight);
        
        selectionHighlight.x = selectedButton.x;
        selectionHighlight.y = selectedButton.y;
        
        FlxTween.tween(selectionHighlight, {y: selectionHighlight.y - 20}, 0.2, {
            ease: FlxEase.quadOut,
            onComplete: function(_) {
                FlxTween.tween(selectionHighlight, {y: selectionHighlight.y + 5}, 1, {
                    ease: FlxEase.quadInOut, 
                    type: FlxTween.PINGPONG
                });
            }
        });
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
                exitToMenu();
        }
    }

    function closeMenu()
    {
        isClosing = true;
        canInteract = false;
        FlxG.sound.play(Paths.sound("unpause"));

        for (button in menuButtons) {
            FlxTween.tween(button, {x: button.x + MENU_ANIM_OFFSET * (button.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
        }
        
        for (text in menuTexts) {
            FlxTween.tween(text, {x: text.x + MENU_ANIM_OFFSET * (text.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
        }
        
        FlxTween.tween(selectionHighlight, {x: selectionHighlight.x + MENU_ANIM_OFFSET * (curSelected + 1)}, 0.2, {ease: FlxEase.quadOut});

        FlxTween.tween(topPanel, {x: -1000}, 0.2, {ease: FlxEase.quadOut});
        FlxTween.tween(bottomPanel, {x: 1280}, 0.2, {
            ease: FlxEase.quadOut, 
            onComplete: function(_) {
                close();
            }
        });

        FlxTween.tween(iconP1, {
            x: -1000,
            angle: 100
        }, 0.8, {ease: FlxEase.circOut});
        FlxTween.tween(timeBar, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
    }

    public static function restartSong()
    {
        switch(PlayState.SONG.song.toLowerCase()){
			case 'sunshine':
				MusicBeatState.getState().transOut = OvalTransitionSubstate;
			default:
                MusicBeatState.getState().transOut = SonicTransitionSubstate;
		}
        
        MusicBeatState.resetState();
        FlxG.sound.music.volume = 0;
    }

    function exitToMenu()
    {
        PlayState.deathCounter = 0;
        PlayState.seenCutscene = false;
        
        if (PlayState.isStoryMode) {
            MusicBeatState.switchState(new StoryMenuState());
        } else if (PlayState.isEncoreMode) {
            MusicBeatState.switchState(new EncoreState());
        } else {
            MusicBeatState.switchState(new FreeplayState());
        }
        
        FlxG.sound.playMusic(Paths.music('freakyMenu'));
        PlayState.instance.practiceMode = false;
        PlayState.changedDifficulty = false;
        PlayState.instance.cpuControlled = false;
    }

    override function destroy()
    {
        if(pauseMusic != null) {
            pauseMusic.stop();
            pauseMusic.destroy();
        }
        
        FlxTween.globalManager.clear();
        FlxTimer.globalManager.clear();
        
        super.destroy();
    }
}