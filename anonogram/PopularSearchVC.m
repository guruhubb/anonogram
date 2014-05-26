//
//  PopularSearchVC.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#define kLimit 20
#define kFlagsAllowed 10
#import "PopularSearchVC.h"
#import "Cell.h"
#import "shareViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "CommentVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "UserViewController.h"
#import "HomeViewController.h"

@interface PopularSearchVC (){
    NSUserDefaults *defaults;
    NSString *token;
    BOOL isSearchOn;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSInteger flagButton;
    NSInteger likeTotalCount;
    BOOL isComment;
    NSInteger commentedPost;
    UITextView *txtChat;
    UIToolbar *_inputAccessoryView;
    NSTimeInterval nowTime;
    NSTimeInterval startTime ;
    HomeViewController *home;
}
@property (strong, nonatomic) IBOutlet UITableView *popularTableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong)   MSClient *client;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, strong)   MSTable *table;
@property (nonatomic, strong)   MSTable *isLikeTable;
@property (nonatomic, strong)   MSTable *isFlagTable;
@property (nonatomic, strong)   MSTable *commentTable;
@property (nonatomic, strong)   MSTable *isLikeCommentTable;
@property (nonatomic, strong)   MSTable *userTable;
@property (nonatomic, strong)   MSTable *popularTable;
@property (nonatomic, strong)   MSTable *extendTable;



@end

@implementation PopularSearchVC

-(void)viewDidAppear:(BOOL)animated {
    
//    if (isComment){
//        isComment = NO;
//        NSLog(@"comment update, commentedPost is %d",commentedPost);
//        [self.table readWithId:[self.array[commentedPost] objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
//            if (item == NULL) return;
//            NSLog(@"item is %@",item);
//            [self.array replaceObjectAtIndex:commentedPost withObject:item];
//            [self.popularTableView reloadData];
//            [self logErrorIfNotNil:error];
//        }];
//    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    startTime=0;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.popularTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    [self.popularTableView setSeparatorInset:UIEdgeInsetsZero];
    home = [[HomeViewController alloc] init];

    self.array = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.isLikeTable = [self.client tableWithName:@"isLike"];
    self.isFlagTable = [self.client tableWithName:@"isFlag"];
    self.commentTable = [self.client tableWithName:@"commentTable"];
    self.isLikeCommentTable = [self.client tableWithName:@"isLikeCommentTable"];
    self.userTable=[self.client tableWithName:@"userTable"];
    self.popularTable=[self.client tableWithName:@"popularTable"];
    self.extendTable=[self.client tableWithName:@"extendTable"];


    if (!IS_TALL_SCREEN) {
        self.popularTableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(handleNotification:) name:@"replyComplete" object:nil ];

    defaults = [NSUserDefaults standardUserDefaults];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.popularTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self setup];
