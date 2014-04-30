//
//  PopularSearchVC.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


@interface PopularSearchVC : UIViewController < UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>


@property (strong, nonatomic) IBOutlet UITableView *popularTableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong)   MSClient *client;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;


@end
