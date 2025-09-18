package funkin.states.wacky;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.states.options.*;
import funkin.states.*;

// stolen from MY engine.
class MainMenuState extends MusicBeatState { // i hate how main menu is coded so why not do it myself
    var loadedMenuItems:FlxTypedGroup<MainMenuItem>;
    var menuItems:Array<String> = [
        'Story',
        'Freeplay',
        'Credits',
        'Options'
        // 'Mods'
    ];

    var curSelected:Int;

    var itemSize:Float = 0.9;
    var yFactor:Float;
	var camFollow:FlxObject;

	var wizzyStaff:FlxSprite;

    override function create() {
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Main Menu", null);
		#end
		
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

		var itemBack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/sonicbar'));
		itemBack.antialiasing = ClientPrefs.globalAntialiasing;
        itemBack.scrollFactor.set(0, 0);
		itemBack.updateHitbox();
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
		wizzyStaff.y = -wizzyStaff.height - 100;
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

        var itemSpacing:Float = 150;
        for (item in loadedMenuItems) {
            item.y = 30 + itemSpacing*item.ID;
            switch item.realName {
                case 'story':
                    item.acceptMenu = () -> {
                        FlxG.switchState(StoryMenuState.new);
                    }
                case 'freeplay':
                    item.acceptMenu = () -> {
						FlxG.switchState(funkin.states.wacky.FreeplayState.new);
                    }
				case 'credits':
					item.acceptMenu = () -> {
						FlxG.switchState(CreditsState.new);
					}
                case 'options':
                    item.acceptMenu = () -> {
						FlxG.switchState(funkin.states.options.OptionsState.new);
						OptionsState.onPlayState = false;
                    }
                default:
                    item.acceptMenu = () -> {
                        trace('"acceptMenu" pointer function isnt set!');
                    }
            }
        }

        changeSelection(0, false);

        super.create();
    }

    override function update(elapsed:Float) {
		var selectedObj = loadedMenuItems.members[curSelected];
		var scaledY = FlxMath.remapToRange(selectedObj.y, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.20, elapsed);
        wizzyStaff.y = FlxMath.lerp(wizzyStaff.y, scaledY, lerpRate);

        if (controls.UI_UP_P || controls.UI_DOWN_P) {
			changeSelection(controls.UI_UP_P ? -1 : 1);
		}

        if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(selectedObj, 1, 0.06, false, false, (s) -> {
            	selectedObj.acceptMenu();
			});

			loadedMenuItems.forEachAlive(s -> if (s != selectedObj) FlxTween.tween(s, {alpha: 0}, 0.4, {ease: FlxEase.quadOut}));
        }

        super.update(elapsed);
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