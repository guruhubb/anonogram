//
//  PageContentViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#import "PageContentViewController.h"
#import "Cell.h"
#import "shareViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface PageContentViewController (){
    UITextField        *txtChat;
    NSUserDefaults *defaults;
    NSString *token;
    NSInteger loadMore;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
    NSMutableArray *buttonsArray;
    NSInteger flagButton;
}
@property (nonatomic)           NSInteger busyCount;
@property (nonatomic, strong)   MSTable *table;
@end

@implementation PageContentViewController
@synthesize items;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createContentPages];
    self.items = [[NSMutableArray alloc] init];
    self.busyCount = 0;
    self.table = [self.client tableWithName:@"anonogramTable"];
    if (!IS_TALL_SCREEN) {
        self.theTableView.frame = CGRectMake(0, 0, 320, 480-64);  // for 3.5 screen; remove autolayout
    }
//    [date formattedAsTimeAgo]
//    NSString *mysqlDatetime = <Get from the database>
//    NSString *timeAgoFormattedDate = [NSDate mysqlDatetimeFormattedAsTimeAgo:mysqlDatetime];
    defaults = [NSUserDefaults standardUserDefaults];
    token = [defaults objectForKey:@"booklyAccessToken"];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.theTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    
    // Create the todoService - this creates the Mobile Service client inside the wrapped service
//    self.todoService = [[TodoService alloc]init];
    
//    [self refreshDataOnSuccess:^{
//        [self.theTableView reloadData];
//    }];
//    if (_pageIndex==2) [self getTwitterUsername];
}

- (void) createContentPages
{
    NSMutableArray *pageStrings = [[NSMutableArray alloc] init];
    for (int i = 1; i < 10; i++)
    {
        NSString *contentString = [[NSString alloc]initWithFormat:@"Chapter %d \nThis is the page %d of content displayed using UIPageViewController in iOS 5.", i, i];
        [pageStrings addObject:contentString];
    }
    _pageContent = [[NSMutableArray alloc] initWithArray:pageStrings];
    NSLog(@"pageContent is %@",_pageContent);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return _pageContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
   
    
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"anonogramCell" ];
    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
    if (_pageIndex==0 ){
    cell.pageContent.text = [dictionary objectForKey:@"text"];
    cell.likeCount.text = [dictionary objectForKey:@"likeCount"];
    cell.timestamp.text = [dictionary objectForKey:@"timestamp"];
    cell.share.tag = indexPath.row;
        cell.flag.tag=indexPath.row;
        cell.like.tag=indexPath.row;
    }
//    NSLog(@"title is %@ and %@",self.navigationItem.title, self.navigationController.navigationItem.title);
//    cell.flag.imageView.image=nil;
    if (_pageIndex==0 )
        [cell.flag setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal ];
    else
        [cell.flag setImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] forState:UIControlStateNormal ];


    indexPathRow=indexPath;
    
    return cell;
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
//    UITableViewCellEditingStyle editingStyle=1;
//    if (editingStyle == UITableViewCellEditingStyleDelete) {  //&& page=mypages or page = private
        [Flurry logEvent:@"Delete"];
        //add code here for when you hit delete
        
        NSString *postId=[[self.array objectAtIndex:indexPathRow.row] objectForKey:@"id"];

//        NSString *strcommentId=[commentId stringByReplacingOccurrencesOfString:@"\n" withString:@""];

//        NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=deleteComment&commentId=%@&authtoken=%@",strcommentId,token];
    
//        NSLog(@"final url is %@",urlString1);
    
//        NSURL *url = [[NSURL alloc]initWithString:urlString1];
//        NSLog(@"url is%@",url);
//        [NSData dataWithContentsOfURL:url];
        [self.array removeObjectAtIndex:indexPathRow.row];
        [self.theTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
//    }
    [self.theTableView endUpdates];
}
- (IBAction)likeAction:(id)sender {
    [Flurry logEvent:@"Like"];
    UIButton *btnPressLike = (UIButton*)sender;
    btnPressLike.userInteractionEnabled=NO;
    NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)[[dictionary objectForKey:@"like"] integerValue]+1] forKey:@"like"];
    [self.theTableView reloadData];


