//
//  wackAmoleGame.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "WackAmoleGame.h"


@implementation WackAmoleGame

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
       
        CGSize window = [[CCDirector sharedDirector] winSize];
        
        // Sprites
        CCSprite *holeBack = [CCSprite spriteWithFile:@"bg_dirt.png"];
        holeBack.scale = 2.0;
        holeBack.position = ccp(window.width/2, window.height/2);
        
        CCSprite *lowerDown = [CCSprite spriteWithFile:@"lower_lower.png"];
        lowerDown.anchorPoint = ccp(0.5, 1);
        lowerDown.position = ccp(window.width/2, window.height/4);
        
        CCSprite *upperDown = [CCSprite spriteWithFile:@"upper_upper.png"];
        upperDown.anchorPoint = ccp(0.5, 0);
        upperDown.position = ccp(window.width/2, window.height/4);
        
        CCSprite *lowerTop = [CCSprite spriteWithFile:@"lower_lower.png"];
        lowerTop.anchorPoint = ccp(0.5, 0);
        lowerTop.position = ccp(window.width/2, window.height/2.33);
        
        CCSprite *upperTop = [CCSprite spriteWithFile:@"upper_upper.png"];
        upperTop.anchorPoint = ccp(0.5, 1);
        upperTop.position = ccp(window.width/2, window.height);
        
        moles = [[NSMutableArray alloc] init];
        
        CCSprite *mole1 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole1.position = ccp(window.width/3.8, window.height/1.7);
        
        CCSprite *mole2 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole2.position = ccp(window.width/1.35, window.height/1.7);
       
        CCSprite *mole3 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole3.position = ccp(window.width/3.8, window.height/10);
        
        CCSprite *mole4 = [CCSprite spriteWithFile:@"mole_1.png"];
        mole4.position = ccp(window.width/1.35, window.height/10);
        
        // Add Sprites to Array.
        [moles addObject:mole1];
        [moles addObject:mole2];
        [moles addObject:mole3];
        [moles addObject:mole4];
        
        label = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Verdana" fontSize:25.0];
        label.anchorPoint = ccp(0, 0);
        label.position = ccp(window.width/2.8, window.height/2);
        
        // Add Sprites to scene.
        [self addChild:mole1];
        [self addChild:mole2];
        [self addChild:mole3];
        [self addChild:mole4];
        [self addChild:holeBack z:-2];
        [self addChild:lowerDown z:1];
        [self addChild:upperDown z:-1];
        [self addChild:lowerTop z:1];
        [self addChild:upperTop z:-1];
        [self addChild:label z:10];
        
        [self schedule:@selector(tryPopMoles:) interval:0.5];
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) popMole:(CCSprite *)mole {
    CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.2 position:ccp(0, mole.contentSize.height)];
    CCEaseInOut *easeMoveUp = [CCEaseInOut actionWithAction:moveUp rate:3.0];
    CCAction *easeMoveDown = [easeMoveUp reverse];
    
    [mole runAction:[CCSequence actions:easeMoveUp, easeMoveDown, nil]];
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

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    // If out of the hole, make moles tappable.
    for (CCSprite *mole in moles) {
        
        if (CGRectContainsPoint(mole.boundingBox, firstTouch) && mole.numberOfRunningActions != 0) {
            score += 10;
            [label setString:[NSString stringWithFormat:@"Score: %d", score]];
            printf("mole touched");
        } else {
            printf("mole missed");
        }
    }
}

@end
