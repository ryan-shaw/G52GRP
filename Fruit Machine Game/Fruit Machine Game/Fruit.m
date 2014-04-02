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
    
    // set the reel position of each instance of this fruit class
    reel = reelPosition;
}

- (int) getReelPosition {
    
    // return the reel position of the fruit
    return reel;
}

@end
