//
//  CommentVC.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kLimit 20
#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#import "CommentVC.h"
#import "AppDelegate.h"
#import "NSDate+NVTimeAgo.h"
@interface CommentVC (){

    UIRefreshControl *refreshControl;

    CGSize textSize;
    NSUserDefaults *defaults;
    NSIndexPath *indexPathRow;

    NSInteger loadMore;
    NSInteger oldCount;
    NSInteger counter;
    NSInteger imageCounter;
    UIToolbar *_inputAccessoryView;
}
@property (weak, nonatomic)IBOutlet UIToolbar *textToolBar;
@property (weak, nonatomic)IBOutlet UITextField *txtChat;
//@property (nonatomic,readwrite) BOOL commentButton;
//@property (nonatomic,readwrite) BOOL myPhotoBook;
//@property(nonatomic,strong)NSDictionary *dicUserData;
@property(nonatomic,strong) NSMutableArray *array;
//@property(nonatomic,strong) NSMutableArray *arrayImages;


@property (weak, nonatomic) IBOutlet UITableView *chat_table;
@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, strong)   MSTable *commentTable;
@property (nonatomic, strong)   MSTable *isLikeCommentTable;
@property (nonatomic, strong)   MSTable *table;
@end

@implementation CommentVC
@synthesize array;
//,arrayImages;
//@synthesize dicUserData;
//@synthesize commentButton, myPhotoBook;
@synthesize chat_table,postId;
//, backButtonString;
//static const NSUInteger kMaximumNumberToParse = 24;
//static const NSUInteger kMaxDownload = 10000;


//- (void) refreshView
//{
//    self.array = nil;
////    self.arrayImages = nil;
////    arrayImages = [[NSMutableArray alloc] init ];
//    array = [[NSMutableArray alloc] init ];
//    loadMore=1;
//    [self updateData];
//}
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        [self my_viewWillUnload];
        
        [self my_viewDidUnload];
        self.view = nil;
    }
}

- (void)my_viewWillUnload
{
    // prepare to unload view
}

- (void)my_viewDidUnload
{
    self.array=nil;
//    self.arrayImages=nil;
    self.chat_table=nil;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    self.table = [self.client tableWithName:@"anonogramTable"];
    self.commentTable = [self.client tableWithName:@"commentTable"];
    self.isLikeCommentTable = [self.client tableWithName:@"isLikeCommentTable"];
//    self.postId = [defaults stringForKey:@"postId"];
    NSLog(@"postId is %@ and %@",self.postId, self.replies);
//    [self turnOnIndicator];
  
//    oldCount=0;
//    CGRect frame = CGRectMake(0, 0, 125, 40);
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:17.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor darkTextColor];
//    loadMore = 1;
//    label.text = @"comments";
//    self.navigationItem.titleView = label;
    defaults =  [NSUserDefaults standardUserDefaults];
//    chat_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, screenSpecificSetting(460, 372))];
    chat_table.frame =CGRectMake(0, 64, 320, screenSpecificSetting(460, 372));
    [self.chat_table setSeparatorInset:UIEdgeInsetsZero];

//    chat_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 480-64)];
    
//    array = [[NSMutableArray alloc] init];
//    array = [[NSMutableArray alloc]initWithObjects:
//               @"Background Color for Share",@"Add Watermark for Share", @"Like us on Facebook",@"Follow us on Twitter",
//               @"Rate App",@"Feedback",@"Restore Purchases",nil];
//    arrayImages = [[NSMutableArray alloc] init];
//    self.chat_table.delegate=self;
//    self.chat_table.dataSource=self;

//    [self.view addSubview:self.chat_table];

//    imageCache = [SDImageCache.alloc initWithNamespace:@"Bookly"];

//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backButtonString
//                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(popBack)];
//    self.navigationItem.leftBarButtonItem = backButton;


//    [self updateData];

