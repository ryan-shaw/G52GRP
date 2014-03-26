//
//  MainMenu.m
//  Fruit Machine Game
//
//  Created by Stephen Sowole on 02/12/2013.
//  Copyright 2013 G52GRP. All rights reserved.
//

#import "MainMenu.h"
#import "MainGameScene.h"
#import "SimpleAudioEngine.h"
#import "GameKitHelper.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation MainMenu {
    
    CCLabelTTF *playLabel;
    int deviceTag, scaleFactor;
    CGSize win;
    
    CCSprite *optionBar, *help;
    CCMenu *menu;
    CCMenuItemSprite *mute;
    
    UIViewController *tempVC;
    FBLoginView *loginView;
}

+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *layer = [MainMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) setDeviceTag {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            
            deviceTag = IPHONE5;
            
        } else {
            
            deviceTag = IPHONE;
            
        }
        
        scaleFactor = 1;
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
            
            deviceTag = IPADHD;
            
        } else {
            
            deviceTag = IPAD;
            
        }
        
        scaleFactor = 2;
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
            
        case IPADHD:
            return @"@ipadhd.png";
            
        default:
            return @".png";
    }
}

- (id) init {
    
	if( (self=[super init])) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [[GameKitHelper sharedGameKitHelper]
         authenticateLocalPlayer];
        
        win = [[CCDirector sharedDirector] winSize];
        
        [SimpleAudioEngine sharedEngine].enabled = NO;
        
        help = NULL;
        
        [self setDeviceTag];
        
        [self createDisplay];
        
        [SimpleAudioEngine sharedEngine].enabled = YES;
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:SOUNDTRACK];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f];//0.1f];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:MUTE_DATA] == MUTE) {
            
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        }
     
        [FBSession openActiveSessionWithAllowLoginUI:YES];
        loginView = [[FBLoginView alloc] init];
        
        UIView *view = [[[CCDirector sharedDirector] view] window];
        
        [view addSubview:loginView];
        
        loginView.frame = CGRectOffset(loginView.frame, (view.center.x - (loginView.frame.size.width / 2)), 125);

    }
    
    self.touchEnabled = YES;
    return self;
    
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
}

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    self.loggedInUser = user;
}

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.loggedInUser = nil;
}

- (void) hideFB {
    [loginView setHidden:YES];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBLoginView class];
    
    return YES;
}

- (void) createDisplay {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"MenuBackground", [self getBackgroundFileSuffix]];
    
    CCSprite *background = [CCSprite spriteWithFile:file];
    
    background.position = ccp(win.width/2, win.height/2);
    
    [self addChild:background];
    
    [self setPlayLabel];
    
    [self setOptions];
}

