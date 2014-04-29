//
//  HomeViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#define kLimit 2
#define kFlagsAllowed 1
#import "HomeViewController.h"
#import "Cell.h"
#import "shareViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface HomeViewController (){
//    UITextField        *txtChat;
    NSUserDefaults *defaults;
    NSString *token;
    BOOL isPrivateOn;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSInteger flagButton;

    UITextView        *txtChat;
    UIToolbar *_inputAccessoryView;
}
@property (nonatomic)           NSInteger busyCount;
@property (nonatomic, strong)   MSTable *table;
@property (nonatomic, strong)   MSTable *isLikeTable;
@property (nonatomic, strong)   MSTable *isFlagTable;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.array = [[NSMutableArray alloc] init];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.busyCount = 0;
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.isLikeTable = [self.client tableWithName:@"isLike"];
    self.isFlagTable = [self.client tableWithName:@"isFlag"];

    if (!IS_TALL_SCREEN) {
        self.theTableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }
//    [date formattedAsTimeAgo]
//    NSString *mysqlDatetime = <Get from the database>
//    NSString *timeAgoFormattedDate = [NSDate mysqlDatetimeFormattedAsTimeAgo:mysqlDatetime];
    defaults = [NSUserDefaults standardUserDefaults];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.theTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self setup];
    [self getUUID];
    [self getData];
    
}
-(void) setup {
    txtChat = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, screenSpecificSetting(290, 202))];
    txtChat.delegate=self;
    txtChat.hidden=YES;
    txtChat.font=[UIFont systemFontOfSize:16];
    txtChat.text=@"placeholder";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(285, screenSpecificSetting(215, 127), 30, 30)];
    label.textColor=[UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text= @"140";
    label.tag =100;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20,15,280, 190)];
    label2.textColor=[UIColor lightGrayColor];
    label2.font = [UIFont systemFontOfSize:18];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.text= @"\nPost Anonymously. \n\nUse @IsPrivate button for direct messages - all @usernames become . \n\nNo location tracking. No signups. ";
    label2.numberOfLines=14;
    label2.tag =105;
    [txtChat addSubview:label];
    [txtChat addSubview:label2];
    [self createInputAccessoryView];
//    [self createInputAccessoryViewForSearch];
    [self.view addSubview:txtChat];
    [self.view addSubview:_inputAccessoryView];
    _inputAccessoryView.hidden=YES;
//    _searchBarButton.hidden=YES;
//    _searchBarButton.placeholder = @"Search #hashtag, @username";
//    [_searchBarButton setKeyboardType:UIKeyboardTypeTwitter];
    [txtChat setKeyboardType:UIKeyboardTypeTwitter];

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
    
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
    if (self.array.count <= indexPath.row)
        return cell;
    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
    NSLog(@"dictionary is %@",dictionary);
    
//    if (_pageIndex==0 ){
    cell.pageContent.text = [dictionary objectForKey:@"text"];
    cell.likeCount.text = [dictionary objectForKey:@"likes"];
    
//    if ([[dictionary objectForKey:@"timestamp"] isEqualToString:@""]) {
//        cell.timestamp.text = @"";
//    }
//    else
//    cell.timestamp.text = [NSDate mysqlDatetimeFormattedAsTimeAgo:[dictionary objectForKey:@"timestamp"]];
//     cell.timestamp.text =[NSDate stringForDisplayFromDate: mysqlDatetimeFormattedAsTimeAgo:[dictionary objectForKey:@"timestamp"]];

    cell.share.tag = indexPath.row;
    cell.flag.tag=indexPath.row;
    cell.like.tag=indexPath.row;
        
//    }
//    NSLog(@"title is %@ and %@",self.navigationItem.title, self.navigationController.navigationItem.title);
//    cell.flag.imageView.image=nil;
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];

    if ([userId isEqualToString:[dictionary objectForKey:@"userId"]] ){
        [cell.flag setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal ];
    }
    else {
        [cell.flag setImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] forState:UIControlStateNormal ];
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isFlagTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) cell.flag.userInteractionEnabled=NO;
        }];
    }
    
    //TO DO get isFlag and isLike status and disable button if already set
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && postId == %@",userId,[dictionary objectForKey:@"id" ]];
//    [self.isLikeTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        if (items.count) cell.like.userInteractionEnabled=NO;
//    }];

    indexPathRow=indexPath;
    
    return cell;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self getData];
        // we are at the end
