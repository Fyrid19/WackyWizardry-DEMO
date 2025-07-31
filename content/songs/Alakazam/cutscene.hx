var PlayStateI = PlayState.instance; // just so i dont have to write this over and over
function onCreate() {
    // if (PlayStateI.isStoryMode) // commented out for testing purposes
    PlayStateI.songStartCallback = function() {
        PlayStateI.startVideo('alakazamstoryboard');
    }
}