//    if ([self.chat_table respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.chat_table setSeparatorInset:UIEdgeInsetsZero];
//    }
//    [self.chat_table reloadData];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.chat_table addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self refreshView];

}
-(UIColor*) colorCode {
//    CGFloat goldenRatio =0.618033988749895;
    CGFloat hue = (CGFloat)arc4random()/ (CGFloat)RAND_MAX;
//    hue += goldenRatio;
    hue = fmodf(hue, 1.0);
    //    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 )+0.5 ;//  0.5 to 1.0, away from white, +0.5 lightens the colors
    CGFloat brightness = ( arc4random() % 128 / 256.0 )+0.25 ;//  0.5 to 1.0, away from black, +0.25 adds more lighter colors
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8];
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
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated: NO completion: nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
//    [UIView animateWithDuration:0.0
//                          delay:0.0
//                        options:UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{ self.navigationController.navigationBar.alpha = 1.0;
//                         [self hideTabBar:self.tabBarController];
//                         self.tabBarController.tabBar.alpha = 0.0;
//                         [self.navigationController setNavigationBarHidden:NO animated:NO];
//                         
//                     }
//                     completion:nil];
//    if (self.commentButton) {
//        [txtChat becomeFirstResponder];
//        [UIView animateWithDuration:0.0 animations:^{
//            [self.chat_table setFrame:CGRectMake(0, 44, 320, screenSpecificSetting(411-209, 323-209))];
//            [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(200+64, 114+64), 320, 44)];
//        }];
//    }
}
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{

    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"view.frame.size.height is %f",view.frame.size.height);
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, screenSpecificSetting(568, 480), view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, screenSpecificSetting(568, 480))];
        }
    }
}
-(void)updateData
{
//    array = nil;
//    arrayImages=nil;
    array = [[NSMutableArray alloc] init];
//    arrayImages = [[NSMutableArray alloc] init];
//    imageCounter=0;
//    [self loadxmlparsing];
}
- (void) turnOnIndicator {
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    activityView.layer.shadowOffset = CGSizeMake(1, 1);
    activityView.layer.shadowColor = [UIColor blackColor].CGColor;
    activityView.layer.shadowOpacity=0.8 ;
    
    
    activityView.tag = 10001;
    activityView.transform = CGAffineTransformScale(activityView.transform, 1.5, 1.5);
    [activityView startAnimating];
    [self.view addSubview:activityView];
}

- (void) turnOffIndicator {
    UIActivityIndicatorView *activityView=(UIActivityIndicatorView *) [self.view viewWithTag:10001];
    [activityView removeFromSuperview];
    [activityView stopAnimating];
}



