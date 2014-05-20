//
//  UserViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#define kLimit 20
#define kFlagsAllowed 10

#import "UserViewController.h"
#import "Cell.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "CommentVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "CommentVC.h"
#import "HomeViewController.h"

@interface UserViewController (){
    NSUserDefaults *defaults;
//    NSString *token;
    BOOL isPrivateOn;
    BOOL isDirectMessage;
    BOOL isAboutMe;
    BOOL isLocation;
    BOOL myPage;
    NSInteger tapAction;
    NSInteger characterLimit;
//    NSIndexPath *indexPathRow;
//    UIRefreshControl *refreshControl;
//    NSMutableArray *buttonsArray;
//    NSInteger flagButton;
//    BOOL isComment;
//    NSInteger commentedPost;
    UITextView        *txtChat;
    UIToolbar *_inputAccessoryView;
    NSString *dataId;
    NSString *myId;
    HomeViewController *home;

//    NSTimeInterval nowTime;
//    NSTimeInterval startTime ;
}
//@property (weak, nonatomic)IBOutlet UIToolbar *textToolBar;
//@property (weak, nonatomic)IBOutlet UITextField *txtChat;
@property (nonatomic, strong)   MSTable *table;
@property (nonatomic, strong)   MSTable *userTable;
@property (weak, nonatomic) IBOutlet UIButton *directMessage;
@property (weak, nonatomic) IBOutlet UIButton *gender;
@property (weak, nonatomic) IBOutlet UIButton *username;
@property (weak, nonatomic) IBOutlet UIButton *aboutMe;
@property (weak, nonatomic) IBOutlet UILabel *reputation;
@property (weak, nonatomic) IBOutlet UILabel *replies;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *posts;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (nonatomic, strong)   MSClient *client;
@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


@end

@implementation UserViewController

//-(void)viewDidAppear:(BOOL)animated {
//
//    if (isComment){
//        isComment = NO;
//        NSLog(@"comment update, commentedPost is %d",commentedPost);
//        [self.table readWithId:[self.array[commentedPost] objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
//            NSLog(@"item is %@",item);
//            if (item == NULL) return;
//
//            [self.array replaceObjectAtIndex:commentedPost withObject:item];
//            [self.TableView reloadData];
//            [self logErrorIfNotNil:error];
//        }];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    startTime=0;
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.TableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
//    [self.TableView setSeparatorInset:UIEdgeInsetsZero];
    home = [[HomeViewController alloc] init];

//    self.array = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.userTable = [self.client tableWithName:@"userTable"];
    myId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    if ([myId isEqualToString:self.userId]) myPage=YES;
//    self.isLikeTable = [self.client tableWithName:@"isLike"];
//    self.isFlagTable = [self.client tableWithName:@"isFlag"];
//    self.commentTable = [self.client tableWithName:@"commentTable"];
//    self.isLikeCommentTable = [self.client tableWithName:@"isLikeCommentTable"];
    isPrivateOn=YES;

//    self.aboutMe.titleLabel.text=[NSString stringWithFormat:@"%@",[_aboutUser objectForKey:@"aboutMe"]];
//    self.username.titleLabel.text=[NSString stringWithFormat:@"%@",[_aboutUser objectForKey:@"username"]];
//    self.navigationItem.title = self.username.titleLabel.text;
//    self.posts.text=[NSString stringWithFormat:@"%@",[_aboutUser objectForKey:@"posts"]];
//    self.replies.text=[NSString stringWithFormat:@"%@",[_aboutUser objectForKey:@"replies"]];
//    self.reputation.text=[NSString stringWithFormat:@"%@",[_aboutUser objectForKey:@"reputation"]];
//    self.userId =[_aboutUser objectForKey:@"userId"];
//    NSMutableString *tempHex=[[NSMutableString alloc] init];
//    [tempHex appendString:[_aboutUser objectForKey:@"color"]];
//    unsigned colorInt = 0;
//    [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
//    self.colorView.backgroundColor = UIColorFromRGB(colorInt);
//    self.colorView.layer.cornerRadius=20;
//    self.colorView.layer.masksToBounds=YES;
//    
//    self.directMessage.layer.cornerRadius=5;
//    self.directMessage.layer.masksToBounds=YES;
    
