//
//  Cell.h
//  PageViewDemo
//
//  Created by Saswata Basu on 4/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pageContent;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;

@end
