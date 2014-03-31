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
        
        clouds = [[NSMutableArray alloc] init];
       
        // Add Sprites to Array.
        
        // clouds
        CCSprite *cloud1 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud2 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud3 = [CCSprite spriteWithFile:@"cloud.png"];
        
        [clouds addObject:cloud1];
        [clouds addObject:cloud2];
        [clouds addObject:cloud3];
        
        // middle x, y
        int y = window.height / 2;
        int x = window.width / 2;
        
        // position them all spaced out evenly
        cloud1.position = ccp(x, y - (y / 1.5));
        cloud2.position = ccp(x, y);
        cloud3.position = ccp(x, y + (y / 1.5));
        
        [self addChild:cloud1 z:1];
        [self addChild:cloud2 z:1];
        [self addChild:cloud3 z:1];
        
        scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Verdana" fontSize:25.0];
        scoreLabel.anchorPoint = ccp(0, 0);
        scoreLabel.color = ccc3(255,0,0);
        scoreLabel.position = ccp(window.width/4, window.height/2);
        
        [self addChild:scoreLabel z:10];
        
        [self schedule:@selector(tryMoveClouds)];
        
    }
    
    self.touchEnabled = YES;
    return self;
}

- (void) score {
        score += 10;
        [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}

- (void) tryMoveClouds {
    
    for (CCSprite *cloud in clouds) {
        if (cloud.numberOfRunningActions == 0) {
            [self tryMoveCloud:cloud];
        }
    }
   
}

- (void) tryMoveCloud:(CCSprite *)cloud0 {
    int move = 0;
    int random = arc4random() % 4;
    if (random == 0) {
        move = cloud0.contentSize.width / 2;
    } else if (random == 1) {
        move = 0 - cloud0.contentSize.width / 2;
    } else if (random == 2) {
        move = cloud0.contentSize.width / 3;
    } else if (random == 3) {
        move = 0 - cloud0.contentSize.width / 3;
    }
    CCMoveBy *moveSide = [CCMoveBy actionWithDuration:3.0 position:ccp(move, 0)];
    CCEaseInOut *easeSide = [CCEaseInOut actionWithAction:moveSide rate:1.0];
    CCAction *easeBack = [easeSide reverse];
    
    [cloud0 runAction:[CCSequence actions:easeSide, easeBack,
                     
                     [CCCallBlockN actionWithBlock:^(CCNode *node) {
        printf("loL");
    }],
                     
                     nil]];

}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:[touch view]];
    firstTouch = [[CCDirector sharedDirector] convertToGL:firstTouch];
    
    for (CCSprite *cloud in clouds) {
        if (CGRectContainsPoint(cloud.boundingBox, firstTouch)) {
            [self score];
        }
    }
    
    
}

@end
