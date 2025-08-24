package funkin.backend.plugins;

import flixel.FlxBasic;

/**
 * Adds the bind of f2 to opening the console.
 */
class OpenConsolePlugin extends FlxBasic
{
	static var instance:Null<OpenConsolePlugin> = null;
	
	public static function init()
	{
		if (instance == null) FlxG.plugins.addPlugin(instance = new OpenConsolePlugin());
	}
	
	public function new()
	{
		super();
		this.visible = false;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F2)
		{	
			#if windows
            // funkin.api.NativeWindows.allocConsole();
            // funkin.api.NativeWindows.clearScreen();
            #end
		}
	}
}
