//
//  HomeViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#define kLimit 1
#define kFlagsAllowed 10

#import "HomeViewController.h"
#import "Cell.h"
#import "shareViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "CommentVC.h"
#import "UserViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@interface HomeViewController (){
    NSUserDefaults *defaults;
    NSString *token;
    BOOL isPrivateOn;
    BOOL recordingHashTag;
    BOOL isHashTag;
    BOOL isComment;
    BOOL isRed;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSMutableArray *filterHashTagArray;
    NSMutableArray *hashTagArray;
    NSMutableArray *screen_nameArray;
    NSMutableArray *filteredScreen_nameArray;
    NSInteger flagButton;
    NSInteger startParse;
    NSInteger commentedPost;
    UITextView        *txtChat;
    UIToolbar *_inputAccessoryView;
    NSTimeInterval nowTime;
    NSTimeInterval startTime ;
    UIBarButtonItem *isPrivateItem;
    UITableView *theTable;
    ACAccount* theAccount;
}
@property (nonatomic, strong)   MSTable *table;
//@property (nonatomic, strong)   MSTable *extendTable;

@property (nonatomic, strong)   MSTable *isLikeTable;
@property (nonatomic, strong)   MSTable *isFlagTable;
@property (nonatomic, strong)   MSTable *commentTable;
@property (nonatomic, strong)   MSTable *isLikeCommentTable;
@property (nonatomic, strong)   MSTable *userTable;
@property (nonatomic, strong)   MSTable *extendTable;

@property (strong, nonatomic) IBOutlet UITableView *theTableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSMutableArray *userIdArray;
@property (strong, nonatomic) NSMutableArray *userInfoArray;

@property (nonatomic, strong)   MSClient *client;

@end

@implementation HomeViewController

-(void)viewDidAppear:(BOOL)animated {
    if ([defaults boolForKey:@"showSurveyAnonogram"]&&![defaults boolForKey:@"rateDoneAnonogram"])
        [self performSelector:@selector(showSurvey) withObject:nil afterDelay:0.1];
//    if (isComment){
//        isComment = NO;
//        NSLog(@"comment update, commentedPost is %d and array is %@",commentedPost,self.array);
//
//        [self.table readWithId:[self.array[commentedPost] objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
//            NSLog(@"item is %@",item);
//            if (item == NULL) return;
//            [self.array replaceObjectAtIndex:commentedPost withObject:item];
//            [self.theTableView reloadData];
//            [self logErrorIfNotNil:error];
//        }];
//     }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self turnOnIndicator];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.theTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    [self.theTableView setSeparatorInset:UIEdgeInsetsZero];

    self.array = [[NSMutableArray alloc] init];
    self.userIdArray = [[NSMutableArray alloc] init];
    self.userInfoArray = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.extendTable = [self.client tableWithName:@"extendedTable"];
    self.isLikeTable = [self.client tableWithName:@"isLike"];
    self.isFlagTable = [self.client tableWithName:@"isFlag"];
    self.commentTable = [self.client tableWithName:@"commentTable"];
    self.isLikeCommentTable = [self.client tableWithName:@"isLikeCommentTable"];
    self.userTable = [self.client tableWithName:@"userTable"];
    NSString *commentCounterString;
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(handleNotification:) name:@"replyComplete" object:nil ];

    if (!IS_TALL_SCREEN) {
        self.theTableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }

    defaults = [NSUserDefaults standardUserDefaults];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.theTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    
    [self setup];
    [self getUUID];
    [self postInitialUserInfo];
    [self getData];
