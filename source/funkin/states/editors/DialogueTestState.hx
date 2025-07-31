package funkin.states.editors;

import funkin.objects.dialogue.DialogueBox;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class DialogueTestState extends MusicBeatState {
    var testBox:DialogueBox;

    var testInputText:FlxUIInputText;
    var testNumericStepper:FlxUINumericStepper;
    var testText:FlxText;
    
    override function create() {
		FlxG.mouse.visible = true;

        var gridSize:Int = 120;
        var grid = FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, gridSize * 2, true, 0x7C7C7C, 0x4D4D4D);
        var bg = new FlxBackdrop(grid);
        bg.velocity.set(50, 0);
        add(bg);

        testBox = new DialogueBox(0, 0);
        testBox.y = testBox.startY = FlxG.height - testBox.height;
        // testBox.screenCenter();
        add(testBox);

        testInputText = new extensions.FlxUIInputTextEx(0, 100, 500, 'Put dialogue here!', 16);
		testNumericStepper = new FlxUINumericStepper(testInputText.x, testInputText.y + 30, 0.01, 0.03, 0.01, 10, 2);

		var submitDialogue:FlxButton = new FlxButton(testInputText.x + testInputText.width, testInputText.y, "Submit", function() {
            testBox.typeText(testInputText.text, testNumericStepper.value);
        });

        testText = new FlxText(0, testNumericStepper.y + 60, FlxG.width, 'RESET to reset the dialogue | ENTER to progress the dialogue | ESC to exit', 16);
        testText.color = 0xFFFFFF;
        
        add(testInputText);
        add(testNumericStepper);
        add(submitDialogue);
        add(testText);

        testBox.dialogueStarted = false;
        testBox.dialogueProgress = 0;
        testBox.beginDialogue();

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.RESET) {
            testBox.dialogueStarted = false;
            testBox.dialogueProgress = 0;
            testBox.beginDialogue();
        }

        if (FlxG.keys.justPressed.ENTER) {
            // testBox.typeText('testign testing. ←—— ↓—— ↑—— →—— yeah, 123... man');
            testBox.progressDialogue();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
		    FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(MainMenuState.new);
        }

        super.update(elapsed);
    }
}