- (void) setOptions {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", @"optionBar", [self getImageFileSuffix]];
    
    CCSprite *select, *unselect;
    
    optionBar = [CCSprite spriteWithFile:file];
    
    optionBar.position = ccp(-optionBar.contentSize.width/2.8, win.height/1.15);
    
    [self addChild:optionBar];
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"option", [self getImageFileSuffix]];
    
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.scale = 0.85;
    
    CCMenuItemSprite *optionButton = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(extendOptions)];
    optionButton.position = ccp(optionBar.contentSize.width/16, optionBar.position.y);
    
    CCMenu *otherMenu = [CCMenu menuWithItems: optionButton, nil];
    otherMenu.position = CGPointZero;
    
    [self addChild:otherMenu];
    
    
    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:MUTE_DATA] || [[NSUserDefaults standardUserDefaults] integerForKey:MUTE_DATA] == UNMUTE) {
        
        file = [NSString stringWithFormat:@"%@%@", @"muteOff", [self getImageFileSuffix]];
        select = [CCSprite spriteWithFile:file];
        
        file = [NSString stringWithFormat:@"%@%@", @"muteOn", [self getImageFileSuffix]];
        unselect = [CCSprite spriteWithFile:file];
        unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
        
    } else {
        
        file = [NSString stringWithFormat:@"%@%@", @"muteOn", [self getImageFileSuffix]];
        select = [CCSprite spriteWithFile:file];
        select.color = ccc3(MENU_R, MENU_G, MENU_B);
        
        file = [NSString stringWithFormat:@"%@%@", @"muteOff", [self getImageFileSuffix]];
        unselect = [CCSprite spriteWithFile:file];
    }
    
    mute = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(mute)];
    mute.position = ccp(optionButton.position.x*1.5 + optionBar.contentSize.width/6, optionBar.position.y);
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"leaderboard", [self getImageFileSuffix]];
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *leaderboard = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(showLeaderboard)];
    leaderboard.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*2, optionBar.position.y);
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"reset", [self getImageFileSuffix]];
    
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *question = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(reset)];
    question.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*3, optionBar.position.y);
    
    
    
    
    file = [NSString stringWithFormat:@"%@%@", @"question", [self getImageFileSuffix]];
    
    select = [CCSprite spriteWithFile:file];
    unselect = [CCSprite spriteWithFile:file];
    unselect.color = ccc3(MENU_R, MENU_G, MENU_B);
    
    CCMenuItemSprite *reset = [CCMenuItemSprite itemWithNormalSprite:select selectedSprite:unselect target:self selector:@selector(showHelp)];
    reset.position = ccp(optionButton.position.x*1.5 + (optionBar.contentSize.width/6)*4, optionBar.position.y);
    
    
    
    menu = [CCMenu menuWithItems: mute, leaderboard, question, reset, nil];
    menu.position = CGPointZero;
    
    [self addChild:menu];
    menu.opacity = 0;
    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:FIRST_RUN]) {
        
        optionBar.position = ccp(optionBar.contentSize.width/2.50, optionBar.position.y);
        menu.enabled = YES;
        menu.opacity = 255;
    }
}

- (void) reset {
    
    if (help == NULL) {
        
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"Reset Everything"
                                message:@"Are you sure you want to reset all progress?"
                                delegate:self
                                cancelButtonTitle:@"Reset"
                                otherButtonTitles:@"Cancel",nil];
        myAlert.tag = 1;
        
        [myAlert show];
        [myAlert release];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // the user clicked Reset
    if (buttonIndex == 0) {
        
        if (alertView.tag == 1) {
            
            NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *file = [NSString stringWithFormat:@"%@%@", @"muteOff", [self getImageFileSuffix]];
            CCSprite *select = [CCSprite spriteWithFile:file];
            mute.normalImage = select;
            
        }
    }
}

- (void) showLeaderboard {
    
    if (help == NULL) {
        
        [self playSoundEffect:TOUCH];
        
        if ([GKLocalPlayer localPlayer].isAuthenticated == YES) {
            
            // Create leaderboard view w/ default Game Center style
            GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
            
            // If view controller was successfully created...
            if (leaderboardController != nil)
            {
                // Leaderboard config
                leaderboardController.leaderboardDelegate = self;   // The leaderboard view controller will send messages to this object
                leaderboardController.category = GAME_CENTER_RICH_LIST;  // Set category here
                leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;    // GKLeaderboardTimeScopeToday, GKLeaderboardTimeScopeWeek, GKLeaderboardTimeScopeAllTime
                
                // Create an additional UIViewController to attach the GKLeaderboardViewController to
                tempVC = [[UIViewController alloc] init];
                
                // Add the temporary UIViewController to the main OpenGL view
                [[[[CCDirector sharedDirector] view] window] addSubview:tempVC.view];
                
                // Tell UIViewController to present the leaderboard
                [tempVC presentViewController:leaderboardController animated:YES completion:nil];
                
            }
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Center Unavailable" message:@"Player is not signed in"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            alert.tag = 2;
            [alert show];
            [alert release];

        }
    }
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    BOOL isAtLeast7 = [version floatValue] >= 7.0;
    
    if (isAtLeast7) {
        
        [tempVC dismissViewControllerAnimated:YES completion:nil];
        [tempVC.view removeFromSuperview];
        [tempVC release];
        
    } else {
        
        [viewController.view removeFromSuperview];
        [viewController release];
    }
}