//    [self TwitterSwitch];
//    [self composeAction:nil];
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Survey
- (void) handleNotification : (NSNotification *)notification {
    NSLog(@"notification");
    [self refreshView];
//    NSString *replies = [self.array[commentedPost] objectForKey:@"replies"];
//    NSString *aString = [NSString stringWithFormat:@"%d", [replies integerValue]+ [defaults integerForKey:@"counter"] ];
//    NSLog(@"replies are %@ and counter is %d, and aString is %@",replies,[defaults integerForKey:@"counter"],aString);
//    [self.array[commentedPost] setObject:aString forKey:@"replies"];
//    [self.theTableView reloadData];
}
- (void) showSurvey {
    NSLog(@"showSurvey");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Like Anonogram? Please Rate" message:nil
                                                   delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Yes, I will rate now", @"Don't ask me again", nil];
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex is %ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        [self rateApp];
    }
    else if (buttonIndex == 2 ){
        [defaults setBool:YES forKey:@"rateDoneAnonogram"];
        NSLog(@"rateDone is %d",[defaults boolForKey:@"rateDoneAnonogram"]);
    }
    else {
        [defaults setBool:NO forKey:@"showSurveyAnonogram"];
        [defaults setInteger:0 forKey:@"counterAnonogram" ];
        NSLog(@"showSurvey is %d and counter is %ld",[defaults boolForKey:@"showSurveyAnonogram"],(long)[defaults integerForKey:@"counterAnonogram"]);
    }
    [defaults synchronize];
}
- (void)rateApp {
    
    [Flurry logEvent:@"Rate App" ];
    [defaults setBool:YES forKey:@"rateDoneAnonogram"];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/850204569"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=869802697&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
}
-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
-(void) setup {
    startTime=0;
    theTable = [[UITableView alloc] initWithFrame:CGRectMake(0,60 ,320, screenSpecificSetting(183, 95))];
    theTable.delegate=self;
    theTable.dataSource=self;
    theTable.hidden=YES;
    theTable.layer.frame=CGRectMake(-2, 60, 324, screenSpecificSetting(186, 98));
    theTable.layer.borderWidth=2.0;
    theTable.layer.borderColor=[UIColor darkGrayColor].CGColor;
    
    
    
    filterHashTagArray=[[NSMutableArray alloc] init];
    screen_nameArray=[[NSMutableArray alloc] init];
    filteredScreen_nameArray =[[NSMutableArray alloc] init];
    if ([defaults objectForKey:@"hashtags"]) {
        hashTagArray=[defaults objectForKey:@"hashtags"];
    }
    else {
        hashTagArray=[[NSMutableArray alloc]initWithObjects:
                      @"#Background", @"#Like",@"#Followr",
                      @"#Rate",@"#Feedback",@"#Restore",nil];
    }
    
    txtChat = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, screenSpecificSetting(290, 202))];
    txtChat.delegate=self;
    txtChat.hidden=YES;
    txtChat.font=[UIFont fontWithName:@"GillSans-Light" size:18];
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
    label2.font = [UIFont fontWithName:@"GillSans-Light" size:18];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.text= @"Share a thought\n\nTo direct message real people, tap Private, mention their Twitter names";
    label2.numberOfLines=14;
    label2.tag =105;
    [txtChat addSubview:label];
    [txtChat addSubview:label2];
//    [self.view addSubview:theTable];
    [txtChat addSubview:theTable];
    [self createInputAccessoryView];
//    [self createInputAccessoryViewForSearch];
    [self.view addSubview:txtChat];
//    [self.view addSubview:_inputAccessoryView];
//    _inputAccessoryView.hidden=YES;
//    _searchBarButton.hidden=YES;
//    _searchBarButton.placeholder = @"Search #hashtag, @username";
//    [_searchBarButton setKeyboardType:UIKeyboardTypeTwitter];
    [txtChat setKeyboardType:UIKeyboardTypeTwitter];

}

#pragma mark - Get UUID

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
#pragma mark - Utility  (Indicator, noInternet)

- (void) turnOnIndicator {
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    activityView.layer.shadowOffset = CGSizeMake(1, 1);
    activityView.layer.shadowColor = [UIColor blackColor].CGColor;
    activityView.layer.shadowOpacity=0.8 ;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    
    activityView.tag = 10001;
    activityView.transform = CGAffineTransformScale(activityView.transform, 1.5, 1.5);
    [activityView startAnimating];
    [self.view addSubview:activityView];
}

- (void) turnOffIndicator {
    UIActivityIndicatorView *activityView=(UIActivityIndicatorView *) [self.view viewWithTag:10001];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [activityView removeFromSuperview];
    [activityView stopAnimating];
}

- (void) noInternetAvailable {
    [self turnOffIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UILabel *noInternet = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 50)];
    noInternet.layer.cornerRadius=5;
    noInternet.layer.masksToBounds=YES;
    noInternet.backgroundColor=[UIColor darkGrayColor];
    noInternet.textColor=[UIColor whiteColor];
    noInternet.center=self.view.center;
    noInternet.text=@"Couldn't connect to the Internet";
    noInternet.font=[UIFont fontWithName:@"GillSans-Light" size:15];
    
    [self.view addSubview:noInternet];
