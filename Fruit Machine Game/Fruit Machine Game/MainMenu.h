//
//  MainMenu.h
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface MainMenu : CCLayer <UIApplicationDelegate, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate> {
    
}

+ (CCScene *) scene;

@end
