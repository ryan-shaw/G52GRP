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

CCSprite *powerBar, *xpBar;

NSMutableArray *fruits;
NSMutableArray *fruitPositions;
NSMutableArray *fruitImages;

int currentReelNumber;

double lastFruitYPosition;
BOOL fruitsSpinning, powerActive;

CGPoint firstTouch, lastTouch;

CGPoint startingPosition;

CCLabelTTF *totalCreditsLabel, *betLabel, *winLabel, *levelLabel;

int xChange, yChange;

int numberOfReels = NUMBER_OF_REELS;
int numberOfFruits = NUMBER_OF_FRUITS;
int numberOfRows = NUMBER_OF_ROWS;

int reel1Fruit, reel2Fruit, reel3Fruit;

int totalSpend = 0, totalXP;

int totalCredits, tCreditsLabelScore, bet = 0, winnings = 0, minBet, maxBet;
int currentLevel;

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
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        fruits = [[NSMutableArray alloc] init];
        fruitPositions = [[NSMutableArray alloc] init];
        fruitImages = [[NSMutableArray alloc] init];
        
        currentReelNumber = 0;
        tCreditsLabelScore = 0;
        fruitsSpinning = NO;
        powerActive = YES;
        currentLevel = 1;
        totalXP = 0;
        
        [self setDeviceTag];
        
        [self createDisplay];
        
        [self addFruits];
        
        [self setTotalCredits];
        
        [self setMinMaxBets];
        
        [self schedule:@selector(update)];
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) setTotalCredits {
    
    totalCredits = 1000;
    tCreditsLabelScore = totalCredits;
    [totalCreditsLabel setString:[NSString stringWithFormat:@"$ %i", tCreditsLabelScore]];
}

- (void) setMinMaxBets {
    
    minBet = CREDITS_CHANGE * currentLevel;
    maxBet = minBet * NUMBER_OF_DIFFERENT_BETS;
    
    if (bet == 0) {
        
        bet = minBet;
    }
}

- (void) update {
    
    [self displayCredits];
    
    [self spinReels];
    
    [self correctCredits];
    
}

- (void) correctCredits {
    
    if (!fruitsSpinning) {
        
        if (maxBet > totalCredits) {
            
            maxBet = totalCredits;
            
        } else {
            
            maxBet = minBet * NUMBER_OF_DIFFERENT_BETS;
        }
        
        if (bet > maxBet && maxBet > 0) {
            
            bet = maxBet;
        }
        
        if (totalCredits <= 0) {
            
            totalCredits = MIN_STARTING_CREDITS * currentLevel;
            [self setMinMaxBets];
        }
    }
}

- (void) spinReels {
    
    if (fruitsSpinning) {
        
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
    
    [self payOut];
}

- (void) payOut {
    
    if (reel1Fruit == reel2Fruit && reel2Fruit == reel3Fruit) {
        
        [self increaseXPBar:WIN_XP];
        
        switch (reel1Fruit) {
                
            case CHERRY:
                winnings = bet * CHERRY_MULT;
                break;
                
            case STRAWBERRY:
                winnings = bet * STRAWBERRY_MULT;
                break;
                
            case MELON:
                winnings = bet * MELON_MULT;
                break;
                
            case APPLE:
                winnings = bet * APPLE_MULT;
                break;
                
            case PEAR:
                winnings = bet * PEAR_MULT;
                break;
                
            case BANANA:
                winnings = bet * BANANA_MULT;
                break;
                
            case ORANGE:
                winnings = bet * ORANGE_MULT;
                break;
                
            default:
                break;
        }
        
        totalCredits += winnings;
        [winLabel setString:[NSString stringWithFormat:@"$ %i", winnings]];
        
    } else {
        
        winnings = 0;
        [winLabel setString:[NSString stringWithFormat:@"$ %i", winnings]];
    }
}

- (void) runStopAnimation:(Fruit*)fruit {
    
    double animationTime = FRUIT_BOUNCE_ANIMATION_TIME;
    
    CCMoveTo *down = [CCMoveTo actionWithDuration:animationTime position:ccp(fruit.position.x, fruit.position.y - STOP_ANIMATION_Y_MOVEMENT)];
    CCMoveTo *up = [CCMoveTo actionWithDuration:animationTime position:ccp(fruit.position.x, fruit.position.y + STOP_ANIMATION_Y_MOVEMENT)];
    
    CCSequence *sequence = [CCSequence actions:down, up, nil];
    
    [fruit runAction:sequence];
    
    if (currentReelNumber == THIRD_REEL) {
        
        [self stopAllActions];
        
        CCDelayTime *start = [CCDelayTime actionWithDuration:REEL_STOP_DELAY];
        
        CCCallBlock *stop = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            
            fruitsSpinning = NO;
            currentReelNumber = 0;
            
        }];
        
        [self runAction:[CCSequence actionOne:start two:stop]];
    }
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

