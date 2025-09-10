package funkin.objects.dialogue.events;

class DialogueEvent {
    public function getName() return 'none';

    public var parentBox:DialogueBox;

    public var index:Int;
    public var index2:Int; // for events that require it
    public var values:Array<Dynamic>;

    public function init() {
        FlxG.signals.preUpdate.add(update);
    }

    private function update() {
        if (parentBox != null) {
            if (parentBox.curIndex == index) {
                onIndexReached();
            }

            if (parentBox.curIndex == index2) {
                onSecondIndexReached();
            }
        }
    }

    public function onIndexReached() {}
    public function onSecondIndexReached() {}
}