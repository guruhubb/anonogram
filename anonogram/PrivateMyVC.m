//
//  PrivateMyVC.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#define kLimit 20
#define kFlagsAllowed 10
#import "PrivateMyVC.h"
#import "Cell.h"
#import "shareViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "CommentVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "CommentVC.h"
#import "UserViewController.h"
#import "HomeViewController.h"

@interface PrivateMyVC (){
    NSUserDefaults *defaults;
    NSString *token;
    BOOL isPrivateOn;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSInteger flagButton;
    NSInteger likeTotalCount;
    BOOL isComment;
    NSInteger commentedPost;
    UITextView        *txtChat;
    UIToolbar *_inputAccessoryView;
    NSTimeInterval nowTime;
    NSTimeInterval startTime ;
       HomeViewController *home;
}
//@property (nonatomic, strong)   NSString *myId;
@property (nonatomic, strong)   MSTable *table;
@property (nonatomic, strong)   MSTable *isLikeTable;
@property (nonatomic, strong)   MSTable *isFlagTable;
@property (nonatomic, strong)   MSTable *commentTable;
@property (nonatomic, strong)   MSTable *isLikeCommentTable;
@property (nonatomic, strong)   MSTable *userTable;
@property (nonatomic, strong)   MSTable *directMessageTable;

@property (strong, nonatomic) IBOutlet UITableView *TableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong)   MSClient *client;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *myButton;

@end

@implementation PrivateMyVC

-(void)viewDidAppear:(BOOL)animated {

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    startTime=0;
    _noDirectMessageView.layer.cornerRadius=5.0;
    _noDirectMessageView.layer.frame=CGRectMake(20, screenSpecificSetting(121,121-88), 280,154);
//    self.myId = [[NSString alloc] init];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.TableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    [self.TableView setSeparatorInset:UIEdgeInsetsZero];
    home = [[HomeViewController alloc] init];

    self.array = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.isLikeTable = [self.client tableWithName:@"isLike"];
    self.isFlagTable = [self.client tableWithName:@"isFlag"];
    self.commentTable = [self.client tableWithName:@"commentTable"];
    self.directMessageTable = [self.client tableWithName:@"directMessageTable"];
    self.isLikeCommentTable = [self.client tableWithName:@"isLikeCommentTable"];
    self.userTable=[self.client tableWithName:@"userTable"];
    isPrivateOn=YES;
//    UILabel *label = (UILabel*)[self.view viewWithTag:110];
//    label.text =@"No Notifications yet\n\nMake sure access to Twitter is On\n\nYou will receive posts that mention your Twitter username";
    if (!IS_TALL_SCREEN) {
        self.TableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(handleNotification:) name:@"replyComplete" object:nil ];
    defaults = [NSUserDefaults standardUserDefaults];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.TableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];

//    if (![defaults objectForKey:@"twitterAccounts"])
//        [self twitterSwitch:nil];
    [self refreshView];
    
}
- (void) handleNotification : (NSNotification *)notification {
    NSLog(@"notification");
    [self refreshView];
    //    NSString *replies = [self.array[commentedPost] objectForKey:@"replies"];
    //    NSString *aString = [NSString stringWithFormat:@"%d", [replies integerValue]+ [defaults integerForKey:@"counter"] ];
    //    NSLog(@"replies are %@ and counter is %d, and aString is %@",replies,[defaults integerForKey:@"counter"],aString);
    //    [self.array[commentedPost] setObject:aString forKey:@"replies"];
    //    [self.theTableView reloadData];
}
- (IBAction)myAction:(id)sender {
    if (isPrivateOn){
        isPrivateOn = NO;
//        UILabel *label = (UILabel*)[self.view viewWithTag:110];
//        label.hidden=YES;
        _noDirectMessageView.hidden=YES;

        self.navigationItem.title= [NSString stringWithFormat:@"My Anonograms"];
        UIBarButtonItem *popularButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                      target:self action:@selector(myAction:)] ;
        self.navigationItem.rightBarButtonItem = popularButton;
        self.array=nil;
        self.array = [[NSMutableArray alloc] init];
        [self.TableView reloadData];
        [self getDataMyAnonograms];
    }
    else {
        isPrivateOn=YES;
//        NSString *string = [defaults valueForKey:@"twitterHandle"];
//        NSLog(@"STRING is %@",string);
//
//        if (string !=NULL)
//            self.navigationItem.title = string;
//        else
            self.navigationItem.title = [NSString stringWithFormat:@"DIRECT MESSAGES"];
        UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_003_user.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(myAction:)] ;
        self.navigationItem.rightBarButtonItem = privateButton;
        self.array=nil;
        self.array = [[NSMutableArray alloc] init];
        [self.TableView reloadData];
        [self getDataMyDirectMessages];
        
