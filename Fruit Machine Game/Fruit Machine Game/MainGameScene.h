//
//  MainGameScene.h
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainGameScene : CCLayer {
    
    NSMutableArray *fruits;
    NSMutableArray *fruitPositions;
    
    int currentReelNumber;
    
    double lastFruitYPosition;
    BOOL spinFruits;
    
    CGPoint firstTouch, lastTouch;
}

+(CCScene *) scene;

@end
