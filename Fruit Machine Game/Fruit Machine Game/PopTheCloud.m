//
//  PopTheCloud.m
//  Fruit Machine Game
//
//  Created by Matthew Herod.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "PopTheCloud.h"
#import "MainGameScene.h"

@implementation PopTheCloud {
    
    double iPadScaleFactor;
    CGSize window;
    
}

+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PopTheCloud *layer = [PopTheCloud node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
    
	if( (self=[super init])) {
        
        popped = 0;
        score = 0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        window = [[CCDirector sharedDirector] winSize];
        
        [self setDeviceScale];
        
        CCSprite *background;
        
        background = [CCLayerColor layerWithColor:ccc4(100,255,255,255)]; //blue
        
        [self addChild:background z:-1];
        
        coin = [CCSprite spriteWithFile:@"coin.png"];
        cross =  [CCSprite spriteWithFile:@"cross.png"];
        
        cross.scale = coin.scale = iPadScaleFactor;
        
        [coin setVisible:NO];
        [cross setVisible:NO];
        
        [self addChild:coin z:3];
        [self addChild:cross z:3];
        
        clouds = [[NSMutableArray alloc] init];
        
        // Add Sprites to Array.
        
        // clouds
        CCSprite *cloud1 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud2 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud3 = [CCSprite spriteWithFile:@"cloud.png"];
        
        cloud1.tag = 1;
        cloud2.tag = 2;
        cloud3.tag = 3;
        
        [clouds addObject:cloud1];
        [clouds addObject:cloud2];
        [clouds addObject:cloud3];
        
        // middle x, y
        y = window.height / 2;
        x = window.width / 2;
        
        // position them all spaced out evenly
        cloud1.position = ccp(x, y - (y / 1.5) - 0);
        cloud2.position = ccp(x, y - 15);
        cloud3.position = ccp(x, y + (y / 1.5) - 20);
        
        for (CCSprite *cloud in clouds) {
            cloud.scale = cloud.scale * iPadScaleFactor;
        }
        
        [self addChild:cloud1 z:4];
        [self addChild:cloud2 z:4];
        [self addChild:cloud3 z:4];
        
        crowcoin = [[CCSprite alloc] init];
        crowcoin.scale = 0.4 * iPadScaleFactor;
        crowcoin.position = ccp(window.width, window.height);
        
        [self addChild:crowcoin z:5];
        
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana" fontSize:(72.0 * iPadScaleFactor)];
        scoreLabel.anchorPoint = ccp(0, 0);
        scoreLabel.color = ccc3(240,240,100);
        scoreLabel.position = ccp(0, window.height - (72 * iPadScaleFactor));
        
        [self addChild:scoreLabel z:10];
        
        [self schedule:@selector(tryAnims)];
        
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) setDeviceScale {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        iPadScaleFactor = 1;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            
            iPadScaleFactor = 1;
            
        } else {
            
            iPadScaleFactor = 0.5;
        }
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            iPadScaleFactor = 2;
        } else {
            iPadScaleFactor = 1.2;
        }
    }
}

- (void) raiseScore {
    
    int multiplier = [[NSUserDefaults standardUserDefaults] integerForKey:CURRENT_LEVEL];
    
    popped += 1;
    score += 50 * popped * multiplier;
    [scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void) tryAnims {
    
    for (CCSprite *cloud in clouds) {
        if (cloud.numberOfRunningActions == 0) {
            [self tryMoveCloud:cloud];
        }
    }
    
    [self tryMoveCrow:crowcoin];
    
    
    
}

- (void) tryMoveCloud:(CCSprite *)cloud0 {
    
    int move = 0;
    if ((arc4random() % 2) == 0){
        move = 0 - cloud0.contentSize.width / 10;
    } else {
        move = 0 + cloud0.contentSize.width / 10;
    }
    CCMoveBy *moveSide = [CCMoveBy actionWithDuration:3.0 position:ccp(move, 0)];
    CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:1.0];
    CCAction *easeBack = [easeSide reverse];
    
    [cloud0 runAction:[CCSequence actions:easeSide, easeBack,
                       
                       [CCCallBlockN actionWithBlock:^(CCNode *node) {
        //[cloud0 setVisible:YES];
    }],
                       
                       nil]];
    
}

- (void) tryMoveCrow:(CCSprite *)crow {
    
    if (crow.numberOfRunningActions == 0) {
        
        CCAnimation *crowcoinanim = [CCAnimation animation];
        [crowcoinanim addSpriteFrameWithFilename:@"crowcoin1.png"];
        [crowcoinanim addSpriteFrameWithFilename:@"crowcoin2.png"];
        
        crowcoin.anchorPoint = ccp(1, 1);
        
        [crow runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:0.8f animation:crowcoinanim restoreOriginalFrame:NO]]];
        
    }
}

- (void) backToGame {
    
    int total = [[NSUserDefaults standardUserDefaults] integerForKey:TOTALCREDITS];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(total + score) forKey:TOTALCREDITS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainGameScene scene]]];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    if (coin.visible) {
        return;
    }
    if (cross.visible) {
        return;
    }
    
    for (CCSprite *cloud in clouds) {
        if (CGRectContainsPoint(cloud.boundingBox, firstTouch)) {
            
            coin.position = cloud.position;
            cross.position = cloud.position;
            
            [cloud setVisible:NO];
            
            if ((arc4random() % 4) != 0){
                
                CCMoveBy *moveSide = [CCMoveBy actionWithDuration:1.0 position:ccp(-(x*2), 0)];
                CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:5.0];
                [coin runAction:[CCSequence actions:easeSide,
                                 
                                 [CCCallBlockN actionWithBlock:^(CCNode *node) {
                    [coin setVisible:NO];
                    [cloud setVisible:YES];
                }]
                                 
                                 , nil]];
                
                [coin setVisible:YES];
                
                [self raiseScore];
                
            } else {
                
                CCMoveBy *moveSide = [CCMoveBy actionWithDuration:1.0 position:ccp(-(x*2), 0)];
                CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:5.0];
                [cross runAction:[CCSequence actions:easeSide,
                                  
                                  [CCCallBlockN actionWithBlock:^(CCNode *node) {
                    [cross setVisible:NO];
                    [cloud setVisible:YES];
                    [self backToGame];
                }]
                                  
                                  , nil]];
                
                [cross setVisible:YES];
                
            }
            
            
        }
    }
    
    
}

@end
