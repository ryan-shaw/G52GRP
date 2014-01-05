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

NSMutableArray *fruits;
NSMutableArray *fruitPositions;

int currentReelNumber;

double lastFruitYPosition;
BOOL spinFruits;

CGPoint firstTouch, lastTouch;

CGPoint startingPosition;

CCLabelTTF *pointsLabel, *betLabel;

int xChange, yChange;

int numberOfReels = NUMBER_OF_REELS;
int numberOfFruits = NUMBER_OF_FRUITS;
int numberOfRows = NUMBER_OF_ROWS;

int pointsScore, labelScore, bet, minBet, maxBet;

int deviceTag;
int iOS7ScaleFactor;
int iPadScaleFactor;
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
        
        iPadScaleFactor = 1;
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            
            deviceTag = IPHONE5;
            
        } else {
            
            deviceTag = IPHONE;
            
        }
        
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        iPadScaleFactor = 2;
        
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            
            deviceTag = IPADHD;
            
        } else {
            
            deviceTag = IPAD;
            
        }
    }
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    BOOL isAtLeast7 = [version floatValue] >= 7.0;
    
    if (isAtLeast7) {
        
        iOS7ScaleFactor = 20;
        
    } else {
        
        iOS7ScaleFactor = 0;
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
        labelScore = 0;
        bet = 0;
        spinFruits = NO;
        
        [self setDeviceTag];
        
        [self createDisplay];
        
        [self addFruits];
        
        [self setMinMaxBets];
        
        [self schedule:@selector(update)];
    }
    
    self.touchEnabled = YES;
    return self;
    
}

- (void) setMinMaxBets {
    
    minBet = 0;
    maxBet = 250;
    
}

- (void) update {
    
    [self displayCredits];
    
    [self spinReels];
}

- (void) spinReels {
    
    if (spinFruits) {
        
        [self moveFruits];
        
        if (self.numberOfRunningActions == 0) {
            
            CCDelayTime *start = [CCDelayTime actionWithDuration:FRUITS_SPINNING_TIME];
            
            CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) { [self stopFirstReel]; }];
            
            [self runAction:[CCSequence actionOne:start two:stop]];
        }
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
    
    int start = 0 + (numberOfFruits * (reel-1));
    
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
        
        if (position >= (start + numberOfFruits)) {
            
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
        
        [self stopAllActions];
        
        CCDelayTime *start = [CCDelayTime actionWithDuration:REEL_STOP_DELAY];
        
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
    
    NSString *file;
    
    int count = 0;
    
    int startPosition = arc4random() % numberOfFruits;
    
    for (NSValue *position in fruitPositions) {
        
        switch (++startPosition) {
                
            case 1:
                
                file = [NSString stringWithFormat:@"%@%@", @"cherry", [self getImageFileSuffix]];
                break;
                
            case 2:
                
                file = [NSString stringWithFormat:@"%@%@", @"strawberry", [self getImageFileSuffix]];
                break;
                
            case 3:
                
                file = [NSString stringWithFormat:@"%@%@", @"melon", [self getImageFileSuffix]];
                break;
                
            case 4:
                
                file = [NSString stringWithFormat:@"%@%@", @"apple", [self getImageFileSuffix]];
                break;
                
            case 5:
                
                file = [NSString stringWithFormat:@"%@%@", @"pear", [self getImageFileSuffix]];
                break;
                
            case 6:
                
                file = [NSString stringWithFormat:@"%@%@", @"orange", [self getImageFileSuffix]];
                break;
                
            case 7:
                
                file = [NSString stringWithFormat:@"%@%@", @"banana", [self getImageFileSuffix]];
                startPosition = 0;
                break;
                
            default:
                startPosition = 0;
                break;
        }
        
        if (++count >= numberOfFruits) {
            
            count = 0;
            startPosition = arc4random() % numberOfFruits;
        }
        
        Fruit *fruit = [Fruit spriteWithFile:file];
        
        fruit.position = ccp(position.CGPointValue.x, position.CGPointValue.y);
        
        [fruit setReel:(((fruit.position.x - startingPosition.x) / xChange) + 1)];
        
        [self addChild:fruit z:-1];
        
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
    
    [self addChild:background z:-1];
    
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"GameBackground", [self getBackgroundFileSuffix]];
    
    background = [CCSprite spriteWithFile:file];
    
    background.position = ccp(win.width/2, win.height/2);
    
    [self addChild:background];
    
    
    pointsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", labelScore] fontName:@"Heiti TC" fontSize:POINTS_FONTSIZE*iPadScaleFactor];
    
    pointsLabel.position = ccp(win.width/2, win.height - (30 * iPadScaleFactor + iOS7ScaleFactor));
    
    pointsLabel.color = ccWHITE;//ccBLACK;
    
    [self addChild:pointsLabel];
    
    
    betLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", bet] fontName:@"Heiti TC" fontSize:POINTS_FONTSIZE*iPadScaleFactor];
    
    betLabel.position = ccp(pointsLabel.position.x + 60, win.height/8);
    
    betLabel.color = ccBLACK;
    
    [betLabel setAnchorPoint:ccp(1, 0.5)];
    
    [self addChild:betLabel];
    
    [self setMenuButtons];
}

