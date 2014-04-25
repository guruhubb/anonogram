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
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
//@property NSString *titleText;
//@property NSString *imageFile;
@property (strong, nonatomic) IBOutlet UITableView *theTableView;
//@property (strong, nonatomic) id dataObject;
@property (strong, nonatomic) NSArray *pageContent;
@property (strong, nonatomic) NSArray *likeCountArray;
@property (strong, nonatomic) NSArray *timestampArray;
@property (strong, nonatomic) NSMutableArray *array;


@end