//        [self getData];

        
    }

    
    
}
- (void)privateAction {
    NSString *string = [defaults valueForKey:@"twitterHandle"];
    NSLog(@"STRING is %@",string);
    if (![string isEqualToString:@""])
        self.navigationItem.title = string;
    else
        self.navigationItem.title = [NSString stringWithFormat:@"NOTIFICATIONS"];
//    self.navigationItem.title= [NSString stringWithFormat:@"PRIVATE"];
    
    UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_003_user.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(myAction:)] ;
    self.navigationItem.rightBarButtonItem = privateButton;
    self.array=nil;

    self.array = [[NSMutableArray alloc] init];
//    [self getData];
    [self getDataMyDirectMessages];

}



- (void) getUUID {
    
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    if (retrieveuuid ==NULL) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        NSString *UUID = (__bridge NSString *)string;
        [SSKeychain setPassword:UUID forService:@"com.anonogram.guruhubb" account:@"user"];
        retrieveuuid=UUID;
        NSLog(@"UUID is %@",retrieveuuid);
        
        
    }
    NSLog(@"UUID is %@",retrieveuuid);
}

+ (NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)(string);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
    if (self.array.count <= indexPath.row)
        return cell;
    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
    cell.pageContent.text = [dictionary objectForKey:@"text"];
    NSString *string = @"+";
    
    NSString *reputation = [home abbreviateNumber:[[dictionary objectForKey:@"reputation"] integerValue] ];
    NSString *posts = [home abbreviateNumber:[[dictionary objectForKey:@"posts"] integerValue] ];
    NSString *userreplies = [home abbreviateNumber:[[dictionary objectForKey:@"userreplies"] integerValue]];
    NSString *replies = [home abbreviateNumber:[[dictionary objectForKey:@"replies"] integerValue]];
    NSString *likes = [home abbreviateNumber:[[dictionary objectForKey:@"likes"] integerValue]];
    
    NSString *userScore = [NSString stringWithFormat:@"%@ \u00B7 %@ \u00B7 %@",reputation,posts,userreplies];
    
    if (isPrivateOn){
        cell.userScore.text = userScore;
        cell.aboutMe.text = [dictionary objectForKey:@"aboutme"];
        cell.location.text = [dictionary objectForKey:@"location"];
        cell.userScoreButton.userInteractionEnabled=YES;

    }
    else {
        cell.userScore.text = @"";
        cell.aboutMe.text = @"";
        cell.location.text = @"";
        cell.userScoreButton.userInteractionEnabled=NO;
        if ([[dictionary objectForKey:@"isprivate"] boolValue]==1) {
            cell.lock.hidden=NO;
        }
        else
            cell.lock.hidden=YES;
        cell.privatePost.tag=indexPath.row+1000;
        cell.lock.tag=indexPath.row;
    }
    
    cell.likeCount.text = [string stringByAppendingString:likes];
    cell.replies.text = replies;
    cell.timestamp.text = [[dictionary objectForKey:@"timestamp"] formattedAsTimeAgo];
    cell.flag.tag=indexPath.row;
    cell.like.tag=indexPath.row;
    cell.replyButton.tag=indexPath.row;
    cell.userScoreButton.tag=indexPath.row;
    
    indexPathRow=indexPath;
    return cell;




}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
        
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) {
//                NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
//                NSLog(@"likeCountis %d",likeCount);
//                if (likeCount>0){
                    NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                    [dictionary setValue:likesCount forKey:@"likes"];
                NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]-1 ];
                [dictionary setValue:reputationCount forKey:@"reputation"];
                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
