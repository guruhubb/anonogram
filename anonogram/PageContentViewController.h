//
//  PageContentViewController.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface PageContentViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property NSUInteger pageIndex;

@property (strong, nonatomic) IBOutlet UITableView *theTableView;
@property (strong, nonatomic) NSMutableArray *pageContent;
//@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSMutableArray *likeCountArray;
@property (strong, nonatomic) NSMutableArray *timestampArray;
@property (strong, nonatomic) NSMutableArray *array;


@end