//    UILabel *label = (UILabel*)[self.view viewWithTag:110];
//    label.text =@"No Notifications yet\n\nMake sure access to Twitter is On\n\nYou will receive posts that mention your Twitter username";
//    if (!IS_TALL_SCREEN) {
//        self.TableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
//    }

    defaults = [NSUserDefaults standardUserDefaults];
//    refreshControl = [[UIRefreshControl alloc]init];
//    [self.TableView addSubview:refreshControl];
//    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
//    [self getUUID];
//    if (![defaults objectForKey:@"twitterAccounts"])
//        [self twitterSwitch:nil];
    [self getData];
//    [self setup];

}
-(void) setup {
    
    txtChat = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, screenSpecificSetting(290, 202))];
    txtChat.delegate=self;
    txtChat.hidden=YES;
    txtChat.font=[UIFont fontWithName:@"GillSans-Light" size:20];
    //    txtChat.textColor=[UIColor lightGrayColor];
    txtChat.tintColor=[UIColor darkGrayColor];
    //    [[UITextView appearance] setTintColor:[UIColor lightGrayColor]];
    //    txtChat.text=@"placeholder";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(285, screenSpecificSetting(215, 127), 30, 30)];
    label.textColor=[UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"GillSans-Light" size:18];
    label.text= @"140";
    label.tag =100;
    label.hidden=YES;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10,screenSpecificSetting(15, -15) ,300, 190)];
    label2.textColor=[UIColor darkGrayColor];
    label2.font = [UIFont fontWithName:@"GillSans-Light" size:20];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.text= [NSString stringWithFormat:@"Direct message %@",self.username.titleLabel.text];
    label2.numberOfLines=14;
    label2.tag =105;
    [txtChat addSubview:label];
    [txtChat addSubview:label2];
    //    [self.view addSubview:theTable];
//    [txtChat addSubview:theTable];
    [self createInputAccessoryView];
    //    [self createInputAccessoryViewForSearch];
    [self.view addSubview:txtChat];
    //    [self.view addSubview:_inputAccessoryView];
    //    _inputAccessoryView.hidden=YES;
    //    _searchBarButton.hidden=YES;
    //    _searchBarButton.placeholder = @"Search #hashtag, @username";
    //    [_searchBarButton setKeyboardType:UIKeyboardTypeTwitter];
    [txtChat setKeyboardType:UIKeyboardTypeTwitter];
    
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    if (!myPage){
        self.aboutMe.userInteractionEnabled=NO;
        self.username.userInteractionEnabled=NO;
        self.gender.userInteractionEnabled=NO;
        self.locationButton.userInteractionEnabled=NO;
        NSLog(@"user page");
    }
    else {
        NSLog(@"my page");
        self.directMessage.hidden=YES;
//        self.aboutMe.hidden=NO;
//        self.location.hidden=NO;
//        self.gender.hidden=NO;
//        [self.view bringSubviewToFront:self.aboutMe];
//        [self.view bringSubviewToFront:self.location];
//        [self.view bringSubviewToFront:self.gender];
    }
}