- (int) getRandomFruitPosition:(int)start {
    
    int tag;
    
    switch (currentReelNumber) {
            
        case FIRST_REEL:
            
            tag = [self firstReelRandomFruit];
            reel1Fruit = tag;
            break;
            
        case SECOND_REEL:
            
            tag = [self secondReelRandomFruit];
            reel2Fruit = tag;
            break;
            
        case THIRD_REEL:
            
            tag = [self thirdReelRandomFruit];
            reel3Fruit = tag;
            break;
            
        default:
            tag = 0;
            break;
    }
    
    
    Fruit *fruit;
    
    for (int i = start; i < (start + numberOfFruits); i++) {
        
        fruit = [fruits objectAtIndex:i];
        
        if (fruit.tag == tag) {
            
            if ((i - 1) < start) {
                
                return ((start + numberOfFruits) - 1);
                
            } else {
                
                return (i - 1);
            }
        }
    }
    return ((arc4random() % numberOfFruits) + start);
}

- (int) randomFruit:(int)fruit {
    
    switch (arc4random() % numberOfFruits) {
            
        case 0:
            
            if (fruit != CHERRY) {
                
                return CHERRY;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 1:
            
            if (fruit != STRAWBERRY) {
                
                return STRAWBERRY;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 2:
            
            if (fruit != MELON) {
                
                return MELON;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 3:
            
            if (fruit != APPLE) {
                
                return APPLE;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 4:
            
            if (fruit != PEAR) {
                
                return PEAR;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 5:
            
            if (fruit != BANANA) {
                
                return BANANA;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        case 6:
            
            if (fruit != ORANGE) {
                
                return ORANGE;
                
            } else {
                
                return [self randomFruit:fruit];
            }
            
        default:
            return NULL;
            break;
    }
}

- (int) firstReelRandomFruit {
    
    if (!powerActive) {
        
        switch (arc4random() % 100) {
                
            case 0 ... 29:
                return CHERRY;
                
            case 40 ... 49:
                return STRAWBERRY;
                
            case 50 ... 59:
                return MELON;
                
            case 60 ... 69:
                return APPLE;
                
            case 70 ... 79:
                return PEAR;
                
            case 80 ... 89:
                return BANANA;
                
            case 90 ... 99:
                return ORANGE;
                
            default:
                return [self randomFruit:ORANGE];
                break;
        }
        
    } else {
        
        switch (arc4random() % 100) {
                
            case 0 ... 29:
                return CHERRY;
                
            case 30 ... 59:
                return STRAWBERRY;
                
            case 60 ... 79:
                return MELON;
                
            case 80 ... 84:
                return APPLE;
                
            case 85 ... 89:
                return PEAR;
                
            case 90 ... 94:
                return BANANA;
                
            case 95 ... 99:
                return ORANGE;
                
            default:
                return [self randomFruit:ORANGE];
                break;
        }
        
    }
}

- (int) secondReelRandomFruit {
    
    if (!powerActive) {
        
        switch (reel1Fruit) {
                
            case CHERRY:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 44:
                        return CHERRY;
                        break;
                }
                
                return [self randomFruit:CHERRY];
                
            case STRAWBERRY:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 39:
                        return STRAWBERRY;
                        break;
                }
                
                return [self randomFruit:STRAWBERRY];
                
            case MELON:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 34:
                        return MELON;
                        break;
                }
                
                return [self randomFruit:MELON];
                
            case APPLE:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 29:
                        return APPLE;
                        break;
                }
                
                return [self randomFruit:APPLE];
                
            case PEAR:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 24:
                        return PEAR;
                        break;
                }
                
                return [self randomFruit:PEAR];
                
            case BANANA:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 19:
                        return BANANA;
                        break;
                }
                
                return [self randomFruit:BANANA];
                
            case ORANGE:
                
                switch (arc4random() % 100) {
                        
                    case 0 ... 14:
                        return ORANGE;
                        break;
                }
                
                return [self randomFruit:ORANGE];
                
            default:
                return [self randomFruit:ORANGE];
                break;
        }
        
    } else {
        
        return reel1Fruit;
    }
}

