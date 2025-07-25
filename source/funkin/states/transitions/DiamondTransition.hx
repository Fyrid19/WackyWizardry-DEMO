package funkin.states.transitions;

import funkin.backend.BaseTransitionState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;

class DiamondTransition extends BaseTransitionState {
	override function create() {
		final time = status == IN ? 0.48 : 0.8;
		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.48, new FlxPoint(1, -1));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.80, new FlxPoint(1, -1));
			
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;
        
        FlxTransitionableState.defaultTransIn.tileData = {asset: diamond, width: 32, height: 32};
        FlxTransitionableState.defaultTransOut.tileData = {asset: diamond, width: 32, height: 32};
        
		// MusicBeatState.transIn = FlxTransitionableState.defaultTransIn;
		// MusicBeatState.transOut = FlxTransitionableState.defaultTransOut;
		
		super.create();
	}
}