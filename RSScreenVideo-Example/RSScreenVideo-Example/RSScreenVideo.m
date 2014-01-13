//
//  RSScreenVideo.m
//
//  Created by Austin Borden on 12/24/13.
//
//

#import "RSScreenVideo.h"
#import <AVFoundation/AVFoundation.h>

#define VIDEOS_FILE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface RSScreenVideo ()

// Video Recording Instances
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;

// The time we started recording last
@property (nonatomic, strong) NSDate *startTime;

// The number of times startRecording was called on this instance
@property (nonatomic) NSInteger takeNumber;

// YES if currently recording
@property (nonatomic) BOOL isRecording;

// When the last frame was captured
@property (nonatomic) CMTime lastFrameTime;

// Timer for capturing frames if framesPerSecond is set
@property (nonatomic, weak) NSTimer *frameCaptureTimer;

// Video Properties
@property (nonatomic) CGSize screenSize;
@property (nonatomic) int pixelFormat;

@end

@implementation RSScreenVideo

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.fileName = @"session";
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [[UIScreen mainScreen] scale];
        self.screenSize = CGSizeMake(screenSize.width * scale, screenSize.height * scale);
        
        self.pixelFormat = kCVPixelFormatType_32BGRA;
        
        self.appendsTakeNumber = YES;
        
        self.framesPerSecond = 60;
        
        [self setupRecordingSession];
    }
    
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName screenSize:(CGSize)screenSize pixelFormat:(int)pixelFormat {
    
    if (self = [self init]) {
        
        self.fileName = fileName;
        self.screenSize = screenSize;
        self.pixelFormat = pixelFormat;
    }
    
    return self;
}

- (void)setupTimer {
    
    self.frameCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/self.framesPerSecond) target:self selector:@selector(captureFrame) userInfo:nil repeats:YES];
}

- (void)tearDownTimer {
    
    if (self.frameCaptureTimer) {
        
        [self.frameCaptureTimer invalidate];
        self.frameCaptureTimer = nil;
    }
}

- (void)setFramesPerSecond:(CGFloat)framesPerSecond {

    _framesPerSecond = MIN(MAX(framesPerSecond, 0), 60);
    
    if (_framesPerSecond == 0.0f) {
        [self tearDownTimer];
    }
}

- (void)setupRecordingSession {
    
    self.takeNumber = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the videos directory if it doesn't exist
    if (![fileManager fileExistsAtPath:VIDEOS_FILE_PATH isDirectory:nil]) {
        
        NSError *error;
        if (![fileManager createDirectoryAtPath:VIDEOS_FILE_PATH withIntermediateDirectories:NO attributes:nil error:&error]) {
            
            NSLog(@"Could not create videos directory at path: %@. Error: %@", VIDEOS_FILE_PATH, error.localizedDescription);
        }
    }
}

- (void)startRecording {
    
    if (self.isRecording) {
        
        [self stopRecordingWithCompletion:^{
            
            [self _startRecording];
        }];
    } else {
        
        [self _startRecording];
    }
}

- (void)resetRecordTime {
    CMTime time;
    time.value = 0;
    self.lastFrameTime = time;
}

- (void)_startRecording {
    
    [self resetRecordTime];
    self.takeNumber++;
    
    NSError *error = nil;
    
    NSString *recordingNumberExtension = @"";
    if (self.appendsTakeNumber) {
        recordingNumberExtension = [NSString stringWithFormat:@"_%d", self.takeNumber];
    }
    
    NSString *videoFileName = [NSString stringWithFormat:@"%@%@.mov", self.fileName, recordingNumberExtension];
    
    NSURL *newMovieURL = [NSURL fileURLWithPath:[VIDEOS_FILE_PATH stringByAppendingPathComponent:videoFileName] isDirectory:NO];
    
    // Remove the file if it already existed
    if ([[NSFileManager defaultManager] fileExistsAtPath:newMovieURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:newMovieURL error:&error];
        if (error) {
            NSLog(@"File Removal Error: %@", error);
        }
    }
    
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:newMovieURL fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if (error) {
        NSLog(@"Asset Writer Error: %@", error);
    }
    
    NSDictionary *outputSettings = @{ AVVideoWidthKey : @(self.screenSize.width),
                                      AVVideoHeightKey: @(self.screenSize.height),
                                      AVVideoCodecKey: AVVideoCodecH264 };
    
    self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    self.assetWriterVideoInput.transform = CGAffineTransformMakeScale(1.0f, -1.0f);
    
    NSDictionary *sourcePixelBufferAttributesDictionary = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey: @(self.pixelFormat),
                                                             (NSString *)kCVPixelBufferWidthKey: @(self.screenSize.width),
                                                             (NSString *)kCVPixelBufferHeightKey: @(self.screenSize.height) };
    self.assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterVideoInput
                                                                                                        sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    [self.assetWriter addInput:self.assetWriterVideoInput];
    
    [self.assetWriter startWriting];
    
    self.startTime = [NSDate date];
    
    self.isRecording = YES;
    
    if (self.framesPerSecond > 0 && !self.frameCaptureTimer) {
        
        [self setupTimer];
    }
}

- (void)stopRecordingWithCompletion:(void (^)(void))completionBlock {
    
    if (!self.isRecording) {
        return;
    }
    
    [self tearDownTimer];
    
    [self.assetWriter finishWritingWithCompletionHandler:^{
        self.isRecording = NO;
        [self resetRecordTime];
                
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)captureFrame {
    
    // Do nothing if the video isn't recording
    if (!self.isRecording) {
        return;
    }
    
    CMTime currentTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSinceDate:self.startTime], 120);
    
    if (!self.lastFrameTime.value) {
        
        [self.assetWriter startSessionAtSourceTime:currentTime];
    }
    
    CVPixelBufferRef pixel_buffer = NULL;
    
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, [self.assetWriterPixelBufferInput pixelBufferPool], &pixel_buffer);
    
    if ((pixel_buffer == NULL) || (status != kCVReturnSuccess)) {
        
        return;
    } else {
        
        CVPixelBufferLockBaseAddress(pixel_buffer, 0);
        GLubyte *pixelBufferData = (GLubyte *)CVPixelBufferGetBaseAddress(pixel_buffer);
        glReadPixels(0, 0, self.screenSize.width, self.screenSize.height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, pixelBufferData);
    }
    
    if (CMTimeCompare(currentTime, self.lastFrameTime) != 0 && self.assetWriterVideoInput.isReadyForMoreMediaData) {
        
        if (![self.assetWriterPixelBufferInput appendPixelBuffer:pixel_buffer withPresentationTime:currentTime]) {
            NSLog(@"Problem appending pixel buffer at time: %lld", currentTime.value);
        } else {
//            NSLog(@"Recorded pixel buffer at time: %lld", currentTime.value);
        }
    }
    
    self.lastFrameTime = currentTime;
    
    CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
    
    CVPixelBufferRelease(pixel_buffer);
}

- (void)removeVideos {
    
    NSString *videosFilePath = VIDEOS_FILE_PATH;
    
    NSArray *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videosFilePath error:nil];
    
    [filePaths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL *stop) {
        
        if ([filePath hasSuffix:@".mov"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[videosFilePath stringByAppendingPathComponent:filePath] error:nil];
        }
        
    }];
}

@end