//- (IBAction)myAction:(id)sender {
////    if (isPrivateOn){
////        isPrivateOn = NO;
////        UILabel *label = (UILabel*)[self.view viewWithTag:110];
////        label.hidden=YES;
////        self.navigationItem.title= [NSString stringWithFormat:@"My Anonograms"];
////        UIBarButtonItem *popularButton = [[UIBarButtonItem alloc]
////                                      initWithBarButtonSystemItem:UIBarButtonSystemItemStop
////                                      target:self action:@selector(myAction:)] ;
////        self.navigationItem.rightBarButtonItem = popularButton;
////        self.array = [[NSMutableArray alloc] init];
////        [self getDataMyAnonograms];
////    }
////    else {
//        isPrivateOn=YES;
////        NSString *string = [defaults valueForKey:@"twitterHandle"];
////        NSLog(@"STRING is %@",string);
////
////        if (string !=NULL)
////            self.navigationItem.title = string;
////        else
//            self.navigationItem.title = [NSString stringWithFormat:@"NOTIFICATIONS"];
//        UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_003_user.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(myAction:)] ;
//        self.navigationItem.rightBarButtonItem = privateButton;
//        self.array = [[NSMutableArray alloc] init];
//        [self getData];
//
//        
////    }
//
//    
//    
//}
//- (void)privateAction {
//    NSString *string = [defaults valueForKey:@"twitterHandle"];
//    NSLog(@"STRING is %@",string);
//    if (![string isEqualToString:@""])
//        self.navigationItem.title = string;
//    else
//        self.navigationItem.title = [NSString stringWithFormat:@"NOTIFICATIONS"];
////    self.navigationItem.title= [NSString stringWithFormat:@"PRIVATE"];
//    
//    UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_003_user.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(myAction:)] ;
//    self.navigationItem.rightBarButtonItem = privateButton;
//    self.array = [[NSMutableArray alloc] init];
//    [self getData];
//}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated: NO completion: nil];
    if (myPage) {
        [self postGender];
    }

}





