package funkin.objects.dialogue;

import haxe.Json;
import openfl.utils.Assets;
import flxanimate.AnimateSprite;

typedef DialogueCharacterFile =
{
	var image:String;
	var fps:Int;
	var no_antialiasing:Bool;
	var defaultPos:String;
	var neutralAnim:String;
	var sound:DialogueSoundData;
	var animations:Array<DialogueAnimArray>;
	var origin:Array<Float>;
	var offset:Array<Float>;
	var scale:Float;
	var defaultFlipX:Bool;
}

typedef DialogueAnimArray =
{
	var name:String;
	var anim:String;
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

class DialogueCharacter extends AnimateSprite {
	public var jsonFile:DialogueCharacterFile = null;
	public var dialogueAnimations:Map<String, DialogueAnimArray> = new Map();
	
	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var animSoundData:Map<String, DialogueSoundData> = new Map();

	public var DEFAULT_CHARACTER:String = 'bf';

	public var character:String = 'bf';
	public var position:String = 'left';
	public var emotion:String = 'neutral';

	public var hasFocus:Bool = false;

	public var sounds:Array<FlxSound> = [];
	var soundArray:Array<String> = null;
	var soundPrefix:String = null;
	var soundPitch:Array<Float> = null;

	public var defaultFlipX:Bool;
	
	public var blinkRate:Array<Float> = [0.7, 1.3]; // How rapid the blinking is (Random between the range of these two numbers)
	public var unblinkRate:Array<Float> = [0.05, 0.1]; // How long they will blink for (Ditto)

	public var talking:Int = 0;
	var blinkFrameOffset:Int = 0;

    public function new(char:String, position:String = 'left', emotion:String = 'neutral') {
		showPivot = false;

		this.character = char;
		this.position = position;
		this.emotion = emotion;

		reloadCharacterJson(char);
		
        super(0, 0, Paths.textureAtlas('dialogue/portraits/${jsonFile.image}'));

		origin.set(jsonFile.origin[0], jsonFile.origin[1]);
		scale.set(jsonFile.scale, jsonFile.scale);

		if (position == 'left' || position == 'middleLeft' || position == 'middle') {
			x = -width;
		} else if (position == 'right' || position == 'middleRight') {
			x = FlxG.width + width;
		}

		defaultFlipX = jsonFile.defaultFlipX ?? false;

		antialiasing = ClientPrefs.globalAntialiasing;
		if (jsonFile.no_antialiasing == true) antialiasing = false;
    }

	var canBlink:Bool = true; // if the character can blink or not
	var blinkTimer:FlxTimer = null; // timer until they blink
	var unblinkTimer:FlxTimer = null; // timer until they unblink
	override function update(elapsed:Float) {
		if (canBlink) {
			blinkTimer = new FlxTimer().start(FlxG.random.float(blinkRate[0], blinkRate[1]), function(t) {
				blinkFrameOffset = FlxG.random.int(0, 1);
				unblinkTimer = new FlxTimer().start(FlxG.random.float(unblinkRate[0], unblinkRate[1]), function(t2) {
					blinkFrameOffset = 0;
					canBlink = true;
				});
			});
			canBlink = false;
		}

		var realPos:Float = 0;

		if (!hasFocus) {
			color = 0xAFAFAF;
			realPos = switch(position) {
				case 'left':
					FlxG.width * 0.25;
				case 'middleLeft':
					FlxG.width * 0.35;
				case 'middle':
					FlxG.width * 0.5;
				case 'middleRight':
					FlxG.width * 0.65;
				case 'right':
					FlxG.width * 0.75;
				default:
					FlxG.width * 0.25;
			}
		} else {
			color = 0xFFFFFF;
			realPos = switch(position) {
				case 'left':
					FlxG.width * 0.3;
				case 'middleLeft':
					FlxG.width * 0.4;
				case 'middle':
					FlxG.width * 0.5;
				case 'middleRight':
					FlxG.width * 0.6;
				case 'right':
					FlxG.width * 0.7;
				default:
					FlxG.width * 0.25;
			}
		}

		var scaledX = FlxMath.remapToRange(realPos - width / 2, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.26, elapsed);
        x = FlxMath.lerp(x, scaledX, lerpRate);

		flipX = switch(position) {
            case 'right' | 'middleRight': defaultFlipX;
            case 'left' | 'middleLeft': !defaultFlipX;
            default: defaultFlipX;
        }

		anim.curFrame = talking + blinkFrameOffset;

		super.update(elapsed);
	}

	var soundToPlay:FlxSound = new FlxSound();
	public function speak() {
		var animSounds:DialogueSoundData = animSoundData.get(emotion) ?? jsonFile.sound;
		if (sounds != null && sounds.length > 0) {
			soundToPlay = sounds[FlxG.random.int(0, sounds.length - 1)];
			soundToPlay.pitch = 1 + FlxG.random.float(animSounds.pitch[0], animSounds.pitch[1]);
			soundToPlay.play();
		}
	}

	// this just assumes every animation has sound data and 
	// it makes it run EVERY TIME, im sure thats probably 
	// not good so ill get it fixed after the first release - kay
	public function reloadSounds() {
		sounds = [];
		var animSounds:DialogueSoundData = animSoundData.get(emotion) ?? jsonFile.sound;
		for (sound in animSounds.sounds) {
			var newSound:FlxSound = new FlxSound();
			newSound.loadEmbedded(Paths.sound('dialogue/' + animSounds.prefix + sound));
			sounds.push(newSound);
			// trace('sound added: $sound ($character)');
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x + jsonFile.offset[0], y + jsonFile.offset[1]];
	}

	public function loadCharAtlas() {
		// loadAtlas(Paths.textureAtlas('dialogue/portraits/${jsonFile.image}'));
		trace('dialogue/portraits/${jsonFile.image}');
        reloadAnimations();
		changeEmotion(emotion);
	}
	
	public function reloadAnimations() {
		dialogueAnimations.clear();
		if (jsonFile.animations != null && jsonFile.animations.length > 0) {
			for (animData in jsonFile.animations) {
				anim.addBySymbol(animData.name, 'expressions/' + animData.anim, 0, !animData.looped);
				dialogueAnimations.set(animData.name, animData);
				animSoundData.set(animData.name, animData.sound);
				addOffset(animData.name, animData.offset[0], animData.offset[1]);
				trace('($character) anim added: ' + animData.name);
			}
		}
	}
	
	public function reloadCharacterJson(character:String) {
		var characterPath:String = 'data/dialogue/characters/' + character + '.json';
		var rawJson = null;
		
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path))
		{
			path = Paths.getPrimaryPath(characterPath);
			trace('loading "$character"');
		}
		
		if (!FileSystem.exists(path))
		{
			path = Paths.getPrimaryPath('data/dialogue/characters/' + DEFAULT_CHARACTER + '.json');
			trace('file not found, loading "$DEFAULT_CHARACTER"');
		}
		rawJson = File.getContent(path);
		#else
		var path:String = Paths.getPrimaryPath(characterPath);
		rawJson = Assets.getText(path);
		#end
		
		jsonFile = cast Json.parse(rawJson);
	}

	public function changeEmotion(emotion:String) {
		if (dialogueAnimations.exists(emotion)) {
			anim.play(emotion, true);

			if (animOffsets.exists(emotion)) {
				final animOffset = animOffsets.get(emotion);
				offset.set(animOffset[0], animOffset[1]);
			}
			
			this.emotion = emotion;
			reloadSounds();

			trace('Changed emotion to "$emotion" ($character)');
		} else {
			trace('Animation not found: $emotion ($character)');
		}
	}

	public function switchFocus(focus:Bool) {
		hasFocus = focus;
	}

	public function switchPosition(pos:String) {
		position = pos;
	}

	public function exit(?afterKill:Void->Void) {
		if (position == 'left' || position == 'middleLeft' || position == 'middle') {
			x = -width;
		} else if (position == 'right' || position == 'middleRight') {
			x = FlxG.width + width;
		}

		new FlxTimer().start(1, (t) -> {
			this.kill();
			afterKill();
			this.destroy();
		});
	}
}