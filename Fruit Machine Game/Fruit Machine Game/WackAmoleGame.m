//
//  wackAmoleGame.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "WackAmoleGame.h"
#import "MainGameScene.h"

#define TOUCHED 1
#define UNTOUCHED 2


@implementation WackAmoleGame {
    int molesMissed;
    bool screenTouched;
    int deviceTag;
    int iPadScaleFactor;
    StringPtr file;
}

+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	WackAmoleGame *layer = [WackAmoleGame node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    
	// return the scene
	return scene;
}

- (CGPoint)convertPoint:(CGPoint)point {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ccp(32 + point.x*2, 64 + point.y*2);
    } else {
        return point;
    }
}

- (id) init {
    
	if( (self=[super init])) {
        
        [self setDeviceTag];
        
        CGSize window = [[CCDirector sharedDirector] winSize];
        
        molesMissed = 0;
        screenTouched = NO;
        
        // Sprites
        CCSprite *holeBack = [CCSprite spriteWithFile:@"bg_dirt.png"];
        holeBack.scale = 2.0;
        holeBack.position = ccp(window.width/2, window.height/2);
        
        CCSprite *background;
        CCSprite *uplower;
        CCSprite *lowlower;
        
        CCSprite *mole1 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole1.position = ccp(window.width/3.8, window.height/1.7);
        
        CCSprite *mole2 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole2.position = ccp(window.width/1.35, window.height/1.7);
        
        CCSprite *mole3 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole3.position = ccp(window.width/3.8, window.height/10);
        
        CCSprite *mole4 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole4.position = ccp(window.width/1.35, window.height/10);
        
        switch (deviceTag) {
            case NONRETINA:
                background = [CCSprite spriteWithFile:@"iphone4S.png"];
                background.scale = 0.5;
                
                lowlower = [CCSprite spriteWithFile:@"loweriphone4S.png"];
                lowlower.scale = 0.5;
                lowlower.anchorPoint = ccp(0.5, 0.5);
                lowlower.position = ccp(window.width/2, 30);
                
                uplower = [CCSprite spriteWithFile:@"loweriphone4S.png"];
                uplower.scale = 0.5;
                uplower.anchorPoint = ccp(0.5, 0.5);
                uplower.position = ccp(window.width/2, window.height/1.85);
                
                mole1.scale = 0.5;
                mole2.scale = 0.5;
                mole3.scale = 0.5;
                mole4.scale = 0.5;
                break;
            case IPHONE:
                background = [CCSprite spriteWithFile:@"iphone4S.png"];
                
                lowlower = [CCSprite spriteWithFile:@"loweriphone4S.png"];
                lowlower.anchorPoint = ccp(0.5, 0.5);
                lowlower.position = ccp(window.width/2, 30);
                
                uplower = [CCSprite spriteWithFile:@"loweriphone4S.png"];
                uplower.anchorPoint = ccp(0.5, 0.5);
                uplower.position = ccp(window.width/2, window.height/1.85);
                break;
            case IPHONE5:
                background = [CCSprite spriteWithFile:@"iphone5.png"];
                
                lowlower = [CCSprite spriteWithFile:@"loweriphone5.png"];
                lowlower.anchorPoint = ccp(0.5, 0.5);
                lowlower.position = ccp(window.width/2, 68);
                
                printf("here");
                uplower = [CCSprite spriteWithFile:@"loweriphone5.png"];
                uplower.anchorPoint = ccp(0.5, 0.5);
                uplower.position = ccp(window.width/2, window.height/1.66);
                break;
            case IPAD:
                background = [CCSprite spriteWithFile:@"ipadMini.png"];
                
                lowlower = [CCSprite spriteWithFile:@"loweripadMini.png"];
                lowlower.anchorPoint = ccp(0.5, 0.5);
                lowlower.position = ccp(window.width/1.98, 139);
                
                uplower = [CCSprite spriteWithFile:@"loweripadMini.png"];
                uplower.anchorPoint = ccp(0.5, 0.5);
                uplower.position = ccp(window.width/1.98, window.height/1.66);
                break;
            case IPADHD:
                background = [CCSprite spriteWithFile:@"ipadMini.png"];
                background.scale = iPadScaleFactor;
                
                mole1.scale = iPadScaleFactor;
                mole1.position = ccp(window.width/3.8, window.height/1.66);
                mole2.scale = iPadScaleFactor;
                mole2.position = ccp(window.width/1.35, window.height/1.66);
                mole3.scale = iPadScaleFactor;
                mole3.position = ccp(window.width/3.8, window.height/7.5);
                mole4.scale = iPadScaleFactor;
                mole4.position = ccp(window.width/1.35, window.height/7.5);
                
                lowlower = [CCSprite spriteWithFile:@"loweripadMini.png"];
                lowlower.scale = iPadScaleFactor;
                lowlower.anchorPoint = ccp(0.5, 0.5);
                lowlower.position = ccp(window.width/1.98, 139);
                
                uplower = [CCSprite spriteWithFile:@"loweripadMini.png"];
                uplower.scale = iPadScaleFactor;
                uplower.anchorPoint = ccp(0.5, 0.5);
                uplower.position = ccp(window.width/1.98, window.height/1.66);
                break;
            default:
                break;
        }
        
        background.anchorPoint = ccp(0.5, 0.5);
        background.position = ccp(window.width/2, window.height/2);

        
        
        moles = [[NSMutableArray alloc] init];
        
        
        
        // Add Sprites to Array.
        
        mole1.tag = TOUCHED;
        mole2.tag = TOUCHED;
        mole3.tag = TOUCHED;
        mole4.tag = TOUCHED;
        
        [moles addObject:mole1];
        [moles addObject:mole2];
        [moles addObject:mole3];
        [moles addObject:mole4];
        
        label = [CCLabelTTF labelWithString:@"Coins: 0" fontName:@"Verdana" fontSize:25.0];
        label.anchorPoint = ccp(0.5, 0.5);
        label.position = ccp(window.width/2, window.height/2);
        
        // Add Sprites to scene.
        [self addChild:mole1];
        [self addChild:mole2];
        [self addChild:mole3];
        [self addChild:mole4];
        [self addChild:label z:10];
        [self addChild:background z:-1];
        [self addChild:uplower z:1];
        [self addChild:lowlower z:1];
        
        [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1.5] two:[CCCallBlockN actionWithBlock:^(CCNode *node) {
            
            [self schedule:@selector(tryPopMoles:) interval:0.5];
            [self schedule:@selector(update)];
            
        }]]];
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) update {
    
    [label setString:[NSString stringWithFormat:@"Coins: %d", score]];
}

