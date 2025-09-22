package funkin.states.wacky;

import haxe.Json;
import openfl.utils.Assets;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;

import flixel.addons.ui.U;

import funkin.states.editors.ChartingState;
import funkin.objects.SongLogo;
import funkin.data.WeekData;
import funkin.data.SongMetadata;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.data.*;
import funkin.objects.*;

typedef RenderData = {
    var offset:Array<Float>;
    var scale:Float;
    var antialiasing:Bool;
}

class FreeplayState extends MusicBeatState {
	public static var curSelected:Int = 0;

	public var debugBG:FlxSprite;
	public var debugTxt:FlxText;

    public var bg:FlxSprite;
    public var songBG:FlxSprite;
    public var gradient:FlxSprite;
    public var divider:FlxSprite;

    public var renderData:RenderData;
    public var charRender:FlxSprite;

    public var barUp:FlxBackdrop;
    public var barDown:FlxBackdrop;
    
	public var scoreTxt:FlxText;
	public var helpTxt:FlxText;
	public var lerpScore:Int = 0;
	public var lerpRating:Float = 0;
	public var intendedScore:Int = 0;
	public var intendedRating:Float = 0;

	public var grpSongs:FlxTypedGroup<SongLogo>;
	public var songs:Array<SongMetadata> = [];
    
	public var intendedColor:Int;

    public var charRenderX:Float = 0;
    public var charRenderHeight:Float = 0;