//        loadMore++;
//        [self loadxmlparsing];
        
    }
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView beginUpdates];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {  //&& page=mypages or page = private
//        [Flurry logEvent:@"Comment: Delete"];
//        //add code here for when you hit delete
//        
//        NSString *commentId=[[self.array objectAtIndex:indexPath.row] objectForKey:@"id"];
//        //        NSString *strlblcomments =[[self.array objectAtIndex:indexPath.row] objectForKey:@"comment"];
//        //        NSLog(@"commentId is %@",strlblcomments);
//        //        if ([strlblcomments isEqualToString:@""]) return;
//        NSString *strcommentId=[commentId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
////        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////        NSString *token = [defaults objectForKey:@"booklyAccessToken"];
//        
//        NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=deleteComment&commentId=%@&authtoken=%@",strcommentId,token];
//        
//        NSLog(@"final url is %@",urlString1);
//        
//        NSURL *url = [[NSURL alloc]initWithString:urlString1];
//        NSLog(@"url is%@",url);
//        [NSData dataWithContentsOfURL:url];
//        [self.array removeObjectAtIndex:1];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
//    }
//    [tableView endUpdates];
//}
- (void) deleteText  {
    [self.theTableView beginUpdates];

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
    [self.theTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];

    [self.theTableView endUpdates];
    [self.theTableView reloadData];
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
            [self.theTableView reloadData];

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
            [self.theTableView reloadData];
        }
    }];
}

