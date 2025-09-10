package funkin.objects.dialogue;

import funkin.objects.dialogue.events.*;

class EventManager {
    public static var eventMap:Map<String, DialogueEvent> = [];

    public var events:Array<Class<DialogueEvent>> = [
        DebugEvent,
        PlaySoundEvent,
        SetSpeedEvent
    ];

    public function init() {
        for (event in events) {
            var newEvent:DialogueEvent = Type.createInstance(event, null);
            newEvent.init();
            eventMap.set(newEvent.getName(), newEvent);
        }
    }

    public function getEvent(event:String) {
        return eventMap.get(event);
    }
}