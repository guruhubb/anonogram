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
#import "AppDelegate.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ViewController (){
    NSUserDefaults *defaults;
    UITextView        *txtChat;
//    UISearchBar *searchBar;
    UIToolbar *_inputAccessoryView;
    NSInteger currentIndex;
    NSMutableArray *buttonsArray;
    BOOL isPrivateOn;

}
@property (nonatomic)           NSInteger busyCount;
@property (nonatomic, strong)   MSTable *table;
@end

@implementation ViewController
@synthesize items;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.items = [[NSMutableArray alloc] init];
    self.busyCount = 0;
    self.table = [self.client tableWithName:@"anonogramTable"];
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
	// Create the data model
    _pageTitles = [NSMutableArray arrayWithObjects:@"myAnonograms",  @"Private", @"ANONOGRAM",@"Popular",@"Search", nil];
//    [@"myAnonograms", @"Favorites", @"Private", @"ANONOGRAM",@"Popular",@"#Event",@"@WorkPlace"];
//    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:3];
    startingViewController.pageTitles=_pageTitles;
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
//    txtChat.textColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(285, screenSpecificSetting(215, 127), 30, 30)];
    label.textColor=[UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text= @"140";
    label.tag =100;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320, 30)];
    label2.textColor=[UIColor lightGrayColor];
    label2.font = [UIFont systemFontOfSize:16];
    label2.text= @"Blah blah";
    label2.tag =105;
    [txtChat addSubview:label];
    [txtChat addSubview:label2];
    [self createInputAccessoryView];
    [self createInputAccessoryViewForSearch];
    [self.view addSubview:txtChat];
    [self.view addSubview:_inputAccessoryView];
    _inputAccessoryView.hidden=YES;
    _searchBarButton.hidden=YES;
    _searchBarButton.placeholder = @"Search #hashtag, @username";
    [_searchBarButton setKeyboardType:UIKeyboardTypeTwitter];
    [txtChat setKeyboardType:UIKeyboardTypeTwitter];

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
//    [self.view addSubview:searchBar];
    [self getUUID];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
    if (!(currentIndex==4)){
        _searchBarButton.hidden=YES;
        _inputAccessoryView.hidden=YES;
        [_searchBarButton resignFirstResponder];
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
    UIBarButtonItem *barButton3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_411_twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(TwitterSwitch)];
    barButton1.tintColor=[UIColor whiteColor];
    barButton2.tintColor=[UIColor whiteColor];
    barButton3.tintColor=[UIColor whiteColor];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    txtChat.hidden=YES;
    [_searchBarButton resignFirstResponder];
    [txtChat resignFirstResponder];
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
//    if (index==0)
//        self.navigationItem.title= @"ANONOGRAM";
//    else
        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[index]];
    if (index==2)
        self.navigationItem.leftBarButtonItem = barButton1;
    else if (index==1)
        self.navigationItem.leftBarButtonItem=barButton3;
    else
        self.navigationItem.leftBarButtonItem = barButton2;
    if (index==4)
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
    [Flurry logEvent:@"goHome"];

    [txtChat resignFirstResponder];
    txtChat.hidden=YES;
    PageContentViewController *targetPageViewController = [self viewControllerAtIndex:2 ];
    currentIndex = 2;
    NSArray *theViewControllers = nil;
    theViewControllers = [NSArray arrayWithObjects:targetPageViewController, nil];

    [self.pageViewController setViewControllers:theViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];  //NO animation is important to prevent false rendering of navigation buttons
    
    UIBarButtonItem *barButton1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_136_cogwheel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettings)];
    barButton1.tintColor=[UIColor whiteColor];
    self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[2]];
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
    UIBarButtonItem *barButton3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_411_twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(TwitterSwitch)];
    barButton3.tintColor=[UIColor whiteColor];

    barButton1.tintColor=[UIColor whiteColor];
    barButton2.tintColor=[UIColor whiteColor];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    txtChat.hidden=YES;
    [_searchBarButton resignFirstResponder];
    [txtChat resignFirstResponder];
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    currentIndex = index;
    self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[index]];
    if (index==2) self.navigationItem.leftBarButtonItem = barButton1;
    else if (index==1)
        self.navigationItem.leftBarButtonItem=barButton3;
    else self.navigationItem.leftBarButtonItem = barButton2;
    if (index==4)
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
    NSLog(@"buttonIndex is %ld",(long)buttonIndex);
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
        NSLog(@"showSurvey is %d and counter is %ld",[defaults boolForKey:@"showSurvey"],(long)[defaults integerForKey:@"counter"]);
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
    _inputAccessoryView.hidden=NO;
    [self.view bringSubviewToFront:_searchBarButton];
    [_searchBarButton becomeFirstResponder];
    

}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    if(![searchBar.text isEqualToString:@""]){
//
//    NSString *string  =[NSString stringWithFormat:@"%@", searchBar.text ];
//    _pageTitles[currentIndex]= string;
//     self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[currentIndex]];
//    }
//    _searchBarButton.hidden=YES;
//    _inputAccessoryView.hidden=YES;
//    [searchBar resignFirstResponder];
//
////    searchBook=searchBar.text;
////    firstTimeSearch = YES;
//}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
//    searchBar.hidden=YES;
//    _inputAccessoryView.hidden=YES;
//    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
//
//    if(!([[_searchBarButton.text stringByTrimmingCharactersInSet: set] length] == 0) ){
//        NSString *string  =[NSString stringWithFormat:@"%@", searchBar.text ];
//        _pageTitles[currentIndex]= string;
//        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[currentIndex]];
////        [self openSearch];
//    }
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
//{
//    [searchBar resignFirstResponder];
//    searchBar.hidden=YES;
//    _inputAccessoryView.hidden=YES;
//
//    
//}
- (void)searchBarCancel
{
    [_searchBarButton resignFirstResponder];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;

    
}
- (void)searchBarClicked
{
    [Flurry logEvent:@"Search"];

    [_searchBarButton resignFirstResponder];
    _searchBarButton.hidden=YES;
    _inputAccessoryView.hidden=YES;
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if(!([[_searchBarButton.text stringByTrimmingCharactersInSet: set] length] == 0) )
    {
          NSLog(@"_searchBarButton.text whitespace length again is %d",[[_searchBarButton.text stringByTrimmingCharactersInSet: set] length]);
        NSString *string  =[NSString stringWithFormat:@"%@", _searchBarButton.text ];
        _pageTitles[currentIndex]= string;
        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[currentIndex]];
        //        [self openSearch];
    }
    
}