//                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"postid == %@",[dictionary objectForKey:@"id" ]];
//                
//                [self.isLikeTable readWithPredicate:predicate2 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    likeTotalCount = totalCount;
//                }];
//                    [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                        NSLog(@"item is %@",item);
//                        if (item == NULL) return;
//
//                        NSString *string =[NSString stringWithFormat:@"%d",likeTotalCount ];
//                        NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                        
//                        [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                            [self logErrorIfNotNil:error];
//                        }];
//                        [self logErrorIfNotNil:error];
//                    }];
                
                    [self.TableView reloadData];
//                }
                
            }
            else {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]+1 ];
                [dictionary setValue:reputationCount forKey:@"reputation"];
                //            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
                //            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                //                [self logErrorIfNotNil:error];
                //            }];
                NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
                
                [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
//                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"postid == %@",[dictionary objectForKey:@"id" ]];
//                
//                [self.isLikeTable readWithPredicate:predicate2 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    likeTotalCount = totalCount;
//                }];
//                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                    NSLog(@"item is %@",item);
//                    if (item == NULL) return;
//
//                    NSString *string =[NSString stringWithFormat:@"%d",likeTotalCount ];
//                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                    
//                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self logErrorIfNotNil:error];
//                }];
//                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
               
                [self.TableView reloadData];
            }
        }];
        
//    }
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
- (IBAction)lockAction:(id)sender {

    UIButton *btn = (UIButton*)sender;
    UILabel *label = (UILabel*)[self.view viewWithTag:btn.tag+1000];
    NSLog(@"lock btn tag is %d and label is %@",btn.tag,label);

//    label.alpha=1;
    label.hidden=NO;
    [UIView animateWithDuration:3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         label.alpha=0.0; }
                     completion:^(BOOL finished){
                         label.alpha=1.0;
                         label.hidden=YES;
                     }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        if(isPrivateOn){
            NSLog(@"scrolling up for more");
            [self getDataMyDirectMessages];
//            [self getData];

        }
        else
            [self getDataMyAnonograms];
    }
    }
}
- (void) deleteText  {
    [self.TableView beginUpdates];
    
    [Flurry logEvent:@"Delete"];
    
    NSString *postId = [[self.array objectAtIndex:flagButton] objectForKey:@"id" ];
    NSLog(@"postId is %@",postId);
    
    /* delete post from table */
    
    [self.table deleteWithId:postId completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    //    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postid == %@",postId];
    
    /* delete likes of the post from isLikeTable */
    
    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"isLikeTable items for postId are %@",items);
        
        for (NSDictionary *dictionary in items){
            [self.isLikeTable deleteWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
        }
        [self logErrorIfNotNil:error];
    }];
    
