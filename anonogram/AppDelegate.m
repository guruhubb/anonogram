//
//  AppDelegate.m
//  Anonogram
//
//  Created by Saswata Basu on 3/18/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.client = [MSClient clientWithApplicationURLString:@"https://anonogram.azure-mobile.net/"
                                            applicationKey:@"oAKRURLTEiBfoIJRVwqrKecBxLtMxW68"];
    [NewRelicAgent startWithApplicationToken:@"AA5805ad45b0b2260a17ed011dfb4e831a13b79eea"];
    
//    [Flurry setCrashReportingEnabled:YES];
//    [Flurry startSession:@"QVX85GQB3X9V2SVHGVJH"];
//    
//    
//	[Tapjoy requestTapjoyConnect:@"e771b5ff-5727-4ff9-8b31-5a2dfaeda76b"
//					   secretKey:@"yKagIWePRD2lkBFeG1Pm" options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES) }];
 
    [MKStoreManager sharedManager];
    
 //    [[MKStoreManager sharedManager] removeAllKeychainData];  //test purpose to reset in-app purchase
    
    
    
    return YES;
}


#pragma mark - assets

-(void)tjcConnectSuccess:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Succeeded");
}


- (void)tjcConnectFail:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Failed");
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSInteger counter = [[NSUserDefaults standardUserDefaults] integerForKey:@"counterAnonogram" ];
    counter++;
    NSLog(@"counter is %d",counter);

    if (counter>4){
        NSLog(@"counter is %d",counter);

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showSurveyAnonogram"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"counterAnonogram" ];
        counter = 0;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:counter forKey:@"counterAnonogram" ];
    
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
