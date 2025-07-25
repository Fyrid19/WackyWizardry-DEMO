package funkin.states.wacky;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;

import funkin.states.editors.ChartingState;
import funkin.objects.SongLogo;
import funkin.data.WeekData;
import funkin.data.SongMetadata;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.data.*;
import funkin.objects.*;

class FreeplayState extends MusicBeatState {
	public static var curSelected:Int = 0;

	public var debugBG:FlxSprite;
	public var debugTxt:FlxText;

    public var bg:FlxSprite;
    public var songBG:FlxSprite;
    public var gradient:FlxSprite;
    public var divider:FlxSprite;
    public var charRender:FlxSprite;

	public var grpSongs:FlxTypedGroup<SongLogo>;
	public var songs:Array<SongMetadata> = [];
    
	public var intendedColor:Int;

    public var charRenderY:Int = 0;

    override function create() {
		FunkinAssets.cache.clearStoredMemory();
		// FunkinAssets.cache.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

        for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i])) continue;
			
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}
			
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

        bg = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);
        bg.screenCenter();
        
        grpSongs = new FlxTypedGroup<SongLogo>();
        add(grpSongs);
        
        for (i in 0...songs.length) {
            var item:SongLogo = new SongLogo(0, 0, songs[i].songName.replace(' ', '-'));
            item.updateHitbox();
            item.centerOffsets();
			item.targetY = i;
            grpSongs.add(item);
			
            Mods.currentModDirectory = songs[i].folder;
        }

        songBG = new FlxSprite().loadGraphic(Paths.image('freeplay/backgrounds/placeholder'));
        songBG.antialiasing = ClientPrefs.globalAntialiasing;
        songBG.angle = -20;
        songBG.x = -100;
        songBG.y = -50;
        songBG.setGraphicSize(Std.int(songBG.width * 1.35));
        songBG.updateHitbox();
        add(songBG);

        gradient = FlxGradient.createGradientFlxSprite(Std.int(songBG.width), Std.int(songBG.height), [FlxColor.WHITE, FlxColor.TRANSPARENT], 1, 180);
        gradient.angle = songBG.angle;
        gradient.x = songBG.x;
        gradient.y = songBG.y;
        add(gradient);

        divider = new FlxSprite().loadGraphic(Paths.image('freeplay/divider'));
        divider.antialiasing = ClientPrefs.globalAntialiasing;
        divider.setGraphicSize(0, Std.int(songBG.height * 1.15));
        divider.angle = songBG.angle;
        divider.x = songBG.x - 30;
        divider.x += songBG.width;
        divider.y = songBG.y + 250;
        add(divider);

        charRender = new FlxSprite().loadGraphic(Paths.image('freeplay/renders/placeholder'));
        charRender.antialiasing = ClientPrefs.globalAntialiasing;
        charRender.angle = songBG.angle;
        charRender.x = songBG.x;
        charRender.y = songBG.y;
        add(charRender);
			
        debugBG = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        debugBG.alpha = 0;
        add(debugBG);
        
        debugTxt = new FlxText(50, 0, FlxG.width - 100, '', 36);
        debugTxt.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        debugTxt.screenCenter(Y);
        add(debugTxt);
        
		FlxTween.tween(songBG, {y: songBG.y + 20}, 5, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(gradient, {y: gradient.y + 20}, 5, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(songBG, {x: songBG.x - 10}, 5.5, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(gradient, {x: gradient.x - 10}, 5.5, {ease: FlxEase.quadInOut, type: PINGPONG});
			
        if (curSelected >= songs.length) curSelected = 0;
        gradient.color = songs[curSelected].color;
        intendedColor = gradient.color;

        changeSelection(0, false);

        super.create();
    }

	var holdTime:Float = 0;
    override function update(elapsed:Float) {
        if (controls.BACK) {
            persistentUpdate = false;
            FlxTween.cancelTweensOf(gradient, ['color']);
            
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(MainMenuState.new);
        }
			
        var shiftMult:Int = 1;
        if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

        if (songs.length > 1)
        {
            if (controls.UI_UP_P)
            {
                changeSelection(-shiftMult);
                holdTime = 0;
            }
            if (controls.UI_DOWN_P)
            {
                changeSelection(shiftMult);
                holdTime = 0;
            }
            
            if (controls.UI_DOWN || controls.UI_UP)
            {
                var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                holdTime += elapsed;
                var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
                
                if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                {
                    changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                }
            }
        }

        if (controls.ACCEPT)
        {
            persistentUpdate = false;
            var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
            var poop:String = Highscore.formatSong(songLowercase, 0);
            
            try
            {
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;
            }
            catch (e)
            {
                final message = 'Failed to load song: [$poop]\ndoes the chart exist?';
                debugBG.alpha = 0.7;
                debugTxt.text = message;
                debugTxt.screenCenter(Y);
                
                FlxG.sound.play(Paths.sound('cancelMenu'));
                
                super.update(FlxG.elapsed);
                return;
            }
            
            trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
            
            FlxTween.cancelTweensOf(bg, ['color']);
            
            if (FlxG.keys.pressed.SHIFT)
            {
                CoolUtil.loadAndSwitchState(ChartingState.new);
            }
            else
            {
                CoolUtil.loadAndSwitchState(PlayState.new);
            }
            
            FlxG.sound.music.volume = 0;
        }

		var scaledY = FlxMath.remapToRange(-curSelected, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.12, elapsed);
        bg.y = FlxMath.lerp(bg.y, (scaledY * 30) - 400, lerpRate);

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0, playSound:Bool = true) {
        debugBG.alpha = 0;
        debugTxt.text = '';
        
        if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        
        var newColor:Int = songs[curSelected].color;
        if (newColor != intendedColor)
        {
            FlxTween.cancelTweensOf(gradient, ['color']);
            intendedColor = newColor;
            FlxTween.color(gradient, 0.75, gradient.color, intendedColor);
        }
    
        var bullShit:Int = 0;
			
        for (item in grpSongs.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;
            
            item.alpha = 0.6;
            
            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }

        var graphic = Paths.image('freeplay/backgrounds/' + songs[curSelected].songName.replace(' ', '-'));
        songBG.loadGraphic(graphic ?? Paths.image('freeplay/backgrounds/placeholder'));

        var graphic2 = Paths.image('freeplay/renders/' + songs[curSelected].songCharacter.replace(' ', '-'));
        charRender.loadGraphic(graphic2 ?? Paths.image('freeplay/renders/placeholder'));
        
        Mods.currentModDirectory = songs[curSelected].folder;
        PlayState.storyWeek = songs[curSelected].week;
    }

    public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
    
	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}
}