#pragma mark - textfield delegated methods

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    txtChat.text=@"placeholder";
//    return YES;
//}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//     UILabel *label = (UILabel *)[self.view viewWithTag:105];
//    [label removeFromSuperview];
//    if ([textView.text isEqualToString:@"placeholder"]) {
        textView.text = @"";
//        textView.textColor = [UIColor blackColor]; //optional
//    }
    [textView becomeFirstResponder];

}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
//    if(![txtChat.text isEqualToString:@""])
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if(!([[txtChat.text stringByTrimmingCharactersInSet: set] length] == 0) )
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
//    NSLog(@"textViewDidChange:");
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
    [inputAccessoryView1 setItems:itemsView animated:YES];
    [txtChat addSubview:inputAccessoryView1];
}
-(void) addText {
    [Flurry logEvent:@"isPrivate Tapped"];

    txtChat.text = [NSString stringWithFormat:@"@IsPrivate %@",txtChat.text];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:105];
    label2.hidden=YES;
}
-(void)createInputAccessoryViewForSearch {
    
    _inputAccessoryView = [[UIToolbar alloc] init];
    _inputAccessoryView.barTintColor=[UIColor lightGrayColor];
    [_inputAccessoryView sizeToFit];
    
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
    [_inputAccessoryView setItems:itemsView animated:YES];
}
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

    

    NSString *hashString;  //find recurrence of #strings and space them apart in a string
    NSString *atString;  //find recurrence of @strings and space them apart in a string
    NSString * aString = [NSString stringWithString:txtChat.text];
    NSString * bString = [NSString stringWithString:txtChat.text];
    
    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:aString];
    [scanner scanUpToString:@"#" intoString:nil]; // Scan all characters before #
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"#" intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@" " intoString:&substring]) {
            // If the space immediately followed the #, this will be skipped
            [substrings addObject:substring];
        }
        [scanner scanUpToString:@"#" intoString:nil]; // Scan all characters before next #
    }
    for (NSString *string in substrings)
        hashString = [NSString stringWithFormat:@"%@ ",string];
    
    NSMutableArray *substrings2 = [NSMutableArray new];
    NSScanner *scanner2 = [NSScanner scannerWithString:bString];
    [scanner2 scanUpToString:@"#" intoString:nil]; // Scan all characters before #
    while(![scanner2 isAtEnd]) {
        NSString *substring2 = nil;
        [scanner2 scanString:@"#" intoString:nil]; // Scan the # character
        if([scanner2 scanUpToString:@" " intoString:&substring2]) {
            // If the space immediately followed the #, this will be skipped
            [substrings2 addObject:substring2];
        }
        [scanner2 scanUpToString:@"#" intoString:nil]; // Scan all characters before next #
    }
    for (NSString *string in substrings2)
        atString = [NSString stringWithFormat:@"%@ ",string];
    
    if ([txtChat.text rangeOfString:@"@isprivate " options:NSCaseInsensitiveSearch].length)
        isPrivateOn = YES;
    
    [txtChat.text stringByReplacingOccurrencesOfString:@"@isprivate" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [txtChat.text length])] ;
    
    
        
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
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 0) {
//        if (buttonIndex==0){
//            NSLog(@"delete");
//            [self deleteText];
//        }
//    }
//    if (actionSheet.tag == 1) {
//        if (buttonIndex==0){
//            NSLog(@"flag as inappropriate");
//        }
//    }
    if (actionSheet.tag == 2){
        if (buttonIndex!=actionSheet.numberOfButtons-1){
        [[NSUserDefaults standardUserDefaults] setValue:buttonsArray[buttonIndex] forKey:@"twitterHandle"];
        _pageTitles[1]= buttonsArray[buttonIndex];
        self.navigationItem.title= [NSString stringWithFormat:@"%@",_pageTitles[1]];
        }
        

    }
    //    [[self.view viewWithTag:1] removeFromSuperview];
}
@end