//-(void)loadxmlparsing
//{
//    dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_barrier_async(queue, ^{
//
//    dispatch_barrier_async(dispatch_get_main_queue(), ^{
//        [self turnOffIndicator];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//        [self turnOnIndicator];
//    });
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *token = [defaults objectForKey:@"booklyAccessToken"];
//    NSString *id1=[self.dicUserData objectForKey:@"id"];
// 
//    NSString *strid = [id1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSString* urlString;
//    NSString *randomNumber=@"arc4random()";
//    if (strid == NULL) return;  //this will prevent memory related crashes where mediaId = NULL
//    urlString=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=getComments&pageNo=%d&recordSize=%d&mediaId=%@&authtoken=%@&rand=%@",loadMore, kMaximumNumberToParse,strid,token,randomNumber];
//    NSLog(@"final url is %@",urlString);
//    
//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    NSLog(@"url is%@",url);
//    NSData *xmlData = [NSData dataWithContentsOfURL:url];
//        NSString *string = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
//        NSLog(@"xmlString is%@",string);
//    url=nil;
//    if (!xmlData) {
//        NSLog(@" No Internet Connection");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//            [self turnOffIndicator];
//        });
//
//        return;
//    }
//    NSLog(@"got contents of url ");
//    xmlDoc * doc = xmlParseMemory(xmlData.bytes, xmlData.length);
//    NSLog(@"xmlData.length is %d",xmlData.length);
//    if (doc) {
//        xmlXPathContext *xPathCtx = xmlXPathNewContext(doc);
//        if (xPathCtx) {
//            xmlXPathObject *xPathObj = xmlXPathEvalExpression((const xmlChar *)"/Records/Result/Record", xPathCtx);
//            NSLog(@"hello ");
//            if (xPathObj) {
//                xmlNodeSet *nodeSet = xPathObj->nodesetval;
//                if (nodeSet->nodeNr == 0) {
//                    dispatch_barrier_async(dispatch_get_main_queue(), ^{
//                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                        [self turnOffIndicator];
//                    });
//                }
//                for (int i = 0; i < nodeSet->nodeNr; ++i) {
//                    NSLog(@"hello1");
//                    xmlNode *item = nodeSet->nodeTab[i];
//                    //                    Song * song = [[Song alloc] init];
//                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
////                    xmlChar *itemId = findTextForFirstChild(item, (xmlChar *)"id");
////                    if (itemId != NULL) {
////                        [dic setValue:[NSString stringWithUTF8String:(const char *)itemId] forKey:@"id"];
////                    }
//                    xmlChar *commentId = findTextForFirstChild(item, (xmlChar *)"id");
//                    if (commentId != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)commentId] forKey:@"id"];
//                    }
//                    xmlChar *userId = findTextForFirstChild(item, (xmlChar *)"userId");
//                    if (userId != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)userId] forKey:@"userId"];
//                    }
//                    xmlChar *photo = findTextForFirstChild(item, (xmlChar *)"photo");
//                    if (photo != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)photo] forKey:@"photo"];
//                    }
//                    xmlChar *comment = findTextForFirstChild(item, (xmlChar *)"comment");
//                    if (comment != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)comment] forKey:@"comment"];
//                    }
//                    xmlChar *userName = findTextForFirstChild(item, (xmlChar *)"username");
//                    if (userName != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)userName] forKey:@"username"];
//                    }
//                    xmlChar *timestamp = findTextForFirstChild(item, (xmlChar *)"timestamp");
//                    if (timestamp != NULL) {
//                        [dic setValue:[NSString stringWithUTF8String:(const char *)timestamp] forKey:@"timestamp"];
//                    }
//                    NSLog(@"dic is %@",dic);
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                    [self getCommentImage:dic];
//                     });
//                    dic=nil;
//                   
//                }
//                xmlXPathFreeObject(xPathObj);
//            }
//            xmlXPathFreeContext(xPathCtx);
//        }
//        xmlFreeDoc(doc);
//    }
////    xmlData = nil;
////    [xmlData release];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [self turnOffIndicator];
//    });
//    });
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//{
////    if (indexPath.section==1)
////        return 45;
////    else {
//        if(array){
////            NSString *strlblcomments =[[self.array objectAtIndex:indexPath.row] objectForKey:@"comment"];
//            NSString *strlblcomments =[self.array objectAtIndex:indexPath.row] ;
//
//            NSLog(@"strlblcomments is %@",strlblcomments);
//        
// 
//            if (strlblcomments){
//                CGRect textRect = [strlblcomments boundingRectWithSize:CGSizeMake(230.0f, MAXFLOAT)
//                                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
//                                                               context:nil];
//                
//                textSize = textRect.size;
//
//
//                NSLog(@"textSize, height is %f and width is %f",textSize.height, textSize.width);
//            }
//        }
//    return MAX(textSize.height+30, 45.0f);
////    }
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section==1)
//        return 1;
//    else 
        return [self.array count];
