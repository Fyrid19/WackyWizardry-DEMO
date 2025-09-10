package funkin.objects.dialogue.events;

class PlaySoundEvent extends DialogueEvent {
    override function getName() return 'sound';

    override function onIndexReached() {
        FlxG.sound.play(Paths.sound(values[0]));
    }
}