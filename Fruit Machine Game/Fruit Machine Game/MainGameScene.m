//
//  MainGameScene.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "MainGameScene.h"
#import "MainMenu.h"
#import "Fruit.h"

CGPoint startingPosition;

int xChange, yChange;

int numberOfReels = NUMBER_OF_REELS;
int numberOfFruits = NUMBER_OF_FRUITS;
int numberOfRows = NUMBER_OF_ROWS;

int deviceTag;
CGSize win;

@implementation MainGameScene

+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainGameScene *layer = [MainGameScene node];
	
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
            
        default:
            return @".png";
    }
}

- (id) init {
    
	if( (self=[super init])) {
        
        win = [[CCDirector sharedDirector] winSize];
        
        fruits = [[NSMutableArray alloc] init];
        fruitPositions = [[NSMutableArray alloc] init];
        
        currentReelNumber = 0;
        spinFruits = NO;
        
        [self setDeviceTag];
        
        [self createDisplay];
        
        [self addFruits];
        
        [self schedule:@selector(update)];
    }
    
    self.touchEnabled = YES;
    return self;
    
}

- (void) update {
    
    if (spinFruits) {
        
        [self spinReels];
    }
}

- (void) spinReels {
    
    [self moveFruits];
    
    if (self.numberOfRunningActions == 0) {
        
        CCDelayTime *start = [CCDelayTime actionWithDuration:FRUITS_SPINNING_TIME];
        
        CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) { [self stopFirstReel]; }];
        
        [self runAction:[CCSequence actionOne:start two:stop]];
        
    }
}

- (void) stopFirstReel {
    
    currentReelNumber = FIRST_REEL;
    
    [self setRandomFruits:currentReelNumber];
    
    CCDelayTime *start = [CCDelayTime actionWithDuration:REEL_STOP_DELAY];
    
    CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) { [self stopSecondReel]; }];
    
    [self runAction:[CCSequence actionOne:start two:stop]];
}

- (void) stopSecondReel {
    
    currentReelNumber = SECOND_REEL;
    
    [self setRandomFruits:currentReelNumber];
    
    CCDelayTime *start = [CCDelayTime actionWithDuration:REEL_STOP_DELAY];
    
    CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) { [self stopThirdReel]; }];
    
    [self runAction:[CCSequence actionOne:start two:stop]];
}

- (void) stopThirdReel {
    
    currentReelNumber = THIRD_REEL;
    
    [self setRandomFruits:currentReelNumber];
}

- (void) setRandomFruits:(int)reel {
    
    int start = 0 + (NUMBER_OF_FRUITS * (reel-1));
    
    int position = [self getRandomFruitPosition:start];
    
    int y;
    
    for (Fruit *fruit in fruits) {
        
        if (fruit.getReelPosition == reel) {
            
            fruit.position = ccp(fruit.position.x, win.height);
        }
    }
    
    Fruit *fruit;
    
    for (int column = 1; column < (numberOfRows + 1); column++) {
        
        y = yChange * column;
        
        fruit = [fruits objectAtIndex:position++];
        
        if (position >= (start + NUMBER_OF_FRUITS)) {
            
            position = start;
        }
        
        fruit.position = ccp(fruit.position.x, startingPosition.y + y);
        
        [self runStopAnimation:fruit];
    }
}

- (void) runStopAnimation:(Fruit*)fruit {
    
    double animationTime = REEL_STOP_DELAY/4;
    
    CCMoveTo *down = [CCMoveTo actionWithDuration:animationTime position:ccp(fruit.position.x, fruit.position.y - STOP_ANIMATION_Y_MOVEMENT)];
    CCMoveTo *up = [CCMoveTo actionWithDuration:animationTime position:ccp(fruit.position.x, fruit.position.y + STOP_ANIMATION_Y_MOVEMENT)];
    
    CCSequence *sequence = [CCSequence actions:down, up, nil];
    
    [fruit runAction:sequence];
    
    if (currentReelNumber == THIRD_REEL) {
        
        CCDelayTime *start = [CCDelayTime actionWithDuration:REEL_STOP_DELAY/4];
        
        CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            
            spinFruits = NO;
            currentReelNumber = 0;
            
        }];
        
        [self runAction:[CCSequence actionOne:start two:stop]];
    }
}

- (int) getRandomFruitPosition:(int)start {
    
    return ((arc4random() % NUMBER_OF_FRUITS) + start);
    
}

- (void) moveFruits {
    
    for (Fruit *fruit in fruits) {
        
        if (fruit.position.y <= startingPosition.y) {
            
            fruit.position = ccp(fruit.position.x, (lastFruitYPosition + yChange));
        }
        
        if (fruit.getReelPosition > currentReelNumber) {
            
            fruit.position = ccp(fruit.position.x, fruit.position.y - FRUIT_SPIN_SPEED);
            
        }
    }
}

- (void) addFruits {
    
    [self setFruitPositions];
    
    for (NSValue *position in fruitPositions) {
        
        NSString *file = [NSString stringWithFormat:@"%@%@", @"cherry", [self getImageFileSuffix]];
        
        Fruit *fruit = [Fruit spriteWithFile:file];
        
        fruit.position = ccp(position.CGPointValue.x, position.CGPointValue.y);
        
        [fruit setReel:(((fruit.position.x - startingPosition.x) / xChange) + 1)];
        
        [self addChild:fruit];
        
        [fruits addObject:fruit];
        
    }
}

- (void) setFruitPositions {
    
    [self getStartingPositions];
    
    int x, y;
    
    for (int row = 0; row < NUMBER_OF_REELS; row++) {
        
        x = xChange * row;
        
        for (int column = 0; column < NUMBER_OF_FRUITS; column++) {
            
            y = yChange * column;
            
            [fruitPositions addObject:[NSValue valueWithCGPoint:ccp((startingPosition.x + x) , (startingPosition.y + y))]];
        }
    }
    
    lastFruitYPosition = startingPosition.y + y;
}

- (void) getStartingPositions {
    
    switch (deviceTag) {
            
        case IPHONE:
            
            startingPosition = ccp(85, 120);
            yChange = 70;
            xChange = 75;
            
            break;
            
        default:
            break;
    }
    
}

- (void) createDisplay {
    
    CCSprite *background;
    
    background = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
    
    [self addChild:background];
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"GameBackground", [self getBackgroundFileSuffix]];
    
    background = [CCSprite spriteWithFile:file];
    
    background.position = ccp(win.width/2, win.height/2);
    
    [self addChild:background z:1];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    /* if (touchLocation.y < win.height/2) {
     
     [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainMenu scene]]];
     
     }*/
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:[touch view]];
    lastTouch = [[CCDirector sharedDirector] convertToGL:lastTouch];
    
    if (firstTouch.y > lastTouch.y && !spinFruits) {
        
        if (firstTouch.y >= startingPosition.y && firstTouch.y <= (startingPosition.y + (yChange*numberOfRows))) {
            
            [self resetFruitPositions];
            spinFruits = YES;
            
        }
    }
}

- (void) resetFruitPositions {
    
    int count = 0;
    
    for (NSValue *position in fruitPositions) {
        
        Fruit *fruit = [fruits objectAtIndex:count++];
        
        fruit.position = ccp(position.CGPointValue.x, position.CGPointValue.y);
    }
}

- (void) dealloc {
    
    [super dealloc];
    [fruits release];
    [fruitPositions release];
    
    fruits = NULL;
    fruitPositions = NULL;
}

@end
