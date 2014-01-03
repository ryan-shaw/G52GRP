//
//  Fruit.h
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 03/01/2014.
//  Copyright 2014 G52GRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Fruit : CCSprite {
    
    int reel;
}

- (void) setReel:(int)reel;

- (int) getReelPosition;

@end
