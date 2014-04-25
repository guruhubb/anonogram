//
//  ViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//

#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)

#import "ViewController.h"
#import "SettingVC.h"
#import "Flurry.h"

@interface ViewController (){
    NSUserDefaults *defaults;
    UITextView        *txtChat;
//    UISearchBar *searchBar;
    UIToolbar *_inputAccessoryView;
    NSInteger currentIndex;

}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
	// Create the data model
    _pageTitles = [NSMutableArray arrayWithObjects:@"myAnonograms", @"Favorites", @"Private", @"ANONOGRAM",@"Popular",@"#Event",@"@WorkPlace", nil];
//    [@"myAnonograms", @"Favorites", @"Private", @"ANONOGRAM",@"Popular",@"#Event",@"@WorkPlace"];
//    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:3];
//    startingViewController.pageTitles=_pageTitles;
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSLog(@"showSurvey is %d and rateDone is %d",[defaults boolForKey:@"showSurvey"],[defaults boolForKey:@"rateDone"]);
    if ([defaults boolForKey:@"showSurvey"]&&![defaults boolForKey:@"rateDone"])
        [self performSelector:@selector(showSurvey) withObject:nil afterDelay:0.1];
    defaults = [NSUserDefaults standardUserDefaults];
    txtChat = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, screenSpecificSetting(290, 202))];
    txtChat.delegate=self;
    txtChat.hidden=YES;
    txtChat.font=[UIFont systemFontOfSize:16];
    txtChat.text=@"placeholder";
    txtChat.textColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(285, screenSpecificSetting(215, 127), 30, 30)];
    label.textColor=[UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text= @"140";
    label.tag =100;
    [txtChat addSubview:label];
    [self createInputAccessoryView];
    [self.view addSubview:txtChat];
//    if (currentIndex==5 || currentIndex == 6){
//        searchBar.userInteractionEnabled=YES;
//        _searchButton.hidden=NO;
//    }
//    else {
//        _searchButton.hidden=YES;
//        searchBar.userInteractionEnabled=NO;
//    }
    
//    [searchBar setFrame:CGRectMake(0, screenSpecificSetting(200+64+44, 114+64+44), 320, 44)];
//    searchBar.delegate=self;
    _searchBarButton.hidden=YES;
//    [self.view addSubview:searchBar];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//    if (currentIndex==5 || currentIndex == 6)
//        searchBar.userInteractionEnabled=YES;
//    else
//        searchBar.userInteractionEnabled=NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)startWalkthrough:(id)sender {
//    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
//    NSArray *viewControllers = @[startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
//}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{

    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
//    pageContentViewController.imageFile = self.pageImages[index];
//    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIBarButtonItem *barButton1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_136_cogwheel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettings)];
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_020_home.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goHome)];
    barButton1.tintColor=[UIColor whiteColor];
    barButton2.tintColor=[UIColor whiteColor];
   
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
//    if (index==0)
//        self.navigationItem.title= @"ANONOGRAM";
//    else
        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[index]];
    if (index==3)
        self.navigationItem.leftBarButtonItem = barButton1;
    else
        self.navigationItem.leftBarButtonItem = barButton2;
    if (index==5 || index ==6)
        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    else
        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeAction:)];

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (void) goHome {

    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    PageContentViewController *targetPageViewController = [self viewControllerAtIndex:3 ];
    currentIndex = 3;
    NSArray *theViewControllers = nil;
    theViewControllers = [NSArray arrayWithObjects:targetPageViewController, nil];

    [self.pageViewController setViewControllers:theViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];  //NO animation is important to prevent false rendering of navigation buttons
    
    UIBarButtonItem *barButton1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_136_cogwheel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettings)];
    barButton1.tintColor=[UIColor whiteColor];
    self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[3]];
    self.navigationItem.leftBarButtonItem = barButton1;

        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeAction:)];
    
}
- (void) goToSettings{
    NSLog(@"settings");
    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    [self performSegueWithIdentifier: @"goToSettings" sender: self];
//    SettingVC *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
//    [self presentViewController:settings animated:YES completion:nil];
    
}
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
////    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
////    selectedPhotoIndex = cell.tag;
////    NSLog(@"index is %ld",(long)selectedPhotoIndex);
////    //    firstTime=YES;
////    
////    ALAsset *asset = self.assets[selectedPhotoIndex];
////    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
//    //    UIImageOrientation orientation = UIImageOrientationUp;
//    //    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
//    //    if (orientationValue != nil) {
//    //        orientation = [orientationValue intValue];
//    //    }
//    
////    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage] scale:[defaultRep scale] orientation:(UIImageOrientation)[defaultRep orientation]];
//    if ([[segue identifier] isEqualToString:@"goToSettings"])
//    {
//        SettingVC *vc = [segue destinationViewController];
////        vc.selectedImage=image;
//        //        NSLog(@"image size is %d",[UIImageJPEGRepresentation(image, 1.0) length]);
//    }
//}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIBarButtonItem *barButton1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_136_cogwheel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettings)];
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_020_home.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goHome)];
    barButton1.tintColor=[UIColor whiteColor];
    barButton2.tintColor=[UIColor whiteColor];
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
    self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[index]];
    if (index==3) self.navigationItem.leftBarButtonItem = barButton1;
    else self.navigationItem.leftBarButtonItem = barButton2;
    if (index==5 || index ==6)
        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    else
        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeAction:)];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 3;
//}

