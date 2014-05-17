//
//  HomeViewController.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


@interface HomeViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIActionSheetDelegate>

-(NSString *)abbreviateNumber:(int)num ;
- (void) turnOnIndicator ;
- (void) turnOffIndicator ;
- (void) noInternetAvailable ;
@end
