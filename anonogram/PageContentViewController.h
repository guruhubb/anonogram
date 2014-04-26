//
//  PageContentViewController.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#pragma mark * Block Definitions


typedef void (^completionBlock) ();
typedef void (^completionWithIndexBlock) (NSUInteger index);
typedef void (^busyUpdateBlock) (BOOL busy);

@interface PageContentViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property NSUInteger pageIndex;
@property NSUInteger moreResults;
@property (strong, nonatomic) IBOutlet UITableView *theTableView;
@property (strong, nonatomic) NSMutableArray *pageContent;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSMutableArray *likeCountArray;
@property (strong, nonatomic) NSMutableArray *timestampArray;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   NSMutableArray *loadedItems;
// TODO - create an MSClient proeprty
@property (nonatomic, strong)   MSClient *client;
- (void) refreshDataOnSuccess:(completionBlock) completion;

- (void) addItem:(NSDictionary *) item
      completion:(completionWithIndexBlock) completion;

- (void) completeItem: (NSDictionary *) item
           completion:(completionWithIndexBlock) completion;
- (void)TwitterSwitch;
@end
