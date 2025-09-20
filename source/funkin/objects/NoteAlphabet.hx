package funkin.objects;

import haxe.Json;
import openfl.utils.Assets;

import flixel.group.FlxSpriteGroup;

import funkin.game.shaders.RGBPalette;
import funkin.game.shaders.RGBPalette.RGBShaderReference;

typedef NoteFont = {
    var image:String;
    var animations:Array<String>;
    var useRgbShader:Bool;
}

class NoteAlphabet extends FlxSpriteGroup {
    var lastSprite:AlphaChar = null;

    public var spaces:Int = 0;
    public var textToType:String;
	var splitWords:Array<String> = [];

    public var textSize:Float = 1;

    public var delay:Float = 0.04;

    var _typing:Bool;
    var _finalText:String;

    var backLayer:FlxSpriteGroup;
    var frontLayer:FlxSpriteGroup;

    public function new(x:Float, y:Float, ?textSize:Float) {
        super(x, y);
        this.textSize = textSize;

        backLayer = new FlxSpriteGroup();
        frontLayer = new FlxSpriteGroup();

        add(backLayer);
        add(frontLayer);
    }

    public function changeText(text:String) {
        // clearText();

        spaces = 0;
        textToType = text;
        splitWords = textToType.split("");
        
		// for (character in splitWords) if (character == ' ') spaces++;
    }

	function doSplitWords() {
		splitWords = _finalText.split("");
	}

    public function quickReplace(text:String) {
        if (typeTimer.active) typeTimer.cancel();

        clearText();
        changeText(text);
		_finalText = textToType;
		doSplitWords();

        trace('quick replace: $text');

        for (i in 0...splitWords.length) {
            switch (splitWords[i]) {
                case ' ':
                    spaces++;
                case '←':
                    addNote(0);
                case '↓':
                    addNote(1);
                case '↑':
                    addNote(2);
                case '→':
                    addNote(3);
                case '—':
                    if (splitWords[i + 1] == '—')
                        addNote(lastSprite != null && lastSprite.isNote ? lastSprite.noteData : 0, true);
                    else
                        addNote(lastSprite != null && lastSprite.isNote ? lastSprite.noteData : 0, true, true);
                default:
                    addSymbol(splitWords[i]);
            }
        }
    }

    // borrowed from cne again, sorry cne devs gulp
    var typeTimer:FlxTimer = new FlxTimer();
	public function startTypedText(speed:Float) {
		_finalText = textToType;
		doSplitWords();
        delay = speed;

		var loopNum:Int = 0;

		typeTimer.start(delay, function(tmr:FlxTimer) {
            switch (splitWords[loopNum]) {
                case ' ':
                    spaces++;
                case '←':
                    addNote(0);
                case '↓':
                    addNote(1);
                case '↑':
                    addNote(2);
                case '→':
                    addNote(3);
                case '—':
                    if (splitWords[loopNum + 1] == '—')
                        addNote(lastSprite != null && lastSprite.isNote ? lastSprite.noteData : 0, true);
                    else
                        addNote(lastSprite != null && lastSprite.isNote ? lastSprite.noteData : 0, true, true);
                default:
                    addSymbol(splitWords[loopNum]);
            }

			loopNum += 1;
			tmr.time = delay;
		}, splitWords.length);
	}