//    NSLog(@"self.array count is %d, and self.array is %@",self.array.count,self.array);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section==1) {
//        static NSString *CellIdentifier = @"Cell1";
//        
//        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell1 == nil) {
//            cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        cell1.selectionStyle = UITableViewCellSelectionStyleGray;
////        if ([self.array count]> oldCount) {
////            oldCount = [self.array count];
////            loadMore ++;
////            [self loadxmlparsing];
////            NSLog(@"loadMore happening, loadMore is %d",loadMore);
////            
////        }
////        else [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        return cell1;
//    }
//    else {
    
        
//        self.chat_table.separatorColor = [UIColor colorWithRed:0.0/255.0 green:64.0/255.0 blue:128.0/255.0 alpha:1.0];
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//     [tableView setSeparatorInset:UIEdgeInsetsZero];
        static NSString *CellIdentifier = @"commentCell";
    
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.array.count <= indexPath.row)
        return cell;
    NSDictionary *dictionary = [self.array objectAtIndex:indexPath.row];
    NSLog(@"dictionary is %@",dictionary);
    NSMutableString *tempHex=[[NSMutableString alloc] init];
    [tempHex appendString:[dictionary objectForKey:@"color"]];
    unsigned colorInt = 0;
    [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
    cell.colorView.backgroundColor = UIColorFromRGB(colorInt);
    cell.colorView.layer.cornerRadius=15;
    cell.colorView.layer.masksToBounds=YES;
    cell.replyLabel.text = [dictionary objectForKey:@"reply"];
    NSString *string = @"+";
    cell.numberOfLikesLabel.text = [string stringByAppendingString: [dictionary objectForKey:@"likes"]];
    cell.timestampLabel.text = [[dictionary objectForKey:@"timestamp"] formattedAsTimeAgo];
    cell.likeButton.tag = indexPath.row;
    indexPathRow=indexPath;
    
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && commentId == %@",userId,[dictionary objectForKey:@"id" ]];
//    [self.isLikeCommentTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
//        if (items.count) {
//            
//            cell.numberOfLikesLabel.textColor=[UIColor redColor];
//        }
//        else {
//            cell.numberOfLikesLabel.textColor=[UIColor lightGrayColor];
//
//        }
////        [self.chat_table reloadData];
//    }];
//        if (cell == nil)
//        {
//            cell = [[CommentVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
//        }
    
//    self.chat_table.allowsSelection=YES;
//    self.chat_table.userInteractionEnabled=YES;
//    
//        cell.userInteractionEnabled = YES;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        [self.chat_table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
//        NSLog(@"hello tableviewcell");
//        cell.firstAlternateLabel.text = @"";
//        cell.firstLabel.hidden=YES;
//        cell.firstImage.image=nil;
//        cell.comments.text=@"";
//        cell.timestamp.text=@"";
//    cell.lblFollow.hidden=YES;
//    cell.lblFriends.hidden=YES;
//    cell.lblPhotos.hidden=YES;
//    cell.btnFirstImageLabel.hidden=YES;
//    cell.btnFollow.hidden=YES;

//        AppRecord *appRecord;
//        __block UIImage *image;
//        if (self.arrayImages.count > indexPath.row) {
//            appRecord = [self.arrayImages objectAtIndex:indexPath.row];
////            dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
//            if ( appRecord.userId ){
////                dispatch_barrier_async(queue, ^{
//                    image=[imageCache imageFromDiskCacheForKey:appRecord.userId];
//                    //                        NSLog(@"image is %@",image);
////                    dispatch_barrier_async(dispatch_get_main_queue(), ^{
////                        if ([[self.chat_table indexPathsForVisibleRows] containsObject:indexPath]) {
////                            CustomTableCell *cell1 = ((CustomTableCell *)[self.chat_table cellForRowAtIndexPath:indexPath]);
//                            cell.firstImage.image = image;
////                        }
////                    });
////                });
//            }
//            dispatch_release(queue);

//    }
//        if (self.arrayImages.count > indexPath.row ) {
//            AppRecord *app = [self.arrayImages objectAtIndex:indexPath.row];
//             NSLog(@"self.arrayImages is %@ and app.appIcon is %@",self.arrayImages, app.appIcon);
//            cell.firstImage.image = app.appIcon;
//        //    [app release];
//        //    app = nil;
//        }
//        if (self.array.count > indexPath.row){
//    
//            NSString *name = [[self.array objectAtIndex:indexPath.row] objectForKey:@"username"];
//            cell.firstAlternateLabel.text = [name stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
//    NSString *strlblcomments =[[self.array objectAtIndex:indexPath.row] objectForKey:@"comment"];

//    NSString *strlblcomments =[self.array objectAtIndex:indexPath.row];
    
//            cell..text = [[self.array objectAtIndex:indexPath.row] objectForKey:@"timestamp"];
//            CGRect textRect = [strlblcomments boundingRectWithSize:CGSizeMake(230.0f, MAXFLOAT)
//                                                 options:NSStringDrawingUsesLineFragmentOrigin
//                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
//                                                 context:nil];
//            
//            textSize = textRect.size;
//            textSize = [strlblcomments sizeWithFont:[UIFont systemFontOfSize:13]
//                                  constrainedToSize:CGSizeMake(230.0f, MAXFLOAT)
//                                      lineBreakMode:NSLineBreakByWordWrapping];

//            [cell.textLabel setFrame:CGRectMake(45, 7, 230, MAX(textSize.height+30, 45.0f))];
  
    
//        }

        return cell;
//    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    if ((indexPath.section == 0) || (indexPath.section == 1)){
//        cell.backgroundColor = [UIColor colorWithRed:108.0/255.0 green:166.0/255.0 blue:205.0/255.0 alpha:1.0];
//    }
//}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView {
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{                                               // any offset changes
//    //logic here
//    [chat_table visibleCells];
////    NSArray *paths = [chat_table indexPathsForVisibleRows];
////    NSLog(@"chat_table paths are %@",paths);
////    NSIndexPath *indexpath = (NSIndexPath*)[paths lastObject]; 
////    if (indexpath.section == 1){
//    float scrollViewHeight = scrollView.frame.size.height;
//    float scrollContentSizeHeight = scrollView.contentSize.height;
//    float scrollOffset = scrollView.contentOffset.y;
//    
//    if (scrollOffset == 0)
//    {
//        // then we are at the top
//    }
//    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
//    {
//        // then we are at the end
////        if ([self.array count]> oldCount) {
////            oldCount = [self.array count];
//            loadMore ++;
////            dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
////            dispatch_barrier_async(queue, ^{
//                [self loadxmlparsing];
////                dispatch_barrier_async(dispatch_get_main_queue(), ^{
////                    [chat_table reloadData];
////                });
////            });
////        dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
////        dispatch_barrier_async(queue, ^{
//////            [self loadxmlparsing];
////            dispatch_barrier_async(dispatch_get_main_queue(), ^{
////                [chat_table reloadData];
////            });
////        });
////            dispatch_release(queue);
//            NSLog(@"loadMore happening, loadMore is %d",loadMore);
////        }
////        else [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }
//}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
//            if (!isSearchOn)
                [self getData];
//            else
//                [self getDataSearch];
        }
    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) {
//        // we are at the end
//            loadMore++;
////            [self loadxmlparsing];
//    }
//}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    CGPoint vel = [scrollView.panGestureRecognizer velocityInView:scrollView.superview];
//    if (vel.y < 0)
//        [self openView];
//    else
//        [self closeView];
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [Flurry logEvent:@"User page from Comments list"];
//    if (indexPath.section == 0){
//    ProfileViewController *pvc = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
//    
//    NSString *userId = [[self.array objectAtIndex:indexPath.row] objectForKey:@"userId"];
//    NSString *nameTemp = [[self.array objectAtIndex:indexPath.row] objectForKey:@"username"];
//    NSString *name = [nameTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
////    UIImage *userPhoto = [[self.array objectAtIndex:indexPath.row] objectForKey:@"commentImage"];
//    pvc.backButtonString=@"comments";
//
//    pvc.userName = name;
////    pvc.isDetailsinfoForuser=TRUE;
//    pvc.userId = userId;
//    
//    [self.navigationController pushViewController:pvc animated:YES];
    [Flurry logEvent:@"LikeComment"];
//    UIButton *btnPressLike = (UIButton*)sender;
    NSDictionary *dictionary=[self.array objectAtIndex:indexPath.row];
    
    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && commentId == %@",userId,[dictionary objectForKey:@"id" ]];
    [self.isLikeCommentTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        if (items.count) {
            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
            [dictionary setValue:likesCount forKey:@"likes"];
            
            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
            [self.commentTable update:item completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.isLikeCommentTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.chat_table reloadData];
        }
        else {
            NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
            [dictionary setValue:likesCount forKey:@"likes"];
            
            NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
            [self.commentTable update:item completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
            NSDictionary *item1 =@{@"commentId" : [dictionary objectForKey:@"id" ], @"userId": userId};
            
            [self.isLikeCommentTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
            [self.chat_table reloadData];
        }
    }];
   [ tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.chat_table reloadData];

//    }
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if (self.array.count > indexPath.row ) {
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];

        if ([userId isEqualToString:[self.array[indexPath.row] objectForKey:@"userId"]] ){
        
        
//        NSString *me = [defaults objectForKey:@"me"];
//        NSString *userId = [[self.array objectAtIndex:indexPath.row] objectForKey:@"userId"];

            NSLog(@"delete allowed");
//        if ([userId isEqualToString:me] || myPhotoBook){
            return YES;
        }
        else {
            return NO;
        }
    }
    else return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates]; 
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Flurry logEvent:@"Delete Comment"];
        //add code here for when you hit delete
        
