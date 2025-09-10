package funkin.objects.dialogue.events;

class DebugEvent extends DialogueEvent {
    override function getName() return 'debug';

    override function onIndexReached() {
        trace(values[0]);
    }
}