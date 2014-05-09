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

@interface PrivateMyVC (){
    NSUserDefaults *defaults;
    NSString *token;
    BOOL isPrivateOn;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSInteger flagButton;
    BOOL isComment;
    NSInteger commentedPost;
    UITextView        *txtChat;
    UIToolbar *_inputAccessoryView;
    NSTimeInterval nowTime;
    NSTimeInterval startTime ;
}
@property (nonatomic, strong)   MSTable *table;
@property (nonatomic, strong)   MSTable *isLikeTable;
@property (nonatomic, strong)   MSTable *isFlagTable;


@property (strong, nonatomic) IBOutlet UITableView *TableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic, strong)   MSClient *client;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *myButton;

@end

@implementation PrivateMyVC

-(void)viewDidAppear:(BOOL)animated {

    if (isComment){
        isComment = NO;
        NSLog(@"comment update, commentedPost is %d",commentedPost);
        [self.table readWithId:[self.array[commentedPost] objectForKey:@"id"] completion:^(NSDictionary *item, NSError *error) {
            NSLog(@"item is %@",item);
            [self.array replaceObjectAtIndex:commentedPost withObject:item];
            [self.TableView reloadData];
            [self logErrorIfNotNil:error];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    startTime=0;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.TableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    [self.TableView setSeparatorInset:UIEdgeInsetsZero];

    self.array = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.isLikeTable = [self.client tableWithName:@"isLike"];
    self.isFlagTable = [self.client tableWithName:@"isFlag"];
    isPrivateOn=YES;
    if (!IS_TALL_SCREEN) {
        self.TableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }

    defaults = [NSUserDefaults standardUserDefaults];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.TableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
//    [self setup];
//    [self getUUID];
    if (![defaults objectForKey:@"twitterAccounts"])
        [self twitterSwitch:nil];
    [self refreshView];
    
}
- (IBAction)myAction:(id)sender {
    if (isPrivateOn){
        isPrivateOn = NO;
        self.navigationItem.title= [NSString stringWithFormat:@"My Anonograms"];
        UIBarButtonItem *popularButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                      target:self action:@selector(myAction:)] ;
        self.navigationItem.rightBarButtonItem = popularButton;
        self.array = [[NSMutableArray alloc] init];
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
            self.navigationItem.title = [NSString stringWithFormat:@"NOTIFICATIONS"];
        UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_003_user.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(myAction:)] ;
        self.navigationItem.rightBarButtonItem = privateButton;
        self.array = [[NSMutableArray alloc] init];
        [self getData];

        
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
    self.array = [[NSMutableArray alloc] init];
    [self getData];
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
//    [tableView setSeparatorInset:UIEdgeInsetsZero];
    Cell *cell = (Cell*)[tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
    if (self.array.count <= indexPath.row)
        return cell;
    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
    NSLog(@"dictionary is %@",dictionary);
    cell.pageContent.text = [dictionary objectForKey:@"text"];
    NSString *string = @"+";
    cell.likeCount.text = [string stringByAppendingString: [dictionary objectForKey:@"likes"]];
//    cell.likeCount.text = [dictionary objectForKey:@"likes"];
    cell.replies.text = [dictionary objectForKey:@"replies"];
    cell.timestamp.text = [[dictionary objectForKey:@"timestamp"] formattedAsTimeAgo];
    if ([[dictionary objectForKey:@"isPrivate"] boolValue]==1) {
        cell.lock.hidden=NO;
    }
    else
        cell.lock.hidden=YES;
//    cell.share.tag = indexPath.row;
    cell.flag.tag=indexPath.row;
    cell.like.tag=indexPath.row;
    cell.privatePost.tag=indexPath.row;
    cell.lock.tag=indexPath.row;
    cell.replyButton.tag=indexPath.row;

//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//
//    if ([userId isEqualToString:[dictionary objectForKey:@"userId"]] ){
//        [cell.flag setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal ];
//    }
//    else {
//        [cell.flag setImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] forState:UIControlStateNormal ];
////        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
////        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
////        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
////            if (items.count) cell.flag.userInteractionEnabled=NO;
////        }];
//    }
    indexPathRow=indexPath;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
        
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
                [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.TableView reloadData];
                
            }
            else {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
                [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};
                
                [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.TableView reloadData];
            }
        }];
        
//    }
//    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
- (IBAction)lockAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UILabel *label = (UILabel*)[self.view viewWithTag:btn.tag];
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
            [self getData];
        }
        else
            [self getDataMyAnonograms];
    }
    }
}
- (void) deleteText  {
    [self.TableView beginUpdates];

    [Flurry logEvent:@"Delete"];

    NSLog(@"delete id is %@",[[self.array objectAtIndex:flagButton] objectForKey:@"id" ]);

    [self.table deleteWithId:[[self.array objectAtIndex:flagButton] objectForKey:@"id" ] completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    NSDictionary *item =@{@"postId" : [[self.array objectAtIndex:flagButton] objectForKey:@"id" ]};
    [self.isLikeTable delete:item completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    [self.isFlagTable delete:item completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
    }];
    
    
    [self.array removeObjectAtIndex:flagButton];
    [self.TableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];

    [self.TableView endUpdates];
    [self.TableView reloadData];
}

- (IBAction)likeAction:(id)sender {
    [Flurry logEvent:@"Like"];
    UIButton *btnPressLike = (UIButton*)sender;
    NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];

    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        if (items.count) {
            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
            [dictionary setValue:likesCount forKey:@"likes"];
            
            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }]; 
            [self.isLikeTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.TableView reloadData];
        }
        else {
            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
            [dictionary setValue:likesCount forKey:@"likes"];

            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSDictionary *item1 =@{@"postId" : [dictionary objectForKey:@"id" ], @"userId": userId};

            [self.isLikeTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.TableView reloadData];
        }
    }];
}