//    /* delete flags of the post from isFlagTable */
    
    [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"isFlagTable items for postId are %@",items);
        
        for (NSDictionary *dictionary in items){
            [self.isFlagTable deleteWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
        }
        [self logErrorIfNotNil:error];
    }];
    
    /* delete comments of the post from commentTable */
    
    [self.commentTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"commentTable items for postId are %@",items);
        
        for (NSDictionary *dictionary in items){
            NSString *commentId = [dictionary objectForKey:@"id" ];
            [self.commentTable deleteWithId:commentId completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            NSPredicate *predicateComment = [NSPredicate predicateWithFormat:@"commentid == %@",commentId];
            [self.isLikeCommentTable readWithPredicate:predicateComment completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                NSLog(@"isLikeCommentTable items for postId are %@",items);
                
                for (NSDictionary *dictionary in items){
                    [self.isLikeCommentTable deleteWithId:[dictionary objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
                        [self logErrorIfNotNil:error];
                    }];
                }
                [self logErrorIfNotNil:error];
            }];
        }
        [self logErrorIfNotNil:error];
    }];
    [self.table deleteWithId:postId completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    /* update reputation and posts count in userTable */

    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
    [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [self logErrorIfNotNil:error];
        if(!error){
            NSString *string1 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"posts"] integerValue]-1 ];
            NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]-6 ];
            NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"], @"posts": string1, @"reputation":string2};
            [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
                [self refreshView];
            }];
        }
    }];

    
    [self.array removeObjectAtIndex:flagButton];
    [self.TableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
    
    [self.TableView endUpdates];
    [self.TableView reloadData];
}
//- (void) deleteText  {
//    [self.TableView beginUpdates];
//
//    [Flurry logEvent:@"Delete"];
//
//    NSLog(@"delete id is %@",[[self.array objectAtIndex:flagButton] objectForKey:@"id" ]);
//
//    [self.table deleteWithId:[[self.array objectAtIndex:flagButton] objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//        [self logErrorIfNotNil:error];
//    }];
//    NSDictionary *item =@{@"postId" : [[self.array objectAtIndex:flagButton] objectForKey:@"id" ]};
//    [self.isLikeTable delete:item completion:^(NSDictionary *item, NSError *error) {
//        [self logErrorIfNotNil:error];
//    }];
//    [self.isFlagTable delete:item completion:^(NSDictionary *item, NSError *error) {
//        [self logErrorIfNotNil:error];
//    }];
//    
//    
//    [self.array removeObjectAtIndex:flagButton];
//    [self.TableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
//
//    [self.TableView endUpdates];
//    [self.TableView reloadData];
//}

//- (IBAction)likeAction:(id)sender {
//    [Flurry logEvent:@"Like"];
//    UIButton *btnPressLike = (UIButton*)sender;
//    NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];
//
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[dictionary objectForKey:@"id" ]];
//    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        if (items.count) {
//            NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
//            NSLog(@"likeCountis %d",likeCount);
//            if (likeCount>0){
//                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
//                [dictionary setValue:likesCount forKey:@"likes"];
//                
//                NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]-1 ];
//                [dictionary setValue:reputationCount forKey:@"reputation"];
//                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
//                [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    NSLog(@"items usertable are %@",items);
//                    [self logErrorIfNotNil:error];
//                    if(!error){
//                        NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]-1 ];
//                        NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
//                        [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
//                            NSLog(@"updated item usertable is %@",item);
//                            
//                            [self logErrorIfNotNil:error];
//                        }];
//                    }
//                }];
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
//            NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]+1 ];
//            [dictionary setValue:reputationCount forKey:@"reputation"];
//            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
//            [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                NSLog(@"items usertable are %@",items);
//                [self logErrorIfNotNil:error];
//                if(!error){
//                    NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]+1 ];
//                    NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
//                    [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
//                        NSLog(@"updated item usertable is %@",item);
//                        
//                        [self logErrorIfNotNil:error];
//                    }];
//                }
//            }];
//            
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
////            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//            NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
//            
//            [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//            [self.TableView reloadData];
//        }
//    }];
//}

- (IBAction)flagAction:(id)sender {
   UIButton *btn = (UIButton *)sender;
    flagButton = btn.tag;
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    
    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userid"]] ){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:@"Share", nil];
        actionSheet.tag=0;
        [actionSheet showInView:sender];
    }
    
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[self.array[flagButton] objectForKey:@"id" ]];
        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (!items.count) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:@"Share", nil];
                actionSheet.tag=1;
                [actionSheet showInView:sender];
                
            }
            else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil];
                actionSheet.tag=2;
                [actionSheet showInView:sender];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have already flagged this post!" message:nil