//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
//{
//    return _array.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
//{
////    [tableView setSeparatorInset:UIEdgeInsetsZero];
//    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
//    if (self.array.count <= indexPath.row)
//        return cell;
//    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
//    NSLog(@"dictionary is %@",dictionary);
//    cell.pageContent.text = [dictionary objectForKey:@"text"];
//    NSString *string = @"+";
//    cell.likeCount.text = [string stringByAppendingString: [dictionary objectForKey:@"likes"]];
////    cell.likeCount.text = [dictionary objectForKey:@"likes"];
//    cell.replies.text = [dictionary objectForKey:@"replies"];
//    cell.timestamp.text = [[dictionary objectForKey:@"timestamp"] formattedAsTimeAgo];
//    if ([[dictionary objectForKey:@"isPrivate"] boolValue]==1) {
//        cell.lock.hidden=NO;
//    }
//    else
//        cell.lock.hidden=YES;
////    cell.share.tag = indexPath.row;
//    cell.flag.tag=indexPath.row;
//    cell.like.tag=indexPath.row;
//    cell.privatePost.tag=indexPath.row+1000;
//    cell.lock.tag=indexPath.row;
//    cell.replyButton.tag=indexPath.row;
//
////    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
////
////    if ([userId isEqualToString:[dictionary objectForKey:@"userId"]] ){
////        [cell.flag setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal ];
////    }
////    else {
////        [cell.flag setImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] forState:UIControlStateNormal ];
//////        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//////        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
//////        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//////            if (items.count) cell.flag.userInteractionEnabled=NO;
//////        }];
////    }
//    indexPathRow=indexPath;
//    return cell;
//}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//        NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
//        
//        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
//        [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//            if (items.count) {
//                NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
//                NSLog(@"likeCountis %d",likeCount);
//                if (likeCount>0){
//                    NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
//                    [dictionary setValue:likesCount forKey:@"likes"];
//                    
//                    [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                        NSLog(@"item is %@",item);
//                        if (item == NULL) return;
//
//                        NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]-1 ];
//                        NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                        
//                        [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                            [self logErrorIfNotNil:error];
//                        }];
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self.TableView reloadData];
//                }
//                
//            }
//            else {
//                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
//                [dictionary setValue:likesCount forKey:@"likes"];
//                
//                //            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
//                //            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
//                //                [self logErrorIfNotNil:error];
//                //            }];
//                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                    NSLog(@"item is %@",item);
//                    if (item == NULL) return;
//
//                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]+1 ];
//                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                    
//                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self logErrorIfNotNil:error];
//                }];
//                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//                NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};
//                
//                [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
//                    [self logErrorIfNotNil:error];
//                }];
//                [self.TableView reloadData];
//            }
//        }];
//        
////    }
////    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
//}
//- (IBAction)lockAction:(id)sender {
//    UIButton *btn = (UIButton*)sender;
//    UILabel *label = (UILabel*)[self.view viewWithTag:btn.tag+1000];
//    NSLog(@"lock btn tag is %d and label is %@",btn.tag,label);
//
////    label.alpha=1;
//    label.hidden=NO;
//    [UIView animateWithDuration:3
//                          delay:0.0
//                        options:UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         label.alpha=0.0; }
//                     completion:^(BOOL finished){
//                         label.alpha=1.0;
//                         label.hidden=YES;
//                     }];
//}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) {
//        if(isPrivateOn){
//            NSLog(@"scrolling up for more");
//            [self getData];
//        }
//    }
//    }
//}
//- (void) deleteText  {
//    [self.TableView beginUpdates];
//    
//    [Flurry logEvent:@"Delete"];
//    
//    NSString *postId = [[self.array objectAtIndex:flagButton] objectForKey:@"id" ];
//    NSLog(@"postId is %@",postId);
//    
//    /* delete post from table */
//    
//    [self.table deleteWithId:postId completion:^(NSDictionary *item, NSError *error) {
//        [self logErrorIfNotNil:error];
//    }];
//    //    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",postId];
//    
//    /* delete likes of the post from isLikeTable */
//    
//    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"isLikeTable items for postId are %@",items);
//        
//        for (NSDictionary *dictionary in items){
//            [self.isLikeTable deleteWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//        }
//        [self logErrorIfNotNil:error];
//    }];
//    
//    /* delete flags of the post from isFlagTable */
//    
//    [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"isFlagTable items for postId are %@",items);
//        
//        for (NSDictionary *dictionary in items){
//            [self.isFlagTable deleteWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//        }
//        [self logErrorIfNotNil:error];
//    }];
//    
//    /* delete comments of the post from commentTable */
//    
//    [self.commentTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"commentTable items for postId are %@",items);
//        
//        for (NSDictionary *dictionary in items){
//            NSString *commentId = [dictionary objectForKey:@"id" ];
//            [self.commentTable deleteWithId:commentId completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//            NSPredicate *predicateComment = [NSPredicate predicateWithFormat:@"commentId == %@",commentId];
//            [self.isLikeCommentTable readWithPredicate:predicateComment completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                NSLog(@"isLikeCommentTable items for postId are %@",items);
//                
//                for (NSDictionary *dictionary in items){
//                    [self.isLikeCommentTable deleteWithId:[dictionary objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                }
//                [self logErrorIfNotNil:error];
//            }];
//        }
//        [self logErrorIfNotNil:error];
//    }];
//    
//    [self.array removeObjectAtIndex:flagButton];
//    [self.TableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
//    
//    [self.TableView endUpdates];
//    [self.TableView reloadData];
//}
//
//- (IBAction)likeAction:(id)sender {
//    [Flurry logEvent:@"Like"];
//    UIButton *btnPressLike = (UIButton*)sender;
//    NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];
//
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
//    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        if (items.count) {
//            NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
//            NSLog(@"likeCountis %d",likeCount);
//            if (likeCount>0){
//                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
//                [dictionary setValue:likesCount forKey:@"likes"];
//                
//                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                    NSLog(@"item is %@",item);
//                    if (item == NULL) return;
//
//                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]-1 ];
//                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                    
//                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self logErrorIfNotNil:error];
//                }];
//                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
//                    [self logErrorIfNotNil:error];
//                }];
//                [self.TableView reloadData];
//            }
//            
//        }
//        else {
//            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
//            [dictionary setValue:likesCount forKey:@"likes"];
//            
//            //            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
//            //            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
//            //                [self logErrorIfNotNil:error];
//            //            }];
//            [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                NSLog(@"item is %@",item);
//                if (item == NULL) return;
//
//                NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]+1 ];
//                NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                
//                [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                    [self logErrorIfNotNil:error];
//                }];
//                [self logErrorIfNotNil:error];
//            }];
//            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//            NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};
//            
//            [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//            [self.TableView reloadData];
//        }
//    }];
//}
//
//- (IBAction)flagAction:(id)sender {
//   UIButton *btn = (UIButton *)sender;
//    flagButton = btn.tag;
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    
//    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userId"]] ){
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:@"Share", nil];
//        actionSheet.tag=0;
//        [actionSheet showInView:sender];
//    }
//    
//    else {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[self.array[flagButton] objectForKey:@"id" ]];
//        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//            if (!items.count) {
//                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:@"Share", nil];
//                actionSheet.tag=1;
//                [actionSheet showInView:sender];
//                
//            }
//            else {
//                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil];
//                actionSheet.tag=2;
//                [actionSheet showInView:sender];
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have already flagged this post!" message:nil
////                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
////                [alert show];
//            }
//        }];
////            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:nil];
////    actionSheet.tag=1;
////    [actionSheet showInView:sender];
//    }
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    UIButton * btn = (UIButton *) sender;
//    NSLog(@"btn.tag is %ld",(long)btn.tag);
//    if ([[segue identifier] isEqualToString:@"share"])
//    {
//        NSLog(@"blah private ");
////        shareViewController *vc = [[shareViewController alloc] init];
////        vc=[segue destinationViewController];
//        
////        UIImage *image = [self captureImage:btn.tag];
//        [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
////        vc.image = image;
//        
//    }
//    else {
//        commentedPost=btn.tag;
//        isComment = YES;
//        NSDictionary *dictionary = self.array[commentedPost];
////        NSString *string = [[NSString alloc] initWithString:[dictionary objectForKey:@"id"]];
//        CommentVC *vc = [[CommentVC alloc] init];
//        vc=(CommentVC*)[[segue destinationViewController]topViewController];
//        vc.postId =[dictionary objectForKey:@"id"];
//        vc.replies = [dictionary objectForKey:@"replies"];
//        vc.replyTitleString=[dictionary objectForKey:@"text"];
//
//    }
//}
//- (UIImage *) captureImage : (NSInteger) index {
//    UIView* captureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
//        captureView.backgroundColor = [UIColor whiteColor];
//    else
//        captureView.backgroundColor = [UIColor blackColor];
//    
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20,20 , 280, 280)];
//    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(185,275 , 110, 30)];
//    label.font = [UIFont fontWithName:@"GillSans-Light" size:22.0];
//    label.textAlignment=NSTextAlignmentCenter;
//    label.numberOfLines=6;
//    label.text = [self.array[index] objectForKey:@"text"];
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
//        label.textColor = [UIColor blackColor];
//    else
//        label.textColor = [UIColor whiteColor];
//    NSLog(@"label is %@",label);
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"watermark"]) {
//        label1.font = [UIFont fontWithName:@"GillSans-Light" size:15.0];
//        label1.textAlignment=NSTextAlignmentRight;
//        label1.text = @"ANONOGRAM";
//        label1.alpha = 0.6;
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
//            label1.textColor = [UIColor blackColor];
//        else
//            label1.textColor = [UIColor whiteColor];
//    }
//    [captureView addSubview:label];
//    [captureView addSubview:label1];
//
//    /* Capture the screen shot at native resolution */
//    UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, YES, 0.0);
//    [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenshot;
////    /* Render the screen shot at custom resolution */
////    CGRect cropRect= CGRectMake(0 ,0 ,2560,2560);
////    UIGraphicsBeginImageContextWithOptions(cropRect.size, YES, 1.0f);
////    [screenshot drawInRect:cropRect];
////    UIImage * customScreenShot = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    return customScreenShot;
//}

//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 0) {
//        if (buttonIndex==0){
//            NSLog(@"delete");
//            [self deleteText];
//        }
//    else if (buttonIndex==1){
// [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
//             [self performSegueWithIdentifier: @"share" sender: nil];
//        }
//    }
//    if (actionSheet.tag == 1) {
//        if (buttonIndex==0){
//            [Flurry logEvent:@"Flag"];
////            UIButton *btn = (UIButton *)[self.view viewWithTag:flagButton];
////            btn.userInteractionEnabled=NO;
//            NSLog(@"flag as inappropriate");
//            
//            NSDictionary *dictionary=[self.array objectAtIndex:flagButton];
//            NSString *flagsCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"flags"] integerValue]+1 ];
//            if ([flagsCount integerValue]>kFlagsAllowed){   //delete item if flagCount is more than kFlagsAllowed
//                [self deleteText];
//                return;
//            }
//            [dictionary setValue:flagsCount forKey:@"flags"];
//            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"flags": flagsCount};
//            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
//                //handle errors or any additional logic as needed
//                [self logErrorIfNotNil:error];
//            }];
//            
//            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//            NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};
//            [self.isFlagTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
//                //handle errors or any additional logic as needed
//                [self logErrorIfNotNil:error];
//            }];
//            [self.TableView reloadData];
//
//        }
//        else if (buttonIndex==1){
//  [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
//            [self performSegueWithIdentifier: @"share" sender: nil];
//        }
//    }
//    if (actionSheet.tag == 2){
//        if (buttonIndex==0) {
//             [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
//            [self performSegueWithIdentifier: @"share" sender: nil];
//        }
////        if(buttonIndex!=buttonsArray.count){
////        [Flurry logEvent:@"TwitterSwitch"];
////            NSString *string = buttonsArray[buttonIndex];
//////          [defaults setValue:string forKey:@"twitterHandle"];
////            self.navigationItem.title= string;
////        [self refreshView];
////        }
//    }
////    [[self.view viewWithTag:1] removeFromSuperview];
//}
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


//- (void) refreshView
//{
//
////    self.array = [[NSMutableArray alloc] init];
////
////    if(isPrivateOn)
//        [self getData];
////    }
////    [refreshControl endRefreshing];
//
//}



- (void) getData {
    NSLog(@"getting data...%@",self.userId);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [home turnOnIndicator];
    if (![home connectedToNetwork]){
        NSLog(@"test if network is available");
        [home noInternetAvailable];
        return;
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userid == %@ ",self.userId];
    [self.userTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"items are %@",items);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [home turnOffIndicator];

    //first order by ascending duration field
        if (items.count ==0)return;
            NSDictionary *dictionary = items[0];
            [self logErrorIfNotNil:error];
        self.navigationItem.title = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"username"]];
        
//        [self.aboutMe setTitle:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"aboutme"]] forState:UIControlStateNormal];
        self.aboutMeLabel.text=[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"aboutme"]];
        [self.username setTitle:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"username"]] forState:UIControlStateNormal];
        [self.gender setTitle:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"gender"]] forState:UIControlStateNormal];

        self.location.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"location"]];
        self.posts.text=[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"posts"]];
        self.replies.text=[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"userreplies"]];
        self.reputation.text=[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"reputation"]];
        NSMutableString *tempHex=[[NSMutableString alloc] init];
        [tempHex appendString:[dictionary objectForKey:@"color"]];
        unsigned colorInt = 0;
        [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
        self.colorView.backgroundColor = UIColorFromRGB(colorInt);
        self.colorView.layer.cornerRadius=20;
        self.colorView.layer.masksToBounds=YES;
        
        self.directMessage.layer.cornerRadius=5;
        self.directMessage.layer.masksToBounds=YES;
        self.directMessage.layer.borderColor=[UIColor blueColor].CGColor;
        self.directMessage.layer.borderWidth=2.0;
        
        if([self.location.text isEqualToString:@""] && myPage){
            NSLog(@"location");
            self.location.text = @"Location?";
//            self.location.hidden=YES;
        }
        if([self.aboutMeLabel.text isEqualToString:@""] && myPage){
            NSLog(@"aboutme");
            self.aboutMeLabel.text=@"Write something about yourself...";
//            [self.aboutMe setTitle:@"Write something about yourself..." forState:UIControlStateNormal];
//            self.aboutMe.hidden=YES;
        }
        if([[dictionary objectForKey:@"gender"] isEqualToString:@""] && myPage){
            NSLog(@"gender");

            [self.gender setTitle:@"gender?" forState:UIControlStateNormal];
//            self.gender.hidden=YES;
        }
        dataId = [dictionary objectForKey:@"id"];
        [self.view setNeedsDisplay];
        }];
    [self setup];

}