- (void) displayCredits {
    
    if (pointsScore > labelScore) {
        
        labelScore += SCORE_DISPLAY_CHANGE;
        [pointsLabel setString:[NSString stringWithFormat:@"%i", labelScore]];
        
    } else if (pointsScore < labelScore) {
        
        labelScore -= SCORE_DISPLAY_CHANGE;
        [pointsLabel setString:[NSString stringWithFormat:@"%i", labelScore]];
    }
    
    [betLabel setString:[NSString stringWithFormat:@"%i", bet]];
}

- (void) setMenuButtons {
    
    NSString *file;
    
    file = [NSString stringWithFormat:@"%@%@", @"cherry", [self getImageFileSuffix]];
    
    CCMenuItem *returnButton = [CCMenuItemImage itemWithNormalImage:file selectedImage:file target:self selector:@selector(returnButtonPressed)];
    
    returnButton.position = ccp(win.width/10, pointsLabel.position.y);
    
    returnButton.scale = 0.5;
    
    
    
   /* file = [NSString stringWithFormat:@"%@%@", @"betMin", [self getImageFileSuffix]];
    
    CCMenuItem *betMin = [CCMenuItemImage itemWithNormalImage:file selectedImage:file target:self selector:@selector(betMin)];
    
    betMin.position = ccp(win.width/4, win.height/8);
    
    
    file = [NSString stringWithFormat:@"%@%@", @"betMax", [self getImageFileSuffix]];
    
    CCMenuItem *betMax = [CCMenuItemImage itemWithNormalImage:file selectedImage:file target:self selector:@selector(betMax)];
    
    betMax.position = ccp(betMin.position.x, betMin.position.y + 55);*/
    
    
    
    
    CCMenu *menu = [CCMenu menuWithItems:returnButton,nil];//, betMin, betMax, nil];
    menu.position = CGPointZero;
    
    [self addChild:menu];
}

- (void) returnButtonPressed {
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainMenu scene]]];
}

- (void) decreaseBet {
    
    if (bet > minBet) {
        
        bet -= SCORE_DISPLAY_CHANGE;
    }
}

- (void) increaseBet {
    
    if (bet < maxBet) {
        
        bet += SCORE_DISPLAY_CHANGE;
    }
}

- (void) betMin {
    
    bet = minBet;
    
}

- (void) betMax {
    
    bet = maxBet;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:[touch view]];
    lastTouch = [[CCDirector sharedDirector] convertToGL:lastTouch];
    
    [self swipeDownOnReels];
    
    [self swipeAcrossBet];
    
}

- (void) swipeAcrossBet {
    
    if (lastTouch.y < startingPosition.y) {
        
        double touchDifference = lastTouch.x - firstTouch.x;
        
        if (touchDifference > 20) {
            
            [self increaseBet];
            firstTouch = lastTouch;
            
        } else if (touchDifference < - 20) {
            
            [self decreaseBet];
            firstTouch = lastTouch;
        }
    }
}

- (void) swipeDownOnReels {
    
    if (firstTouch.y > (lastTouch.y + yChange/2) && !spinFruits) {
        
        if (firstTouch.y >= startingPosition.y && firstTouch.y <= (startingPosition.y + (yChange*(numberOfRows + 1)))) {
            
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