- (void) popMole:(CCSprite *)mole {
    
    CCMoveBy *moveUp;
    if(deviceTag == IPADHD) {
        moveUp = [CCMoveBy actionWithDuration:0.4 position:ccp(0, mole.contentSize.height + 70)];
    } else if (deviceTag == NONRETINA){
        moveUp = [CCMoveBy actionWithDuration:0.4 position:ccp(0, mole.contentSize.height - 100)];
    } else {
        moveUp = [CCMoveBy actionWithDuration:0.4 position:ccp(0, mole.contentSize.height)];
    }
    CCEaseInOut *easeMoveUp = [CCEaseInOut actionWithAction:moveUp rate:3.0];
    CCAction *easeMoveDown = [easeMoveUp reverse];
    
    [mole runAction:[CCSequence actions:easeMoveUp, easeMoveDown,
                     
    [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [self hasMoleBeenTouched:mole];
    }],
                     
    nil]];
    
    mole.tag = UNTOUCHED;
}

- (void)tryPopMoles:(ccTime)dt {
    for (CCSprite *mole in moles) {
        if (arc4random() % 3 == 0) {
            if (mole.numberOfRunningActions == 0) {
                [self popMole:mole];
            }
        }
    }
}

- (void) hasMoleBeenTouched:(CCSprite*)mole {
    
     [label setString:[NSString stringWithFormat:@"Coins: %d", score]];
    
    if (mole.tag == UNTOUCHED) {
        
        molesMissed += 1;
        
        if (molesMissed >= 15) {
            [self backToGame];
        }
        
    }
    
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    // If out of the hole, make moles tappable.
    
    screenTouched = YES;
    
    for (CCSprite *mole in moles) {
        
        if (CGRectContainsPoint(mole.boundingBox, firstTouch) && mole.numberOfRunningActions != 0) {
            score += 100;
            
            mole.tag = TOUCHED;
            
            screenTouched = NO;
        }
    }
    
    if (screenTouched) {
        molesMissed += 1;
    }
}

- (void) backToGame {
    
    int total = [[NSUserDefaults standardUserDefaults] integerForKey:TOTALCREDITS];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(total + score) forKey:TOTALCREDITS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainGameScene scene]]];
}

- (void) setDeviceTag {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        iPadScaleFactor = 1;
        
       
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            
            
            
            iPadScaleFactor = 1;
            deviceTag = IPHONE;
            
        } else {
            iPadScaleFactor = 0.5;
            deviceTag = NONRETINA;
        }
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            deviceTag = IPHONE5;
        }
        
        
       
        
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        iPadScaleFactor = 2;
        
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            deviceTag = IPADHD;
        } else {
            deviceTag = IPAD;
        }
    }
}



@end
