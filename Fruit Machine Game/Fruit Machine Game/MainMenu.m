//
//  MainMenu.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "MainMenu.h"
#import "MainGameScene.h"

int deviceTag;
CGSize win;

@implementation MainMenu

+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *layer = [MainMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) setDeviceTag {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            
            deviceTag = IPHONE5;
            
        } else {
            
            deviceTag = IPHONE;
            
        }
        
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            
            deviceTag = IPADHD;
            
        } else {
            
            deviceTag = IPAD;
            
        }
    }
    
}

- (NSString*) getBackgroundFileSuffix {
    
    switch (deviceTag) {
            
        case IPHONE:
            return @".png";
            
        case IPHONE5:
            return @"@i5.png";
            
        case IPAD:
            return @"@ipad.png";
            
        case IPADHD:
            return @"@ipadhd.png";
            
        default:
            return @"";
    }
    
}

- (NSString*) getImageFileSuffix {
    
    switch (deviceTag) {
            
        case IPADHD:
            return @"@ipadhd.png";
     
        default:
            return @".png";
    }
}

- (id) init {
    
	if( (self=[super init])) {
        
        win = [[CCDirector sharedDirector] winSize];
        
        [self setDeviceTag];
        
        [self createDisplay];
    }
    
    self.touchEnabled = YES;
    return self;
    
}

- (void) createDisplay {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"MenuBackground", [self getBackgroundFileSuffix]];
    
    CCSprite *background = [CCSprite spriteWithFile:file];
    
    background.position = ccp(win.width/2, win.height/2);
    
    [self addChild:background];
    
    [self setPlayLabel];
    
    [self setLogo];
}

- (void) setPlayLabel {
    
    playLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"insert coin to play"] fontName:@"Heiti TC" fontSize:INSERT_COIN_FONTSIZE];
    
    playLabel.color = ccBLACK;
    
    playLabel.position = ccp(win.width/2, win.height/10);
    
    [self addChild:playLabel];
    
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:30];
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    
    [playLabel runAction:repeat];
    
}

- (void) setLogo {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"FruitySlotsLogo", [self getImageFileSuffix]];
    
    CCSprite *logo = [CCSprite spriteWithFile:file];
    
    logo.position = ccp(win.width/2, win.height/1.8);
    
    [self addChild:logo];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    if (touchLocation.y < win.height/2) {
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainGameScene scene]]];
        
    }
}

@end
