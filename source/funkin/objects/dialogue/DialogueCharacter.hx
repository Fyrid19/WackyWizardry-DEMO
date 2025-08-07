package funkin.objects.dialogue;

import haxe.Json;
import openfl.utils.Assets;

import funkin.objects.character.AnimateCharacter; // i dont feel like implementing this myself right now, probably gonna be placeholder
import flxanimate.FlxAnimateController;
import flxanimate.AnimateSprite;

typedef DialogueCharacterFile =
{
	var image:String;
	var fps:Int;
	var no_antialiasing:Bool;
	var defaultPos:String;
	var sound:DialogueSoundData;
	var animations:Array<DialogueAnimArray>;
	var offset:Array<Float>;
	var scale:Float;
}

typedef DialogueAnimArray =
{
	var anim:String;
	var animXml:String;
	var ?fps:Int;
	var looped:Bool;
	var offset:Array<Int>;
	var blinkRates:Array<Int>;
	var unblinkRates:Array<Int>;
	var ?sound:DialogueSoundData;
}

typedef DialogueSoundData = 
{
	var sounds:Array<String>;
	var pitch:Array<Float>;
	var prefix:String;
}

// heavily edited to work with the custom dialogue
class DialogueCharacter extends FlxSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf';
	public static var DEFAULT_SCALE:Float = 1;
	
	public var jsonFile:DialogueCharacterFile = null;
	public var dialogueAnimations:Map<String, DialogueAnimArray> = new Map();
	
	public var curCharacter:String = 'bf';
	public var neutralAnim:String = 'neutral';
	public var emotion:String = 'neutral';
	public var position:String = 'right';
	public var posOffset:Array<Float> = [0, 0];
	public var flipXDefault:Bool = false;
	public var hasFocus:Bool = false;

	public var dialogueSounds:Array<FlxSound> = [];

	public var blinkRate:Array<Float> = [0.7, 1.3]; // How rapid the blinking is (Random between the range of these two numbers)
	public var unblinkRate:Array<Float> = [0.05, 0.1]; // How long they will blink for (Ditto)
	
	public function new(character:String = null, position:String = 'left', emotion:String = 'neutral')
	{
		super();
		
		if (character == null) character = DEFAULT_CHARACTER;
		this.curCharacter = character;

		this.position = position;
		this.emotion = emotion;
		
		reloadCharacterJson(character);
		frames = Paths.getSparrowAtlas('dialogue/portraits/' + jsonFile.image);
		reloadAnimations();
		
		antialiasing = ClientPrefs.globalAntialiasing;
		if (jsonFile.no_antialiasing == true) antialiasing = false;
	}

	var canBlink:Bool = true; // if the character can blink or not
	var blinkTimer:FlxTimer = null; // timer until they blink
	var unblinkTimer:FlxTimer = null; // timer until they unblink
	override function update(elapsed:Float) {
		if (canBlink) {
			blinkTimer = new FlxTimer().start(FlxG.random.float(blinkRate[0], blinkRate[1]), function(t) {
				// stuff for blinking
				trace('blink! ($curCharacter)');

				unblinkTimer = new FlxTimer().start(FlxG.random.float(unblinkRate[0], unblinkRate[1]), function(t2) {
					// stuff for unblinking
					trace('unblink! ($curCharacter)');

					canBlink = true;
				});
			});
			canBlink = false;
		}

		flipX = switch(position) {
			case 'right' | 'middleRight': flipXDefault;
			case 'left' | 'middleLeft': !flipXDefault;
			default: flipXDefault;
		}

		var realPosition:Float = switch(position) {
			case 'left':
				FlxG.width * 0.25;
			case 'middleLeft':
				FlxG.width * 0.4;
			case 'middleRight':
				FlxG.width * 0.6;
			case 'right':
				FlxG.width * 0.75;
			default:
				FlxG.width * 0.25;
		}

		realPosition += posOffset[0];
		
		var scaledX = FlxMath.remapToRange(realPosition - width / 2, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.08, elapsed);
        x = FlxMath.lerp(x, scaledX, lerpRate); // so if the position were to change during dialogue it flows smoothly
		y += posOffset[1];

		super.update(elapsed);
	}
	
	public function reloadCharacterJson(character:String)
	{
		var characterPath:String = 'data/dialogue/' + character + '.json';
		var rawJson = null;
		
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path))
		{
			path = Paths.getPrimaryPath(characterPath);
		}
		
		if (!FileSystem.exists(path))
		{
			path = Paths.getPrimaryPath('data/dialogue/' + DEFAULT_CHARACTER + '.json');
		}
		rawJson = File.getContent(path);
		#else
		var path:String = Paths.getPrimaryPath(characterPath);
		rawJson = Assets.getText(path);
		#end
		
		jsonFile = cast Json.parse(rawJson);
	}
	
	public function reloadAnimations()
	{
		dialogueAnimations.clear();
		if (jsonFile.animations != null && jsonFile.animations.length > 0)
		{
			for (anim in jsonFile.animations)
			{
				animation.addByPrefix(anim.anim, anim.animXml, anim.fps);
				dialogueAnimations.set(anim.anim, anim);
			}
		}
	}
	
	public function changeEmotion(emotion:String) {
		trace(emotion + ' | $curCharacter');
	}
}