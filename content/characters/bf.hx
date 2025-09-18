import funkin.states.substates.GameOverSubstate;

function onCreate() {
    GameOverSubstate.characterName = 'bf-murder';
    GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
    GameOverSubstate.loopSoundName = 'gameOver/bf';
    GameOverSubstate.endSoundName = 'gameOver/bfEnd';
    GameOverSubstate.endDelay = 4.2;
    GameOverSubstate.zoomOffset = 0.2;
}