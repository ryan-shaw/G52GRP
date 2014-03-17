//
//  FacebookController.cpp
//  Fruity Slots
//
//  Created by rxs62u on 17/03/2014.
//  Copyright (c) 2014 G52GRP. All rights reserved.
//

#include "FacebookController.h"
#include <Social/Social.h>
#include <Social/SLComposeViewController.h>

namespace FruitySlots
{
    namespace Fruit
    {
        static const u64 kuFBAppID = 235859759909476;
        
        NSString* FacebookController::ms_nsstrFirstName = NULL;
        u64 FacebookController::ms_uPlayerFBID(0);
        bool FacebookController::ms_bIsLoggedIn = false;
        
        void FacebookController::CreateNewSession()
        {
            FBSession* session = [[FBSession alloc] init];
            [FBSession setActiveSession: session];
            
        }
        
        bool FacebookController::isLoggedIn()
        {
            return ms_bIsLoggedIn;
        }
        
        void FacebookController::OpenSession(void (*callback)(bool))
        {
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"email",
                                    nil];
            
            // Attempt to open the session. If the session is not open, show the user the Facebook login UX
            [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:false completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
             
             // Did something go wrong during login? I.e. did the user cancel?
             
             if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateClosed || status == FBSessionStateCreatedOpening) {
                ms_bIsLoggedIn = false;
                callback(false);
             }
             else {
                ms_bIsLoggedIn = true;
                callback(true);
             }
             }];         
        }
    }
}

