package funkin.objects.dialogue;

import haxe.Json;
import openfl.utils.Assets;

import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal;

import funkin.objects.NoteAlphabet.AlphaChar;

using flixel.util.FlxSpriteUtil;

typedef DialogueCharInfo = {
    var name:String;
    var emotion:String;
    var position:String;
}

typedef DialogueFile = {
    // var dialogueBox:String;
    var music:String;
    var bg:String;
    var font:String;
    var dialogue:Array<DialogueLine>;
}

typedef DialogueLine = {
    var speed:Float;
    var character:String;
    var position:String;
    var emotion:String;
    var boxEmotion:String;
    var namePlate:String;
    var line:String;
    var useNotes:Bool;
    var ?font:String;
    var ?noteFont:String;
    var ?removeChar:String;
}

class DialogueData {
    static var fallback:DialogueFile = {
        music:  'freakyMenu',
        bg:  'menuBG',
        font:  'comic',
        dialogue:  [
            {
                speed: 0.08,
                character: 'dave',
                position: 'right',
                emotion: 'neutral',
                boxEmotion: 'regular',
                namePlate: 'bf',
                line: '←—— ↓——. ↑—— →——!',
                useNotes: false,
                font: null,
                noteFont: null,
                removeChar: null
            },
            {
                speed: 0.04,
                character: 'dave',
                position: 'left',
                emotion: 'neutral',
                boxEmotion: 'regular',
                namePlate: 'dave',
                line: 'old mccdownlad',
                useNotes: false,
                font: null,
                noteFont: null,
                removeChar: null
            }
        ]
    };

    public static function getDefaultData():DialogueFile return fallback;
    
    public static function parse(path:String):DialogueFile {
		#if MODS_ALLOWED
		if (FileSystem.exists(path)) {
			return cast Json.parse(File.getContent(path));
		}
		#end
		return cast Json.parse(Assets.getText(path));
	}
}

@:access(flixel.addons.text.FlxTypeText)
class DialogueBox extends FlxSpriteGroup {
    var _file:DialogueFile = null;
    var _baseY:Float = 0;

    // VARIABLES
    public var progress:Int = 0;
    public var curIndex:Int = 0;
    public var lineSpeed:Float = 0.04;
    public var bgPath:String = '';
    
    public var dialogueStarting:Bool = true;
    public var dialogueEnded:Bool = false;

    // used mainly for skipping dialogue stuff
    var useNotes:Bool = false;
    var lineString:String = ''; 

    var defaultFont = Paths.font('comic/normal.ttf');

    // SPRITES
    var box:FlxSprite;
    var background:FlxSprite;
    var nextIndicator:FlxSprite;
    var namePlate:FlxSprite;
    var textBox:FlxTypeText;
    var textBoxNote:NoteAlphabet;
    var charGroup:FlxSpriteGroup;
    var activeCharGroup:FlxSpriteGroup;
    var charMap:Map<String, DialogueCharacter> = new Map();
    var focusedChar:DialogueCharacter;
    var oldFocusedChar:DialogueCharacter;

    // DEBUG
    var progressTxt:FlxText;

    // CALLBACKS
    public var completeLineCallback:Void->Void;
    public var nextLineCallback:Void->Void;
    public var skipLineCallback:Void->Void;

    public var startDialogueCallback:Void->Void;
    public var skipDialogueCallback:Void->Void;
    public var finishDialogueCallback:Void->Void;

    // SIGNALS (unused for now)
    public static var onCompleteLine:FlxSignal = new FlxSignal();
    public static var onNextLine:FlxSignal = new FlxSignal();
    public static var onSkipLine:FlxSignal = new FlxSignal();

    public static var onStartDialogue:FlxSignal = new FlxSignal();
    public static var onFinishDialogue:FlxSignal = new FlxSignal();

    // KEYS
    public var skipKeys:Array<FlxKey> = [FlxKey.ESCAPE];
    public var progressKeys:Array<FlxKey> = [FlxKey.ENTER, FlxKey.SPACE];

