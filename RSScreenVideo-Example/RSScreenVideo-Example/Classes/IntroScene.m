//
//  IntroScene.m
//  RSScreenVideo-Example
//
//  Created by Austin Borden on 1/12/14.
//  Copyright RareSloth LLC 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "IntroScene.h"
#import "RSScreenVideo.h"

@interface IntroScene ()
@property (nonatomic, strong) RSScreenVideo *screenVideo;
@property (nonatomic, strong) CCSprite *raresloth;
@end

@implementation IntroScene

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    [self addChild:background];
    
    // Main title
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"RSScreenVideo" fontName:@"Verdana-Bold" fontSize:24.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor whiteColor];
    label.position = ccp(0.5f, 0.8f);
    [self addChild:label];
    
    // RareSloth
    self.raresloth = [CCSprite spriteWithImageNamed:@"raresloth.png"];
    self.raresloth.positionType = CCPositionTypeNormalized;
    self.raresloth.position = ccp(0.5f, 0.53f);
    self.raresloth.scale = 0.2f;
    [self addChild:self.raresloth];
    
    // Start Button
    CCButton *startButton = [CCButton buttonWithTitle:@"[ Start ]" fontName:@"Verdana" fontSize:18.0f];
    startButton.positionType = CCPositionTypeNormalized;
    startButton.position = ccp(0.5f, 0.25f);
    startButton.color = [CCColor greenColor];
    [startButton setTarget:self selector:@selector(startTapped:)];
    [self addChild:startButton];

    // Stop Button
    CCButton *stopButton = [CCButton buttonWithTitle:@"[ Stop ]" fontName:@"Verdana" fontSize:18.0f];
    stopButton.positionType = CCPositionTypeNormalized;
    stopButton.position = ccp(0.5f, 0.12f);
    stopButton.color = [CCColor redColor];
    [stopButton setTarget:self selector:@selector(stopTapped:)];
    [self addChild:stopButton];
    
    /*
     This initialization will set the recording names to be "example_n.mov", where n is the nth time startRecording is called.
	 Set appendsTakeNumber to NO if you want to only ever have one recording created called "example.mov".
     
     kCVPixelFormatType_32BGRA works with textures configured with CCTexturePixelFormat_RGBA8888 (default),
     not sure what other combinations will work.
     */
    self.screenVideo = [[RSScreenVideo alloc] initWithFileName:@"example"
                                                    screenSize:[[CCDirector sharedDirector] viewSizeInPixels]
                                                   pixelFormat:kCVPixelFormatType_32BGRA];
    
	return self;
}

#pragma mark - Button Callbacks

- (void)startTapped:(id)sender
{
    [self.screenVideo startRecording];
    
    [self.raresloth runAction:[CCActionRepeatForever actionWithAction:
                               [CCActionSequence actionOne:[CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:1 scale:0.4f] rate:3]
                                                       two:[CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:1 scale:0.2f] rate:3]]]];
    
    NSLog(@"Started Recording");
}

- (void)stopTapped:(id)sender
{
    [self.raresloth stopAllActions];
    
    [self.screenVideo stopRecordingWithCompletion:^{
        NSLog(@"Completed Recording");
    }];
}

@end
