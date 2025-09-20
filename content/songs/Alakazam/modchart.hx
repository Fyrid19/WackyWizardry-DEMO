function onSongStart() {
    // modManager.queueEase(0, 128, "transformX", 1000, "linear");
    // modManager.queueEase(128, 170, "transformX", 0, "linear");
    // modManager.queueEase(170, 256, "transformX", 20000, "linear");

    for (i in 256...512) {
        switch (i % 16) {
            case 0:
                modManager.queueSet(i, "transformX", -20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", -30);
                modManager.queueEase(i, i+8, "angle", 0, "circOut");
            case 4:
                modManager.queueSet(i, "mini", -0.2);
                modManager.queueEase(i, i+4, "mini", 0, "circOut");
            case 8:
                modManager.queueSet(i, "transformX", 20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", 30);
                modManager.queueEase(i, i+8, "angle", 0, "circOut");
            case 12:
                modManager.queueSet(i, "mini", -0.2);
                modManager.queueEase(i, i+4, "mini", 0, "circOut");
        }
    }
    
    modManager.queueEase(512, 516, "tipsy", 0.2, "circOut");

    for (i in 512...768) {
        switch (i % 32) {
            case 8:
                modManager.queueSet(i, "tipsy", 1);
                modManager.queueEase(i, i+8, "tipsy", 0.2, "circOut");
            case 24:
                modManager.queueSet(i, "tipsy", 1);
                modManager.queueEase(i, i+8, "tipsy", 0.2, "circOut");
        }
    }
    
    modManager.queueEase(768, 774, "tipsy", 0.5, "circOut");
    modManager.queueEase(768, 1024, "angle", 1800, "circOut");
    modManager.queueSet(1024, "angle", 0);
    modManager.queueEase(1024, 1028, "tipsy", 0, "circIn");

    for (i in 1024...1280) {
        switch (i % 16) {
            case 0:
                modManager.queueSet(i, "transformX", -20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", -30);
                modManager.queueEase(i, i+8, "angle", 0, "circOut");
            case 4:
                modManager.queueSet(i, "mini", -0.2);
                modManager.queueEase(i, i+4, "mini", 0, "circOut");
            case 8:
                modManager.queueSet(i, "transformX", 20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", 30);
                modManager.queueEase(i, i+8, "angle", 0, "circOut");
            case 12:
                modManager.queueSet(i, "mini", -0.2);
                modManager.queueEase(i, i+4, "mini", 0, "circOut");
        }
    }

    for (i in 1280...1536) {
        switch (i % 32) {
            case 0:
                modManager.queueSet(i, "transformX", -20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", -30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 6:
                modManager.queueSet(i, "transformX", 20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", 30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 12:
                modManager.queueSet(i, "transformX", -20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", -30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 16:
                modManager.queueSet(i, "transformX", 20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", 30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 22:
                modManager.queueSet(i, "transformX", -20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", -30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
            case 28:
                modManager.queueSet(i, "transformX", 20);
                modManager.queueEase(i, i+4, "transformX", 0, "circOut");
                
                modManager.queueSet(i, "angle", 30);
                modManager.queueEase(i, i+4, "angle", 0, "circOut");
                
                modManager.queueSet(i, "stretch", -0.1);
                modManager.queueEase(i, i+4, "stretch", 0, "circOut");
        }
        
        // modManager.queueEase(1536, 1559, "angle", 720, "circOut");
        // modManager.queueSet(1559, "angle", 0);
    }
}