//    noInternet.hidden=NO;
    [UIView animateWithDuration:2.0
                          delay:1.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         noInternet.alpha=0.0;
                     }
                     completion:^(BOOL completed) {
//                         noInternet.hidden=YES;
//                         noInternet.alpha=1.0;
                         [noInternet removeFromSuperview];
                     }
     ];

}
#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView== theTable)
        return 30;
    else
        return 290;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    if (tableView==self.theTableView)
        return _array.count;
    else {
        if (isHashTag)
            return filterHashTagArray.count;
        else
            return filteredScreen_nameArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (tableView==_theTableView){
        Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
        if (self.array.count <= indexPath.row)
            return cell;
        NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
        cell.pageContent.text = [dictionary objectForKey:@"text"];
        NSString *string = @"+";

        NSString *reputation = [self abbreviateNumber:[[dictionary objectForKey:@"reputation"] integerValue] ];
        NSString *posts = [self abbreviateNumber:[[dictionary objectForKey:@"posts"] integerValue] ];
        NSString *userreplies = [self abbreviateNumber:[[dictionary objectForKey:@"userreplies"] integerValue]];
        NSString *replies = [self abbreviateNumber:[[dictionary objectForKey:@"replies"] integerValue]];
        NSString *likes = [self abbreviateNumber:[[dictionary objectForKey:@"likes"] integerValue]];

        NSString *userScore = [NSString stringWithFormat:@"%@ \u00B7 %@ \u00B7 %@",reputation,posts,userreplies];

        cell.userScore.text = userScore;
        cell.aboutMe.text = [dictionary objectForKey:@"aboutme"];
        cell.location.text = [dictionary objectForKey:@"location"];;
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
    
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"List"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"List"];
        }
        if (isHashTag)
            cell.textLabel.text = [filterHashTagArray objectAtIndex:indexPath.row];
        else
            cell.textLabel.text = [filteredScreen_nameArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"GillSans-Light" size:16];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==theTable) {
        
        UITableViewCell *cell = (UITableViewCell*)[self tableView:theTable cellForRowAtIndexPath:indexPath];
        
        NSString *newString = [txtChat.text stringByReplacingCharactersInRange:NSMakeRange(startParse, [txtChat.text length] - startParse) withString:cell.textLabel.text];
        txtChat.text = newString;
        theTable.hidden=YES;
    }
    else {
        NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
        
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) {
                NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
                NSLog(@"likeCountis %d",likeCount);
                if (likeCount>0){
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                    
                    NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]-1 ];
                    [dictionary setValue:reputationCount forKey:@"reputation"];
                    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
                    [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                        NSLog(@"items usertable are %@",items);
                        [self logErrorIfNotNil:error];
                        if(!error){
                            NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]-1 ];
                            NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
                            [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
                                NSLog(@"updated item usertable is %@",item);
                                
                                [self logErrorIfNotNil:error];
                            }];
                        }
                    }];
                    
                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                    if (!error){
                    NSLog(@"item is %@",item);
                    if (item == NULL) return;
                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]-1 ];
                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
                    
                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
                        [self logErrorIfNotNil:error];
                    }];
                    }
                    [self logErrorIfNotNil:error];
                }];
                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.theTableView reloadData];
                   }
            }
            else {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]+1 ];
                [dictionary setValue:reputationCount forKey:@"reputation"];
                
                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                NSLog(@"userid is %@",userId);
                
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
                [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                    NSLog(@"items usertable are %@",items);
                    [self logErrorIfNotNil:error];
                    if(!error){
                        NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]+1 ];
                        NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
                        [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
                            NSLog(@"updated item usertable is %@",item);
                            
                            [self logErrorIfNotNil:error];
                        }];
                    }
                }];

                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                    if(!error){
                    NSLog(@"item is %@",item);
//                    if (item == NULL) return;

                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]+1 ];
                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
                    
                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
                        [self logErrorIfNotNil:error];
                    }];
                    }
                    [self logErrorIfNotNil:error];
                }];
//                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
                
                [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.theTableView reloadData];
            }
        }];
        [tableView reloadData];


    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {      float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) {
//        [self getData];
//    }
//    }
//}
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
- (void) refreshView
{
    
    //    nowTime =[[NSDate date] timeIntervalSince1970];
    //    if ((nowTime-startTime)> 5 ){
    //        startTime =[[NSDate date] timeIntervalSince1970];
    self.array = [[NSMutableArray alloc] init];
    [self getData];
    //    }
    [refreshControl endRefreshing];
}

//- (void) storeData {
//    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
//    NSDictionary *item = @{ @"text" : @"Awesome item" };
//    MSTable *itemTable = [client tableWithName:@"anonogramTable"];
//    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
//        }
//    }];
//    
//}

#pragma mark - Delete,Like,Flag,Share

- (void) deleteText  {
    [self.theTableView beginUpdates];

    [Flurry logEvent:@"Delete"];

    NSString *postId = [[self.array objectAtIndex:flagButton] objectForKey:@"id" ];
    NSLog(@"postId is %@",postId);

    /* delete post from table */
    
    [self.table deleteWithId:postId completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
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
    
    /* delete flags of the post from isFlagTable */

    [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"isFlagTable items for postId are %@",items);

        for (NSDictionary *dictionary in items){
            [self.isFlagTable deleteWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
        }
        [self logErrorIfNotNil:error];
    }];
    
    /* delete comments and their likes of the post from commentTable */
    
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
    
    /* update reputation and posts count in userTable */
    
//    NSString *userId = [[self.array objectAtIndex:indexPath.row] objectForKey:@"userid" ];
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
    [self.theTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];

    [self.theTableView endUpdates];
    [self.theTableView reloadData];
}

- (IBAction)likeAction:(id)sender {
    [Flurry logEvent:@"Like"];
    
    UIButton *btnPressLike = (UIButton*)sender;
    NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"postId == %@",[dictionary objectForKey:@"id" ]];

//    [self.isLikeTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSInteger likeCount = totalCount;
//        NSLog(@"likeCountis %d",likeCount);
//
//    }];
    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[dictionary objectForKey:@"id" ]];
    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        if (items.count) {
            NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
            NSLog(@"likeCountis %d",likeCount);
//            if (likeCount>0){
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                /* read and update anonogramTable for likes column */

                [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];

                    if(!error){
                    NSLog(@"item is %@",item);
//                    if (item == NULL) return;

                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]-1 ];
                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
                    
                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
                        [self logErrorIfNotNil:error];
                    }];
                    }
                }];
                
                /* read and update userTable for reputation column */

                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSLog(@"userid is %@",userId);

                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
                [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                    NSLog(@"items usertable are %@",items);
                    [self logErrorIfNotNil:error];
                    if(!error){
                        NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]-1 ];
                        NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
                        [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
                            NSLog(@"updated item usertable is %@",item);

                            [self logErrorIfNotNil:error];
                        }];
                    }
                }];
                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.theTableView reloadData];
            