//                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }
        }];
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:nil];
//    actionSheet.tag=1;
//    [actionSheet showInView:sender];
    }
}
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton * btn = (UIButton *) sender;
    NSLog(@"btn.tag is %ld",(long)btn.tag);
    if ([[segue identifier] isEqualToString:@"share"])
        [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
    else if ([[segue identifier] isEqualToString:@"goToSettings"]){
    }
    else if ([[segue identifier] isEqualToString:@"user"]){
        NSDictionary *dictionary = self.array[btn.tag];
        UserViewController *vc = [[UserViewController alloc] init];
        vc=(UserViewController*)[[segue destinationViewController]topViewController];
        vc.userId =[dictionary objectForKey:@"userid"];
    }
    else {
        commentedPost=btn.tag;
        isComment = YES;
        NSDictionary *dictionary = self.array[commentedPost];
        CommentVC *vc = [[CommentVC alloc] init];
        vc=(CommentVC*)[[segue destinationViewController]topViewController];
        vc.postId =[dictionary objectForKey:@"id"];
        vc.replies = [dictionary objectForKey:@"replies"];
        vc.replyTitleString=[dictionary objectForKey:@"text"];
        NSLog(@"vc is %@, %@, %@",vc.postId, vc.replies, vc.replyTitleString);

    }
}
- (UIImage *) captureImage : (NSInteger) index {
    UIView* captureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
        captureView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    else
        captureView.backgroundColor = [UIColor blackColor];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20,20 , 280, 280)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(185,275 , 110, 30)];
    label.font = [UIFont fontWithName:@"GillSans-Light" size:22.0];
    label.textAlignment=NSTextAlignmentCenter;
    label.numberOfLines=6;
    label.text = [self.array[index] objectForKey:@"text"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
        label.textColor = [UIColor blackColor];
    else
        label.textColor = [UIColor whiteColor];
    NSLog(@"label is %@",label);
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"watermark"]) {
        label1.font = [UIFont fontWithName:@"GillSans-Light" size:15.0];
        label1.textAlignment=NSTextAlignmentRight;
        label1.text = @"ANONOGRAM";
        label1.alpha = 0.6;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
            label1.textColor = [UIColor blackColor];
        else
            label1.textColor = [UIColor whiteColor];
    }
    [captureView addSubview:label];
    [captureView addSubview:label1];

    /* Capture the screen shot at native resolution */
    UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, YES, 0.0);
    [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
//    /* Render the screen shot at custom resolution */
//    CGRect cropRect= CGRectMake(0 ,0 ,2560,2560);
//    UIGraphicsBeginImageContextWithOptions(cropRect.size, YES, 1.0f);
//    [screenshot drawInRect:cropRect];
//    UIImage * customScreenShot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return customScreenShot;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex==0){
            NSLog(@"delete");
            [self deleteText];
        }
    else if (buttonIndex==1){
 [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
             [self performSegueWithIdentifier: @"share" sender: nil];
        }
    }
    if (actionSheet.tag == 1) {
        if (buttonIndex==0){
            [Flurry logEvent:@"Flag"];
//            UIButton *btn = (UIButton *)[self.view viewWithTag:flagButton];
//            btn.userInteractionEnabled=NO;
            NSLog(@"flag as inappropriate");
            
            NSDictionary *dictionary=[self.array objectAtIndex:flagButton];
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
            
            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
            [self.isFlagTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                //handle errors or any additional logic as needed
                [self logErrorIfNotNil:error];
            }];
            [self.TableView reloadData];

        }
        else if (buttonIndex==1){
  [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
            [self performSegueWithIdentifier: @"share" sender: nil];
        }
    }
    if (actionSheet.tag == 2){
        if (buttonIndex==0) {
             [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
            [self performSegueWithIdentifier: @"share" sender: nil];
        }
//        if(buttonIndex!=buttonsArray.count){
//        [Flurry logEvent:@"TwitterSwitch"];
//            NSString *string = buttonsArray[buttonIndex];
////          [defaults setValue:string forKey:@"twitterHandle"];
//            self.navigationItem.title= string;
//        [self refreshView];
//        }
    }
//    [[self.view viewWithTag:1] removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) refreshView
{
  
//    nowTime =[[NSDate date] timeIntervalSince1970];
//    if ((nowTime-startTime)> 5 ){
//        startTime =[[NSDate date] timeIntervalSince1970];
//        NSLog(@"refresh start time is %f",startTime);
//        NSLog(@"refresh now time is %f",nowTime-startTime);

//        self.array=nil;
    self.array=nil;

    self.array = [[NSMutableArray alloc] init];

    if(isPrivateOn){
//        [self getData];
        [self getDataMyDirectMessages];

    }
    else
        [self getDataMyAnonograms];
//    }
    [refreshControl endRefreshing];

}

- (void) storeData {
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    NSDictionary *item = @{ @"text" : @"Awesome item" };
    MSTable *itemTable = [client tableWithName:@"anonogramTable"];
    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
    }];
    
}

