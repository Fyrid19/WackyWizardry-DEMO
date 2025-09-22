import funkin.states.substates.GameOverSubstate;

function onCreate() {
    GameOverSubstate.characterName = 'dave-murder';
    GameOverSubstate.deathSoundName = 'dave_3D_loss_sfx';
    GameOverSubstate.loopSoundName = 'gameOver/dave';
    GameOverSubstate.endSoundName = 'gameOver/daveEnd';
    GameOverSubstate.endDelay = 2.5;
}