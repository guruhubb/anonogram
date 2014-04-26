//
//  ViewController.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#pragma mark * Block Definitions


typedef void (^completionBlock) ();
typedef void (^completionWithIndexBlock) (NSUInteger index);
typedef void (^busyUpdateBlock) (BOOL busy);

@interface ViewController : UIViewController <UIPageViewControllerDataSource,UITextViewDelegate,UITextFieldDelegate,UISearchBarDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarButton;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *pageTitles;

@property (nonatomic, strong)   NSArray *items;
// TODO - create an MSClient proeprty
@property (nonatomic, strong)   MSClient *client;
- (void) refreshDataOnSuccess:(completionBlock) completion;

- (void) addItem:(NSDictionary *) item
      completion:(completionWithIndexBlock) completion;

- (void) completeItem: (NSDictionary *) item
           completion:(completionWithIndexBlock) completion;
+ (NSString *)GetUUID;

@end