//            }
            
        }
        else {
            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
            [dictionary setValue:likesCount forKey:@"likes"];

            /* read and update anonogramTable for likes column */
            
            [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
                if (!error){
                    NSLog(@"item is %@",item);
//                  if (item == NULL) return;

                    NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"likes"] integerValue]+1 ];
                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
                
                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
                        [self logErrorIfNotNil:error];
                    }];
                }
            }];
            
            /* read and update userTable for reputation column */

            
            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
            [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                NSLog(@"items usertable are %@",items);
                [self logErrorIfNotNil:error];
                if(!error){
                    NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]+1 ];
                    NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
                    [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
                        NSLog(@"updated item usertable is %@",item);
                        [self logErrorIfNotNil:error];
                    }];
                }
            }];
            NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
            
            [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.theTableView reloadData];
        }
    }];
}
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
//- (IBAction)flagAction:(id)sender {
//   UIButton *btn = (UIButton *)sender;
//    flagButton = btn.tag;
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    
//    
//    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userId"]] ){
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:nil];
//        actionSheet.tag=0;
//        [actionSheet showInView:sender];
//    }
//    
//    else {
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[self.array[flagButton] objectForKey:@"id" ]];
//        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//            if (!items.count) {
//                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:nil];
//                actionSheet.tag=1;
//                [actionSheet showInView:sender];
//
//            }
//            else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have already flagged this post!" message:nil
//                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            }
//        }];
//                }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton * btn = (UIButton *) sender;
    NSLog(@"btn.tag is %ld",(long)btn.tag);
    if ([[segue identifier] isEqualToString:@"share"])
    {
        NSLog(@"blah");
//        shareViewController *vc = [[shareViewController alloc] init];
//        vc=[segue destinationViewController];
        
//        UIImage *image = [self captureImage:btn.tag];
        [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];

//        [defaults setObject:UIImagePNGRepresentation([self captureImage:btn.tag]) forKey:@"image"];
//        vc.image = image;
        
    }
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
//        NSString *string = [[NSString alloc] initWithString:[dictionary objectForKey:@"id"]];
//        NSString *string = [[NSString alloc] initWithString:[dictionary objectForKey:@"text"]];
        CommentVC *vc = [[CommentVC alloc] init];
        vc=(CommentVC*)[[segue destinationViewController]topViewController];
        vc.postId =[dictionary objectForKey:@"id"];
        vc.replies = [dictionary objectForKey:@"replies"];
        vc.replyTitleString=[dictionary objectForKey:@"text"];

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
    label.textAlignment=NSTextAlignmentCenter;
    label.numberOfLines=6;
    label.font = [UIFont fontWithName:@"GillSans-Light" size:22.0];
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
            NSString *flagsCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"flags"] integerValue]+1 ];
            if ([flagsCount integerValue]>kFlagsAllowed){   //delete item if flagCount is more than kFlagsAllowed
                [self deleteText];
                return;
            }
            [dictionary setValue:flagsCount forKey:@"flags"];
            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"flags": flagsCount};
            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                //handle errors or any additional logic as needed
                [self logErrorIfNotNil:error];
            }];
            
            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};
            [self.isFlagTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                //handle errors or any additional logic as needed
                [self logErrorIfNotNil:error];
            }];
            [self.theTableView reloadData];
            
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
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 0) {
//        if (buttonIndex==0){
//            NSLog(@"delete");
//            [self deleteText];
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
//            [self.theTableView reloadData];
//
//        }
//    }
//    if (actionSheet.tag == 2){
//        [Flurry logEvent:@"TwitterSwitch"];
//
//          [[NSUserDefaults standardUserDefaults] setValue:buttonsArray[buttonIndex] forKey:@"twitterHandle"];
//        [self refreshView];
//    }
////    [[self.view viewWithTag:1] removeFromSuperview];
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get, Post Data
-(BOOL)connectedToNetwork  {
    NSURL* url = [[NSURL alloc] initWithString:@"http://m.omentos.com/backend/api.php"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    url=nil;
    if (data != nil)
        return YES;
    return NO;
}
- (void) getData {
    NSLog(@"getting data...");
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate;
//    if (![defaults boolForKey:@"filter"])
//        predicate = [NSPredicate predicateWithFormat:@"isPrivate == false",userId];
//    else {
//        
//        predicate = [NSPredicate predicateWithFormat:@"((text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@) && isPrivate == false)|| userId == %@",word1,word2,word3,userId];
//    }
 
//    MSQuery *query = [self.table queryWithPredicate:predicate];
    
//    MSQuery *query = [self.table query];
//    MSQuery *query = [[MSQuery alloc] initWithTable:self.table];
//    MSQuery *query = [self.extendTable query];

//    query.predicate=predicate;
//    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
//    query.includeTotalCount = YES; // Request the total item count
//    query.fetchLimit = kLimit;
//    query.fetchOffset = self.array.count;
//    NSString *queryString = [[NSString alloc] init];
//    NSString* queryString = [NSString stringWithFormat:@"fetchOffset=%d, fetchLimit=%d",self.array.count, kLimit];

//    NSLog(@"queryString is %@",queryString);
//    [self.table readWithQueryString:queryString completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [self.extendTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//            [self.extendTable readWithQueryString:queryString completion:^(NSArray *items, NSInteger totalCount, NSError *error) {

        if (items.count ==0)return;
        [self logErrorIfNotNil:error];
//        if(!error) {
            [self.array addObjectsFromArray:items];  //copy items into array
            NSLog(@"items are %@",items);
//            for (NSDictionary *dictionary in items){
//                NSArray *newUserIdArray = [defaults objectForKey:@"userIdArray"]; //get stored userIdArray
//                for (NSString *string in newUserIdArray)
//                    if (!([string isEqualToString:[dictionary objectForKey:@"userId"]])){
//                        [self.userIdArray addObject:[dictionary objectForKey:@"userId"]];
//                        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userId == %@ ",userId];
//                        [self.userTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                            NSLog(@"items are %@",items);
//                            [self.userInfoArray addObject:items];
//                            [self.userIdArray addObject:[dictionary objectForKey:@"userId"]];
//                        }];
//                    }
//                //first order by ascending duration field
////                NSDictionary *dictionary = items[0];
//                [self logErrorIfNotNil:error];
//
            [self.theTableView reloadData];
//            }
//        }
    }];
//    [self.table readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items table are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//    }];
//    [self.isLikeTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items isLikeTable are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//    }];
//    [self.isFlagTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items isFlagTable are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//    }];
//    [self.commentTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items commentTable are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//    }];
//    [self.isLikeCommentTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items isLikeCommentTable are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//    }];
    
    
}
-(UIColor*) pastelColorCode : (UIColor *) mix {
    CGFloat red = ( arc4random() % 256 / 256.0 );
    CGFloat green = ( arc4random() % 256 / 256.0 );
    CGFloat blue = ( arc4random() % 256 / 256.0 );
    const CGFloat *components = CGColorGetComponents(mix.CGColor);
    
    // mix the color
    if (mix != NULL) {
        red = (red + components[0]) / 2;
        green = (green + components[1]) / 2;
        blue = (blue + components[2]) / 2;
    }
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:components[3]];
    return color;
}
- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}
-(void)postComment
{
    
//    if (isPrivateOn)
//        [Flurry logEvent:@"Private Post"];
//    else
//        [Flurry logEvent:@"Post"];
    
//    NSArray *parameters = [txtChat.text componentsSeparatedByString:@" "];
//    NSLog(@"parameters are %@",parameters);
//    for (NSString *parameter in parameters)
//    {
//        if([parameter hasPrefix:@"#"] && ![hashTagArray containsObject: parameter]){
//            NSLog(@"parameter is %@",parameter);
//            [hashTagArray insertObject:parameter atIndex:0];
//            [defaults setObject:hashTagArray forKey:@"hashtags"];
//        }
//        if([parameter hasPrefix:@"@"] && ![screen_nameArray containsObject: parameter]){
//            NSLog(@"parameter is %@",parameter);
//            [screen_nameArray insertObject:parameter atIndex:0];
//            [defaults setObject:screen_nameArray forKey:@"nametags"];
//        }
//    }
//    NSLog(@"hashtagarray is %@",hashTagArray);


    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSDictionary *item = @{@"userid" : userId,@"text" : txtChat.text, @"likes" :@"0",@"replies" :@"0",@"flags" : @"0", @"touserid" : @"",@"isprivate":[NSNumber numberWithBool:isPrivateOn]};
    [self.table insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
            [self logErrorIfNotNil:error];
//        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
//        }
        [self refreshView];
    }];
}
-(void)postInitialUserInfo
{
    UIColor *color;
    NSString *colorString = [defaults objectForKey:@"color"];
    if (!colorString){
        color = [self pastelColorCode:[UIColor whiteColor]];
        //    color = [self colorCode];
        
        colorString = [self hexStringForColor:color];
        NSLog(@"color is %@",colorString);
        [defaults setObject:colorString forKey:@"color"];
    }
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSLog(@"inserting into commentTable userId = %@, postId = %@, reply = %@, color = %@",userId,postId,_txtChat.text, colorString);
    NSString *randomString = [self randomStringWithLength:8];
    NSDictionary *item = @{@"userid" : userId, @"posts" : @"0",@"userreplies" : @"0", @"color" :colorString,@"reputation" :@"0",@"username":randomString, @"aboutme":@"",@"gender" : @"",@"location":@""};
    
    
    //    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"replies" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isPrivateOn]};
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userid == %@ ",userId];
    [self.userTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        //first order by ascending duration field
        if (items.count ==0)
            [self.userTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        //        if (error) {
                NSLog(@"inserted item: %@", insertedItem);
                [self logErrorIfNotNil:error];
        //        } else {
        //            NSString *string = [NSString stringWithFormat:@"%d",self.array.count+1 ];
        //            NSDictionary *item =@{@"id" : self.postId, @"replies": string};
//        [self.table readWithId:userId completion:^(NSDictionary *item, NSError *error) {
//            NSLog(@"item is %@",item);
//            if (item == NULL) return;
//            NSString *string =[NSString stringWithFormat:@"%d",[[item objectForKey:@"replies"] integerValue]+1 ];
//            NSDictionary *itemReplies =@{@"id" : [item objectForKey:@"id" ], @"replies": string};
//            
//            [self.table update:itemReplies   completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//            [self logErrorIfNotNil:error];
        }];
        
        //            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
        //                [self logErrorIfNotNil:error];
        //            }];
        //            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
        //        }
//        [self refreshView];
    }];
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

