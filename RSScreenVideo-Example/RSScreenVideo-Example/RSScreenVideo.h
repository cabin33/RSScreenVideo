//
//  RSScreenVideo.h
//
//  Created by Austin Borden on 12/24/13.
//

#import <Foundation/Foundation.h>

@interface RSScreenVideo : NSObject

/*
 *  The name of the file that will be created the next time startRecording is called.
 */
@property (nonatomic, copy) NSString *fileName;

/**
 *  The number of times per second grabFrame is called. The value will be clamped between 0 - 60.
 *  Set this to a value > 0 if not calling captureFrame directly. Default is 0.
 */
@property (nonatomic) CGFloat framesPerSecond;

/**
 *  Setting to YES will append "_n" to the file name where n is the nth time startRecording was called on this instance.
 *  Default is YES.
 */
@property (nonatomic) BOOL appendsTakeNumber;

// YES if currently recording
@property (nonatomic, readonly) BOOL isRecording;

/**
 *  Initializes a new instance of RSScreenVideo that will save videos with the given fileName/screenSize/pixelFormat.
 */
- (instancetype)initWithFileName:(NSString *)fileName screenSize:(CGSize)screenSize pixelFormat:(int)pixelFormat;

/**
 *  Starts a new video recording. If already recording, the current recording will be stopped and a new one will be created.
 */
- (void)startRecording;

/**
 *  Stops the current recording and completes the file save. Must be called before trying to extract
 *  the video from the device.
 */
- (void)stopRecordingWithCompletion:(void (^)(void))completionBlock;

/**
 * Captures a frame for the currently recording video.
 */
- (void)captureFrame;

/**
 * Deletes all videos in the RSScreenVideo folder.
 */
- (void)removeVideos;


@end