//        NSString *commentId=[[self.array objectAtIndex:indexPath.row] objectForKey:@"id"];
//        NSString *strcommentId=[commentId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        NSString *token = [defaults objectForKey:@"booklyAccessToken"];
//        
//        NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=deleteComment&commentId=%@&authtoken=%@",strcommentId,token];
//        
//        NSLog(@"final url is %@",urlString1);
//        
//        NSURL *url = [[NSURL alloc]initWithString:urlString1];
//        NSLog(@"url is%@",url);
//        NSData *Data = [NSData dataWithContentsOfURL:url];
//        Data=nil;
//        url=nil;
        
        
       
        NSString *string = [[self.array objectAtIndex:indexPath.row] objectForKey:@"id" ];
        [self.commentTable deleteWithId:string completion:^(NSDictionary *item, NSError *error) {
            [self logErrorIfNotNil:error];
        }];
        NSDictionary *item =@{@"commentId" :string};
        [self.isLikeCommentTable delete:item completion:^(NSDictionary *item, NSError *error) {
            [self logErrorIfNotNil:error];
        }];
        NSString *string1 = [NSString stringWithFormat:@"%d",self.array.count-1 ];
        NSDictionary *item1 =@{@"id" : self.postId, @"replies": string1};
        [self.table update:item1 completion:^(NSDictionary *item, NSError *error) {
            [self logErrorIfNotNil:error];
        }];
        [self.array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
    [tableView reloadData];
}

