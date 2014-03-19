//
//  PopTheCloud.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
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
        
        CGSize window = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
        
        background = [CCLayerColor layerWithColor:ccc4(100,255,255,255)];
        
        [self addChild:background z:-1];
        
        CCSprite *cloud1 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud2 = [CCSprite spriteWithFile:@"cloud.png"];
        CCSprite *cloud3 = [CCSprite spriteWithFile:@"cloud.png"];
        
        cloud1.anchorPoint = ccp(0,0);
        cloud2.anchorPoint = ccp(0,0);
        cloud3.anchorPoint = ccp(0,0);
        
        cloud1.position = ccp(window.height / 3 , 10);
        cloud1.position = ccp((window.height / 3) * 2, 15);
        cloud1.position = ccp(window.height, 20);
        
        [self addChild:cloud1 z:1];
        [self addChild:cloud2 z:1];
        [self addChild:cloud3 z:1];
        
        
    }
    
    self.touchEnabled = YES;
    return self;
}

@end