#pragma mark - textview delegated methods


- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
    [textView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        NSLog(@"done");
        [self doneKeyboard];
        return YES;
    }
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;

    if (textView.text.length + text.length > characterLimit){
        if (location != NSNotFound){
            [txtChat resignFirstResponder];
            txtChat.hidden=YES;
        }
        return NO;
    }
    else if (location != NSNotFound){
        [txtChat resignFirstResponder];
        txtChat.hidden=YES;
        return NO;
    }

    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{

    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.hidden=NO;
    label.text = [NSString stringWithFormat:@"%u",characterLimit-textView.text.length];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=YES;
}
-(void)createInputAccessoryView {
    
    UIToolbar *inputAccessoryView1 = [[UIToolbar alloc] init];
    //    inputAccessoryView1.barTintColor=[UIColor whiteColor];
    //    [inputAccessoryView1 sizeToFit];
    
    inputAccessoryView1.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(cancelKeyboard)];
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
//    isPrivateItem = [[UIBarButtonItem alloc] initWithTitle:@"Private"
//                                                     style:UIBarButtonItemStyleBordered
//                                                    target:self action:@selector(addText)];
    //    isPrivateItem.tag=200;
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(doneKeyboard)];
    
    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,doneItem, nil];
    [inputAccessoryView1 setItems:itemsView animated:NO];
    [txtChat addSubview:inputAccessoryView1];
    
}


