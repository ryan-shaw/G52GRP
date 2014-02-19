//
//  MainMenu.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "MainMenu.h"
#import "MainGameScene.h"


@implementation MainMenu {
    
    CCLabelTTF *playLabel;
    int deviceTag, scaleFactor;
    CGSize win;
    
    CCSprite *optionBar;
    CCMenu *menu;

}

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
        
        scaleFactor = 1;
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            
            deviceTag = IPADHD;
            
        } else {
            
            deviceTag = IPAD;
            
        }
        
        scaleFactor = 2;
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
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
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
    
    [self setOptions];
}

- (void) setOptions {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"optionBar", [self getImageFileSuffix]];
    
    CCSprite *select, *unselect;
    
    optionBar = [CCSprite spriteWithFile:file];
    
    optionBar.position = ccp(-optionBar.contentSize.width/2.8, win.height/1.15);
    
    [self addChild:optionBar];
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"option", [self getImageFileSuffix]];
    
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.scale = 0.85;
    
    CCMenuItemSprite *optionButton = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(extendOptions)];
    optionButton.position = ccp(optionBar.contentSize.width/16, optionBar.position.y);
    
    CCMenu *otherMenu = [CCMenu menuWithItems: optionButton, nil];
    otherMenu.position = CGPointZero;
    
    [self addChild:otherMenu];
    
    
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"muteOff", [self getImageFileSuffix]];
    select = [CCSprite spriteWithFile:file];
    
    file = [NSString stringWithFormat:@"%@%@", @"muteOn", [self getImageFileSuffix]];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *mute = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(mute)];
    mute.position = ccp(optionButton.position.x*1.5 + optionBar.contentSize.width/6, optionBar.position.y);
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"leaderboard", [self getImageFileSuffix]];
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *leaderboard = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(showLeaderboard)];
    leaderboard.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*2, optionBar.position.y);
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"reset", [self getImageFileSuffix]];

    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *question = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(reset)];
    question.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*3, optionBar.position.y);
    
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"question", [self getImageFileSuffix]];
    
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *reset = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(showHelp)];
    reset.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*4, optionBar.position.y);
    
    
    
    menu = [CCMenu menuWithItems: mute, leaderboard, question, reset, nil];
    menu.position = CGPointZero;
    
    [self addChild:menu];
    menu.opacity = 0;
}

- (void) reset {
    
    
    
}

- (void) showLeaderboard {
    
}

- (void) showHelp {
    
}

- (void) mute {
    
}

- (void) extendOptions {
    
    if (optionBar.numberOfRunningActions == 0) {
        
        if (optionBar.position.x < 0) {
            
            [optionBar runAction:[CCMoveTo actionWithDuration:OPTION_BAR_MOVE_TIME position:ccp(optionBar.contentSize.width/2.50, optionBar.position.y)]];
            
            menu.enabled = YES;
            [menu runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:OPTION_BAR_MOVE_TIME] two:[CCFadeIn actionWithDuration:0.1]]];
            
        } else {
            
            [optionBar runAction:[CCMoveTo actionWithDuration:OPTION_BAR_MOVE_TIME position:ccp(-optionBar.contentSize.width/2.8, optionBar.position.y)]];
            menu.opacity = 0;
            menu.enabled = NO;
        }
    }
}

- (void) setPlayLabel {
    
    playLabel = [CCLabelTTF labelWithString:PLAY_LABEL_TEXT fontName:PLAY_LABEL_FONT fontSize:INSERT_COIN_FONTSIZE*scaleFactor];
    
    playLabel.color = ccWHITE;
    
    playLabel.position = ccp(win.width/2, win.height/10);
    
    [self addChild:playLabel];
    
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:30];
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    
    [playLabel runAction:repeat];
    
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
