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

@interface PageContentViewController (){
    UITextField        *txtChat;
    NSUserDefaults *defaults;
    NSString *token;
    NSInteger loadMore;
    NSIndexPath *indexPathRow;
    UIRefreshControl *refreshControl;
}

@end

@implementation PageContentViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createContentPages];
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
    
//    cell.pageContent.text = [_pageContent objectAtIndex:indexPath.row];
//    cell.likeCount.text = [_likeCountArray objectAtIndex:indexPath.row];
//    cell.timestamp.text = [_timestampArray objectAtIndex:indexPath.row];
//    cell.share.tag = indexPath.row;
    NSLog(@"title is %@ and %@",self.navigationItem.title, self.navigationController.navigationItem.title);
//    cell.flag.imageView.image=nil;
    if (_pageIndex==0 || _pageIndex==2)
        [cell.flag setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal ];
    else
        [cell.flag setImage:[UIImage imageNamed:@"glyphicons_266_flag.png"] forState:UIControlStateNormal ];

    cell.flag.tag=indexPath.row;
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
        [Flurry logEvent:@"Comment: Delete"];
        //add code here for when you hit delete
        
        NSString *commentId=[[self.array objectAtIndex:indexPathRow.row] objectForKey:@"id"];

        NSString *strcommentId=[commentId stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=deleteComment&commentId=%@&authtoken=%@",strcommentId,token];
        
        NSLog(@"final url is %@",urlString1);
        
        NSURL *url = [[NSURL alloc]initWithString:urlString1];
        NSLog(@"url is%@",url);
        [NSData dataWithContentsOfURL:url];
        [self.array removeObjectAtIndex:1];
        [self.theTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPathRow, nil] withRowAnimation:UITableViewRowAnimationTop];
//    }
    [self.theTableView endUpdates];
}
- (IBAction)likeAction:(id)sender {
    
    UIButton *btnPressLike = (UIButton*)sender;
    int tagLikeBtn = btnPressLike.tag;
    //    cell.btnLike.tag = btnPressLike.tag;
    NSDictionary *dictionary=[self.array objectAtIndex:tagLikeBtn];
    BOOL isLikeValue = [[dictionary objectForKey:@"islike"] boolValue];  // 0 for UnLike, 1 for Like
    NSInteger count = [[dictionary objectForKey:@"like"] integerValue];
    if (!isLikeValue) {
//        [self facebookUpdateNewLikeActivity];
        [dictionary setValue:@"1" forKey:@"islike"];
        //        [cell.btnLike setBackgroundImage:[UIImage imageNamed:@"heart_like.png"] forState:UIControlStateNormal];
        count++;
        [dictionary setValue:[NSString stringWithFormat:@"%d", count] forKey:@"like"];
        //        [cell.btnLike setBackgroundImage:[UIImage imageNamed:@"heart_like.png"] forState:UIControlStateNormal];
        //  btnPressLike.userInteractionEnabled=FALSE;
        [self.theTableView reloadData];
        dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_barrier_async(queue, ^{
            
            
            NSDictionary *dicMedia=[self.array objectAtIndex:tagLikeBtn];
            NSString *strMediaId=[dicMedia objectForKey:@"id"];
            NSString *strWithOutSpaceMediaId = [strMediaId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSLog(@"media id is%@",strWithOutSpaceMediaId);
            
            NSString *strTagId=[dicMedia objectForKey:@"tagId"];
            NSString *strWithOutSpaceTagId = [strTagId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSLog(@"tag id IS %@",strWithOutSpaceTagId);
            
            NSString *urlString= [NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=postLike&mediaId=%@&tagId=%@&authtoken=%@",strWithOutSpaceMediaId,strWithOutSpaceTagId,token];
            
            
            NSLog(@"final url is %@",urlString);
            
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            NSLog(@"url is%@",url);
            //    IsLikeUnlikeTag=TRUE;
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
            url=nil;
            xmlParser=nil;
            //        [xmlParser setDelegate:self];
        });
        //   dispatch_release(queue);
    } else {
        [dictionary setValue:@"0" forKey:@"islike"];
        count--;
        [dictionary setValue:[NSString stringWithFormat:@"%d", count] forKey:@"like"];
        [self.theTableView reloadData];
        
        dispatch_queue_t queue = dispatch_queue_create("com.saswata.queue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_barrier_async(queue, ^{
            
            
            NSDictionary *dicMedia=[self.array objectAtIndex:tagLikeBtn];
            NSString *strMediaId=[dicMedia objectForKey:@"id"];
            NSString *strWithOutSpaceMediaId = [strMediaId stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSLog(@"media id is%@",strWithOutSpaceMediaId);
            NSString *urlString= [NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=disLike&mediaId=%@&authtoken=%@",strWithOutSpaceMediaId,token];
            
            
            NSLog(@"final url is %@",urlString);
            
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            NSLog(@"url is%@",url);
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
            //        [NSData dataWithContentsOfURL:url];
            url=nil;
            xmlParser=nil;
        });
        //   dispatch_release(queue);
    }
    

}

- (IBAction)flagAction:(id)sender {
//   UIButton *btn = (UIButton *)sender;
    
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
    NSLog(@"btn.tag is %d",btn.tag);
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(190,280 , 110, 30)];
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
            NSLog(@"flag as inappropriate");
        }
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

@end
