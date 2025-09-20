package funkin.objects;

import funkin.game.shaders.RGBPalette;
import funkin.game.shaders.RGBPalette.RGBShaderReference;

import flixel.FlxSprite;

import funkin.game.shaders.*;
import funkin.data.*;
import funkin.states.*;

class NoteSplash extends FlxSprite
{
	public static var handler:NoteSkinHelper;
	public static var keys:Int = 4;
	
	public var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];
	
	private var idleAnim:String;
	private var textureLoaded:String = null;
	
	public var data:Int = 0;

	public function setShaderColors(?note:Note)
	{
		if (note != null)
		{
			rgbShader.r = note.rgbShader.r;
			rgbShader.g = note.rgbShader.g;
			rgbShader.b = note.rgbShader.b;
		}
		else
		{
			rgbShader.r = 0xFFFF0000;
			rgbShader.g = 0xFFFFFFFF;
			rgbShader.b = 0xFF960101;
		}
	}
	
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);
		
		var skin:String = getPlayStateSplash('noteSplashes');
		
		loadAnims(skin);
		
		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(note));
		rgbShader.enabled = false;
		
		// to prevent it from having some weird color
		setShaderColors(null);
		
		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}
	
	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, ?field:PlayField, ?fieldNote:Note = null)
	{
		scale.set(0.8, 0.8);
		if (field != null) setPosition(x - field.members[note].swagWidth * 0.95, y - field.members[note].swagWidth * 0.95);
		else setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		
		if (texture == null)
		{
			texture = getPlayStateSplash('noteSplashes');
		}
		
		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		if (field != null)
		{
			// scale.x *= field.scale;
			// scale.y *= field.scale;
		}
		data = note;
		switch (texture)
		{
			default:
				// alpha = 0.6;
				alpha = 1;
				antialiasing = true;
				setShaderColors(fieldNote);
				animation.play('note' + note, true);
				offset.set(-20, -20);
				// animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}
	}
	
	public function playAnim()
	{
		animation.play('note' + data, true);
	}
	
	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);
		switch (skin)
		{
			default:
				for (i in 0...keys)
				{
					animation.addByPrefix(handler.data.noteSplashAnimations[i].anim, handler.data.noteSplashAnimations[i].xmlName, 24, false);
				}
		}
		
		textureLoaded = skin;
	}
	
	function getPlayStateSplash(?fallback:String = ''):String
	{
		if (PlayState.SONG != null)
		{
			return (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) ? PlayState.SONG.splashSkin : fallback;
		}
		
		return fallback;
	}
	
	override function update(elapsed:Float)
	{
		if (animation.curAnim != null) if (animation.curAnim.finished) kill();
		
		super.update(elapsed);
	}
}
