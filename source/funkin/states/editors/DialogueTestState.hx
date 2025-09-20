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

        testInputText = new extensions.FlxUIInputTextEx(0, 100, 500, 'Load File', 16);
		testNumericStepper = new FlxUINumericStepper(testInputText.x, testInputText.y + 30, 0.01, 0.03, 0.01, 1, 2);

		var submitDialogue:FlxButton = new FlxButton(testInputText.x + testInputText.width, testInputText.y, "Submit", function() {
		    var file:String = Paths.getPath('data/dialogue/dialogue/${testInputText.text}.json');
		    var hasDialogue:Bool = Paths.fileExists('data/dialogue/dialogue/${testInputText.text}.json', TEXT);
            if (hasDialogue) {
                remove(testBox);
                testBox = new DialogueBox(funkin.objects.dialogue.DialogueBox.DialogueData.parse(file));
                add(testBox);
                testBox.beginDialogue();
            }
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
            FlxG.switchState(funkin.states.wacky.MainMenuState.new);
        }

        super.update(elapsed);
    }
}