#pragma mark - Twitter

- (void)TwitterSwitch {
    if ([defaults objectForKey:@"nametags"]) {
        screen_nameArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"nametags"]];
        return;
    }
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
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
        theAccount=(ACAccount*)obj;
        [self getTwitterFriendsForAccount:((ACAccount*)obj)];
        [buttonsArray addObject:((ACAccount*)obj).username];
        [defaults setObject:buttonsArray forKey:@"twitterAccounts"];
    }];
    
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

-(void)getTwitterFriendsForAccount:(ACAccount*)account {
    // In this case I am creating a dictionary for the account
    // Add the account screen name
    NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil];
    // Add the user id (I needed it in my case, but it's not necessary for doing the requests)
    [accountDictionary setObject:[[[account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]] objectForKey:@"properties"] objectForKey:@"user_id"] forKey:@"user_id"];
    // Setup the URL, as you can see it's just Twitter's own API url scheme. In this case we want to receive it in JSON
    NSURL *followingURL = [NSURL URLWithString:@"https://api.twitter.com/1/friends/ids.json"];
//NSURL *followingURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
//    NSString *string=@"http://api.twitter.com/1/users/lookup.json?user_id=77687121,43662011,6253282
//    NSURL *followingURL = [NSURL URLWithString:@"http://api.twitter.com/1/users/lookup.json?user_id=%@",string];

