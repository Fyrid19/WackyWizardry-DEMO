package funkin.objects.dialogue;

import haxe.Json;
import openfl.utils.Assets;

import flixel.group.FlxGroup.FlxTypedGroup;
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
    var charFocus:String;
    var characters:Array<DialogueCharInfo>;
    var position:String;
    var namePlate:String;
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
                speed: 0.03,
                charFocus:  'bf',
                characters: [
                    {
                        name: 'bf',
                        emotion: 'neutral',
                        position: 'left'
                    }
                ],
                position:  'right',
                namePlate: 'bf',
                boxEmotion:  'regular',
                line:  'this is the default dialogue. hi',
                font:  null
            },
            {
                speed:  0.03,
                charFocus:  'bf',
                characters: [
                    {
                        name: 'bf',
                        emotion: 'neutral',
                        position: 'left'
                    }
                ],
                position:  'left',
                namePlate: 'bf',
                boxEmotion:  'think',
                line:  'which means, there is no dialogue',
                font:  null
            },
            {
                speed:  0.03,
                charFocus:  'bf',
                characters: [
                    {
                        name: 'bf',
                        emotion: 'neutral',
                        position: 'left'
                    }
                ],
                position:  'right',
                namePlate: 'bf',
                boxEmotion:  'intense',
                line:  'go get some dialogue! fool.',
                font:  null
            }
        ]
    };

    var background:FlxSprite;
    var nextIndicator:FlxShapeCircle;
    var textBox:FlxTypeText;
    var noteSymbols:FlxSpriteGroup;
    var characters:Map<String, DialogueCharacter> = new Map<String, DialogueCharacter>();

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

        background = new FlxSprite(x, y);
        background.frames = Paths.getSparrowAtlas('dialogue/boxes/default');
        background.animation.addByPrefix('regular', 'regular_box', 24, true);
        background.animation.addByPrefix('intense', 'intense_box', 24, true);
        background.animation.addByPrefix('think', 'think_box', 24, true);
        background.animation.play('regular', true);
        add(background);

        textBox = new FlxTypeText(x + 40, y + 160, FlxG.width - 80, '', 24);
        textBox.setFormat(defaultFont, 24, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
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

    override function update(elapsed:Float) {
        var curLine = dialogueFile.dialogue[dialogueProgress];
        switch (textBox.text.charAt(textBox.text.length - 1)) {
            case '.' | '!' | '?':
                textBox.delay = lineSpeed * 10;
            case ',':
                textBox.delay = lineSpeed * 5;
            default:
                textBox.delay = lineSpeed;
        }

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

        // trace(line);
        // trace(line.characters);
        // characters.clear();
        for (char in line.characters) {
            trace('char: ' + char.name + ' | position: ' + char.position + ' | emotion: ' + char.emotion);

            if (!characters.exists(char.name)) {
                var newChar:DialogueCharacter = new DialogueCharacter(char.name, char.position, char.emotion);
                characters.set(char.name, newChar);
            } else {
                characters.get(char.name).position = char.position;
                characters.get(char.name).emotion = char.emotion;
            }
        }

        changeEmotion(line.boxEmotion);
        typeText(line.line, line.speed);
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