- (IBAction)flagAction:(id)sender {
   UIButton *btn = (UIButton *)sender;
    flagButton = btn.tag;
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    
    if ([userId isEqualToString:[self.array[btn.tag] objectForKey:@"userId"]] ){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Anonogram" otherButtonTitles:nil];
        actionSheet.tag=0;
        [actionSheet showInView:sender];
    }
    
    else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as Inappropriate" otherButtonTitles:nil];
    actionSheet.tag=1;
    [actionSheet showInView:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton * btn = (UIButton *) sender;
    NSLog(@"btn.tag is %ld",(long)btn.tag);
    if ([[segue identifier] isEqualToString:@"share"])
    {
        NSLog(@"blah");
        shareViewController *vc = [[shareViewController alloc] init];
        vc=[segue destinationViewController];
        
//        UIImage *image = [self captureImage:btn.tag];
        [defaults setObject:UIImagePNGRepresentation([self captureImage:btn.tag]) forKey:@"image"];
//        vc.image = image;
        
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
    label.text = [self.array[indexPathRow.row] objectForKey:@"text"];
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
    }
    if (actionSheet.tag == 1) {
        if (buttonIndex==0){
            [Flurry logEvent:@"Flag"];
            UIButton *btn = (UIButton *)[self.view viewWithTag:flagButton];
            btn.userInteractionEnabled=NO;
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
    }
    if (actionSheet.tag == 2){
        [Flurry logEvent:@"TwitterSwitch"];

          [[NSUserDefaults standardUserDefaults] setValue:buttonsArray[buttonIndex] forKey:@"twitterHandle"];
        [self refreshView];
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
    self.array = [[NSMutableArray alloc] init];
    [self getData];
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

//- (void) refreshDataOnSuccess:(completionBlock)completion
//{
//    // TODO
//    // Create a predicate that finds items where complete is false
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
//    
//    // TODO
//    // Query the TodoItem table and update the items property with the results from the service
//    [self.table readWithPredicate:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error)
//     {
//         self.items = [results mutableCopy];
//         completion();
//     }];
//    
//    completion();
//}

//-(void) addItem:(NSDictionary *)item completion:(completionWithIndexBlock)completion
//{
//    // TODO
//    // Insert the item into the TodoItem table and add to the items array on completion
//    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
//        NSUInteger index = [items count];
//        [(NSMutableArray *)items insertObject:item atIndex:index];
//        
//        // Let the caller know that we finished
//        completion(index);
//    }];
//    
//    NSUInteger index = [items count];
//    [(NSMutableArray *)items insertObject:item atIndex:index];
//    
//    // Let the caller know that we finished
//    completion(index);
//    
//}

//-(void) completeItem:(NSDictionary *)item completion:(completionWithIndexBlock)completion
//{
//    // Cast the public items property to the mutable type (it was created as mutable)
//    NSMutableArray *mutableItems = (NSMutableArray *) items;
//    
//    // Set the item to be complete (we need a mutable copy)
//    NSMutableDictionary *mutable = [item mutableCopy];
//    [mutable setObject:@(YES) forKey:@"complete"];
//    
//    // Replace the original in the items array
//    NSUInteger index = [items indexOfObjectIdenticalTo:item];
//    [mutableItems replaceObjectAtIndex:index withObject:mutable];
//    
//    // TODO
//    // Update the item in the TodoItem table and remove from the items array on completion
//    [self.table update:mutable completion:^(NSDictionary *item, NSError *error) {
//        
//        // TODO
//        // Get a fresh index in case the list has changed
//        NSUInteger index = [items indexOfObjectIdenticalTo:mutable];
//        
//        [mutableItems removeObjectAtIndex:index];
//        
//        // Let the caller know that we have finished
//        completion(index);
//    }];
//    
//    
//    [mutableItems removeObjectAtIndex:index];
//    
//    // Let the caller know that we have finished
//    completion(index);
//    
//}

//- (void) logErrorIfNotNil:(NSError *) error
//{
//    if (error) {
//        NSLog(@"ERROR %@", error);
//    }
//}
//- (void) loadResults {
//    MSQuery *query = [self.table query];
//    
//    query.includeTotalCount = YES;
//    query.fetchLimit = 20;
//    query.fetchOffset = self.loadedItems.count;
//    
//    [query readWithCompletion:^(NSArray *itemsDB, NSInteger totalCount, NSError *error) {
//        if(!error) {
//            //add the items to our local copy
//            [self.loadedItems addObjectsFromArray:itemsDB];
//            
//            //set a flag to keep track if there are any additional records we need to load
//            self.moreResults = (self.loadedItems.count < totalCount);
//        }
//    }];
//    
//}

//- (void) getData {
////    if (!loadMore) {
////        return;
////    }
//
//    NSLog(@"getting data...");
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    MSQuery * query;
//    switch (_pageIndex) {
////        case 0:{ //mypage
////            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
////            query = [[MSQuery alloc] initWithTable:self.table predicate:predicate];
////
////        }
////            break;
//        case 0: { //private
//            if(![defaults boolForKey:@"myAnons"]) {
//                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(isPrivate == YES)  &&  (text contains[cd] %@)",[defaults objectForKey:@"twitterHandle"]];
//                query = [[MSQuery alloc] initWithTable:self.table predicate:predicate];
//            }
//            else {
//                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
//                query = [[MSQuery alloc] initWithTable:self.table predicate:predicate];
//            }
//        }
//            break;
//        case 1:{  //home
//            
//            query = [[MSQuery alloc] initWithTable:self.table ];
//            [query orderByDescending:@"timestamp"];  //first order by ascending duration field
//
//        }
//            break;
//        case 2:{//popular
//            NSLog(@"popular or search %d",[defaults boolForKey:@"search"]);
//            if(![defaults boolForKey:@"searchOn"]) {
//
//                query = [[MSQuery alloc] initWithTable:self.table ];
//                [query orderByDescending:@"likes"];  //first order by ascending duration field
//                [query orderByDescending:@"timestamp"];  //first order by ascending duration field
//            } else {
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@",[defaults objectForKey:@"search"] ];
//                query = [[MSQuery alloc] initWithTable:self.table predicate:predicate];
//            }
//
//        }
//            break;
////        case 4: {//search
////            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@",[defaults objectForKey:@"search"] ];
////            query = [[MSQuery alloc] initWithTable:self.table predicate:predicate];
////        }
//            break;
//        default:{ //home
//            query = [[MSQuery alloc] initWithTable:self.table ];
//        }
//            break;
//    }
//    
//    query.includeTotalCount = YES; // Request the total item count
//    query.fetchLimit = kLimit;
//    query.fetchOffset = self.array.count;
//    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        NSLog(@"items are %@, totalCount is %d",items,totalCount);
//        [self logErrorIfNotNil:error];
//        if(!error) {
//            //add the items to our local copy
//            [self.array addObjectsFromArray:items];
//            
//            //set a flag to keep track if there are any additional records we need to load
//            if(self.array.count < totalCount) loadMore=YES;
//            else loadMore=NO;
//            [self.theTableView reloadData];
//
//        }
//    }];
//}
- (void) getData {
    NSLog(@"getting data...");
    MSQuery * query = [[MSQuery alloc] initWithTable:self.table ];
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
            [self.theTableView reloadData];
        }
    }];
}
- (void)TwitterSwitch {
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
    buttonsArray = [NSMutableArray array];
    [accountsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [buttonsArray addObject:((ACAccount*)obj).username];
    }];
    
    
    NSLog(@"%@", buttonsArray);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag=2;
    for( NSString *title in buttonsArray){
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];
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
    
//    if ([txtChat.text rangeOfString:@"@isprivate " options:NSCaseInsensitiveSearch].length)
//        isPrivateOn = YES;
//    else
//        isPrivateOn = NO;
//    
//    txtChat.text=[txtChat.text stringByReplacingOccurrencesOfString:@"@isprivate" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [txtChat.text length])] ;
    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    //    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isPrivateOn],@"hashtag":hashString, @"atName": atString};
    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isPrivateOn]};
    MSTable *itemTable = [client tableWithName:@"anonogramTable"];
    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [self logErrorIfNotNil:error];
        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
    }];
    [self refreshView];
}


- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

@end