//    NSInteger tagLikeBtn = btnPressLike.tag;
//    BOOL isLikeValue = [[dictionary objectForKey:@"islike"] boolValue];  // 0 for UnLike, 1 for Like
//    if (!isLikeValue) {
////        [self facebookUpdateNewLikeActivity];
//        [dictionary setValue:@"1" forKey:@"islike"];
//        //        [cell.btnLike setBackgroundImage:[UIImage imageNamed:@"heart_like.png"] forState:UIControlStateNormal];
//        count++;
//        [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"like"];
//        //        [cell.btnLike setBackgroundImage:[UIImage imageNamed:@"heart_like.png"] forState:UIControlStateNormal];
//        //  btnPressLike.userInteractionEnabled=FALSE;
//        [self.theTableView reloadData];
//        dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
//        
//        dispatch_barrier_async(queue, ^{
//            
//            
//            NSDictionary *dicMedia=[self.array objectAtIndex:tagLikeBtn];
//            NSString *strMediaId=[dicMedia objectForKey:@"id"];
//            NSString *strWithOutSpaceMediaId = [strMediaId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//            NSLog(@"media id is%@",strWithOutSpaceMediaId);
//            
//            NSString *strTagId=[dicMedia objectForKey:@"tagId"];
//            NSString *strWithOutSpaceTagId = [strTagId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//            
//            NSLog(@"tag id IS %@",strWithOutSpaceTagId);
//            
//            NSString *urlString= [NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=postLike&mediaId=%@&tagId=%@&authtoken=%@",strWithOutSpaceMediaId,strWithOutSpaceTagId,token];
//            
//            
//            NSLog(@"final url is %@",urlString);
//            
//            NSURL *url = [[NSURL alloc] initWithString:urlString];
//            NSLog(@"url is%@",url);
//            //    IsLikeUnlikeTag=TRUE;
//            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
//            url=nil;
//            xmlParser=nil;
//            //        [xmlParser setDelegate:self];
//        });
//        //   dispatch_release(queue);
//    }
//    else {
//        [dictionary setValue:@"0" forKey:@"islike"];
//        count--;
//        [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"like"];
//        [self.theTableView reloadData];
//        
//        dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
//        
//        dispatch_barrier_async(queue, ^{
//            
//            
//            NSDictionary *dicMedia=[self.array objectAtIndex:tagLikeBtn];
//            NSString *strMediaId=[dicMedia objectForKey:@"id"];
//            NSString *strWithOutSpaceMediaId = [strMediaId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//            NSLog(@"media id is%@",strWithOutSpaceMediaId);
//            NSString *urlString= [NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=disLike&mediaId=%@&authtoken=%@",strWithOutSpaceMediaId,token];
//            
//            
//            NSLog(@"final url is %@",urlString);
//            
//            NSURL *url = [[NSURL alloc] initWithString:urlString];
//            NSLog(@"url is%@",url);
//            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
//            //        [NSData dataWithContentsOfURL:url];
//            url=nil;
//            xmlParser=nil;
//        });
//        //   dispatch_release(queue);
//    }
    

}

- (IBAction)flagAction:(id)sender {
   UIButton *btn = (UIButton *)sender;
    flagButton = btn.tag;
    if (_pageIndex==0 || _pageIndex==2){
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
    label.text = _pageContent[index];
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
        }
    }
    if (actionSheet.tag == 2){
        [Flurry logEvent:@"TwitterSwitch"];

          [[NSUserDefaults standardUserDefaults] setValue:buttonsArray[buttonIndex] forKey:@"twitterHandle"];
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
    self.array = nil;
//    packagesOriginalImages=nil;
    self.array = [[NSMutableArray alloc] init];
//    packagesOriginalImages=[[NSMutableArray alloc]init];
    
    loadMore=1;
    
    dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_barrier_async(queue, ^{
//        [self loadxmlparsing];
    });
    //   dispatch_release(queue);
    [self.theTableView reloadData];
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

- (void) refreshDataOnSuccess:(completionBlock)completion
{
    // TODO
    // Create a predicate that finds items where complete is false
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    
    // TODO
    // Query the TodoItem table and update the items property with the results from the service
    [self.table readWithPredicate:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error)
     {
         self.items = [results mutableCopy];
         completion();
     }];
    
    completion();
}

-(void) addItem:(NSDictionary *)item completion:(completionWithIndexBlock)completion
{
    // TODO
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        NSUInteger index = [items count];
        [(NSMutableArray *)items insertObject:item atIndex:index];
        
        // Let the caller know that we finished
        completion(index);
    }];
    
    NSUInteger index = [items count];
    [(NSMutableArray *)items insertObject:item atIndex:index];
    
    // Let the caller know that we finished
    completion(index);
    
}