//    [self getUUID];
    [self getData];
    
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
- (IBAction)searchAction:(id)sender {
    isSearchOn=YES;
    self.array=nil;
    self.array = [[NSMutableArray alloc] init];
    [self.popularTableView reloadData];
    self.navigationItem.title= [NSString stringWithFormat:@"Search"];
    _searchBarButton.hidden=NO;
    _inputAccessoryView.hidden=NO;
    [self.view bringSubviewToFront:_searchBarButton];
    [_searchBarButton becomeFirstResponder];
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                   target:self action:@selector(stopAction)] ;
    self.navigationItem.rightBarButtonItem = stopButton;
}
- (void)searchBarCancel
{
    isSearchOn=NO;
    self.array=nil;
    self.array = [[NSMutableArray alloc] init];
    [self.popularTableView reloadData];
    [_searchBarButton resignFirstResponder];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    _searchButton.image=nil;
    self.navigationItem.title= @"POPULAR";

    UIBarButtonItem *popularButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                       target:self action:@selector(searchAction:)] ;
    self.navigationItem.rightBarButtonItem = popularButton;
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    if(!([[_searchBarButton.text stringByTrimmingCharactersInSet: set] length] == 0) )
    {
        [Flurry logEvent:@"Search"];
        [defaults setBool:YES forKey:@"searchOn"];
        self.array=nil;
        self.array = [[NSMutableArray alloc] init];
        [self.popularTableView reloadData];
        [_searchBarButton resignFirstResponder];
        _searchBarButton.hidden=YES;
        _inputAccessoryView.hidden=YES;
        
        NSLog(@"_searchBarButton.text whitespace length again is %d",[[_searchBarButton.text stringByTrimmingCharactersInSet: set] length]);
        NSString *string  =[NSString stringWithFormat:@"%@", _searchBarButton.text ];
        //        _pageTitles[currentIndex]= string;
        self.navigationItem.title= [NSString stringWithFormat:@"%@",string];
        //        [self openSearch];
        [defaults setObject:string forKey:@"search"];
        [self getDataSearch];
    }
}// called when keyboard search button pressed
- (void)searchBarClicked
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];

    if(!([[_searchBarButton.text stringByTrimmingCharactersInSet: set] length] == 0) )
    {
    [Flurry logEvent:@"Search"];
    [defaults setBool:YES forKey:@"searchOn"];
    self.array=nil;
    self.array = [[NSMutableArray alloc] init];
    [self.popularTableView reloadData];

    [_searchBarButton resignFirstResponder];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    
        NSLog(@"_searchBarButton.text whitespace length again is %d",[[_searchBarButton.text stringByTrimmingCharactersInSet: set] length]);
        NSString *string  =[NSString stringWithFormat:@"%@", _searchBarButton.text ];
        //        _pageTitles[currentIndex]= string;
        self.navigationItem.title= [NSString stringWithFormat:@"%@",string];
        //        [self openSearch];
        [defaults setObject:string forKey:@"search"];
        [self getDataSearch];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchNow" object:nil];

}
-(void) stopAction {
    isSearchOn=NO;
    [_searchBarButton resignFirstResponder];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    self.navigationItem.title= @"POPULAR";
    UIBarButtonItem *popularButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                      target:self action:@selector(searchAction:)] ;
    self.navigationItem.rightBarButtonItem = popularButton;
    self.array=nil;
    self.array = [[NSMutableArray alloc] init];
    [self.popularTableView reloadData];
    [self getData];

}
-(void) setup {

    [self createInputAccessoryViewForSearch];
    _searchBarButton.delegate=self;
    _searchBarButton.hidden=YES;
    _searchBarButton.placeholder = @"Search here";
    _searchBarButton.tintColor=[UIColor lightGrayColor];
    [_searchBarButton setKeyboardType:UIKeyboardTypeTwitter];
    [self.view addSubview:_inputAccessoryView];
    _inputAccessoryView.hidden=YES;

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
    if (self.array.count==0) cell = nil;
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

////     [tableView setSeparatorInset:UIEdgeInsetsZero];
//    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
//   
//    if (self.array.count <= indexPath.row)
//        return cell;
//    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
//    NSLog(@"dictionary is %@",dictionary);
//    cell.pageContent.text = [dictionary objectForKey:@"text"];
//    NSString *string = @"+";
//    cell.likeCount.text = [string stringByAppendingString: [dictionary objectForKey:@"likes"]];
////    cell.likeCount.text = [dictionary objectForKey:@"likes"];
//    cell.timestamp.text = [[dictionary objectForKey:@"timestamp"] formattedAsTimeAgo];
//    cell.replies.text = [dictionary objectForKey:@"replies"];
//    cell.flag.tag=indexPath.row;
//    cell.like.tag=indexPath.row;
//    cell.replyButton.tag=indexPath.row;
//
//    indexPathRow=indexPath;
//    
//    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
        
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@  && postid == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) {
                NSInteger likeCount = [[dictionary objectForKey:@"likes"] integerValue];
                NSLog(@"likeCountis %d",likeCount);
//                if (likeCount>0){
                    NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                    [dictionary setValue:likesCount forKey:@"likes"];
                    
                    NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]-1 ];
                    [dictionary setValue:reputationCount forKey:@"reputation"];
//                    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
//                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"postid == %@",[dictionary objectForKey:@"id" ]];
//                
//                [self.isLikeTable readWithPredicate:predicate2 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    likeTotalCount = totalCount;
//                }];
//                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
//                    [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                        NSLog(@"items usertable are %@",items);
//                        [self logErrorIfNotNil:error];
//                        if(!error){
//                            NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]-1 ];
//                            NSDictionary *item1 =@{@"id" : [items[0] objectForKey:@"id"],  @"reputation":string2};
//                            [self.userTable update:item1 completion:^(NSDictionary *item, NSError *error) {
//                                NSLog(@"updated item usertable is %@",item);
//                                
//                                [self logErrorIfNotNil:error];
//                            }];
//                        }
//                    }];
//                    
//                    [self.table readWithId:[dictionary objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
//                        NSLog(@"item is %@",item);
//                        if (item == NULL) return;
//
//                        NSString *string =[NSString stringWithFormat:@"%d",likeTotalCount];
//                        NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                        
//                        [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                            [self logErrorIfNotNil:error];
//                        }];
//                        [self logErrorIfNotNil:error];
//                    }];
                
                    [self.popularTableView reloadData];
