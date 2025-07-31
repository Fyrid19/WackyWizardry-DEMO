package funkin.objects.dialogue;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTypeText;

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
                speed: 0.03,
                character:  'bf',
                position:  'right',
                emotion:  'neutral',
                boxEmotion:  'regular',
                line:  'this is the default dialogue. hi',
                font:  null
            },
            {
                speed:  0.03,
                character:  'bf',
                position:  'left',
                emotion:  'neutral',
                boxEmotion:  'think',
                line:  'which means, there is no dialogue',
                font:  null
            },
            {
                speed:  0.03,
                character:  'bf',
                position:  'right',
                emotion:  'neutral',
                boxEmotion:  'intense',
                line:  'go get some dialogue! fool.',
                font:  null
            }
        ]
    };

    var background:FlxSprite;
    var textBox:FlxTypeText;
    var noteSymbols:FlxSpriteGroup;
    var characters:FlxTypedGroup<DialogueCharacter>;

    var defaultFont = Paths.font('comic/normal.ttf');

    // debug stuff
    var progressTxt:FlxText;

    public var dialogueStarted:Bool = false;
    public var dialogueProgress:Int = 0;
    
    public var startY:Float;

    public var completeCallback:Void->Void;

    public function new(x:Float, y:Float, ?dialogue:DialogueFile) {
        super(x, y);

        startY = y;

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

        progressTxt = new FlxText(x, y, FlxG.width, '', 36);
        progressTxt.setFormat(defaultFont, 36, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
        add(progressTxt);
    }

    override function update(elapsed:Float) {
        var curLine = dialogueFile.dialogue[dialogueProgress];
        switch (textBox.text.charAt(textBox.text.length - 1)) {
            case '.' | '!' | '?':
                textBox.delay = curLine.speed * 10;
            case ',':
                textBox.delay = curLine.speed * 5;
            default:
                textBox.delay = curLine.speed;
        }

        progressTxt.text = 'line: $dialogueProgress';

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

        textBox.delay = speed;

        textBox.resetText(newText);
        textBox.start(speed);
    }
}