//    http://api.twitter.com/1/users/lookup.json?user_id=77687121,43662011,6253282
    // Pass in the parameters (basically '.ids.json?screen_name=[screen_name]')
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil];
    // Setup the request

    
    SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:TWRequestMethodGET URL:followingURL parameters:parameters];

    // This is important! Set the account for the request so we can do an authenticated request. Without this you cannot get the followers for private accounts and Twitter may also return an error if you're doing too many requests
    [twitterRequest setAccount:account];
    // Perform the request for Twitter friends
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            // deal with any errors - keep in mind, though you may receive a valid response that contains an error, so you may want to look at the response and ensure no 'error:' key is present in the dictionary
        }
        NSError *jsonError = nil;
        // Convert the response into a dictionary
        
        NSDictionary *twitterFriends = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:&jsonError];
        NSLog(@"twitterFriends are %@",twitterFriends);
        // Grab the Ids that Twitter returned and add them to the dictionary we created earlier
        [accountDictionary setObject:[twitterFriends objectForKey:@"ids"] forKey:@"screen_name"];
        NSString *string = [NSString stringWithFormat:@"%@",[accountDictionary objectForKey:@"screen_name"] ] ;
        string = [string stringByReplacingOccurrencesOfString:@"(" withString:@" "];
        string = [string stringByReplacingOccurrencesOfString:@")" withString:@" "];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//        __block NSString *newString;