//                }
                
            }
            else {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                NSString *reputationCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"reputation"] integerValue]+1 ];
                [dictionary setValue:reputationCount forKey:@"reputation"];
                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
                [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
//                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"postid == %@",[dictionary objectForKey:@"id" ]];
                
//                [self.isLikeTable readWithPredicate:predicate2 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    likeTotalCount = totalCount;
//                }];
//                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userId];
//                [self.userTable readWithPredicate:predicate1 completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//                    NSLog(@"items usertable are %@",items);
//                    [self logErrorIfNotNil:error];
//                    if(!error){
//                        NSString *string2 = [NSString stringWithFormat:@"%d",[[items[0] objectForKey:@"reputation"] integerValue]+1 ];
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
//                    NSString *string =[NSString stringWithFormat:@"%d",likeTotalCount ];
//                    NSDictionary *itemLikes =@{@"id" : [item objectForKey:@"id" ], @"likes": string};
//                    
//                    [self.table update:itemLikes   completion:^(NSDictionary *item, NSError *error) {
//                        [self logErrorIfNotNil:error];
//                    }];
//                    [self logErrorIfNotNil:error];
//                }];
                
                
                
                [self.popularTableView reloadData];
            }
        }];
        
//    }
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            if (!isSearchOn)
                [self getData];
            else
                [self getDataSearch];
    }
    }
}
- (void) deleteText  {
    [self.popularTableView beginUpdates];
    
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
    [self.popularTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
    
    [self.popularTableView endUpdates];
    [self.popularTableView reloadData];
}
//- (void) deleteText  {
//    [self.popularTableView beginUpdates];
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
//    [self.array removeObjectAtIndex:flagButton];
//    [self.popularTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
//
//    [self.popularTableView endUpdates];
//    [self.popularTableView reloadData];
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
//                [self.popularTableView reloadData];
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
//            NSDictionary *item1 =@{@"postid" : [dictionary objectForKey:@"id" ], @"userid": userId};
//            
//            [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
//                [self logErrorIfNotNil:error];
//            }];
//            [self.popularTableView reloadData];
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
//- (IBAction)flagAction:(id)sender {
//   UIButton *btn = (UIButton *)sender;
//    flagButton = btn.tag;
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    
//    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userId"]] ){
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:nil];
//        actionSheet.tag=0;
//        [actionSheet showInView:sender];
//    }
//    
//    else {
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
////            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:nil];
////    actionSheet.tag=1;
////    [actionSheet showInView:sender];
//    }
//}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    UIButton * btn = (UIButton *) sender;
//    NSLog(@"btn.tag is %ld",(long)btn.tag);
//    if ([[segue identifier] isEqualToString:@"share"])
//    {
//        NSLog(@"blah popular");
////        shareViewController *vc = [[shareViewController alloc] init];
////        vc=[segue destinationViewController];
//        
////        UIImage *image = [self captureImage:btn.tag];
////        [defaults setObject:UIImagePNGRepresentation([self captureImage:btn.tag]) forKey:@"image"];
//        [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
//
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
//         vc.replyTitleString=[dictionary objectForKey:@"text"];
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
            [self.popularTableView reloadData];
            
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
//            UIButton *btn = (UIButton *)[self.view viewWithTag:flagButton];
//            btn.userInteractionEnabled=NO;
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
//            [self.popularTableView reloadData];
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