-(void)doneKeyboard{
    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = @"140";
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if(!([[txtChat.text stringByTrimmingCharactersInSet: set] length] == 0) )
    {
        //    if(![txtChat.text isEqualToString:@""])
        txtChat.text = [NSString stringWithFormat:@"%@",txtChat.text];
        if (isDirectMessage)
            [self postDirectMessage];
        else if (isAboutMe)
            [self postAboutMe];
        else if (isLocation)
            [self postLocation];
        else
            [self postUsername];
    }
    
    txtChat.text = @"";
}
-(void)cancelKeyboard{
    [txtChat resignFirstResponder];
    txtChat.text=@"";
    txtChat.hidden=YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = @"140";
    
}

- (IBAction)composeAction:(id)sender {
    isDirectMessage=YES;
    isAboutMe=NO;
    isLocation=NO;
    [self bringUpTextView];
 
    
}

- (IBAction)aboutMeAction:(id)sender {
    isAboutMe=YES;
    isDirectMessage=NO;
    isLocation=NO;
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.text= [NSString stringWithFormat:@"Write a bit about you...%@",self.username.titleLabel.text];

    [self bringUpTextView];

}

- (IBAction)userNameAction:(id)sender {
    isAboutMe=NO;
    isDirectMessage=NO;
    isLocation=NO;
    [self bringUpTextView];
}

