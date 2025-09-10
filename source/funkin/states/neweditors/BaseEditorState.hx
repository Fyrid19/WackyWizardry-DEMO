package funkin.states.neweditors;

import haxe.io.Bytes; // fuck bytes
import haxe.ui.backend.flixel.UIState;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.Dialogs.FileDialogTypes;
import haxe.ui.containers.dialogs.OpenFileDialog;
import haxe.ui.containers.dialogs.SaveFileDialog;

import funkin.backend.DebugDisplay;

// dont know why nobody has thought to make this ngl
class BaseEditorState extends UIState {
    public var returnedBytes:Bytes = null;
    public var defaultSavePath:String = 'assets/';

    override function create() {
		FlxG.mouse.visible = true;
        DebugDisplay.offset.y = 30;
        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) { // todo add an are you sure thing here, or just a callback so you can edit what it does yourself
		    FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(MainMenuState.new);
        }

        super.update(elapsed);
    }

    public function openFile(windowTitle:String, ?callback:Void->Void = null) {
        var dialog = new OpenFileDialog();
        dialog.options = {
            readContents: true,
            title: windowTitle,
            readAsBinary: true
        };
        dialog.onDialogClosed = function(event) {
            if (event.button == DialogButton.OK) {
                returnedBytes = dialog.selectedFiles[0].bytes;
                if (callback != null) callback();
            }
        }
        dialog.show();
    }
}