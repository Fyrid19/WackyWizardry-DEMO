package funkin.states.neweditors;

import funkin.objects.dialogue.DialogueBox;
import funkin.objects.dialogue.DialogueBox.DialogueFile;
import funkin.objects.dialogue.DialogueBox.DialogueCharInfo;
import funkin.objects.dialogue.DialogueBox.DialogueLine;

import flixel.addons.display.FlxBackdrop;

import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.menus.MenuCheckBox;
import haxe.ui.containers.menus.MenuItem;

@:build(haxe.ui.ComponentBuilder.build("assets/embeds/xml-ui/dialogue-editor/main-view.xml"))
class DialogueEditor extends BaseEditorState {
    public var menuBar:MenuBar;
    
    public var fileNewMenuItem:MenuItem;
    public var fileOpenMenuItem:MenuItem;
    public var fileSaveMenuItem:MenuItem;
    public var fileSaveAsMenuItem:MenuItem;
    public var loadAutoSaveMenuItem:MenuItem;
    
    public var editDialogueDataMenuItem:MenuItem;
    public var hideUiMenuItem:MenuCheckBox;
    public var autoSaveMenuItem:MenuCheckBox;
    
    public var dialogueWindowMenuItem:MenuItem;
    public var eventWindowMenuItem:MenuItem;
    public var helpWindowMenuItem:MenuItem;

    // actual dialogue stuff
    public var dialogueFile:DialogueFile;
    public var testBox:DialogueBox;

    public var background:FlxSprite;

    override function create() {
        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('gridd'), XY);
        grid.velocity.y = 40;
        grid.antialiasing = false;
        add(grid);

        setButtonFunctions();
        
        super.create();
    }

    function setButtonFunctions() {
        
    }
}