- (void) showSurvey {
    NSLog(@"showSurvey");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Like Anonogram? Please Rate" message:nil
                                                   delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Yes, I will rate now", @"Don't ask me again", nil];
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex is %d",buttonIndex);
    if (buttonIndex == 1) {
        [self rateApp];
    }
    else if (buttonIndex == 2 ){
        [defaults setBool:YES forKey:@"rateDone"];
        NSLog(@"rateDone is %d",[defaults boolForKey:@"rateDone"]);
    }
    else {
        [defaults setBool:NO forKey:@"showSurvey"];
        [defaults setInteger:0 forKey:@"counter" ];
        NSLog(@"showSurvey is %d and counter is %d",[defaults boolForKey:@"showSurvey"],[defaults integerForKey:@"counter"]);
    }
    [defaults synchronize];
}
- (void)rateApp {
    
    [Flurry logEvent:@"Rate App" ];
    [defaults setBool:YES forKey:@"rateDone"];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/850204569"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=866641636&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
}
- (IBAction)searchAction:(id)sender {
    _searchBarButton.hidden=NO;
    [self.view bringSubviewToFront:_searchBarButton];
    [_searchBarButton becomeFirstResponder];

}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSString *string  =[NSString stringWithFormat:@"%@", searchBar.text ];
    _pageTitles[currentIndex]= string;
     self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[currentIndex]];
//    searchBook=searchBar.text;
//    firstTimeSearch = YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.hidden=YES;
    if(![searchBar.text isEqualToString:@""]){
        NSString *string  =[NSString stringWithFormat:@"%@", searchBar.text ];
        _pageTitles[currentIndex]= string;
        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[currentIndex]];
//        [self openSearch];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [searchBar resignFirstResponder];
    searchBar.hidden=YES;
    
}


#pragma mark - textfield delegated methods

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    txtChat.text=@"placeholder";
//    return YES;
//}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    if ([textView.text isEqualToString:@"placeholder"]) {
        textView.text = @"";
//        textView.textColor = [UIColor blackColor]; //optional
//    }
    [textView becomeFirstResponder];

}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    if(![txtChat.text isEqualToString:@""])
        [self postComment];
    txtChat.text = @"";
    txtChat.hidden=YES;

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
    NSLog(@"textViewDidChange:");
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%d",140-textView.text.length];
    
}

-(void)createInputAccessoryView {
    
    _inputAccessoryView = [[UIToolbar alloc] init];
    _inputAccessoryView.barTintColor=[UIColor lightGrayColor];
    [_inputAccessoryView sizeToFit];
    
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
    [txtChat addSubview:_inputAccessoryView];
}

-(void)doneKeyboard{
    [txtChat resignFirstResponder];
    txtChat.hidden=YES;

//    [UIView animateWithDuration:0.2 animations:^{
//        [self.chat_table setFrame:CGRectMake(0, 44, 320, screenSpecificSetting(460, 372))];
//        [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
//    }];
    if(![txtChat.text isEqualToString:@""])
        [self postComment];
    
    // make comment nil now.
    txtChat.text = @"";

}
-(void)cancelKeyboard{
    [txtChat resignFirstResponder];
    txtChat.text=@"";
    txtChat.hidden=YES;
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.chat_table setFrame:CGRectMake(0, 44, 320, screenSpecificSetting(460, 372))];
//        [textToolBar setFrame:CGRectMake(0, screenSpecificSetting(460+64, 372+64), 320, 44)];
//    }];
 
}
- (IBAction)composeAction:(id)sender {
    NSLog(@"compose");
    txtChat.hidden=NO;
    [self.view bringSubviewToFront:txtChat];
    [txtChat becomeFirstResponder];
    
}
-(void)postComment
{
}
//-(void)postComment
//{
//    //    iscomment=TRUE;
//    
//    [txtChat resignFirstResponder];
//    [Flurry logEvent:@"Comment: Post"];
//    NSString *id1=[self.array objectForKey:@"id"];
//    
//    NSString *strid= [id1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    
//    NSString *tagid=[self.dicUserData objectForKey:@"tagId"];
//    NSString *strtagid=[tagid stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSString *randomNumber=@"arc4random()";
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *token = [defaults objectForKey:@"booklyAccessToken"];
//    NSString *urlString1=[NSString stringWithFormat:@"http://m.omentos.com/backend/api.php?method=postComment&mediaId=%@&tagId=%@&comment=%@&authtoken=%@&rand=%@",strid,strtagid,[txtChat.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],token,randomNumber];
//    
//    //  http://m.omentos.com/backend/api.php?method=postComment&mediaId=78&tagId=32&comment=Nice!!&auth token=//f7177163c833dff4b38fc8d2872f1ec6_4fd081e00cdb0U2FyYXZhbmFuVVNFUg==4fd081e00d19a
//    
//    
//    NSLog(@"final url is %@",urlString1);
//    
//    NSURL *url = [[NSURL alloc]initWithString:urlString1];
//    NSLog(@"url is%@",url);
//    NSData *Data = [NSData dataWithContentsOfURL:url];
//    url=nil;
//    
//    if (!Data) {
//        //        downloadBusy = NO;
//        NSLog(@" No Internet Connection");
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        
//        return;
//    }
//    //    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        //Set delegate
//    self.array = nil;
//    self.arrayImages = nil;
//    arrayImages = [[NSMutableArray alloc] init ];
//    array = [[NSMutableArray alloc] init ];
//    loadMore=1;
//    [self updateData];
//}
//-(void)updateData
//{
//    array = nil;
//    arrayImages=nil;
//    array = [[NSMutableArray alloc] init];
//    arrayImages = [[NSMutableArray alloc] init];
//    imageCounter=0;
//    [self loadxmlparsing];
//
//}
@end
