//
//  Cell.h
//  PageViewDemo
//
//  Created by Saswata Basu on 4/23/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pageContent;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UIButton *flag;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) IBOutlet UIButton *lock;
@property (weak, nonatomic) IBOutlet UILabel *privatePost;
@property (weak, nonatomic) IBOutlet UILabel *replies;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UILabel *aboutMe;
@property (weak, nonatomic) IBOutlet UILabel *userScore;



@end
