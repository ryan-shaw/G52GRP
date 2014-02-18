//
//  Fruit.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 03/01/2014.
//  Copyright 2014 G52GRP. All rights reserved.
//

#import "Fruit.h"

@implementation Fruit {
    
    int reel;
}

- (void) setReel:(int)reelPosition {
    
    reel = reelPosition;
}

- (int) getReelPosition {
    
    return reel;
}

@end