- (void) refreshView
{

//    nowTime =[[NSDate date] timeIntervalSince1970];
//    if ((nowTime-startTime)> 5 ){
//        startTime =[[NSDate date] timeIntervalSince1970];
    self.array=nil;

    self.array = [[NSMutableArray alloc] init];
    if(!isSearchOn)
        [self getData];
    else
        [self getDataSearch];
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

- (void) getData {
    NSLog(@"getting data...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [home turnOnIndicator];
    if (![home connectedToNetwork]){
        NSLog(@"test if network is available");
        [home noInternetAvailable];
        return;
    }
    NSDictionary *postValues = @{
                                 @"offset":[NSNumber numberWithInt:self.array.count],
                                 @"limit" :[NSNumber numberWithInt:kLimit]
                                 };
    NSLog(@"postvalues are %@",postValues);
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postValues
    //                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
    //                                                         error:&error];
    //    NSString *jsonString;
    //    if (! jsonData) {
    //        NSLog(@"Got an error: %@", error);
    //    } else {
    //        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //        NSLog(@"jsonString is %@",jsonString);
    //    }
    [self.client invokeAPI:@"getpopularfeed" body:postValues HTTPMethod:@"POST"
                parameters:nil
                   headers:nil
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                    [home turnOffIndicator];
                    //                    });
                    NSLog(@"URLResponse: %@", response);
                    NSLog(@"result: %@", result);
                    if (error)
                    {
                        NSString* errorMessage = @"There was a problem! ";
                        errorMessage = [errorMessage stringByAppendingString:[error localizedDescription]];
                        NSLog(@"error is %@",errorMessage);

//                        UIAlertView* myAlert = [[UIAlertView alloc]
//                                                initWithTitle:@"Error!"
//                                                message:errorMessage
//                                                delegate:nil
//                                                cancelButtonTitle:@"Okay"
//                                                otherButtonTitles:nil];
//                        [myAlert show];
                    } else {
                        NSLog(@"result is %@",result);
                        [self.array addObjectsFromArray:result];
                        [self.popularTableView reloadData];
                    }
                }];
    

//    [self.popularTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        NSLog(@"items are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//        if(!error) {
//            //add the items to our local copy
//            [self.array addObjectsFromArray:items];
//            [self.popularTableView reloadData];
//        }
//    }];
}
- (void) getDataSearch {
    NSLog(@"getting data...");
    [self.array removeAllObjects];
    [self.popularTableView reloadData];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [home turnOnIndicator];

    if (![home connectedToNetwork]){
        NSLog(@"test if network is available");
        [home noInternetAvailable];
        return;
    }
    NSString *search = [defaults objectForKey:@"search"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@  && isprivate == NO",search];
    MSQuery *query = [self.table query];
    query.predicate=predicate;
    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
    query.includeTotalCount = YES; // Request the total item count
    query.fetchLimit = kLimit;
    query.fetchOffset = self.array.count;
 
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [home turnOffIndicator];
//        NSLog(@"items are %@, totalCount is %d",items,totalCount);
        [self logErrorIfNotNil:error];
        [self.array addObjectsFromArray:items];
        if(!error) {
            //add the items to our local copy
            for (NSMutableDictionary *dictionary in self.array){
                NSString *userid = [dictionary objectForKey:@"userid"];
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userid == %@",userid];
                MSQuery *query1=[self.userTable queryWithPredicate:predicate1];
                query1.selectFields=@[@"userreplies", @"reputation",@"posts",@"aboutme",@"location"];

                [query1 readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                    NSDictionary *dic = items[0];
//                    NSLog(@"dic is %@",dic);
                    [dictionary setValuesForKeysWithDictionary:dic];
                    NSLog(@"dictionary is %@",dictionary);
                    [self.popularTableView reloadData];
                }];
            }
//            NSLog(@"self.array is %@",self.array);
        }

    }];
}
//- (void)TwitterSwitch {
//    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    
//    // Create an account type that ensures Twitter accounts are retrieved.
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    
//    
//    // Request access from the user to use their Twitter accounts.
//    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
////    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
//        
//        
//        // Get the list of Twitter accounts.
//        NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
//        
//        NSLog(@"%@", accountsArray);
//        [self performSelectorOnMainThread:@selector(populateSheetAndShow:) withObject:accountsArray waitUntilDone:NO];
//    }];
//}
//
//-(void)populateSheetAndShow:(NSArray *) accountsArray {
//    buttonsArray = [NSMutableArray array];
//    [accountsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//        [buttonsArray addObject:((ACAccount*)obj).username];
//    }];
//    
//    
//    NSLog(@"%@", buttonsArray);
//    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    actionSheet.tag=2;
//    for( NSString *title in buttonsArray){
//        [actionSheet addButtonWithTitle:title];
//    }
//    [actionSheet addButtonWithTitle:@"Cancel"];
//    
//    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
//    [actionSheet showInView:self.view];
//}
//- (void) getTwitterUsername {
//    //get Twitter username and store it
//    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
//     {
//         if(granted) {
//             NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
//             if ([accountsArray count] > 0) {
//                 ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
//                 NSLog(@"%@",twitterAccount.username);
//                 NSLog(@"%@",twitterAccount.accountType);
//                 [defaults setValue:twitterAccount.username forKey:@"twitterHandle"];
//             }
//         }}];
//    NSLog(@"twitterHandle is %@",[defaults valueForKey:@"twitterHandle"]);
//}