- (IBAction)flagAction:(id)sender {
   UIButton *btn = (UIButton *)sender;
    flagButton = btn.tag;
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    
    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userId"]] ){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:@"Share", nil];
        actionSheet.tag=0;
        [actionSheet showInView:sender];
    }
    
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[self.array[flagButton] objectForKey:@"id" ]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton * btn = (UIButton *) sender;
    NSLog(@"btn.tag is %ld",(long)btn.tag);
    if ([[segue identifier] isEqualToString:@"share"])
    {
        NSLog(@"blah private ");
//        shareViewController *vc = [[shareViewController alloc] init];
//        vc=[segue destinationViewController];
        
//        UIImage *image = [self captureImage:btn.tag];
        [defaults setObject:UIImagePNGRepresentation([self captureImage:flagButton]) forKey:@"image"];
//        vc.image = image;
        
    }
    else {
        commentedPost=btn.tag;
        isComment = YES;
        NSDictionary *dictionary = self.array[commentedPost];
//        NSString *string = [[NSString alloc] initWithString:[dictionary objectForKey:@"id"]];
        CommentVC *vc = [[CommentVC alloc] init];
        vc=(CommentVC*)[[segue destinationViewController]topViewController];
        vc.postId =[dictionary objectForKey:@"id"];
        vc.replies = [dictionary objectForKey:@"replies"];
        vc.replyTitleString=[dictionary objectForKey:@"text"];

    }
}
- (UIImage *) captureImage : (NSInteger) index {
    
    UIView* captureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 310)];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"white"])
        captureView.backgroundColor = [UIColor whiteColor];
    else
        captureView.backgroundColor = [UIColor blackColor];

    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15,60 , 290, 180)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(185,275 , 110, 30)];
    label.textAlignment=NSTextAlignmentCenter;
    label.numberOfLines=6;
    label.font = [UIFont fontWithName:@"GillSans-Light" size:20.0];
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
    self.array = [[NSMutableArray alloc] init];

    if(isPrivateOn)
        [self getData];
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
        self.array=nil;
        [self.TableView reloadData];
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
    MSQuery *query = [self.table queryWithPredicate:predicate];

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

            [self.TableView reloadData];
        }
    }];
}
- (void) getDataMyAnonograms {
    NSLog(@"getting data my anons...");
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
    MSQuery *query = [self.table queryWithPredicate:predicate];
    [query orderByDescending:@"timestamp"];  //first order by ascending duration field
    query.includeTotalCount = YES; // Request the total item count
    query.fetchLimit = kLimit;
    query.fetchOffset = self.array.count;
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        NSLog(@"items are %@, totalCount is %d",items,totalCount);
        [self logErrorIfNotNil:error];
        if(!error) {
            //add the items to our local copy
            [self.array addObjectsFromArray:items];
            [self.TableView reloadData];
        }
    }];
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Access" message:@"You need to grant access to receive private messages\nGo to Settings->Twitter. Scroll down and turn Anonogram on"
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
    [Flurry logEvent:@"Post"];
    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isPrivateOn]};
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