// post comment to parse server.
//-(void)postComment
//{
////    iscomment=TRUE;
//    
//    [_txtChat resignFirstResponder];
//   [Flurry logEvent:@"Comment: Post"];
////    NSString *id1=[self.dicUserData objectForKey:@"id"];
////    
////    NSString *strid= [id1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    
////    NSString *tagid=[self.dicUserData objectForKey:@"tagId"];
////    NSString *strtagid=[tagid stringByReplacingOccurrencesOfString:@"\n" withString:@""];
////    NSString *randomNumber=@"arc4random()";
////    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////    NSString *token = [defaults objectForKey:@"booklyAccessToken"];
////    NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=postComment&mediaId=%@&tagId=%@&comment=%@&authtoken=%@&rand=%@",strid,_tagId,[txtChat.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],token,randomNumber];
//    
//  //  http://m.omentos.com/backend/api.php?method=postComment&mediaId=78&tagId=32&comment=Nice!!&auth token=//f7177163c833dff4b38fc8d2872f1ec6_4fd081e00cdb0U2FyYXZhbmFuVVNFUg==4fd081e00d19a
//    
//    
////    NSLog(@"final url is %@",urlString1);
////    
////    NSURL *url = [[NSURL alloc]initWithString:urlString1];
////    NSLog(@"url is%@",url);
////    NSData *Data = [NSData dataWithContentsOfURL:url];
////    url=nil;
//    
////    if (!Data) {
//////        downloadBusy = NO;
////        NSLog(@" No Internet Connection");
////        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
////
////        return;
////    }
////    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
////    self.array = nil;
////    self.arrayImages = nil;
////    arrayImages = [[NSMutableArray alloc] init ];
////    array = [[NSMutableArray alloc] init ];
////    loadMore=1;
////    [self updateData];
//    
//    [self.array insertObject:_txtChat.text atIndex:0];
//    [self.chat_table reloadData];
//}
- (void) getData {
    NSLog(@"getting data...");
//    NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    //    NSString *word1 = [defaults objectForKey:@"filterWord1"];
    //    NSString *word2 = [defaults objectForKey:@"filterWord2"];
    //    NSString *word3 = [defaults objectForKey:@"filterWord3"];
    
    NSPredicate *predicate;
    //    if (![defaults boolForKey:@"filter"])
    predicate = [NSPredicate predicateWithFormat:@"postId == %@ ",self.postId];
    //    else {
    //
    //        predicate = [NSPredicate predicateWithFormat:@"((text contains[cd] %@ || text contains[cd] %@ || text contains[cd] %@) && isPrivate == false)|| userId == %@",word1,word2,word3,userId];
    //    }
    
    MSQuery *query = [self.commentTable queryWithPredicate:predicate];
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
            [self.chat_table reloadData];
        }
    }];
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
    
    UIColor *color;
    NSString *colorString = [defaults objectForKey:@"color"];
    if (!colorString){
        color = [self pastelColorCode:[UIColor whiteColor]];
    color = [self colorCode];

        colorString = [self hexStringForColor:color];
        NSLog(@"color is %@",colorString);
        [defaults setObject:colorString forKey:@"color"];
    }
     NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
    NSLog(@"inserting into commentTable userId = %@, postId = %@, reply = %@, color = %@",userId,postId,_txtChat.text, colorString);

    NSDictionary *item = @{@"postId" : self.postId, @"userId" : userId,@"reply" : _txtChat.text, @"color" :colorString,@"likes" :@"0"};
    
    