- (void) getData {
    NSLog(@"getting data...");
    buttonsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"twitterAccounts"]];
    NSPredicate *predicate ;
    if (!buttonsArray.count) {
//        self.array=nil;
        [self.TableView reloadData];
        UILabel *label = (UILabel*)[self.view viewWithTag:110];
        label.hidden=NO;
        [self.view bringSubviewToFront:label];
        return;
    }
    switch (buttonsArray.count) {
        case 1:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@",buttonsArray[0]];
            break;
        case 2:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1]];
            break;
        case 3:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1],buttonsArray[2]];
            break;
        case 4:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1],buttonsArray[2],buttonsArray[3]];
            break;
        case 5:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1],buttonsArray[2],buttonsArray[3],buttonsArray[4]];
            break;
        case 6:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1],buttonsArray[2],buttonsArray[3],buttonsArray[4],buttonsArray[5]];
            break;
        case 7:
            predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@",buttonsArray[0],buttonsArray[1],buttonsArray[2],buttonsArray[3],buttonsArray[4],buttonsArray[5],buttonsArray[6]];
            break;
            
        default:
            break;
    }
//    NSString *string1 =[NSString stringWithFormat:@" %@ ",[defaults valueForKey:@"twitterHandle"]];
//    NSString *string2 =[NSString stringWithFormat:@" @%@ ",[defaults valueForKey:@"twitterHandle"]];
//     NSString *string3 =[NSString stringWithFormat:@" #%@ ",[defaults valueForKey:@"twitterHandle"]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@ || %@",string1,string2];
//    MSQuery *query = [self.table queryWithPredicate:predicate];
    MSQuery *query = [self.table query];
    query.predicate=predicate;
    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
    query.includeTotalCount = YES; // Request the total item count
    query.fetchLimit = kLimit;
    query.fetchOffset = self.array.count;
    NSLog(@"array count is %d",self.array.count);

    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"items are %@, totalCount is %d",items,totalCount);
        [self logErrorIfNotNil:error];
        if(!error) {
            //add the items to our local copy
            [self.array addObjectsFromArray:items];
            NSLog(@"array is %@",self.array);
            if (self.array.count==0){
                UILabel *label = (UILabel*)[self.view viewWithTag:110];
                label.hidden=NO;
                [self.view bringSubviewToFront:label];
            }
            else {
                UILabel *label = (UILabel*)[self.view viewWithTag:110];
                label.hidden=YES;
            }
                

            [self.TableView reloadData];
        }
    }];
}
- (void) getDataMyAnonograms {
    NSLog(@"getting data my anons...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [home turnOnIndicator];

    if (![home connectedToNetwork]){
        NSLog(@"test if network is available");
        [home noInternetAvailable];
        return;
    }
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@",userId];
    MSQuery *query = [self.table query];
    query.predicate=predicate;
    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
    query.includeTotalCount = YES; // Request the total item count
    query.fetchLimit = kLimit;
    query.fetchOffset = self.array.count;
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [home turnOffIndicator];

        NSLog(@"items are %@, totalCount is %d",items,totalCount);
        [self logErrorIfNotNil:error];
        if(!error) {
            //add the items to our local copy
            [self.array addObjectsFromArray:items];
            [self.TableView reloadData];
        }
    }];
}
- (void) getDataMyDirectMessages {
    NSLog(@"getting direct messages...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [home turnOnIndicator];
    if (![home connectedToNetwork]){
        NSLog(@"test if network is available");
        [home noInternetAvailable];
        return;
    }
    NSString *myId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    
//    NSDictionary *postValues = @{
//                                 @"touserid":myId ,
//                                 @"offset":[NSNumber numberWithInt:self.array.count],
//                                 @"limit" :[NSNumber numberWithInt:kLimit]
//                                 };
//    NSLog(@"postvalues are %@",postValues);
//    [self.client invokeAPI:@"getdirectmessagefeed" body:postValues HTTPMethod:@"POST"
//                parameters:nil
//                   headers:nil
//                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
//                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                    [home turnOffIndicator];
//                    NSLog(@"URLResponse: %@", response);
//                    NSLog(@"result: %@", result);
//                    if (error)
//                    {
//                        NSString* errorMessage = @"There was a problem! ";
//                        errorMessage = [errorMessage stringByAppendingString:[error localizedDescription]];
//                        UIAlertView* myAlert = [[UIAlertView alloc]
//                                                initWithTitle:@"Error!"
//                                                message:errorMessage
//                                                delegate:nil
//                                                cancelButtonTitle:@"Okay"
//                                                otherButtonTitles:nil];
//                        [myAlert show];
//                    } else {
//                        NSLog(@"result is %@",result);
//                        [self.array addObjectsFromArray:result];
//                        [self.TableView reloadData];
//                    }
//                }];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"touserid == %@",myId];
    MSQuery *query = [self.table queryWithPredicate:predicate];
    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
    query.includeTotalCount = YES; // Request the total item count
    query.fetchLimit = kLimit;
    query.fetchOffset = self.array.count;
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [home turnOffIndicator];
        NSLog(@"items are %@, totalCount is %d",items,totalCount);
        [self logErrorIfNotNil:error];
        [self.array addObjectsFromArray:items];
        if (!self.array.count) _noDirectMessageView.hidden=NO;
        else _noDirectMessageView.hidden=YES;
        if(!error) {
            //add the items to our local copy
            for (NSMutableDictionary *dictionary in self.array){
                NSString *userid = [dictionary objectForKey:@"userid"];
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userid];
                MSQuery *query1=[self.userTable queryWithPredicate:predicate1];
                query1.selectFields=@[@"userreplies", @"reputation",@"posts",@"aboutme",@"location"];
                [query1 readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                    NSDictionary *dic = items[0];
                    NSLog(@"dic is %@",dic);
                    [dictionary setValuesForKeysWithDictionary:dic];
                    NSLog(@"dictionary is %@",dictionary);
                    [self.TableView reloadData];
                }];
            }
            NSLog(@"self.array is %@",self.array);
        }
    }];
}
- (IBAction)noDMAction:(id)sender {
    _noDirectMessageView.hidden=YES;
}


