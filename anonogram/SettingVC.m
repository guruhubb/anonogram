//
//  SettingVC.m
//  Anonogram
//
//  Created by Saswata Basu on 3/21/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
//#define NSLog                       //
//#define NSLog(...)
#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)
#import "SettingVC.h"
#import "Flurry.h"
#import <Accounts/Accounts.h>
@implementation SettingVC



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];

    editArr = [[NSArray alloc]initWithObjects:
               @"Share Background Color",@"Share Watermark",
               @"Follow us on Instagram", @"Like us on Facebook",@"Follow us on Twitter",
               @"Rate App",@"Feedback",@"Restore Purchases",nil];
    [self.settingsTableView reloadData];
//    [defaults setBool:YES forKey:kFeature2];  //test

    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)rateApp {
    
    [Flurry logEvent:@"Rate App" ];
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/850204569"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=866641636&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];

}



- (void) sendMail
{
//     [Flurry logEvent:@"Settings - Customer Feedback"];
    MFMailComposeViewController *pickerMail = [[MFMailComposeViewController alloc] init];
    pickerMail.mailComposeDelegate = self;
    
    [pickerMail setSubject:@"Customer Feedback"];
    [pickerMail setToRecipients:[NSArray arrayWithObject:@"oneframeapp@yahoo.com"]];
    // Fill out the email body text
    NSString *emailBody = @"Hi, I have the following feedback on Anonogram...";
    [pickerMail setMessageBody:emailBody isHTML:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];

    [self presentViewController:pickerMail animated:YES completion:nil];
    pickerMail=nil;
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - tableView delegated methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case (0):
            return 2;
        case (1):
            return 3;
        case (2):
            return 3;
        default:
            return 1;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case (0):
            return @"  ";
        case (1):
            return @"  ";
        case (2):
            return @"  ";
        default:
            return @"  ";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"%ld and %ld",(long)indexPath.row,(long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] ;
    }

        if (indexPath.section == 0){

            if (indexPath.row==0) {
                [cell.textLabel setText:[editArr objectAtIndex:0]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(255, 0, 40, 40)];
                label.textColor = [UIColor lightGrayColor];
                label.font = [UIFont systemFontOfSize:14];
                label.tag = 101;
                [cell.contentView addSubview:label];
                if ([defaults boolForKey:@"white"])
                    label.text = @"Black";
                else
                    label.text = @"White";
                
            }

            if (indexPath.row==1) {
                [cell.textLabel setText:[editArr objectAtIndex:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                watermark = [[UISwitch alloc] initWithFrame:CGRectZero];
                [watermark addTarget: self action: @selector(watermarkAction) forControlEvents:UIControlEventValueChanged];
               
                cell.accessoryView = watermark;
                
                if ([defaults boolForKey:@"watermark"]) { //if 0 then watermark is ON
                    watermark.on = NO;
                }
                else
                    watermark.on = YES;
                
            }

        }
        if (indexPath.section == 1) {
            if(indexPath.row==0){
                [cell.textLabel setText:[editArr objectAtIndex:2]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==1){
                [cell.textLabel setText:[editArr objectAtIndex:3]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if (indexPath.row==2) {
                [cell.textLabel setText:[editArr objectAtIndex:4]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }
        if (indexPath.section == 2) {
            if(indexPath.row==0){
                [cell.textLabel setText:[editArr objectAtIndex:5]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==1){
                [cell.textLabel setText:[editArr objectAtIndex:6]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==2){
                [cell.textLabel setText:[editArr objectAtIndex:7]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            
        }

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row==0) {
            [self backgroundColorAction];
        }
    }
    if (indexPath.section == 2){
        if (indexPath.row==0) {
            [self rateApp];
        }
        if (indexPath.row==1) {
            [self sendMail];
        }
        if (indexPath.row == 2){
            [self restorePurchases];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row==0) {
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=oneframeapp"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }
        }
        if (indexPath.row==1) {
            NSURL *fbURL = [NSURL URLWithString:@"fb://profile/1440695526169043"];
            if ([[UIApplication sharedApplication] canOpenURL:fbURL]) {
                [[UIApplication sharedApplication] openURL:fbURL];
            }
        }
        if (indexPath.row==2) {
            NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=oneframeapp"];
            if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
                [[UIApplication sharedApplication] openURL:twitterURL];
            }
        }
    }
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)watermarkAction
{
    UIActionSheet *popupQuery;
    if (![defaults boolForKey:kFeature2]){  //if not purchased
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove Watermark",@"Buy for $0.99",nil];
        popupQuery.tag=3;
        [popupQuery showInView:self.view];
        watermark.on = YES;
    }
    else {  //if purchased
        if (watermark.on) {
//            watermark.on = NO;
            [defaults setBool:NO forKey:@"watermark"];
        }
        else {
//            watermark.on = YES;
            [defaults setBool:YES forKey:@"watermark"];
        }
    }
}
- (void)inAppBuyAction:(int)tag {
    [Flurry logEvent:@"InApp Watermark"];
 
    NSLog(@"buying...");
    
    [[MKStoreManager sharedManager] buyFeature:kFeature2
                                    onComplete:^(NSString* purchasedFeature,
                                                 NSData* purchasedReceipt,
                                                 NSArray* availableDownloads)
     {
         NSLog(@"Purchased: %@, available downloads is %@ watermark ", purchasedFeature, availableDownloads );
         
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Successful" message:nil
                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [defaults setBool:YES  forKey:kFeature2];
         [alert show];
         [self updateAppViewAndDefaults];

     }
                                   onCancelled:^
     {
         NSLog(@"User Cancelled Transaction");
     }];
    
}
- (void)restorePurchases {
    
        if( [defaults boolForKey:@"restorePurchases"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Restored" message:nil
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        [[MKStoreManager sharedManager]restorePreviousTransactionsOnComplete:^{
            NSLog(@"RESTORED PREVIOUS PURCHASE");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Successful" message:nil
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self updateAppViewAndDefaults];
            [defaults setBool:YES forKey:@"restorePurchases"];
        } onError:nil];
    
}
- (void) updateAppViewAndDefaults {

    
    if([MKStoreManager isFeaturePurchased:kFeature2])
        [defaults setBool:YES forKey:kFeature2];
    else
        [defaults setBool:NO forKey:kFeature2];
    
}




-(void)backgroundColorAction
{
    UIActionSheet *popupQuery;
    popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"White",@"Black",nil];
    popupQuery.tag=1;
    [popupQuery showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

        if (actionSheet.tag == 1){
            if (buttonIndex==0){
                [defaults setBool:NO forKey:@"white"];
            }
            else if (buttonIndex==1)[defaults setBool:YES forKey:@"white"];
        }
        else if (actionSheet.tag == 3) {
            if (buttonIndex==1){
                [self inAppBuyAction:actionSheet.tag];
            }
        }
    UILabel *label2 = (UILabel *) [self.view viewWithTag:101];
    [label2 removeFromSuperview];

    [self.settingsTableView reloadData];

}
- (void) getTwitterUsername {
    //get Twitter username and store it
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    
    {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
            ;
            [[NSUserDefaults standardUserDefaults] setValue:twitterAccount.username forKey:@"twitterHandle"];
            NSLog(@"twitterHandle is %@",twitterAccount.username);
        }}];
    
        //get the username later...
//        [textField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"twitterHandle"]];
    NSLog(@"twitterHandle is %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"twitterHandle"]);

}







@end