//    NSDictionary *item = @{@"userId" : userId,@"text" : txtChat.text, @"likes" :@"0",@"replies" :@"0",@"flags" : @"0", @"isPrivate":[NSNumber numberWithBool:isPrivateOn]};

    [self.commentTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [self logErrorIfNotNil:error];
        } else {
            NSString *string = [NSString stringWithFormat:@"%d",self.array.count+1 ];
            NSDictionary *item =@{@"id" : self.postId, @"replies": string};
            [self.table update:item completion:^(NSDictionary *item, NSError *error) {
                [self logErrorIfNotNil:error];
            }];
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
// retrieving comments from parse server and load it to tableview by reloading tableview.
-(void)retrieveComments
{
    NSLog(@"retrieve data");
}
- (IBAction)likeButtonAction:(id)sender {
 
        [Flurry logEvent:@"LikeComment"];
        UIButton *btnPressLike = (UIButton*)sender;
        NSDictionary *dictionary=[self.array objectAtIndex:btnPressLike.tag];
        
        NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@  && commentId == %@",userId,[dictionary objectForKey:@"id" ]];
        [self.isLikeCommentTable readWithPredicate:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            if (items.count) {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]-1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
                [self.commentTable update:item completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.isLikeCommentTable deleteWithId:[items[0] objectForKey:@"id"]completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.chat_table reloadData];
            }
            else {
                NSString *likesCount = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"likes"] integerValue]+1 ];
                [dictionary setValue:likesCount forKey:@"likes"];
                
                NSDictionary *item =@{@"id" : [dictionary objectForKey:@"id" ], @"likes": likesCount};
                [self.commentTable update:item completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                NSString *userId = [SSKeychain passwordForService:@"com.anonogram.guruhubb" account:@"user"];
                NSDictionary *item1 =@{@"commentId" : [dictionary objectForKey:@"id" ], @"userId": userId};
                
                [self.isLikeCommentTable insert:item1 completion:^(NSDictionary *item, NSError *error) {
                    [self logErrorIfNotNil:error];
                }];
                [self.chat_table reloadData];
            }
        }];
    
}

//- (void) getCommentImage: (NSMutableDictionary*) dic12
//{
//    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
//    [NSURLCache setSharedURLCache:sharedCache];
//    @autoreleasepool {
//        if (dic12.count==0)return;
//    [self.array addObject:dic12];
//    AppRecord *app = [[AppRecord alloc] init];
//    [self.arrayImages addObject:app];
//    NSString *struseriamge=[dic12 objectForKey:@"photo"];
//    NSString *stringWithoutSpacesUserImage = [struseriamge stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    app.appURLString=stringWithoutSpacesUserImage;
//   
//    app.userId=[dic12 objectForKey:@"userId"];
//    UIImage *commentImage=[imageCache imageFromDiskCacheForKey:app.userId];
////    SDImageCache* imageCache = [SDImageCache.alloc initWithNamespace:@"Bookly"];
////    app.appIcon=[imageCache imageFromDiskCacheForKey:app.userId];
//    NSLog(@"Retrieving app.appIcon is %@", app.appIcon);
//    if (commentImage == NULL){
//        
//        dispatch_queue_t q7 = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
//        dispatch_barrier_async( q7, ^{
//            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:app.appURLString]];
//            if ( data == nil ){
//                imageCounter++;
//                dispatch_barrier_async(dispatch_get_main_queue(), ^{
//                    [chat_table reloadData];
//                });
//                return;
//            }
//            [imageCache storeImage:[UIImage imageWithData:data] forKey:app.userId];//namespace file
//
//            dispatch_barrier_async(dispatch_get_main_queue(), ^{
//////                NSLog (@"before:imagesize of followers is %d", [data length]);
//////                app.appIcon = [UIImage imageWithData:data];
//////                SDImageCache* imageCache = [SDImageCache.alloc initWithNamespace:@"Bookly"];
////                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                imageCounter ++;
//                if ((imageCounter%kMaximumNumberToParse==0) ||  (imageCounter == array.count) /*|| (imageCounter%12==0)*/){
//               
//                [chat_table reloadData];
//                }
//            });
//        });
//        //   //   dispatch_release(q7);
//    }
//    else {
//        imageCounter++;
//        if ((imageCounter%kMaximumNumberToParse==0) ||  (imageCounter == array.count)/*|| (imageCounter%12==0)*/)
//            [chat_table reloadData];
//    }
//
////        dispatch_barrier_async(dispatch_get_main_queue(), ^{
//////            app.appIcon = [self reSize:app.appIcon size:CGSizeMake(35,35)];
//////            NSData *imageDataMed = UIImageJPEGRepresentation(app.appIcon, 0.85f);
//////            NSLog (@"after:imagesize of followers is %d", [imageDataMed length]);
//////            app.appIcon = [UIImage imageWithData:imageDataMed];
////            
//////            NSLog (@"before:imagesize of commentPhoto is %d", [data length]);
//////            NSData *imageDataMed = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.0f);
//////            app.appIcon = [UIImage imageWithData:imageDataMed];
//////            NSLog (@"after:imagesize of commentPhoto is %d", [imageDataMed length]);
////////            app.appIcon = [UIImage imageWithData:data];
////////            NSLog(@"app.appIcon is %@",app.appIcon);
////            
//////            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
////            [chat_table reloadData];
////        });
////        [data release];
////        data=nil;
//        
//        
////    [imageCache release];
//    app = nil;
//    }
//    [sharedCache removeAllCachedResponses];
//    
//
//}

