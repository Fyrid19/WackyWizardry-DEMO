package funkin.objects.dialogue;

import haxe.Json;
import openfl.utils.Assets;

import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTypeText;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.keyboard.FlxKey;

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
    var line:String;
    var ?font:String;
}

class DialogueBox extends FlxSpriteGroup {
    public var dialogueFile:DialogueFile = null;
    public var fallbackFile:DialogueFile = {
        music:  'freakyMenu',
        bg:  'menuBG',
        font:  'comic',
        dialogue:  [
            {
                speed: 0.04,
                character: 'bf',
                position: 'right',
                emotion: 'neutral',
                boxEmotion: 'regular',
                line: 'this is the default dialogue. hi ←↓↑→',
                font: null
            },
            {
                speed: 0.04,
                character: 'dave',
                position: 'left',
                emotion: 'neutral',
                boxEmotion: 'think',
                line: 'which means, there is no dialogue',
                font: null
            },
            {
                speed: 0.04,
                character: 'bf',
                position: 'middleRight',
                emotion: 'blissful',
                boxEmotion: 'intense',
                line: 'go get some dialogue! fool.',
                font: null
            }
        ]
    };

    var background:FlxSprite;
    var nextIndicator:FlxShapeCircle;
    var namePlate:FlxSprite;
    var textBox:FlxTypeText;
    var noteSymbols:FlxSpriteGroup;
    var charGroup:FlxSpriteGroup;
    var charMap:Map<String, DialogueCharacter> = new Map();
    var focusedChar:String;

    var defaultFont = Paths.font('comic/normal.ttf');

    public var lineSpeed:Float = 0.03;
    public var dialogueStarted:Bool = false;
    public var dialogueProgress:Int = 0;
    
    public var startY:Float;

    public var completeCallback:Void->Void;
    public var nextCallback:Void->Void;
    public var skipCallback:Void->Void;
    public var finishCallback:Void->Void;

    // keys
    public var skipKeys:Array<FlxKey> = [FlxKey.ESCAPE];
    public var progressKeys:Array<FlxKey> = [FlxKey.SPACE, FlxKey.ENTER];

    // debug stuff
    var progressTxt:FlxText;

