package funkin.states.editors;

import funkin.objects.dialogue.DialogueBox;
import funkin.objects.dialogue.DialogueCharacter;
import funkin.objects.dialogue.DialogueBox.DialogueFile;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

class DdeDialogueEditorState extends MusicBeatState {
    public static var _dialogue:DialogueFile;
    
    var dialogueBox:DialogueBox;

    // dialogue values
    public var line:String = '';
    public var speed:Float = 0.03;
    public var character:String = 'bf';
    public var position:String = 'left';

    public function new(?dialogueFile:DialogueFile) {
        super();
        _dialogue = dialogueFile;
    }

    override function create() {
        var gridSize:Int = 40;
        var grid = FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, gridSize * 2, true, 0x7C7C7C, 0x4D4D4D);
        var bg = new FlxBackdrop(grid);
        bg.velocity.set(50, 0);
        add(bg);
        
    }
}

class DialogueTestState extends MusicBeatState {
    var testBox:DialogueBox;

    var testInputText:FlxUIInputText;
    var testNumericStepper:FlxUINumericStepper;
    var testText:FlxText;
    
    override function create() {
		FlxG.mouse.visible = true;

        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('gridd'), XY);
        grid.setGraphicSize(Std.int(grid.width * 2));
        grid.velocity.y = 40;
        grid.antialiasing = false;
        add(grid);

        testBox = new DialogueBox();
        // testBox.screenCenter();
        add(testBox);

        testInputText = new extensions.FlxUIInputTextEx(0, 100, 500, 'Put dialogue here!', 16);
		testNumericStepper = new FlxUINumericStepper(testInputText.x, testInputText.y + 30, 0.01, 0.03, 0.01, 1, 2);

		var submitDialogue:FlxButton = new FlxButton(testInputText.x + testInputText.width, testInputText.y, "Submit", function() {
            testBox.typeText(testInputText.text, testNumericStepper.value);
        });

        testText = new FlxText(0, testNumericStepper.y + 60, FlxG.width, 'RESET to reset the dialogue | ENTER to progress the dialogue | ESC to exit | TAB to switch to editor', 16);
        testText.color = 0xFFFFFF;
        
        add(testInputText);
        add(testNumericStepper);
        add(submitDialogue);
        add(testText);

        testBox.beginDialogue();

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.RESET) {
            testBox.beginDialogue();
        }

        if (FlxG.keys.justPressed.ENTER) {
            // testBox.typeText('testign testing. ←—— ↓—— ↑—— →—— yeah, 123... man');
            // testBox.progressDialogue();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
		    FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(MainMenuState.new);
        }
        
        if (FlxG.keys.justPressed.TAB) {
            CoolUtil.loadAndSwitchState(new DdeDialogueEditorState(null));
        }

        super.update(elapsed);
    }
}