import funkin.states.substates.GameOverSubstate;

function onCreate() {
    GameOverSubstate.characterName = 'wizzlow-dies';
    GameOverSubstate.deathSoundName = 'damage';
    GameOverSubstate.loopSoundName = 'gameOver/wizzlow';
    GameOverSubstate.endSoundName = 'gameOver/wizzlowEnd';
    GameOverSubstate.endDelay = 3;
    GameOverSubstate.zoomOffset = -0.15;
}