- (UIImage *)reSize:(UIImage *) image size:(CGSize) size {
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
    
}
//-(IBAction)editCellAction:(id)sender
//{
//    
//    [txtChat resignFirstResponder];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.chat_table setFrame:CGRectMake(0, 44, 320, screenSpecificSetting(460, 372))];
//        [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
//    }];
//    
//    // check if comment is nil or not.
//    if(![txtChat.text isEqualToString:@""])
//        [self postComment];
//    txtChat.text = @"";
//
//}

#pragma mark - textfield delegated methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//            // changing frame of tableview and toolbar when textfield resign.
    NSLog(@"resign first responder");
            [textField resignFirstResponder];
            [UIView animateWithDuration:0.2 animations:^{

                [self.chat_table setFrame:CGRectMake(0, 64, 320, screenSpecificSetting(460, 372))];
                [_textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
                }];
    
//    [self.chat_table setFrame:CGRectMake(0, 44, 320, screenSpecificSetting(460, 372))];
//    [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460, 372), 320, 44)];
//}];

            // check if comment is nil or not.
            if(![_txtChat.text isEqualToString:@""])
                [self postComment];
            
            // make comment nil now.
           _txtChat.text = @"";

            return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"begin editing");
    
//    [textField becomeFirstResponder];
    // changing frame of tableview and toolbar when textfield begin editing.
    [UIView animateWithDuration:0.2 animations:^{
        [self.chat_table setFrame:CGRectMake(0, 64, 320, screenSpecificSetting(411-209, 323-209))];
        [_textToolBar setFrame:CGRectMake(0, screenSpecificSetting(200+64, 112+64), 320, 44)];
//        [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(200, 112), 320, 44)];

        }];
    [_inputAccessoryView removeFromSuperview];
    [self createInputAccessoryView];
    [textField setInputAccessoryView:_inputAccessoryView];
//    txtChat=textField;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 120) ? NO : YES;
}



-(void)createInputAccessoryView {
    
    _inputAccessoryView = [[UIToolbar alloc] init];
//    [_inputAccessoryView sizeToFit];
//    _inputAccessoryView.barTintColor=[UIColor lightGrayColor];

    _inputAccessoryView.frame = CGRectMake(0, screenSpecificSetting(244, 156), 320, 44);
    

    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(cancelKeyboard)];
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self action:@selector(doneKeyboard)];
    
    NSArray *items = [NSArray arrayWithObjects:/*fontItem,*/removeItem,flexItem,doneItem, nil];
    [_inputAccessoryView setItems:items animated:YES];
    [_txtChat addSubview:_inputAccessoryView];
}

-(void)doneKeyboard{
    [_txtChat resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        [self.chat_table setFrame:CGRectMake(0, 64, 320, screenSpecificSetting(460, 372))];
        [_textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
    }];
    if(![_txtChat.text isEqualToString:@""])
        [self postComment];
    
    // make comment nil now.
    _txtChat.text = @"";

}
-(void)cancelKeyboard{
    [_txtChat resignFirstResponder];
    _txtChat.text=@"";
    [UIView animateWithDuration:0.2 animations:^{
        [self.chat_table setFrame:CGRectMake(0, 64, 320, screenSpecificSetting(460, 372))];
        [_textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
    }];
 }



@end
