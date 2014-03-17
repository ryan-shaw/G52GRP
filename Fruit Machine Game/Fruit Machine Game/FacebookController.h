//
//  FacebookController.h
//  Fruity Slots
//
//  Created by rxs62u on 17/03/2014.
//  Copyright (c) 2014 G52GRP. All rights reserved.
//

#ifndef Fruity_Slots_FacebookController_h
#define Fruity_Slots_FacebookController_h

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#include "math_lib.h"

namespace FruitySlots
{
    namespace Fruit
    {
        class FacebookController
        {
        public:
            enum eGameAchievements
            {
                
            };
            
            FacebookController();
            virtual ~FacebookController();
            
            static void CreateNewSession();
            static void Login(void (*callback)(bool));
            static void OpenSession(void (*callback)(bool));
            static void Logout(void (*callback)(bool));
            static bool isLoggedIn();
            
            static void FetchUserDetails(void (*callback)(bool));
            
            static void ProcessIncomingURL(NSURL* targetURL, void (*callback)(NSString*, NSString*));
            static void ProcessIncomingRequest(NSURL* targetURL, void (*callback)(NSString *, NSString *));
            
            static void SendRequest(const int nScore);
            static void SendFilteredRequest(const int nScore);
            static void SendBrag(const int nScore);
            static void SendScore(const int nScore);
            static void SendAchievement(eGameAchievements achievement);
            static void GetScores();
            static void SendOG(const u64 uFriendID);
            static void RequestWritePermissions();
            
            static NSString* GetUserFirstName() { return ms_nsstringFirstName; }
            static u64 GetUserFBID() { return ms_uPlayerFBID; }
            
        private:
            static NSString* ms_nsstrFirstName;
            static u64 ms_uPlayerFBID;
            static bool ms_bIsLoggedIn;
        };
    }
}

#endif
