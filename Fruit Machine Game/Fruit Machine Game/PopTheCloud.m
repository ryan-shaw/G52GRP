//
//  PopTheCloud.m
//  Fruit Machine Game
//
//  Created by Matthew Herod.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "PopTheCloud.h"

@implementation PopTheCloud

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
       
        CGSize window = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
        
        background = [CCLayerColor layerWithColor:ccc4(100,255,255,255)]; //blue
        
        [self addChild:background z:-1];
        
        coin = [CCSprite spriteWithFile:@"coin.png"];
        
        [self addChild:coin z:3];
        
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
        
        [self addChild:cloud1 z:4];
        [self addChild:cloud2 z:4];
        [self addChild:cloud3 z:4];
        
        crowcoin = [[CCSprite alloc] init];
        //crowcoin.scaleX = crowcoin.scaleY = 0.7;
        crowcoin.tag = 0;
        
        [self addChild:crowcoin z:2];
        
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana" fontSize:72.0];
        scoreLabel.anchorPoint = ccp(0, 0);
        scoreLabel.color = ccc3(230,230,230);
        scoreLabel.position = ccp(0, window.height - 72);
        
        [self addChild:scoreLabel z:10];
        
        [self schedule:@selector(tryAnims)];
        
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) raiseScore {
        score += 1;
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
        [cloud0 setVisible:YES];
    }],
                     
                     nil]];

}

- (void) tryMoveCrow:(CCSprite *)crow {
    
    if (crow.numberOfRunningActions == 0) {
        
        CCAnimation *crowcoinanim = [CCAnimation animation];
        [crowcoinanim addSpriteFrameWithFilename:@"crowcoin1.png"];
        [crowcoinanim addSpriteFrameWithFilename:@"crowcoin2.png"];
        
        // crowcoin.anchorPoint = ccp(0.5, 0.5);
        
        [crow runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithDuration:0.8f animation:crowcoinanim restoreOriginalFrame:NO]]];
        
    }
    
    if (crow.tag == 10) { // fly off screen
        crow.tag = 11;
        
        CCMoveBy *moveSide = [CCMoveBy actionWithDuration:4.0 position:ccp(- (2 * x), 0)];
        CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:3.0];
        
        [crow runAction:[CCSequence actions:easeSide,
                            [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                crow.tag = 0;
                                // new crow
                            }]
                         , nil]];
        
    } else if (crow.tag == 0) { // fly on screen
        crow.tag = 11;
        int moveX = 0;
        
        int chosenCloudNo = (arc4random() % 3) + 1;
        for (CCSprite *cloud in clouds) {
            if (cloud.tag == chosenCloudNo) {
                crow.tag = cloud.tag;
                crow.position = ccp(cloud.position.y, -crow.contentSize.width);
                
                moveX = cloud.position.x - crow.position.x;
            }
        }
        
        CCMoveBy *moveSide = [CCMoveBy actionWithDuration:1.0 position:ccp(-x, 0)];
        CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:4.0];
        
        [crow runAction:[CCSequence actions:easeSide,
                         [CCCallBlockN actionWithBlock:^(CCNode *node) {
            // move under a cloud then hide (so we don't have to track clouds)
            [crow setVisible:NO];
        }]
                         , nil]];
        
        
    }
    
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    for (CCSprite *cloud in clouds) {
        if (CGRectContainsPoint(cloud.boundingBox, firstTouch)) {
            if (crowcoin.tag == cloud.tag) {
                crowcoin.tag = 10;
                crowcoin.position = cloud.position;
                
                coin.position = cloud.position;
                
                [coin setVisible:YES];
                
                [crowcoin setVisible:YES];
                [self raiseScore];
            }
            [cloud setVisible:NO];
        }
    }
    
    
}

@end