- (IBAction)genderAction:(id)sender {
    if(tapAction>2) tapAction=0;
    if ([self.gender.titleLabel.text isEqualToString:@"Female"])
        tapAction=1;
    if (tapAction==0)
        [self.gender setTitle:@"Female" forState:UIControlStateNormal];
    else if (tapAction==1)
        [self.gender setTitle:@"Male" forState:UIControlStateNormal];
    else
        [self.gender setTitle:@" " forState:UIControlStateNormal];
    tapAction++;

}

- (IBAction)locationAction:(id)sender {
    isAboutMe=NO;
    isDirectMessage=NO;
    isLocation=YES;
    [self bringUpTextView];
}

-(void) bringUpTextView {

    NSLog(@"compose");
    txtChat.hidden=NO;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=NO;
    label.hidden=NO;

    if (isDirectMessage){
        label2.text= [NSString stringWithFormat:@"Direct message %@",self.username.titleLabel.text];
        label.text=@"140";
        characterLimit=200;
    }
    else if (isAboutMe){
        label2.text=@"Write something about yourself ...";
        label.text =@"140";
        characterLimit=140;

    }
    else if (isLocation){
        label.text=@"20";
        label2.text=@"Enter your location - e.g., San Francisco, CA";
        characterLimit=20;
    }
    else {
        label.text=@"20";
        label2.text=@"Create a username";
        characterLimit=20;
    }
    [self.view bringSubviewToFront:txtChat];
    [txtChat becomeFirstResponder];
}

