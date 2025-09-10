package funkin.backend;

import openfl.utils.Assets;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Sprite;

import flixel.FlxG;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class DebugDisplay extends Sprite
{
	var updating:Bool = true;
	
	var text:TextField;
	var underlay:Bitmap;

	public static var offset:FlxPoint = new FlxPoint();
	
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	
	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	
	@:noCompletion private var times:Array<Float>;
	
	public function new(color:Int = 0x000000)
	{
		super();
		
		underlay = new Bitmap();
		underlay.bitmapData = new BitmapData(1, 1, true, 0x00000000);
		addChild(underlay);
		
		text = new TextField();
		addChild(text);
		
		currentFPS = 0;
		text.selectable = false;
		text.mouseEnabled = false;
		text.defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/comic/bolditalic.ttf").fontName, 12, color);
		text.autoSize = LEFT;
		text.multiline = true;
		text.text = "FPS: ";
		
		times = [];
		
		FlxG.signals.postStateSwitch.add(() -> updateText = __updateTxt);
	}
	
	var deltaTimeout:Float = 0.0;
	
	// Event Handlers
	private override function __enterFrame(deltaTime:Int):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();
			
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}
		
		x = 10 + offset.x;
		y = 2 + offset.y;

		super.__enterFrame(deltaTime);
		
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		underlay.width = text.width + 3;
		underlay.height = text.height;
		
		deltaTimeout = 0.0;
	}
	
	dynamic function updateText():Void
	{
		__updateTxt();
	}
	
	function __updateTxt()
	{
		if (!updating) return;
		
		text.text = 'FPS: $currentFPS \nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
		
		text.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5) text.textColor = 0xFFFF0000;
	}
	
	inline function get_memoryMegas():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif (openfl >= "9.4.0")
		return cast(openfl.system.System.totalMemoryNumber, UInt);
		#else
		return cast(openfl.system.System.totalMemory, UInt);
		#end
	}
}
