var PlayStateI = PlayState.instance; // just so i dont have to write this over and over

function onCreate() {
    if (isStoryMode && !fromRestart)
    PlayStateI.songStartCallback = function() {
        PlayStateI.startVideo('alakazamstoryboard', () -> {
            PlayStateI.startDialogueAlt(null);
        });
        trace('playing video');
    }
}