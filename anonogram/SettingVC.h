//
//  SettingVC.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MKStoreManager.h"


@class HackbookAppDelegate;
@interface SettingVC : UITableViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate,SKStoreProductViewControllerDelegate>{
    
    NSArray *editArr;
    UISwitch *watermark;
    NSUserDefaults *defaults;
    BOOL restoreON;
    NSMutableArray *buttonsArray;

}
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

