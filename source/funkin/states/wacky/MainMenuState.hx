package funkin.states.wacky;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;

import funkin.data.WeekData;
import funkin.data.*;
import funkin.states.options.*;
import funkin.states.*;
import funkin.states.editors.MasterEditorMenu;

// stolen from MY engine.
class MainMenuState extends MusicBeatState {
    var loadedMenuItems:FlxTypedGroup<MainMenuItem>;
    var menuItems:Array<String> = [
        'Story',
        'Freeplay',
        'Credits',
        'Options'
        // 'Mods'
    ];

    var curSelected:Int;

    var itemSpacing:Float = 150;
    var itemSize:Float = 0.9;
    var yFactor:Float;
	var camFollow:FlxObject;
	var debugKeys:Array<FlxKey>;

	var wizzyStaff:FlxSprite;

    override function create() {
        funkin.utils.WindowUtil.setTitle();
        
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
        WeekData.reloadWeekFiles(true);

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Main Menu", null);
		#end
        
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
        
		persistentUpdate = persistentDraw = true;
		
		camFollow = new FlxObject(FlxG.width / 2, 0, 1, 1);
		add(camFollow);
		
		yFactor = Math.max(0.25 - (0.05 * (menuItems.length - 4)), 0.1);

        var bgGraphicPath:String = 'freeplay/bg';
        var menuBG:FlxSprite = new FlxSprite(-80, -600).loadGraphic(Paths.image(bgGraphicPath));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.2));
        menuBG.scrollFactor.set(0, yFactor);
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
        // menuBG.color = 0xF5CF3B;
		add(menuBG);

		var itemBack:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/sideSonicBars'), Y);
		itemBack.antialiasing = ClientPrefs.globalAntialiasing;
        itemBack.velocity.set(0, 100);
        itemBack.scrollFactor.set(0, 0);
		itemBack.updateHitbox();
        itemBack.rotation = -10;
        itemBack.x = -40;
		add(itemBack);

		var wizzy:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/wizzin'));
		wizzy.antialiasing = ClientPrefs.globalAntialiasing;
        wizzy.scrollFactor.set(0, 0);
		wizzy.updateHitbox();
		wizzy.x = FlxG.width - wizzy.width;
		wizzy.y = FlxG.height - wizzy.height;
		add(wizzy);

		wizzyStaff = new FlxSprite().loadGraphic(Paths.image('mainmenu/wand'));
		wizzyStaff.setGraphicSize(Std.int(wizzyStaff.width * 0.9));
		wizzyStaff.antialiasing = ClientPrefs.globalAntialiasing;
        wizzyStaff.scrollFactor.set(0, 0);
		wizzyStaff.updateHitbox();
		wizzyStaff.x = FlxG.width - wizzyStaff.width - 20;
		wizzyStaff.y = FlxG.height + wizzyStaff.height;
		add(wizzyStaff);

        loadedMenuItems = new FlxTypedGroup<MainMenuItem>();
        add(loadedMenuItems);

		var ver = "Nightmare Vision Engine\n" + 'Psych Engine v' + Main.PSYCH_VERSION + "\nFriday Night Funkin' v" + Main.FUNKIN_VERSION;
		var verionDesc:FlxText = new FlxText(12, FlxG.height - 44, 0, ver, 16);
		verionDesc.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		verionDesc.y = FlxG.height - verionDesc.height - 12;
		verionDesc.scrollFactor.set();
		add(verionDesc);

        for (i in 0...menuItems.length) {
            addMenuItem(menuItems[i]);
        }
			
		FlxG.camera.follow(camFollow, null, 0.15);

        for (item in loadedMenuItems) {
            item.y = 30 + itemSpacing*item.ID;
            item.acceptMenu = () -> {
                switch item.realName {
                    case 'story':
                        selectWeek();
                    case 'freeplay':
                        FlxG.switchState(funkin.states.wacky.FreeplayState.new);
                    case 'credits':
                        FlxG.switchState(CreditsState.new);
                    case 'options':
                        FlxG.switchState(funkin.states.options.OptionsState.new);
                        OptionsState.onPlayState = false;
                    default:
                        trace('"acceptMenu" pointer function isnt set!');
                }
            }
        }

        changeSelection(0, false);

        super.create();
    }

	var selectedSomethin:Bool = false;
    override function update(elapsed:Float) {
		@:privateAccess
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var selectedObj = loadedMenuItems.members[curSelected];
        
        var properXPos:Float = switch (curSelected) {
            case 0: 80;
            case 1: -60;
            default: 0;
        }

        // hate
        var properYPos:Float = switch (curSelected) {
            case 0: 0;
            case 1: 30;
            case 2: 60;
            case 3: 95;
            default: 0;
        }

		var scaledX = FlxMath.remapToRange((FlxG.width - wizzyStaff.width - 170) - properXPos, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.20, elapsed);
        wizzyStaff.x = FlxMath.lerp(wizzyStaff.x, scaledX, lerpRate);

		var scaledY = FlxMath.remapToRange((30 + itemSpacing*selectedObj.ID) - properYPos, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.20, elapsed);
        wizzyStaff.y = FlxMath.lerp(wizzyStaff.y, scaledY, lerpRate);

        if (controls.UI_UP_P || controls.UI_DOWN_P) {
			changeSelection(controls.UI_UP_P ? -1 : 1);
		}
				
        if (controls.BACK) {
            selectedSomethin = true;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(TitleState.new);
        }

        if (controls.ACCEPT) {
            if (!selectedSomethin) {
                FlxG.sound.play(Paths.sound('confirmMenu'));

                FlxFlicker.flicker(selectedObj, 1.5, 0.06, false, false, (s) -> {
                    selectedObj.acceptMenu();
                });

                loadedMenuItems.forEachAlive(s -> if (s != selectedObj) FlxTween.tween(s, {alpha: 0}, 0.4, {ease: FlxEase.quadOut}));
            }
        }	
        #if desktop
        else if (FlxG.keys.anyJustPressed(debugKeys))
        {
            selectedSomethin = true;
            FlxG.switchState(MasterEditorMenu.new);
        }
        #end

        super.update(elapsed);
    }

    function selectWeek() {
        var songArray:Array<String> = [];
        var weekToPlay:WeekData = WeekData.weeksLoaded.get('wizz');
        for (i in 0...weekToPlay.songs.length) {
            songArray.push(weekToPlay.songs[i][0]);
        }
        
        PlayState.storyPlaylist = songArray;
        PlayState.isStoryMode = true;
        PlayState.storyDifficulty = 0;
        
        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        CoolUtil.loadAndSwitchState(PlayState.new, true);
        FreeplayState.destroyFreeplayVocals();
    }

    var id:Int = 0;
    function addMenuItem(name:String) {
        var item:MainMenuItem;
        item = new MainMenuItem(0, 0, name.toLowerCase());
        item.setGraphicSize(Std.int(item.width*itemSize));
		var scr:Float = (menuItems.length - 4) * 0.135;
		if (menuItems.length < 6) scr = 0;
        item.scrollFactor.set(0, scr);
        item.x = 30;
        item.ID = id;

        loadedMenuItems.add(item);
        id++;
    }

    function changeSelection(change:Int = 0, playSound:Bool = true) {
        if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		final add:Float = menuItems.length > 4 ? menuItems.length * 8 : 0;
		for (item in loadedMenuItems.members) {
			if (item.ID == curSelected) {
                item.animation.play('selected');
                item.centerOffsets();
				camFollow.y = item.getGraphicMidpoint().y - add;
            } else {
                item.animation.play('idle');
                item.centerOffsets();
            }
        }
    }
}

class MainMenuItem extends FlxSprite {
    public var acceptMenu:Void->Void = null;
    // public var targetY:Float = 0;
    public var imageName:String;
    public var realName:String;

    public function new(x:Float, y:Float, name:String) {
        super(x, y);
        realName = name;
        imageName = StringTools.replace(name, ' ', '_');
        // frames = Paths.getSparrowAtlas('mainmenu/' + imageName + '_menu');
		frames = Paths.getSparrowAtlas('mainmenu/opts'); // temporary

        antialiasing = ClientPrefs.globalAntialiasing;

        animation.addByPrefix('idle', realName + '0', 24);
        animation.addByPrefix('selected', realName + '_hover', 24);
        animation.play('idle');
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        // y = FlxMath.lerp((targetY * 160) + 240, y, Math.exp(-elapsed * 10.2));
        // screenCenter(X);
    }
}