//        [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
//                                   options:NSStringEnumerationByWords | NSStringEnumerationLocalized
//                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
//                                    newString = [substring stringByAppendingString:[substring lowercaseString] ];
//                                    // This block is called once for each word in the string.
////                                    [countedSet addObject:substring];
//                                    
//                                    // If you want to ignore case, so that "this" and "This"
//                                    // are counted the same, use this line instead to convert
//                                    // each word to lowercase first:
//                                    // [countedSet addObject:[substring lowercaseString]];
//                                }];

        string = [self truncateByWordWithLimit:1200 string:string];
        NSLog(@"Accountstring is %@", string);
        [self getTwitterNames:string account:account];
//        NSString *newString = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];

        
    }];
}

- (NSString *)truncateByWordWithLimit:(NSInteger)limit string:(NSString *)string {

    NSRange r = NSMakeRange(0, string.length);
    while (r.length > limit) {
        NSRange r0 = [string rangeOfString:@" " options:NSBackwardsSearch range:r];
        if (!r0.length) break;
        r = NSMakeRange(0, r0.location);
    }
    if (r.length == string.length) return string;
    return [[string substringWithRange:r] stringByAppendingString:@" "];
}

- (void) turnFriendId: (NSString *)friID account: (ACAccount*) account{
    // Setup the URL, as you can see it's just Twitter's own API url scheme. In this case we want to receive it in JSON
//    NSLog(@"%@",friID);
    friID = @"586671909";
    NSString *string = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?user_id=%@",friID];
    NSURL *followingURL = [NSURL URLWithString:string];
    // Pass in the parameters (basically '.ids.json?screen_name=[screen_name]')
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:friID, @"id_str", nil];
    // Setup the request
    SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:TWRequestMethodGET URL:followingURL parameters:parameters];
//    TWRequest *twitterRequest = [[TWRequest alloc] initWithURL:followingURL
//                                                    parameters:parameters
//                                                 requestMethod:TWRequestMethodGET];
    // This is important! Set the account for the request so we can do an authenticated request. Without this you cannot get the followers for private accounts and Twitter may also return an error if you're doing too many requests
    [twitterRequest setAccount:account];
    // Perform the request for Twitter friends
    
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            // deal with any errors - keep in mind, though you may receive a valid response that contains an error, so you may want to look at the response and ensure no 'error:' key is present in the dictionary
        }
        NSError *jsonError = nil;
        // Convert the response into a dictionary
        NSDictionary *twitterGrabbedUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:&jsonError];
        // Grab the Ids that Twitter returned and add them to the dictionary we created earlier
        NSLog(@"twitterUserInfo are %@",twitterGrabbedUserInfo);

        NSLog(@"names are %@", [twitterGrabbedUserInfo objectForKey:@"name"]);
    }];
}

- (void) getTwitterNames: (NSString *)friID account:(ACAccount *)account {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:friID forKey:@"user_id"];
    [params setObject:@"0" forKey:@"include_rts"]; // don't include retweets
    [params setObject:@"1" forKey:@"trim_user"]; // trim the user information
    [params setObject:@"1" forKey:@"count"]; // i don't even know what this does but it does something useful
    [params setObject:@"0" forKey:@"include_entities"]; // i don't even know what this does but it does something useful
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:TWRequestMethodGET URL:url parameters:params];
//    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
    //  Attach an account to the request
    [request setAccount:account]; // this can be any Twitter account obtained from the Account store
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSArray *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL] ;
            NSLog(@"received Twitter data: %@", twitterData);
            NSString *screen_name;
            // to do something useful with this data:
            for (NSDictionary *dictionary in twitterData){
              
                 screen_name = [dictionary objectForKey:@"screen_name"]; // the screen name you were after
                screen_name = [NSString stringWithFormat:@"@%@",screen_name];
                [screen_nameArray addObject:screen_name];
            }
            [defaults setObject:screen_nameArray forKey:@"nametags"];
//            NSString *screen_name = [NSString stringWithFormat:@"%@",[twitterData objectForKey:@"screen_name"] ] ;

           
            NSLog(@"screen_name is %@",screen_nameArray);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // update your UI in here
//                twitterScreenNameLabel.text = screen_name;
//            });
            