#pragma mark - textView delegated methods


//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    textView.text = @"";
//    [textView becomeFirstResponder];
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if([text isEqualToString:@"\n"]) {
//        NSLog(@"done");
//        [self doneKeyboard];
//        return YES;
//    }
//    
//    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
//    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
//    NSUInteger location = replacementTextRange.location;
//    
//    if (textView.text.length + text.length > 140){
//        if (location != NSNotFound){
//            [textView resignFirstResponder];
//        }
//        return NO;
//    }
//    else if (location != NSNotFound){
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}
//- (void)textViewDidChange:(UITextView *)textView{
//    UILabel *label = (UILabel *)[self.view viewWithTag:100];
//    label.text = [NSString stringWithFormat:@"%u",140-textView.text.length];
//    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
//    label2.hidden=YES;
//    
//}
//
//-(void)createInputAccessoryView {
//    
//    UIToolbar *inputAccessoryView1 = [[UIToolbar alloc] init];
////    inputAccessoryView1.barTintColor=[UIColor lightGrayColor];
////    [inputAccessoryView1 sizeToFit];
//    
//    inputAccessoryView1.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
//    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
//                                                                   style:UIBarButtonItemStyleBordered
//                                                                  target:self action:@selector(cancelKeyboard)];
//    //Use this to put space in between your toolbox buttons
//    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                              target:nil
//                                                                              action:nil];
//    UIBarButtonItem *isPrivateItem = [[UIBarButtonItem alloc] initWithTitle:@"@IsPrivate"
//                                                                      style:UIBarButtonItemStyleBordered
//                                                                     target:self action:@selector(addText)];
//    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
//                                                                 style:UIBarButtonItemStyleBordered
//                                                                target:self action:@selector(doneKeyboard)];
//    
//    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,isPrivateItem,flexItem,doneItem, nil];
//    [inputAccessoryView1 setItems:itemsView animated:NO];
//    [txtChat addSubview:inputAccessoryView1];
//    
//}
//
//-(void) addText {
//    [Flurry logEvent:@"isPrivate Tapped"];
//    
//    txtChat.text = [NSString stringWithFormat:@"@IsPrivate %@",txtChat.text];
//    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
//    label2.hidden=YES;
//    
//}

-(void)createInputAccessoryViewForSearch {
    
    _inputAccessoryView = [[UIToolbar alloc] init];
    _inputAccessoryView.barTintColor=[UIColor lightGrayColor];
//    [_inputAccessoryView sizeToFit];
    
    _inputAccessoryView.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(searchBarCancel)];
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(searchBarClicked)];
    
    NSArray *itemsView = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,doneItem, nil];
    [_inputAccessoryView setItems:itemsView animated:NO];
}

//-(void)doneKeyboard{
//    [txtChat resignFirstResponder];
//    txtChat.hidden=YES;
//    UILabel *label = (UILabel *)[self.view viewWithTag:100];
//    label.text = @"140";
//    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
//    if(!([[txtChat.text stringByTrimmingCharactersInSet: set] length] == 0) )
//        //    {
//        //    if(![txtChat.text isEqualToString:@""])
////        [self postComment];
//    txtChat.text = @"";
//}
//-(void)cancelKeyboard{
//    [txtChat resignFirstResponder];
//    txtChat.text=@"";
//    txtChat.hidden=YES;
//    UILabel *label = (UILabel *)[self.view viewWithTag:100];
//    label.text = @"140";
//    
//}
//- (IBAction)composeAction:(id)sender {
//    
//    NSLog(@"compose");
//    txtChat.hidden=NO;
//    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
//    label2.hidden=NO;
//    [self.view bringSubviewToFront:txtChat];
//    [txtChat becomeFirstResponder];
//}

//-(void)postComment
//{
//    [Flurry logEvent:@"Post"];
//    
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
//    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isSearchOn]};
//    MSTable *itemTable = [client tableWithName:@"anonogramTable"];
//    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//            [self logErrorIfNotNil:error];
//        } else {
//            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
//        }
//        [self refreshView];
//
//    }];
//}


- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

@end