- (int) thirdReelRandomFruit {
    
    if (reel1Fruit == reel2Fruit) {
        
        if (!powerActive) {
            
            switch (reel2Fruit) {
                    
                case CHERRY:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 49:
                            return CHERRY;
                            break;
                    }
                    
                    return [self randomFruit:CHERRY];
                    
                case STRAWBERRY:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 39:
                            return STRAWBERRY;
                            break;
                    }
                    
                    return [self randomFruit:STRAWBERRY];
                    
                case MELON:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 31:
                            return MELON;
                            break;
                    }
                    
                    return [self randomFruit:MELON];
                    
                case APPLE:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 26:
                            return APPLE;
                            break;
                    }
                    
                    return [self randomFruit:APPLE];
                    
                case PEAR:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 19:
                            return PEAR;
                            break;
                    }
                    
                    return [self randomFruit:PEAR];
                    
                case BANANA:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 14:
                            return BANANA;
                            break;
                    }
                    
                    return [self randomFruit:BANANA];
                    
                case ORANGE:
                    
                    switch (arc4random() % 100) {
                            
                        case 0 ... 9:
                            return ORANGE;
                            break;
                    }
                    
                    return [self randomFruit:ORANGE];
                    
                default:
                    return [self randomFruit:ORANGE];
                    break;
            }
            
        } else {
            
            return reel2Fruit;
        }
        
    } else {
        
        return [self randomFruit:0];
    }
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
    
    int fruitArrayPosition;
    
    for (NSValue *position in fruitPositions) {
        
        if (fruitImages.count == 0) {
            
            [self setFruitImageNames];
        }
        
        fruitArrayPosition = arc4random() % fruitImages.count;
        
        Fruit *fruit = [fruitImages objectAtIndex:fruitArrayPosition];
        
        [fruitImages removeObjectAtIndex:fruitArrayPosition];
        
        fruit.position = ccp(position.CGPointValue.x, position.CGPointValue.y);
        
        [fruit setReel:(((fruit.position.x - startingPosition.x) / xChange) + 1)];
        
        [self addChild:fruit z:-1];
        
        [fruits addObject:fruit];
        
    }
}