    public function clearText() {
        lastSprite = null;
        backLayer.clear();
        frontLayer.clear();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function addNote(data:Int, sustain:Bool = false, ?sustainEnd:Bool = false) {
        var newNote:AlphaChar = new AlphaChar(true);
        // if (lastSprite.noteData > -1 && sustain && lastSprite != null) data = lastSprite.noteData;
        newNote.createNote(data, sustain, sustainEnd);
        if (sustain) backLayer.add(newNote);
        else frontLayer.add(newNote);

        var fixedSize:Int = Std.int(newNote.width * textSize);
		newNote.setGraphicSize(fixedSize, fixedSize);
        newNote.updateHitbox();

        if (sustain) newNote.scale.set(0.5, 0.7);

        newNote.x = x;
        newNote.x += (lastSprite != null ? lastSprite.x + lastSprite.width - newNote.width / 2 - 15 : 0);
        
        if (sustain) {
            newNote.x -= 60;
            // newNote.y += fixedSize/2;
        }

        if (spaces > 0) {
            newNote.x += 50 * spaces * textSize;
            spaces = 0;
        }

        lastSprite = newNote;
    }

    public function addSymbol(symbol:String) {
        var newSymbol:AlphaChar = new AlphaChar(false);
        newSymbol.createSymbol(symbol);
        frontLayer.add(newSymbol);

		newSymbol.setGraphicSize(Std.int(newSymbol.width * textSize));
        newSymbol.updateHitbox();

        newSymbol.x = x;
        newSymbol.x += (lastSprite != null ? lastSprite.x + lastSprite.width - newSymbol.width / 2 - 50: 0);

        if (spaces > 0) {
            newSymbol.x += 50 * spaces * textSize;
            spaces = 0;
        }

        lastSprite = newSymbol;
    }
}

class AlphaChar extends FlxSprite {
    public var isNote:Bool = false;

    public var noteData:Int = -1;
    public var isSustain:Bool = false;

    public static var noteFont:NoteFont = null;

    public var useRgbShader:Bool = true;

    public function new(isNote:Bool) {
        super();

        this.isNote = isNote;

        if (isNote) {
            frames = Paths.getSparrowAtlas(noteFont.image ?? 'note/NOTE_assets');
            useRgbShader = noteFont.useRgbShader ?? true;
        } else {
            frames = Paths.getSparrowAtlas('alphabet');
        }

        antialiasing = ClientPrefs.globalAntialiasing;
    }

    public static function changeFont(font:String) {
        if (Paths.fileExists('data/dialogue/noteFonts/$font.json', TEXT)) {
            noteFont = Json.parse(Paths.getTextFromFile('data/dialogue/noteFonts/$font.json'));
            trace(noteFont);
        } else {
            trace('Cant find $font!');
        }
    }

    public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '#':
				animation.addByPrefix(letter, 'hashtag', 24);
			case '.':
				animation.addByPrefix(letter, 'period', 24);
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				y -= 50;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
			default:
				animation.addByPrefix(letter, letter, 24);
		}
		animation.play(letter);
		
		updateHitbox();
		
		y = (110 - height);
		switch (letter)
		{
			case "'":
				y -= 20;
			case '-':
				// x -= 35 - (90 * (1.0 - textSize));
				y -= 16;
            case '.':
                y -= 25;
            case ':':
                y -= 15;
		}
	}
    
    var rgbShader:RGBShaderReference;
	public function createNote(data:Int, sustain:Bool, ?sustainEnd:Bool) {
        if (!sustain) {
            animation.addByPrefix('left', noteFont.animations[0] ?? 'purple0', 24, false);
            animation.addByPrefix('down', noteFont.animations[1] ?? 'blue0', 24, false);
            animation.addByPrefix('up', noteFont.animations[2] ?? 'green0', 24, false);
            animation.addByPrefix('right', noteFont.animations[3] ?? 'red0', 24, false);
        } else {
            animation.addByPrefix('hold', noteFont.animations[4] ?? 'purple hold piece', 24, false);
            animation.addByPrefix('holdend', noteFont.animations[5] ?? 'pruple end hold', 24, false);
            angle = 270;
        }

        var animToPlay:String = switch(data) {
            case 0: 'left';
            case 1: 'down';
            case 2: 'up';
            case 3: 'right';
            default: 'left';
        }

		if (!sustain) {
			animation.play(animToPlay);
		} else { // this only supports two hold notes but tbh nobody is putting more than 2 so
            if (sustainEnd) animation.play('holdend');
            else animation.play('hold');
		}

        noteData = data;
		// trace(data);

        var arr:Array<FlxColor> = ClientPrefs.arrowRGB[data];
		var newRGB:RGBPalette = new RGBPalette();
        newRGB.r = arr[0];
        newRGB.g = arr[1];
        newRGB.b = arr[2];
        rgbShader = new RGBShaderReference(this, newRGB);
        rgbShader.enabled = useRgbShader;

        y += 10;
	}
}