//            // A handy bonus tip: twitter display picture
//            NSString *profileImageUrl = [twitterData objectForKey:@"profile_image_url"];
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                
//                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]];
//                UIImage *image = [UIImage imageWithData:imageData]; // the matching profile image
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // assign it to an imageview in your UI here
//                    twitterProfileImageView.image = image;
//                });
//            });
        }else{
            NSLog(@"Error while downloading Twitter user data: %@", error);
        }
    }];
}
#pragma mark - TextView delegate methods


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
    static NSString *suffix = @"#";
    static NSString *suffix1 = @"@";
    if (textView.text.length + text.length > 140){
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

    
    if ([text isEqualToString:suffix] || [text isEqualToString:suffix1] ) {
        if ([text isEqualToString:suffix])
            isHashTag = YES;
        else
            isHashTag = NO;
        NSLog(@"recordingHasTag");
        recordingHashTag = YES;
        startParse = range.location;
        NSLog(@"startParse is %d",startParse);
        theTable.hidden = NO;
        
    }else if ([text isEqualToString:@" "]) {
        recordingHashTag = NO;
        theTable.hidden = YES;
        
    }
    
    
    if (range.length == 1 && [text length] == 0) {
        // The user presses the Delete key.
        NSLog(@"delete");

        NSString *currentText = [textView.text substringToIndex:range.location+1];
     
        if ([currentText hasSuffix:suffix] || [currentText hasSuffix:suffix1]) {
            NSLog(@"recordingHasTag=NO");
            theTable.hidden = YES;
            recordingHashTag = NO;
        }
    }

    
       return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    if (recordingHashTag == YES) {
        NSString *value;
        NSLog(@"recordingHasTag1");
        NSLog(@"textView.text length = %d",textView.text.length);
        if (startParse < [textView.text length] ) {
            value = [textView.text substringWithRange:NSMakeRange(startParse, [textView.text length] - startParse)];
            if(isHashTag)
                [self filterHashTagTableWithHash:value];
            else
                [self filterAtTagTableWithAt:value];
            NSLog(@"recordingHasTag2, value = %@",value);
        }
    }
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.hidden=NO;
    label.text = [NSString stringWithFormat:@"%u",140-textView.text.length];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=YES;
}

-(void)filterHashTagTableWithHash:(NSString *)hash{
    
    [filterHashTagArray removeAllObjects];

    for (NSString *hashTag in hashTagArray ){
        if ([hashTag rangeOfString:hash options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filterHashTagArray addObject:hashTag];
        }
    }

    if (!filterHashTagArray.count && [hash length]<1) {
        filterHashTagArray = [NSMutableArray arrayWithArray:hashTagArray];
    }

    if (!filterHashTagArray.count)
        theTable.hidden=YES;
    NSLog(@"filterhashtagarray is %@",filterHashTagArray);
    [theTable reloadData];
}

-(void)filterAtTagTableWithAt:(NSString *)hash{
    
    [filteredScreen_nameArray removeAllObjects];
    
    for (NSString *hashTag in screen_nameArray )
        if ([hashTag rangeOfString:hash options:NSCaseInsensitiveSearch].location != NSNotFound)
            [filteredScreen_nameArray addObject:hashTag];

    
    if (!filteredScreen_nameArray.count && [hash length]<1)
        filteredScreen_nameArray = [NSMutableArray arrayWithArray:screen_nameArray];

    
    if (!filteredScreen_nameArray.count)
        theTable.hidden=YES;
    NSLog(@"filterhashtagarray is %@",filteredScreen_nameArray);
    
    
    [theTable reloadData];
}

-(void)createInputAccessoryView {
    
    UIToolbar *inputAccessoryView1 = [[UIToolbar alloc] init];
    
    inputAccessoryView1.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(cancelKeyboard)];
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    isPrivateItem = [[UIBarButtonItem alloc] initWithTitle:@"Private"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(addText)];
//    isPrivateItem.tag=200;
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(doneKeyboard)];
    
//    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,isPrivateItem,flexItem,doneItem, nil];
       NSArray *itemsView = [NSArray arrayWithObjects:removeItem,flexItem,doneItem, nil];
    [inputAccessoryView1 setItems:itemsView animated:NO];
    [txtChat addSubview:inputAccessoryView1];
    
}

-(void) addText {

    NSLog(@"isPrivateItem title is %@",isPrivateItem.title);
    if (isPrivateOn){
        isPrivateOn=NO;
        isPrivateItem.title=@"Private";
        isPrivateItem.tintColor=[UIColor lightGrayColor];
    }
    else {
        isPrivateOn=YES;
        isPrivateItem.title=@"Private";
        isPrivateItem.tintColor=[UIColor redColor];
        UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
        label2.hidden=YES;
        UILabel *label = (UILabel*)[self.view viewWithTag:110];
        label.hidden=NO;
        [self.view bringSubviewToFront:label];
        [UIView animateWithDuration:5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             label.alpha=0.0; }
                         completion:^(BOOL finished){
                             label.alpha=1.0;
                             label.hidden=YES;
                         }];

    }
    
}

-(void)doneKeyboard{
    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = @"140";
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if(!([[txtChat.text stringByTrimmingCharactersInSet: set] length] == 0) )
        {
        txtChat.text = [NSString stringWithFormat:@"%@",txtChat.text];
        [self postComment];
        }
    txtChat.text = @"";
}
-(void)cancelKeyboard{
    [txtChat resignFirstResponder];
    txtChat.text=@"";
    txtChat.hidden=YES;
    theTable.hidden=YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = @"140";
    
}
- (IBAction)composeAction:(id)sender {
    
    NSLog(@"compose");
    txtChat.hidden=NO;
    
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=NO;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.hidden=YES;
    [self.view bringSubviewToFront:txtChat];
    [txtChat becomeFirstResponder];
}



@end