- (void) setFruitImageNames {
    
    NSString *file;
    Fruit *fruit;
    
    file = [NSString stringWithFormat:@"%@%@", @"cherry", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = CHERRY;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"strawberry", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = STRAWBERRY;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"melon", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = MELON;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"apple", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = APPLE;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"pear", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = PEAR;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"orange", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = ORANGE;
    [fruitImages addObject:fruit];
    
    file = [NSString stringWithFormat:@"%@%@", @"banana", [self getImageFileSuffix]];
    fruit = [Fruit spriteWithFile:file];
    fruit.tag = BANANA;
    [fruitImages addObject:fruit];
}

- (void) setFruitPositions {
    
    [self getStartingPositions];
    
    int x, y;
    
    for (int row = 0; row < numberOfReels; row++) {
        
        x = xChange * row;
        
        for (int column = 0; column < numberOfFruits; column++) {
            
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
    
    // white background behind transparent layer
    CCSprite *background;
    
    background = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
    
    [self addChild:background z:-1];
    
    // add the transparent layer
    NSString *file = [NSString stringWithFormat:@"%@%@", @"GameBackground", [self getBackgroundFileSuffix]];
    
    background = [CCSprite spriteWithFile:file];
    
    background.position = ccp(win.width/2, win.height/2);
    
    [self addChild:background];
    
    // total credits label
    totalCreditsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$ %i", tCreditsLabelScore] fontName:CREDITS_FONT fontSize:POINTS_FONTSIZE*iPadScaleFactor];
    
    totalCreditsLabel.position = [self getTotalCreditPosition];
    
    totalCreditsLabel.color = ccWHITE;//ccc3(XP_R,XP_G,XP_B);//ccWHITE;
    
    [self addChild:totalCreditsLabel];
    
    
    // current bet label
    betLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$ %i", bet] fontName:CREDITS_FONT fontSize:POINTS_FONTSIZE*iPadScaleFactor];
    
    betLabel.position = [self getBetCreditPosition];
    
    betLabel.color = ccc3(POWER_R, POWER_G, POWER_B);//ccWHITE;
    
    [betLabel setAnchorPoint:ccp(1, 0.5)];
    
    [self addChild:betLabel];
    
    // win label
    winLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$ %i", winnings] fontName:CREDITS_FONT fontSize:POINTS_FONTSIZE*iPadScaleFactor];
    
    winLabel.position = [self getWinCreditPosition];
    
    winLabel.color = ccc3(XP_R,XP_G,XP_B);//ccWHITE;
    
    [winLabel setAnchorPoint:ccp(1, 0.5)];
    
    [self addChild:winLabel];
    
    [self createPowerAndXPBars];
    
    [self setMenuButtons];
    
    [self setLevel];
}

- (void) setLevel {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"levelStar", [self getImageFileSuffix]];
    
    CCSprite *star = [CCSprite spriteWithFile:file];
    
    star.position = ccp(xpBar.position.x, totalCreditsLabel.position.y);
    
    [self addChild:star];
    
    
    levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", currentLevel] fontName:LEVEL_FONT fontSize:LEVEL_FONTSIZE*iPadScaleFactor];
    
    levelLabel.position = ccp(xpBar.position.x, totalCreditsLabel.position.y - 2);
    
    levelLabel.color = ccBLACK;
    
    [self addChild:levelLabel];
    
}

- (void) createPowerAndXPBars {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"bar", [self getImageFileSuffix]];
    
    powerBar = [CCSprite spriteWithFile:file];
    
    powerBar.position = [self getPowerBarPosition];
    
    powerBar.color = ccc3(POWER_R, POWER_G, POWER_B);
    
    [self addChild:powerBar z:-1];
    
    xpBar = [CCSprite spriteWithFile:file];
    
    xpBar.position = [self getXPBarPosition];
    
    xpBar.color = ccc3(XP_R, XP_G, XP_B);
    
    [self addChild:xpBar z:-1];
}

- (CGPoint) getPowerBarPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            
            return ccp(25,41);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
}

- (CGPoint) getXPBarPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            //41
            return ccp(295,41);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
}

- (void) displayCredits {
    
    if (totalCredits > tCreditsLabelScore && totalCredits >= 0) {
        
        tCreditsLabelScore += CREDITS_CHANGE;
        [totalCreditsLabel setString:[NSString stringWithFormat:@"$ %i", tCreditsLabelScore]];
        
    } else if (totalCredits < tCreditsLabelScore && totalCredits >= 0) {
        
        tCreditsLabelScore = totalCredits;
        [totalCreditsLabel setString:[NSString stringWithFormat:@"$ %i", tCreditsLabelScore]];
    }
    
    [betLabel setString:[NSString stringWithFormat:@"$ %i", bet]];
}