-(void)postDirectMessage
{
    [Flurry logEvent:@"PostDirectMessage"];
    
//    NSString *myId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSDictionary *item = @{@"userid" : myId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0",@"replies" :@"0", @"isprivate":[NSNumber numberWithBool:isPrivateOn], @"touserid" : self.userId};
    [self.table insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    [self cancel:nil];

}
-(void)postAboutMe
{
    [Flurry logEvent:@"PostAboutMe"];
//    [self.aboutMe setTitle:txtChat.text forState:UIControlStateNormal];
    self.aboutMeLabel.text=txtChat.text;
    NSDictionary *item = @{@"id" : dataId,@"aboutme" : txtChat.text};
    [self.userTable update:item completion:^(NSDictionary *insertedItem, NSError *error) {
        [self logErrorIfNotNil:error];
//        [self getData];
    }];
}
-(void)postUsername
{
    [Flurry logEvent:@"PostUsername"];
    [self.username setTitle:txtChat.text forState:UIControlStateNormal];
    self.navigationItem.title=txtChat.text;
    NSDictionary *item = @{@"id" : dataId,@"username" : txtChat.text};
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@",txtChat.text];
    [self.userTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [self logErrorIfNotNil:error];
        if (items.count) {
            //ALERT MESSAGE
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Username already exists!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
        else {
            [self.userTable update:item completion:^(NSDictionary *insertedItem, NSError *error) {
                [self logErrorIfNotNil:error];
//                [self getData];
            }];
        }
    }];
}

-(void)postGender
{
    NSString *string = self.gender.titleLabel.text;
    if ([string isEqualToString:@"gender?"]) {
        NSLog(@"gender is %@",string);
        return;
    }
    [Flurry logEvent:@"PostGender"];

    NSDictionary *item = @{@"id" : dataId,@"gender" : self.gender.titleLabel.text};
    [self.userTable update:item completion:^(NSDictionary *insertedItem, NSError *error) {
        [self logErrorIfNotNil:error];
        
//        [self getData];
    }];
}
-(void)postLocation
{
    [Flurry logEvent:@"PostLocation"];
    self.location.text= txtChat.text;

    NSDictionary *item = @{@"id" : dataId,@"location" : txtChat.text};
    [self.userTable update:item completion:^(NSDictionary *insertedItem, NSError *error) {
        [self logErrorIfNotNil:error];
//        [self getData];
    }];
}
- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

@end
