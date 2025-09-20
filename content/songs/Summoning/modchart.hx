var measure:Int = 16;
var beat:Int = 4;

// Math.PI is half a rotation

function onSongStart() {
    squashNstretch(128, 384, 0.5);
    bumpyNotes(128, 256, 20);
    slidey(128, 256, 20);

    slideNBumpEveryOtherNote(256, 384, 20, 20);
    
    for (i in 128...256) {
        switch (i % 8) {
            case 0:
                modManager.queueEase(i, i+4, "localrotateY", Math.PI / 8, 'circOut', 0);
                modManager.queueEase(i, i+4, "localrotateY", -Math.PI / 8, 'circOut', 1);
            case 4:
                modManager.queueEase(i, i+4, "localrotateY", -Math.PI / 8, 'circOut', 0);
                modManager.queueEase(i, i+4, "localrotateY", Math.PI / 8, 'circOut', 1);
        }
    }

    modManager.queueEase(136, 140, "angle", 360, 'circOut');
    modManager.queueEase(136, 138, "transformY-a", -120, 'circOut');
    modManager.queueEase(138, 140, "transformY-a", 0, 'circIn');
    modManager.queueSet(140, "angle", 0);
    
    modManager.queueEase(256, 260, "localrotateY", 0, 'circOut');
    
    for (i in 256...384) {
        switch (i % 8) {
            case 0:
                modManager.queueEase(i, i+4, "localrotateX", Math.PI / 10, 'backOut');
            case 4:
                modManager.queueEase(i, i+4, "localrotateX", -Math.PI / 10, 'backOut');
        }
    }
    
    modManager.queueEase(384, 388, "localrotateX", 0, "backOut");
    modManager.queueEase(384, 388, "transformY", 0, "circOut");

    modManager.queueEase(384, 388, "transform0Y", -10, "circOut");
    modManager.queueEase(384, 388, "transform1Y", -10, "circOut");
    modManager.queueEase(384, 388, "transform2Y", -10, "circOut");
    modManager.queueEase(384, 388, "transform3Y", -10, "circOut");

    modManager.queueEase(384, 388, "transformX", -20, "circOut", 0);
    modManager.queueEase(384, 388, "transformX", 20, "circOut", 1);
    
    
    bumpyNotes(512, 640, 10);
    for (i in 512...640) {
        switch (i % 16) {
            case 0:
                modManager.queueEase(i, i+4, "angle0", 0, 'backOut');
                modManager.queueEase(i, i+4, "angle1", 0, 'backOut');
                modManager.queueEase(i, i+4, "angle2", 0, 'backOut');
                modManager.queueEase(i, i+4, "angle3", 0, 'backOut');
                
                modManager.queueSet(i, "stretch", 0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 4:
                modManager.queueEase(i, i+4, "angle0", 90, 'backOut');
                modManager.queueEase(i, i+4, "angle1", -90, 'backOut');
                modManager.queueEase(i, i+4, "angle2", 90, 'backOut');
                modManager.queueEase(i, i+4, "angle3", -90, 'backOut');
                
                modManager.queueSet(i, "stretch", 0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 8:
                modManager.queueEase(i, i+4, "angle0", 180, 'backOut');
                modManager.queueEase(i, i+4, "angle1", -180, 'backOut');
                modManager.queueEase(i, i+4, "angle2", 180, 'backOut');
                modManager.queueEase(i, i+4, "angle3", -180, 'backOut');
                
                modManager.queueSet(i, "stretch", 0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 12:
                modManager.queueEase(i, i+4, "angle0", 270, 'backOut');
                modManager.queueEase(i, i+4, "angle1", -270, 'backOut');
                modManager.queueEase(i, i+4, "angle2", 270, 'backOut');
                modManager.queueEase(i, i+4, "angle3", -270, 'backOut');
                
                modManager.queueSet(i, "stretch", 0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");

                modManager.queueSet(i+4, "angle0", -90);
                modManager.queueSet(i+4, "angle1", 90);
                modManager.queueSet(i+4, "angle2", -90);
                modManager.queueSet(i+4, "angle3", 90);
        }
    }
    
    modManager.queueEase(640, 644, "angle0", 0, 'backOut');
    modManager.queueEase(640, 644, "angle1", 0, 'backOut');
    modManager.queueEase(640, 644, "angle2", 0, 'backOut');
    modManager.queueEase(640, 644, "angle3", 0, 'backOut');
    
    modManager.queueEase(640, 644, "tipsy", 0.6, 'circOut');
    modManager.queueEase(896, 904, "tipsy", 0, 'circIn');
    
    for (i in 640...896) {
        switch (i % 8) {
            case 0:
                modManager.queueSet(i, "angle", 40);
                modManager.queueEase(i, i+8, "angle", 0, "elasticOut");

                modManager.queueSet(i, "transform0Z", 0.1);
                modManager.queueSet(i, "transform2Z", 0.1);
                modManager.queueSet(i, "transform1Z", -0.1);
                modManager.queueSet(i, "transform3Z", -0.1);

                modManager.queueEase(i, i+4, "transform0Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform2Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform1Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform3Z", 0, "circOut");
            case 4:
                modManager.queueSet(i, "angle", -40);
                modManager.queueEase(i, i+8, "angle", 0, "elasticOut");

                modManager.queueSet(i, "transform0Z", -0.1);
                modManager.queueSet(i, "transform2Z", -0.1);
                modManager.queueSet(i, "transform1Z", 0.1);
                modManager.queueSet(i, "transform3Z", 0.1);

                modManager.queueEase(i, i+4, "transform0Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform2Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform1Z", 0, "circOut");
                modManager.queueEase(i, i+4, "transform3Z", 0, "circOut");
        }
    }
    
    modManager.queueEase(900, 904, "angle", 0, "quintOut");
    modManager.queueEase(900, 904, "transform0Z", 0, "circOut");
    modManager.queueEase(900, 904, "transform2Z", 0, "circOut");
    modManager.queueEase(900, 904, "transform1Z", 0, "circOut");
    modManager.queueEase(900, 904, "transform3Z", 0, "circOut");

    stretchToBeat(1024, 1152);

    modManager.queueEase(1152-2, 1152, "drunk", 10, "circIn", 1);
    modManager.queueEase(1152-4, 1152, "drunk", 0.3);
    // modManager.queueEase(1152-4, 1152, "localrotateX", 5.4, "circOut");
    modManager.queueEase(1152, 1152+4, "drunk", 0.3, "circOut");

    bumpyNotes(1152, 1408, 20);
    squashNstretch(1280, 1408, 0.7);
    modManager.queueEase(1408, 1412, "transformY", 0, "circOut");

    modManager.queueEase(1280, 1408, "angle", 1800, "sineIn");
    
    for (i in 1408...1472) {
        switch (i % 16) {
            case 0:
                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 8:
                modManager.queueSet(i, "stretch", 1);
                modManager.queueEase(i, i+8, "stretch", 0, "elasticOut");
        }
        
        switch (i % 32) {
            case 6:
                modManager.queueSet(i, "angle", 45);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+2, "stretch", 0, "circOut");
            case 22:
                modManager.queueSet(i, "angle", -45);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");

                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+2, "stretch", 0, "circOut");
        }
    }
    
    bumpyNotes(1472, 1536, 20);
    slidey(1472, 1536, 20);

    modManager.queueEase(1536, 1540, "transformY", 0, "circOut");
    modManager.queueEase(1536, 1540, "transformX", -20, "circOut", 0);
    modManager.queueEase(1536, 1540, "transformX", 20, "circOut", 1);

    for (i in 1536...1600) {
        switch (i % 16) {
            case 0:
                modManager.queueSet(i, "angle", -90);
                modManager.queueEase(i, i+4, "angle", 0, "backOut");
            case 4:
                modManager.queueEase(i, i+4, "angle", 90, "backOut");
            case 8:
                modManager.queueEase(i, i+4, "angle", 180, "backOut");
            case 12:
                modManager.queueEase(i, i+4, "angle", 270, "backOut");
        }

        switch (i % 4) {
            case 0:
                modManager.queueSet(i, "stretch", -1);
                modManager.queueEase(i, i+8, "stretch", 0, "elasticOut");
        }
    }

    modManager.queueSet(1536, 'wave', 1);
    modManager.queueEase(1600, 1616, 'wave', 0);
    modManager.queueEase(1600, 1616, "angle", 3600, "sineOut");
    
    modManager.queueEase(1600, 1616, "transform0Z", 0.1, "circOut");
    modManager.queueEase(1600, 1616, "transform1Z", -0.14, "circOut");
    modManager.queueEase(1600, 1616, "transform2Z", 0.15, "circOut");
    modManager.queueEase(1600, 1616, "transform3Z", -0.12, "circOut");
    
    modManager.queueEase(1600, 1616, "transform0X", -90, "circOut", 0);
    modManager.queueEase(1600, 1616, "transform1X", -30, "circOut", 0);
    modManager.queueEase(1600, 1616, "transform2X", 40, "circOut", 0);
    modManager.queueEase(1600, 1616, "transform3X", 50, "circOut", 0);
    
    modManager.queueEase(1600, 1616, "transform0X", 90, "circOut", 1);
    modManager.queueEase(1600, 1616, "transform1X", 30, "circOut", 1);
    modManager.queueEase(1600, 1616, "transform2X", -40, "circOut", 1);
    modManager.queueEase(1600, 1616, "transform3X", -50, "circOut", 1);
    
    modManager.queueEase(1600, 1608, 'transformY', -200, 'circOut');
    modManager.queueEase(1608, 1616, 'transformY', 320, 'quadIn');
}

function stretchToBeat(firstStep:Int, lastStep:Int) {
    for (i in firstStep...lastStep) {
        switch (i % 16) {
            case 0:
                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 8:
                modManager.queueSet(i, "stretch", 1);
                modManager.queueEase(i, i+8, "stretch", 0, "elasticOut");
        }
        
        switch (i % 32) {
            case 6:
                modManager.queueSet(i, "angle", 45);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+2, "stretch", 0, "circOut");
            case 22:
                modManager.queueSet(i, "angle", -45);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");

                modManager.queueSet(i, "stretch", -0.5);
                modManager.queueEase(i, i+2, "stretch", 0, "circOut");
        }
    }
}

function bumpyNotes(firstStep:Int, lastStep:Int, intensity:Float) {
    for (i in firstStep...lastStep) {
        switch (i % 4) {
            case 0:
                modManager.queueEase(i, i+2, "transformY", -intensity, "circOut");
            case 2:
                modManager.queueEase(i, i+2, "transformY", intensity, "circIn");
        }
    }
}

function slidey(firstStep:Int, lastStep:Int, intensity:Float) {
    for (i in firstStep...lastStep) {
        switch (i % 8) {
            case 0:
                modManager.queueEase(i, i+4, "transformX", intensity, "linear", 1);
                modManager.queueEase(i, i+4, "transformX", -intensity, "linear", 0);
            case 4:
                modManager.queueEase(i, i+4, "transformX", -intensity, "linear", 1);
                modManager.queueEase(i, i+4, "transformX", intensity, "linear", 0);
        }
    }
}

function squashNstretch(firstStep:Int, lastStep:Int, intensity:Float) {
    for (i in firstStep...lastStep) {
        switch (i % 8) {
            case 0:
                modManager.queueSet(i, "stretch", intensity);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 4:
                modManager.queueSet(i, "stretch", -intensity);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
        }
    }
}

function slideNBumpEveryOtherNote(firstStep:Int, lastStep:Int, intensity:Float, slideIntensity:Float) {
    for (i in firstStep...lastStep) {
        // bump
        switch (i % 8) {
            case 0:
                modManager.queueEase(i, i+2, "transform0Y", -intensity, "circOut");
                modManager.queueEase(i, i+2, "transform2Y", -intensity, "circOut");
            case 2:
                modManager.queueEase(i, i+2, "transform0Y", 0, "circIn");
                modManager.queueEase(i, i+2, "transform2Y", 0, "circIn");
            case 4:
                modManager.queueEase(i, i+2, "transform1Y", -intensity, "circOut");
                modManager.queueEase(i, i+2, "transform3Y", -intensity, "circOut");
            case 6:
                modManager.queueEase(i, i+2, "transform1Y", 0, "circIn");
                modManager.queueEase(i, i+2, "transform3Y", 0, "circIn");
        }
        
        // slide
        switch (i % 16) {
            case 0:
                modManager.queueEase(i, i+4, "transform0X", slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform2X", slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform0X", -slideIntensity, "linear", 0);
                modManager.queueEase(i, i+4, "transform2X", -slideIntensity, "linear", 0);
            case 4:
                modManager.queueEase(i, i+4, "transform1X", slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform3X", slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform1X", -slideIntensity, "linear", 0);
                modManager.queueEase(i, i+4, "transform3X", -slideIntensity, "linear", 0);
            case 8:
                modManager.queueEase(i, i+4, "transform0X", -slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform2X", -slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform0X", slideIntensity, "linear", 0);
                modManager.queueEase(i, i+4, "transform2X", slideIntensity, "linear", 0);
            case 12:
                modManager.queueEase(i, i+4, "transform1X", -slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform3X", -slideIntensity, "linear", 1);
                modManager.queueEase(i, i+4, "transform1X", slideIntensity, "linear", 0);
                modManager.queueEase(i, i+4, "transform3X", slideIntensity, "linear", 0);

        }
    }
}