- (void) setMenuButtons {
    
    NSString *file;
    NSString *secondFile;
    
    // button to go back to main menu
    file = [NSString stringWithFormat:@"%@%@", @"backButton", [self getImageFileSuffix]];
    
    CCSprite *firstSprite = [CCSprite spriteWithFile:file];
    
    CCSprite *secondSprite = [CCSprite spriteWithFile:file];
    secondSprite.color = ccc3(150, 150, 150);
    
    CCMenuItem *returnButton = [CCMenuItemSprite itemWithNormalSprite:firstSprite selectedSprite:secondSprite target:self selector:@selector(returnButtonPressed)];
    
    returnButton.position = ccp(powerBar.position.x, totalCreditsLabel.position.y);
    
    // bet Max Button
    file = [NSString stringWithFormat:@"%@%@", @"betMaxOff", [self getImageFileSuffix]];
    secondFile = [NSString stringWithFormat:@"%@%@", @"betMaxOn", [self getImageFileSuffix]];
    
    CCMenuItem *betMax = [CCMenuItemImage itemWithNormalImage:file selectedImage:secondFile target:self selector:@selector(betMax)];
    
    betMax.position = [self getMaxButtonPosition];
    
    // bet Min Button
    
    file = [NSString stringWithFormat:@"%@%@", @"betMinOff", [self getImageFileSuffix]];
    secondFile = [NSString stringWithFormat:@"%@%@", @"betMinOn", [self getImageFileSuffix]];
    
    CCMenuItem *betMin = [CCMenuItemImage itemWithNormalImage:file selectedImage:secondFile target:self selector:@selector(betMin)];
    
    betMin.position = [self getMinButtonPosition];
    
    
    
    CCMenu *menu = [CCMenu menuWithItems:returnButton, betMin, betMax, nil];
    menu.position = CGPointZero;
    
    [self addChild:menu];
}

- (CGPoint) getTotalCreditPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            return ccp(160,423);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
    
}

- (CGPoint) getWinCreditPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            //225
            return ccp(245,49);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
}

- (CGPoint) getBetCreditPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            
            return ccp(245,111);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
    
}

- (CGPoint) getMaxButtonPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            
            return ccp(62,110);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
    
}

- (CGPoint) getMinButtonPosition {
    
    switch (deviceTag) {
            
        case IPHONE:
            
            return ccp(62,48);
            break;
            
        default:
            return ccp(0,0);
            break;
    }
}

- (void) returnButtonPressed {
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainMenu scene]]];
}

- (void) decreaseBet {
    
    if ((bet % minBet) != 0) {
        
        bet -= bet % minBet;
        
    } else if (bet > minBet) {
        
        bet -= minBet;
    }
}

- (void) increaseBet {
    
    if ((bet % minBet) != 0) {
        
        bet += bet % minBet;
        
    } else if (bet < maxBet) {
        
        bet += minBet;
    }
}

- (void) betMin {
    
    if (!fruitsSpinning) {
        
        bet = minBet;
        
    }
}

- (void) betMax {
    
    if (!fruitsSpinning) {
        
        bet = maxBet;
        
    }
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
    
    [self swipeOnBet];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:[touch view]];
    lastTouch = [[CCDirector sharedDirector] convertToGL:lastTouch];
    
    double touchDifference = lastTouch.y - firstTouch.y;
    
    if (!fruitsSpinning && touchDifference <= 20 && touchDifference >= - 20) {
        
        if (firstTouch.y <= (startingPosition.y + startingPosition.y/2) && firstTouch.y >= betLabel.position.y) {
            
            [self increaseBet];
            
        } else if (firstTouch.y < startingPosition.y && firstTouch.y <= winLabel.position.y) {
            
            [self decreaseBet];
        }
    }
}