    public function new(?dialogue:DialogueFile) {
        super();

        _file = dialogue ?? DialogueData.getDefaultData();

        bgPath = _file.bg ?? '';

        charGroup = new FlxSpriteGroup();
        add(charGroup);

        activeCharGroup = new FlxSpriteGroup();
        add(activeCharGroup);

        box = new FlxSprite(x, y);
        box.frames = Paths.getSparrowAtlas('dialogue/boxes/default');
        box.animation.addByPrefix('regular', 'regular_box', 24, true);
        box.animation.addByPrefix('intense', 'intense_box', 24, true);
        box.animation.addByPrefix('think', 'think_box', 24, true);
        box.animation.play('regular', true);
        box.antialiasing = ClientPrefs.globalAntialiasing;
        add(box);

        textBox = new FlxTypeText(x + 70, y + 160, FlxG.width - 100, '', 24);
        textBox.setFormat(defaultFont, 24, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        add(textBox);

        textBoxNote = new NoteAlphabet(x + 60, y + 140, 0.5);
        add(textBoxNote);

        namePlate = new FlxSprite();
        namePlate.antialiasing = ClientPrefs.globalAntialiasing;
        namePlate.visible = false;
        add(namePlate);

		// nextIndicator = new FlxSprite(); // fucking spriteutil is crashing everything so thank u juli
        // nextIndicator.drawCircle(0, 0, 50, FlxColor.BLACK);
        // nextIndicator.x = box.width - nextIndicator.width - 10;
        // nextIndicator.y = box.height - nextIndicator.height - 10;
        // nextIndicator.visible = false;
		// add(nextIndicator);

        progressTxt = new FlxText(x, y, FlxG.width, '', 36);
        progressTxt.setFormat(defaultFont, 36, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        progressTxt.visible = false;
        add(progressTxt);

        y = _baseY = FlxG.height - box.height;
        // alpha = 0;
    }

    var oldLength:Int = 0;
    override function update(elapsed:Float) {
        var curLine:DialogueLine = getCurrentLineData();
        
        if (textBoxNote != null) textBoxNote.delay = textBox.delay;

        // var splitWords:Array<String> = curLine.line.split("");
        if (textBox.text.length > oldLength) {
            switch (textBox.text.charAt(oldLength)) {
                case '.' | '!' | '?' | ':':
                    textBox.delay = lineSpeed * 3;
                    if (focusedChar != null) focusedChar.talking = 0;
                case ',':
                    textBox.delay = lineSpeed * 2;
                    if (focusedChar != null) focusedChar.talking = 0;
                default:
                    textBox.delay = lineSpeed;
                    if (focusedChar != null) focusedChar.talking = 2;
                    if (textBox.text.charAt(oldLength) != ' ') // experimenting, could remove
                        focusedChar.speak();
            }
            
            oldLength = textBox.text.length;
            curIndex = oldLength;
        }

        if (textBox.text == textBox._finalText && focusedChar != null) focusedChar.talking = 0;

        nextIndicator.visible = textBox.text == textBox._finalText;

        if (!dialogueEnded && !dialogueStarting) {
            if (progressKeys != null && progressKeys.length > 0 && FlxG.keys.anyJustPressed(progressKeys)) {
                if (textBox.text == textBox._finalText) {
                    if (progress >= _file.dialogue.length) endDialogue();
                    else progressDialogue();
                } else {
                    skipLine();
                }
            }
            
            if (skipKeys != null && skipKeys.length > 0 && FlxG.keys.anyJustPressed(skipKeys)) {
                skipLine();
                endDialogue();
            }
        }
        
        super.update(elapsed);
    }

    public function addCharacter(charName:String, position:String = 'left', emotion:String = 'neutral') {
        if (!charMap.exists(charName)) {
            var newChar:DialogueCharacter = new DialogueCharacter(charName, position, emotion);
            newChar.loadCharAtlas();
            charMap.set(charName, newChar);
            charGroup.add(newChar);
            trace('new char "$charName"');
        } else {
            charMap.get(charName).changeEmotion(emotion);
            charMap.get(charName).switchPosition(position);
        }
    }

    public function removeCharacter(charName:String) {
        if (charMap.exists(charName)) {
            var char:DialogueCharacter = charMap.get(charName);
            if (!char.hasFocus) {
                char.exit(() -> {
                    charGroup.remove(char);
                });
            }
        }
    }

    public function typeText(text:String, speed:Float) {
        lineSpeed = speed;
        textBox.resetText(text);
        textBox.start(speed, true);
        oldLength = 0;
    }

    public function typeNoteText(text:String, speed:Float, ?font:String) {
        AlphaChar.changeFont(font ?? 'default');
        textBoxNote.changeText(text);
        textBoxNote.startTypedText(speed);
    }

    public function beginDialogue() {
        alpha = 0;
        y = _baseY + 50;
        progress = 0;
        namePlate.visible = false;

        dialogueEnded = false;
        dialogueStarting = true;

        FlxG.sound.playMusic(Paths.music(_file.music ?? 'freakyMenu'), 0);
		FlxG.sound.music.fadeIn();
        FlxG.sound.play(Paths.sound('dialogueContinue'));

        FlxTween.tween(this, {y: _baseY, alpha: 1}, 0.5, {ease: FlxEase.quadOut});

        new FlxTimer().start(0.5, (tmr:FlxTimer) -> {
            progressDialogue();
            namePlate.visible = true;
            dialogueStarting = false;
        });
    }

    function endDialogue() {
        dialogueEnded = true;
        FlxG.sound.play(Paths.sound('dialogueEnd'));
        FlxTween.tween(this, {y: _baseY + 50, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        FlxG.sound.music.fadeOut(0.5, 0);
        if (finishDialogueCallback != null) finishDialogueCallback();
    }

    function progressDialogue() {
        var curLine:DialogueLine = getCurrentLineData();
        trace(curLine.line + ' (speed: ${curLine.speed})');

        box.flipX = switch(curLine.position) {
            case 'right' | 'middleRight': false;
            case 'left' | 'middleLeft': true;
            default: false;
        }

        box.animation.play(curLine.boxEmotion ?? 'regular');

        namePlate.loadGraphic(Paths.image('dialogue/plates/' + curLine.namePlate + '_title'));
        namePlate.y = (box.y - namePlate.height/2) + 90;
        namePlate.x = box.flipX ? 80 : FlxG.width - namePlate.width - 80;

        if (curLine.removeChar != null) removeCharacter(curLine.removeChar);

        addCharacter(curLine.character, curLine.position, curLine.emotion);
        focusedChar = charMap.get(curLine.character) ?? null;
        
        for (char in charMap) {
            char.switchFocus(char.character == curLine.character);
        }

        if (oldFocusedChar != null) {
            activeCharGroup.remove(oldFocusedChar);
            charGroup.add(oldFocusedChar);
        }
        
        charGroup.remove(focusedChar);
        activeCharGroup.add(focusedChar);

        oldFocusedChar = focusedChar;

        textBox.visible = !curLine.useNotes;
        textBoxNote.clearText();

        textBox.font = curLine.font ?? defaultFont;

        var line:String = curLine.line ?? ' ';
        var speed:Float = curLine.speed ?? 0.04;
        typeText(line, speed);
        if (curLine.useNotes) typeNoteText(line, speed, curLine.noteFont);
        useNotes = curLine.useNotes;
        lineString = line;

        progress++;

        if (nextLineCallback != null) nextLineCallback();
    }

    function skipLine() {
        textBox.skip();
        if (useNotes) textBoxNote.quickReplace(lineString);
        if (skipLineCallback != null) skipLineCallback();
    }

    function getCurrentLineData():DialogueLine {
        var lineToReturn:DialogueLine = {
            speed: 0.04,
            character: 'bf',
            position: 'left',
            emotion: 'neutral',
            boxEmotion: 'regular',
            namePlate: 'bf',
            line: ' ',
            useNotes: false,
            font: null
        };

        if (_file != null)
        if (_file.dialogue != null)
        if (_file.dialogue[progress] != null)
        lineToReturn = _file.dialogue[progress];

        return lineToReturn;
    }
}