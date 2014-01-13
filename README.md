#RSScreenVideo

A very light utility for recording gameplay in a cocos2d game. Configuration is kept to a minimum to keep it extremely simple. The output will be .mov files in the application's Documents directory.

Please do not attempt to use this in production code, as you'll probably get rejected.

__Note__: Frame rates will drop in the actual gameplay if there are too many sprites being rendered, but the output videos will keep the configured frame rate.

__Wanted__: Suggestions on how to make the recording more efficient or how we could make this work for non cocos2d apps.

##Required Frameworks
Add these in Build Phases under the Link Binary With Libraries section  
* `AVFoundation.framework`  
* `CoreVideo.framework`  
* `CoreMedia.framework`  

##Retrieving Recordings
Add the entry `UIFileSharingEnabled` (Application supports iTunes file sharing) into your app's info.plist and set it to YES. This will allow you to retrieve your recordings from your app through iTunes.

After calling `stopRecordingWithCompletion:` the current take will be completed and a .mov file will be available to view. To view the recording:

1. Open up iTunes and click your device next to the iTunes Store button
2. Click on the Apps tab.
3. Under the File Sharing section near the bottom, select your app.
4. Select the files you want to save to your computer and click Save to...
5. Make awesome trailers.

##Example Usage
In this example we create an RSScreenVideo instance that will save recordings with the filename example\_n.mov, where n is the nth time `startRecording` is called. This allows us to save multiple recordings per session. The pixel format used works with cocos2d apps that use the `CCTexturePixelFormat_RGBA8888` for their textures. The default frame rate the video will be captured at is 60fps. You can set the `framesPerSecond` instance variable to one you prefer. Calling `startRecording` does just that - starts the recording, but the video will not be viewable until you call `stopRecordingWithCompletion:` and the completion block runs.

The default parameters for the regular `init` method are "session" for the file name, the size of `[UIScreen mainScreen]` and the pixel format `kCVPixelFormatType_32BGRA`.

	self.screenVideo = [[RSScreenVideo alloc] initWithFileName:@"example"
                                                    screenSize:[[CCDirector sharedDirector] viewSizeInPixels]
                                                   pixelFormat:kCVPixelFormatType_32BGRA];
												   
    // Start recording
	[self.screenVideo startRecording];
	
	
	... in some other method that stops recording
	
	// Stop recording
	[self.screenVideo stopRecordingWithCompletion:^{}];

##Contact
Please feel free to submit pull requests if you see a good opportunity for improvement, we appreciate any feedback!

Austin Borden  
* <http://github.com/raresloth>  
* <http://raresloth.com>  
* <austin@raresloth.com>  
* [@raresloth](http://twitter.com/raresloth)  