- (IBAction)twitterSwitch:(id)sender {
//}
//- (IBAction)TwitterSwitch:(id)sender {
//- (void)TwitterSwitch {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
//    NSDictionary *options = @{
//                              @"ACFacebookAppIdKey" : @"1467245410178277",
////                              @"ACFacebookPermissionsKey" : @[@"publish_stream"],
////                              @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
//                              }; // Needed only when write permissions are requested
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
//    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        
        
        // Get the list of Twitter accounts.
        NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
        
        NSLog(@"%@", accountsArray);
            [self performSelectorOnMainThread:@selector(populateSheetAndShow:) withObject:accountsArray waitUntilDone:NO];
           }];
}

-(void)populateSheetAndShow:(NSArray *) accountsArray {
    if(accountsArray.count==0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Access" message:@"You need to grant access to receive public or private mentions\nGo to Settings->Twitter. Scroll down and turn Anonogram on"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
        
    }
    buttonsArray = [NSMutableArray array];
    [accountsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [buttonsArray addObject:((ACAccount*)obj).username];
    }];
    [defaults setObject:buttonsArray forKey:@"twitterAccounts"];
    
    NSLog(@"%@", buttonsArray);
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    actionSheet.tag=2;
//    for( NSString *title in buttonsArray){
//        [actionSheet addButtonWithTitle:title];
//    }
//    [actionSheet addButtonWithTitle:@"Cancel"];
//    
//    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
//    [actionSheet showInView:self.view];
}
- (void) getTwitterUsername {
    //get Twitter username and store it
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if(granted) {
             NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
             if ([accountsArray count] > 0) {
                 ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                 NSLog(@"%@",twitterAccount.username);
                 NSLog(@"%@",twitterAccount.accountType);
                 [[NSUserDefaults standardUserDefaults] setValue:twitterAccount.username forKey:@"twitterHandle"];
             }
         }}];
    NSLog(@"twitterHandle is %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"twitterHandle"]);
}