- (void) showHelp {
    
    if (help == NULL) {
        
        [self playSoundEffect:TOUCH];
        
        NSString *file = [NSString stringWithFormat:@"%@%@", @"help", [self getBackgroundFileSuffix]];
        
        help = [CCSprite spriteWithFile:file];
        
        help.position = ccp(win.width/2, win.height/2);
        
        help.opacity = 0;
        
        [self addChild:help];
        
        [help runAction:[CCFadeIn actionWithDuration:0.1]];
    }
}

- (void) mute {
    
    if (help == NULL) {
        
        [self playSoundEffect:TOUCH];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:MUTE_DATA] == UNMUTE) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:MUTE forKey:MUTE_DATA];
            
            NSString *file = [NSString stringWithFormat:@"%@%@", @"muteOn", [self getImageFileSuffix]];
            CCSprite *select = [CCSprite spriteWithFile:file];
            select.color = ccc3(MENU_R, MENU_G, MENU_B);
            mute.normalImage = select;
            
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setInteger:UNMUTE forKey:MUTE_DATA];
            
            NSString *file = [NSString stringWithFormat:@"%@%@", @"muteOff", [self getImageFileSuffix]];
            CCSprite *select = [CCSprite spriteWithFile:file];
            mute.normalImage = select;
            
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        }
    }
}

- (void) extendOptions {
    
    if (help == NULL) {
        
        [self playSoundEffect:TOUCH];
        
        if (optionBar.numberOfRunningActions == 0 && menu.numberOfRunningActions == 0) {
            
            if (optionBar.position.x < 0) {
                
                [optionBar runAction:[CCMoveTo actionWithDuration:OPTION_BAR_MOVE_TIME position:ccp(optionBar.contentSize.width/2.50, optionBar.position.y)]];
                
                menu.enabled = YES;
                [menu runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:OPTION_BAR_MOVE_TIME] two:[CCFadeIn actionWithDuration:0.1]]];
                
            } else {
                
                [optionBar runAction:[CCMoveTo actionWithDuration:OPTION_BAR_MOVE_TIME position:ccp(-optionBar.contentSize.width/2.8, optionBar.position.y)]];
                menu.opacity = 0;
                menu.enabled = NO;
            }
        }
    }
}

- (void) setPlayLabel {
    
    playLabel = [CCLabelTTF labelWithString:PLAY_LABEL_TEXT fontName:PLAY_LABEL_FONT fontSize:INSERT_COIN_FONTSIZE*scaleFactor];
    
    playLabel.color = ccWHITE;
    
    playLabel.position = ccp(win.width/2, win.height/10);
    
    [self addChild:playLabel];
    
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:30];
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:FADE_IN_OUT_TIME opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    
    [playLabel runAction:repeat];
    
}

- (void) playSoundEffect:(NSString*)effect {
    
    [SimpleAudioEngine sharedEngine].enabled = YES;
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:MUTE_DATA] == UNMUTE) {
        
        [[SimpleAudioEngine sharedEngine] playEffect:effect];
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    if (help == NULL) {
        
        if (touchLocation.y < win.height/2) {
            
            if (![[NSUserDefaults standardUserDefaults] integerForKey:FIRST_RUN]) {
                
                [self showHelp];
                
            } else {
                
                [self hideFB];
                [self playSoundEffect:TOUCH];
                [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainGameScene scene]]];
            }
        }
        
    } else if (touchLocation.y < win.height/2) {
        
        if (![[NSUserDefaults standardUserDefaults] integerForKey:FIRST_RUN]) {
            
            [self hideFB];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:FIRST_RUN];
            [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[MainGameScene scene]]];
            
        } else {
            
            [self playSoundEffect:TOUCH];
            [self removeChild:help cleanup:YES];
            help = NULL;
        }
        
    } else {
        
        [self playSoundEffect:TOUCH];
        [self removeChild:help cleanup:YES];
        help = NULL;
    }
}

@end