    public function new(?dialogue:DialogueFile) {
        super();

        dialogueFile = dialogue ?? fallbackFile;

        charGroup = new FlxSpriteGroup();
        add(charGroup);

        background = new FlxSprite(x, y);
        background.frames = Paths.getSparrowAtlas('dialogue/boxes/default');
        background.animation.addByPrefix('regular', 'regular_box', 24, true);
        background.animation.addByPrefix('intense', 'intense_box', 24, true);
        background.animation.addByPrefix('think', 'think_box', 24, true);
        background.animation.play('regular', true);
        background.antialiasing = ClientPrefs.globalAntialiasing;
        add(background);

        textBox = new FlxTypeText(x + 40, y + 160, FlxG.width - 80, '', 24);
        textBox.setFormat(defaultFont, 24, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        add(textBox);

        namePlate = new FlxSprite();
        namePlate.antialiasing = ClientPrefs.globalAntialiasing;
        add(textBox);

        textBox.completeCallback = () -> { onComplete(); };

		// nextIndicator = new FlxShapeCircle(FlxG.width - 100, FlxG.height - 100, 40, null, FlxColor.BLACK);
        // nextIndicator.visible = false;
		// add(nextIndicator);

        progressTxt = new FlxText(x, y, FlxG.width, '', 36);
        progressTxt.setFormat(defaultFont, 36, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        add(progressTxt);

        y = startY = FlxG.height - background.height;
        alpha = 0;
    }

    var oldLength:Int = 0;
    override function update(elapsed:Float) {
        var curLine = dialogueFile.dialogue[dialogueProgress];
        var focusedChar:DialogueCharacter = charMap[curLine.character];
        if (textBox.text.length > oldLength) {
            switch (textBox.text.charAt(textBox.text.length - 1)) {
                case '.' | '!' | '?':
                    textBox.delay = lineSpeed * 10;
                    if (focusedChar != null) focusedChar.talking = 0;
                case ',':
                    textBox.delay = lineSpeed * 5;
                    if (focusedChar != null) focusedChar.talking = 0;
                default:
                    textBox.delay = lineSpeed;
            }

            if (focusedChar != null) {
                focusedChar.talking = 2;
                focusedChar.speak();
            }
            
            oldLength = textBox.text.length;
        }

        if (textBox.text.charAt(textBox.text.length - 1) == '←') trace('left');

        if (textBox.text == curLine.line) focusedChar.talking = 0;

        progressTxt.text = 'line: $dialogueProgress';

        if (skipKeys != null && skipKeys.length > 0 && FlxG.keys.anyJustPressed(skipKeys)) {
            textBox.skip();
            endDialogue(finishCallback);
        }

        if (progressKeys != null && progressKeys.length > 0 && FlxG.keys.anyJustPressed(progressKeys)) {
            if (textBox.text != curLine.line) {
                textBox.skip();
                if (skipCallback != null) skipCallback();
            } else {
                progressDialogue(finishCallback);
                if (nextCallback != null) nextCallback();
            }
		}

        // nextIndicator.visible = textBox.text == curLine.line;

        super.update(elapsed);
    }

    public function changeEmotion(emotion:String) {
        if (background.animation.exists(emotion)) background.animation.play(emotion, true);
    }

    public function onComplete() {
        if (completeCallback != null) completeCallback(); // theres probably a better way to do this but im fucking tired man
    }

    public function beginDialogue() {
        alpha = 0;
        y = startY + 50;

        FlxTween.tween(this, {y: startY, alpha: 1}, 0.5, {ease: FlxEase.quadOut, onComplete: function(t) {
            changeLine(dialogueFile.dialogue[0]);
            dialogueStarted = true;
            dialogueProgress = 0;
        }});
    }

    public function progressDialogue(?endCallback:Void->Void) {
        dialogueProgress += 1;
        if (dialogueFile.dialogue[dialogueProgress] != null) changeLine(dialogueFile.dialogue[dialogueProgress]);
        else endDialogue(endCallback);
    }

    public function changeLine(line:DialogueLine) {
        background.flipX = switch(line.position) {
            case 'right' | 'middleRight': false;
            case 'left' | 'middleLeft': true;
            default: false;
        }

        namePlate.loadGraphic(Paths.image('dialogue/plates/' + line.character + '_title'));
        namePlate.y = (background.y - namePlate.height/2) + 150;
        namePlate.x = background.flipX ? 20 : FlxG.width - namePlate.width - 20;

        addCharacter(line.character, line.position, line.emotion);

        changeEmotion(line.boxEmotion);
        typeText(line.line, line.speed);
    }

    public function addCharacter(charName:String, position:String = 'left', emotion:String = 'neutral') {
        for (char in charMap) char.switchFocus(false);
        if (!charMap.exists(charName)) {
            var newChar:DialogueCharacter = new DialogueCharacter(charName, position, emotion);
            newChar.loadCharAtlas();
            charMap.set(charName, newChar);
            charGroup.add(newChar);
            trace('new char "$charName"');
        } else {
            charMap.get(charName).changeEmotion(emotion);
            charMap.get(charName).switchPosition(position);
            charMap.get(charName).switchFocus(true);
        }
    }

    public function skipDialogue() {
        textBox.skip();
    }

    public function endDialogue(?callback:Void->Void) {
        dialogueProgress = 0;
        dialogueStarted = false;
		FlxTween.tween(this, {y: y + 50, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        if (callback != null) callback();
    }

    public function typeText(?newText:String = 'Hello world!', ?speed:Float = 0.08) {
        trace(newText + ' (speed: $speed)');
        lineSpeed = speed;
        textBox.resetText(newText);
        textBox.start(speed);
        oldLength = 0;
    }

    public static function parse(path:String):DialogueFile {
		#if MODS_ALLOWED
		if (FileSystem.exists(path)) {
			return cast Json.parse(File.getContent(path));
		}
		#end
		return cast Json.parse(Assets.getText(path));
	}
}