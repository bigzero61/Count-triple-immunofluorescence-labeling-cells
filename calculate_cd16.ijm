dir_saving = getDirectory("Choose a Directory to save");
dir_processing = getDirectory("Choose a Directory to proess");
list = getFileList(dir_processing);
for(i = 0; i < list.length; i++) 
	{
		open(list[i]);//Open each image
		name = getTitle();
		Stack.setDisplayMode("color");
		Stack.setChannel(3);
		run("Enhance Contrast", "saturated=0.35");
		run("Grays");
		makeRectangle(0, 0, 1280, 1080);
		waitForUser("Move ROI to proper region");
		run("Duplicate...", "duplicate");
		images = getList("image.titles");
		for (j = 0; j < images.length; j++) {
			if (matches(images[j], ".*-1.tif")) {
				selectWindow(images[j]);
			}
		}
		saveAs("tiff", dir_saving + "ori" + getTitle);
		title = getTitle();
		run("Split Channels");
		images = getList("image.titles");
		for (j = 0; j < images.length; j++) {
			if (matches(images[j], "C3.*")) {
				selectWindow(images[j]);
			}
		}
		setAutoThreshold("Moments dark");
		run("Convert to Mask");
		for (j = 0; j < images.length; j++) {
			if (matches(images[j], "C1.*")) {
				DAPI = images[j];
			}
			if (matches(images[j], "C2.*")) {
				CD206 = images[j];
			}
			if (matches(images[j], "C3.*")) {
				iba1 = images[j];
			}
			if (matches(images[j], "C4.*")) {
				CD16 = images[j];
			}
		}
		run("Merge Channels...", "c1=[" + DAPI +"] c3=[" + iba1 + "] create");
		selectWindow(title);
		Stack.setChannel(1);
		run("Cyan");
		run("Enhance Contrast", "saturated=0.35");
		Stack.setDisplayMode("color");
		Stack.setChannel(2);
		setMinAndMax(254, 256);
		Stack.setDisplayMode("composite");
		Stack.setChannel(2);
		waitForUser("Use pencil to seperate overlapped cells");
		saveAs("tiff", dir_saving + getTitle);
		Stack.setDisplayMode("color");
		Stack.setChannel(2);
		setAutoThreshold("Moments dark");
		run("Analyze Particles...", "size=50-Infinity display exclude clear add slice");
		n = roiManager("count");
		roiManager("combine");
		waitForUser("Make sure all cells are selected");
		roiManager("save", dir_saving + name + ".zip");
		selectWindow(CD16);
		waitForUser("Select appropriate background in this channel");
		run("Measure");
		for (j=0; j<n; j++) {
      		roiManager("select", j);
      		run("Measure");
      		}
      	selectWindow(CD206);
      	waitForUser("Select appropriate background in this channel");
		run("Measure");
      	for (j=0; j<n; j++) {
      		roiManager("select", j);
      		run("Measure");
      		}
      	saveAs("Results", dir_saving + name + ".csv");
      	close("*");
	}
	
