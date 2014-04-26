//
//  AppDelegate.h
//  Anonogram
//
//  Created by Saswata Basu on 3/18/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tapjoy/Tapjoy.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MKStoreManager.h"
#import "Flurry.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SSKeychain.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSClient *client;

@end