-(void) completeItem:(NSDictionary *)item completion:(completionWithIndexBlock)completion
{
    // Cast the public items property to the mutable type (it was created as mutable)
    NSMutableArray *mutableItems = (NSMutableArray *) items;
    
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
    [mutable setObject:@(YES) forKey:@"complete"];
    
    // Replace the original in the items array
    NSUInteger index = [items indexOfObjectIdenticalTo:item];
    [mutableItems replaceObjectAtIndex:index withObject:mutable];
    
    // TODO
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.table update:mutable completion:^(NSDictionary *item, NSError *error) {
        
        // TODO
        // Get a fresh index in case the list has changed
        NSUInteger index = [items indexOfObjectIdenticalTo:mutable];
        
        [mutableItems removeObjectAtIndex:index];
        
        // Let the caller know that we have finished
        completion(index);
    }];
    
    
    [mutableItems removeObjectAtIndex:index];
    
    // Let the caller know that we have finished
    completion(index);
    
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}
- (void) loadResults {
    MSQuery *query = [self.table query];
    
    query.includeTotalCount = YES;
    query.fetchLimit = 20;
    query.fetchOffset = self.loadedItems.count;
    
    [query readWithCompletion:^(NSArray *itemsDB, NSInteger totalCount, NSError *error) {
        if(!error) {
            //add the items to our local copy
            [self.loadedItems addObjectsFromArray:itemsDB];
            
            //set a flag to keep track if there are any additional records we need to load
            self.moreResults = (self.loadedItems.count < totalCount);
        }
    }];
    
}

- (void) getData {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    // Retrieve the MSTable's MSQuery instance with the predicate you just created.
    MSQuery * query = [self.table queryWithPredicate:predicate];
    
    
    
    query.includeTotalCount = YES; // Request the total item count
    
    // Start with the first item, and retrieve only three items
    query.fetchOffset = 0;
    query.fetchLimit = 3;
    
    [query orderByAscending:@"duration"];  //first order by ascending duration field
    [query orderByAscending:@"complete"]; // second order by ascending complete field
    query.parameters = @{
                         @"myKey1" : @"value1",
                         @"myKey2" : @"value2",
                         };

    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        //here everything is OK(items, error), but totalCount is -1
    }];

    
    // Invoke the MSQuery instance directly, rather than using the MSTable helper methods.
    [query readWithCompletion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
        [self logErrorIfNotNil:error];
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            for(NSDictionary *item in items) {
                NSLog(@"Todo Item: %@", [item objectForKey:@"text"]);
            }
        }
        if (!error)
        {
            // Log total count.
            NSLog(@"Total item count: %@",[NSString stringWithFormat:@"%zd", (ssize_t) totalCount]);
            items = [results mutableCopy];
        }
        
        
        
        // Let the caller know that we finished
//        completion();
    }];
    id itemId =@"37BBF396-11F0-4B39-85C8-B319C729AF6D";
    
    [self.table readWithId:itemId completion:^(NSDictionary *item, NSError *error) {
        //your code here
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
//             ACAccount *twitterAccount;
//             if (accountsArray.count!=0) {
//                twitterAccount = [accountsArray objectAtIndex:0];
//             }
//             NSLog(@"%@",accountsArray);
             if ([accountsArray count] > 0) {
                 ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                 NSLog(@"%@",twitterAccount.username);
                 NSLog(@"%@",twitterAccount.accountType);
                 [[NSUserDefaults standardUserDefaults] setValue:twitterAccount.username forKey:@"twitterHandle"];
             }
             
             
         }}];
    NSLog(@"twitterHandle is %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"twitterHandle"]);
    //get the username later...
    //        [textField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"twitterHandle"]];
    
//    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    [params setObject:tempUserID forKey:@"user_id"];
//    [params setObject:@"0" forKey:@"include_rts"]; // don't include retweets
//    [params setObject:@"1" forKey:@"trim_user"]; // trim the user information
//    [params setObject:@"1" forKey:@"count"]; // i don't even know what this does but it does something useful
//    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
//
//
//    //  Attach an account to the request
//    [request setAccount:twitterAccount]; // this can be any Twitter account obtained from the Account store
//    
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//        if (responseData) {
//            NSDictionary *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];
//            NSLog(@"received Twitter data: %@", twitterData);
//            
//            // to do something useful with this data:
//            NSString *screen_name = [twitterData objectForKey:@"screen_name"]; // the screen name you were after
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // update your UI in here
//                twitterScreenNameLabel.text = screen_name;
//            });
//            
            // A handy bonus tip: twitter display picture
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
//        }else{
//            NSLog(@"Error while downloading Twitter user data: %@", error);
//        }
//    }];
}


@end
