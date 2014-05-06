//
//  CommentVC.h
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flurry.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


@interface CommentVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    IBOutlet UIToolbar          *textToolBar;
    IBOutlet UITextField        *txtChat;
    CGSize textSize;

    NSInteger loadMore;
    NSInteger oldCount;
    NSInteger counter;
    NSInteger imageCounter;
    UIToolbar *_inputAccessoryView;
}
@property (nonatomic,readwrite) BOOL commentButton;
@property (nonatomic,readwrite) BOOL myPhotoBook;
@property(nonatomic,strong)NSDictionary *dicUserData;
@property(nonatomic,strong) NSMutableArray *array;
@property(nonatomic,strong) NSMutableArray *arrayImages;
@property(nonatomic,strong) UITableView *chat_table;
@property(nonatomic,strong)NSString *backButtonString;
@property(nonatomic,strong)NSString *tagId;
@end


