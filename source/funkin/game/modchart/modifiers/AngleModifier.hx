package funkin.game.modchart.modifiers;

import math.Vector3;

import flixel.FlxSprite;

import funkin.game.modchart.Modifier.ModifierOrder;
import funkin.states.*;
import funkin.objects.*;

class AngleModifier extends NoteModifier
{ // this'll be transformX in ModManager
	inline function lerp(a:Float, b:Float, c:Float)
	{
		return a + (b - a) * c;
	}
	
	override function getName() return 'angle';
	
	override function getOrder() return Modifier.ModifierOrder.FIRST;
	
	function getAngle(sprite:Dynamic, angle:Float, data:Int, player:Int)
	{
		var ogAngle:Float = sprite.angle;
		var realAngle = getSubmodValue("angle", player) + getSubmodValue('angle${data}', player);
		if ((sprite is Note) && sprite.isSustainNote) realAngle = ogAngle;
		
		return realAngle + angle;
	}
	
	override function shouldExecute(player:Int, val:Float) return true;
	
	override function ignorePos() return true;
	
	override function ignoreUpdateReceptor() return false;
	
	override function ignoreUpdateNote() return false;
	
	override function updateNote(beat:Float, note:Note, pos:Vector3, player:Int)
	{
		var localAngle:Float = getSubmodValue("noteAngle", player);
		note.angle = getAngle(note, localAngle, note.noteData, player);
	}
	
	override function updateReceptor(beat:Float, receptor:StrumNote, pos:Vector3, player:Int)
	{
		var localAngle:Float = getSubmodValue("receptorAngle", player);
		receptor.angle = getAngle(receptor, localAngle, receptor.noteData, player);
	}
	
	override function getSubmods()
	{
		var subMods:Array<String> = ["angle", "noteAngle", "receptorAngle"];
		
		var receptors = modMgr.receptors[0];
		for (i in 0...PlayState.SONG.keys)
		{
			subMods.push('angle${i}');
			subMods.push('noteAngle${i}');
			subMods.push('receptorAngle${i}');
		}
		return subMods;
	}
}