#pragma mark - textView delegated methods


- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
    [textView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 140){
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    else if (location != NSNotFound){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%u",140-textView.text.length];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=YES;
    
}

-(void)createInputAccessoryView {
    
    UIToolbar *inputAccessoryView1 = [[UIToolbar alloc] init];
    inputAccessoryView1.barTintColor=[UIColor lightGrayColor];
    [inputAccessoryView1 sizeToFit];
    
    inputAccessoryView1.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(cancelKeyboard)];
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *isPrivateItem = [[UIBarButtonItem alloc] initWithTitle:@"@IsPrivate"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(addText)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(doneKeyboard)];
    
    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,isPrivateItem,flexItem,doneItem, nil];
    [inputAccessoryView1 setItems:itemsView animated:NO];
    [txtChat addSubview:inputAccessoryView1];
    
}

-(void) addText {
    [Flurry logEvent:@"isPrivate Tapped"];
    
    txtChat.text = [NSString stringWithFormat:@"@IsPrivate %@",txtChat.text];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=YES;
    
}

//-(void)createInputAccessoryViewForSearch {
//    
//    _inputAccessoryView = [[UIToolbar alloc] init];
//    _inputAccessoryView.barTintColor=[UIColor lightGrayColor];
//    [_inputAccessoryView sizeToFit];
//    
//    _inputAccessoryView.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
//    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
//                                                                   style:UIBarButtonItemStyleBordered
//                                                                  target:self action:@selector(searchBarCancel)];
//    //Use this to put space in between your toolbox buttons
//    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                              target:nil
//                                                                              action:nil];
//    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
//                                                                 style:UIBarButtonItemStyleBordered
//                                                                target:self action:@selector(searchBarClicked)];
//    
//    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,doneItem, nil];
//    [_inputAccessoryView setItems:itemsView animated:NO];
//}

-(void)doneKeyboard{
    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = @"140";
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if(!([[txtChat.text stringByTrimmingCharactersInSet: set] length] == 0) )
        //    {
        //    if(![txtChat.text isEqualToString:@""])
        [self postComment];
    
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
    
    NSLog(@"compose");
    txtChat.hidden=NO;
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=NO;
    [self.view bringSubviewToFront:txtChat];
    [txtChat becomeFirstResponder];
}

-(void)postComment
{
//    [Flurry logEvent:@"Private Post"];
    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    NSDictionary *item = @{@"userid" : userId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0", @"isprivate":[NSNumber numberWithBool:isPrivateOn]};
    MSTable *itemTable = [client tableWithName:@"anonogramTable"];
    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [self logErrorIfNotNil:error];
        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
        [self refreshView];

    }];
}


- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

@end