- (void) swipeOnBet {
    
    if (lastTouch.y < startingPosition.y && !fruitsSpinning) {
        
        double touchDifference = lastTouch.y - firstTouch.y;
        
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
    
    if (firstTouch.y > (lastTouch.y + yChange/2) && !fruitsSpinning) {
        
        if (firstTouch.y >= (startingPosition.y*2) && firstTouch.y <= (startingPosition.y + (yChange*(numberOfRows + 1)))) {
            
            [self resetFruitPositions];
            fruitsSpinning = YES;
            totalSpend += bet;
            [self increaseBars];
            [self increaseXPBar:SPIN_XP];
            [self removeCredits];
        }
    }
}

- (void) removeCredits {
    
    totalCredits -= bet;
}

- (void) increaseBars {
    
    [powerBar stopAllActions];
    
    if (powerActive) {
        
        powerActive = NO;
    }
    
    double startingHeight = [self getPowerBarPosition].y;
    
    double addedHeight = powerBar.contentSize.height;
    
    double divisionFactor = [self getPowerBarDivisionFactor];
    
    double moveTo = startingHeight + (addedHeight * divisionFactor);
    
    double maxHeight = (addedHeight + startingHeight);
    
    if (moveTo > maxHeight) {
        
        moveTo = maxHeight;
    }
    
    divisionFactor = (moveTo - powerBar.position.y) / 30;
    
    [powerBar runAction:[CCMoveTo actionWithDuration:divisionFactor position:ccp(powerBar.position.x, moveTo)]];
    
    if (moveTo == maxHeight) {
        
        [powerBar runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCFadeTo actionWithDuration:0.5 opacity:110] two:[CCFadeTo actionWithDuration:0.5 opacity:255]]]];
    }
    
    if (powerBar.position.y >= maxHeight) {
        
        [self activatePowerBar];
        
        [powerBar stopAllActions];
        [powerBar runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
        [powerBar runAction:[CCMoveTo actionWithDuration:REEL_STOP_DELAY*3.5 position:ccp(powerBar.position.x, startingHeight)]];
    }
}

- (void) increaseXPBar:(int)points {
    
    totalXP += points;
    
    double startingHeight = [self getXPBarPosition].y;
    
    double addedHeight = xpBar.contentSize.height;
    
    double maxHeight = (addedHeight + startingHeight);
    
    double xp = (totalXP)/(double)(LEVEL_XP_INCREASE * currentLevel);
    
    double moveTo = startingHeight + (addedHeight * xp);
    
    
    if (totalXP > (LEVEL_XP_INCREASE * currentLevel)) {
        
        totalXP -= (LEVEL_XP_INCREASE * currentLevel);
        
        [self increaseLevel];
        
        xp = (moveTo - xpBar.position.y) / 50;
        
        [xpBar runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:xp position:ccp(xpBar.position.x, maxHeight)] two:[CCCallBlockN actionWithBlock:^(CCNode *node) { xpBar.position = ccp(xpBar.position.x, startingHeight); [self increaseXPBar:0]; }]]];
        
    } else {
        
        [xpBar stopActionByTag:1];
        
        xp = (moveTo - xpBar.position.y) / 20;
        
        CCMoveTo *move = [CCMoveTo actionWithDuration:xp position:ccp(xpBar.position.x, moveTo)];
        move.tag = 1;
        
        [xpBar runAction:move];
        
    }
}

- (void) increaseLevel {
    
    currentLevel ++;
    
    [levelLabel setString:[NSString stringWithFormat:@"%i", currentLevel]];
    
    totalSpend = COMBO_AMOUNT_TO_SPEND * currentLevel;
    
    [powerBar stopAllActions];
    [self increaseBars];
    
    [self setMinMaxBets];
}

- (double) getPowerBarDivisionFactor {
    
    return (totalSpend/(double)(COMBO_AMOUNT_TO_SPEND * currentLevel));
}

- (void) activatePowerBar {
    
    [self increaseXPBar:POWER_XP];
    totalSpend = 0;
    powerActive = YES;
}

- (void) resetFruitPositions {
    
    reel1Fruit = NULL;
    reel2Fruit = NULL;
    reel3Fruit = NULL;
    
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
    [fruitImages release];
    
    fruitImages = NULL;
    fruits = NULL;
    fruitPositions = NULL;
}

@end
