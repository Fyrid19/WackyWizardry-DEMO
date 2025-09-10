package funkin.objects.dialogue.events;

class SetSpeedEvent extends DialogueEvent {
    override function getName() return 'debug';

    override function onIndexReached() {
        parentBox.lineSpeed = parentBox.lineSpeed * values[0];
    }
}