    override function create() {
        funkin.utils.WindowUtil.setTitle();
        
		FunkinAssets.cache.clearStoredMemory();
		FunkinAssets.cache.clearUnusedMemory();
		
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

        barDown = new FlxBackdrop(Paths.image('freeplay/sonicbars'), X);
		barDown.antialiasing = ClientPrefs.globalAntialiasing;
        barDown.velocity.set(100, 0);
		barDown.updateHitbox();
		barDown.screenCenter(X);
        barDown.y = FlxG.height - barDown.height + 110;
        barDown.rotation = -10;
        add(barDown);

        barUp = new FlxBackdrop(Paths.image('freeplay/sonicbars'), X);
		barUp.antialiasing = ClientPrefs.globalAntialiasing;
        barUp.velocity.set(-100, 0);
		barUp.updateHitbox();
		barUp.screenCenter(X);
        barUp.y = -110;
        barUp.flipY = true;
        barUp.rotation = -10;
        add(barUp);

        helpTxt = new FlxText(0, 0, FlxG.width - 3, "Press SPACE to listen to the instrumental / Press RESET to Reset your Score and Accuracy.", 14);
		helpTxt.setFormat(Paths.font("comic/italic.ttf"), 14, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
        helpTxt.y = FlxG.height - helpTxt.height - 3;
        add(helpTxt);

        scoreTxt = new FlxText(0, 0, FlxG.width - 3, "HIGH SCORE: 000000", 28);
		scoreTxt.setFormat(Paths.font("comic/bolditalic.ttf"), 28, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
        scoreTxt.y = helpTxt.y - scoreTxt.height - 3;
        add(scoreTxt);

        songBG = new FlxSprite().loadGraphic(Paths.image('freeplay/backgrounds/placeholder'));
        songBG.antialiasing = ClientPrefs.globalAntialiasing;
        songBG.angle = -10;
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
        divider.setGraphicSize(0, Std.int(songBG.height * 1.15));
        divider.updateHitbox();
        divider.antialiasing = ClientPrefs.globalAntialiasing;
        divider.angle = songBG.angle;
        divider.x = songBG.x - 70;
        divider.x += songBG.width;
        divider.y = songBG.y + 20;
        add(divider);

        charRenderX = songBG.x + 340;
        charRenderHeight = Std.int(songBG.height * 0.85);
        charRender = new FlxSprite().loadGraphic(Paths.image('freeplay/renders/placeholder'));
        charRender.setGraphicSize(0, Std.int(songBG.height * 0.85));
        charRender.updateHitbox();
        charRender.antialiasing = ClientPrefs.globalAntialiasing;
        charRender.angle = songBG.angle - 3;
        charRender.x = charRenderX - charRender.width/2;
        charRender.y = songBG.y - 20;
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
		FlxTween.tween(charRender, {y: charRender.y + 10}, 2.5, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(charRender, {angle: charRender.angle + 6}, 5, {ease: FlxEase.quadInOut, type: PINGPONG});
			
        if (curSelected >= songs.length) curSelected = 0;
        gradient.color = songs[curSelected].color;
        intendedColor = gradient.color;

        changeSelection(0, false);

        super.create();
    }

	var instPlaying:Int = -1;
	var holdTime:Float = 0;
    override function update(elapsed:Float) {
        lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
        lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));
			
        if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
        if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;
			
        var ratingSplit:Array<String> = Std.string(funkin.utils.MathUtil.floorDecimal(lerpRating * 100, 2)).split('.');
        if (ratingSplit.length < 2)
        { // No decimals, add an empty space
            ratingSplit.push('');
        }
        
        while (ratingSplit[1].length < 2)
        { // Less than 2 decimals in it, add decimals then
            ratingSplit[1] += '0';
        }
        
        scoreTxt.text = 'HIGH SCORE: ' + U.padDigits(lerpScore, 6) + ' (' + ratingSplit.join('.') + '%)';

        if (controls.BACK) {
            persistentUpdate = false;
            FlxTween.cancelTweensOf(gradient, ['color']);
            
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(funkin.states.wacky.MainMenuState.new);
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

        if (FlxG.keys.justPressed.CONTROL)
        {
            persistentUpdate = false;
            openSubState(new GameplayChangersSubstate());
        }
        else if (FlxG.keys.justPressed.SPACE)
        {
            if (instPlaying != curSelected)
            {
                FlxG.sound.music.volume = 0;
                Mods.currentModDirectory = songs[curSelected].folder;
                var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), 0);
                PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
                
                FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
                instPlaying = curSelected;
            }
        }
        else if (controls.ACCEPT)
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
        else if (controls.RESET)
        {
            persistentUpdate = false;
            openSubState(new ResetScoreSubState(songs[curSelected].songName, 0, songs[curSelected].songCharacter));
            FlxG.sound.play(Paths.sound('scrollMenu'));
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

        #if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, 0);
		intendedRating = Highscore.getRating(songs[curSelected].songName, 0);
		trace(intendedScore);
        #end
        
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

        var charPath = 'freeplay/renders/' + songs[curSelected].songCharacter.replace(' ', '-');
        var graphic2 = Paths.image(charPath);
        charRender.loadGraphic(graphic2 ?? Paths.image('freeplay/renders/placeholder'));

        if (Paths.fileExists('images/$charPath.json', TEXT)) {
            renderData = Json.parse(Paths.getTextFromFile('images/$charPath.json'));
            charRender.offset.set(renderData.offset[0] ?? 0, renderData.offset[1] ?? 0);
            charRender.setGraphicSize(0, Std.int(charRenderHeight * (renderData.scale ?? 1)));
            charRender.antialiasing = renderData.antialiasing ?? ClientPrefs.globalAntialiasing;
            trace(renderData);
        } else {
            charRender.offset.set(0, 0);
            charRender.setGraphicSize(0, Std.int(charRenderHeight));
            charRender.antialiasing = ClientPrefs.globalAntialiasing;
            trace('dont');
        }

        if (FlxG.random.bool(0.05)) {
            charRender.loadGraphic(Paths.image('freeplay/renders/jason'));
        }

        charRender.x = charRenderX - charRender.width/2 - 30;
        FlxTween.cancelTweensOf(charRender, ['x']);
		FlxTween.tween(charRender, {x: charRenderX - charRender.width/2}, 0.5, {ease: FlxEase.circOut});
        
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