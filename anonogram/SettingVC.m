//
//  SettingVC.m
//  One Frame
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
    CGRect frame = CGRectMake(0, 0, 125, 40);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"SETTINGS";
    self.navigationItem.titleView = label;
    editArr = [[NSArray alloc]initWithObjects:
               @"Photo Background Color",@"Auto-Save to Camera Roll",@"Add Watermark",@"Output Pixel format",
               @"Follow us on Instagram", @"Like us on Facebook",@"Follow us on Twitter",
               @"Rate App",@"Feedback",@"Restore Purchases",nil];
    [self.settingsTableView reloadData];
//    [defaults setBool:YES forKey:kFeature2];  //test

    
}



- (void)rateApp {
    
    [Flurry logEvent:@"Rate App" ];
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/850204569"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=866641636&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];


    return;
    // Initialize Product View Controller
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    // Configure View Controller  850204569
    [storeProductViewController setDelegate:self];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @"866641636"} completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
        } else {
            // Present Store Product View Controller
            [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];

            [self presentViewController:storeProductViewController animated:YES completion:nil];
        }
    }];

}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

}


- (void) sendMail
{
//     [Flurry logEvent:@"Settings - Customer Feedback"];
    MFMailComposeViewController *pickerMail = [[MFMailComposeViewController alloc] init];
    pickerMail.mailComposeDelegate = self;
    
    [pickerMail setSubject:@"Customer Feedback"];
    [pickerMail setToRecipients:[NSArray arrayWithObject:@"oneframeapp@yahoo.com"]];
    // Fill out the email body text
    NSString *emailBody = @"Hi, I have the following feedback on One Frame...";
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
            return 4;
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

//        [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (indexPath.section == 0){
//            if (indexPath.row==0) {
//                [cell.textLabel setText:[editArr objectAtIndex:0]];
//                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(255, 0, 40, 40)];
//                label.textColor = [UIColor lightGrayColor];
//                label.font = [UIFont systemFontOfSize:14];
//                label.tag = 100;
//                [cell.contentView addSubview:label];
//                if ([defaults boolForKey:@"fill"])
//                    label.text = @"Fit";
//                else
//                    label.text = @"Fill";
//            
//            }
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
//            if (indexPath.row==2) {
//                [cell.textLabel setText:[editArr objectAtIndex:2]];
//                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(255, 0, 40, 40)];
//                label.textColor = [UIColor lightGrayColor];
//                label.font = [UIFont systemFontOfSize:14];
//                label.tag = 102;
//                [cell.contentView addSubview:label];
//                if ([defaults boolForKey:@"filter"])
//                    label.text = @"No";
//                else
//                    label.text = @"Yes";
//                
//            }
            if (indexPath.row==1) {
                [cell.textLabel setText:[editArr objectAtIndex:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                savePhoto = [[UISwitch alloc] initWithFrame:CGRectZero];
                [savePhoto addTarget: self action: @selector(flip) forControlEvents:UIControlEventValueChanged];
                if ([defaults boolForKey:@"savePhoto"])  //if 0 then save is ON
                    savePhoto.on = NO;
                else
                    savePhoto.on = YES;
                cell.accessoryView = savePhoto;

            }
            if (indexPath.row==2) {
                [cell.textLabel setText:[editArr objectAtIndex:2]];
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
            else if(indexPath.row==3) {
                [cell.textLabel setText:[editArr objectAtIndex:3]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 100, 40)];
                label.textColor = [UIColor lightGrayColor];
                label.textAlignment=NSTextAlignmentRight;
                label.font = [UIFont systemFontOfSize:14];
                label.tag = 103;
                [cell.contentView addSubview:label];
                if ([defaults integerForKey:@"pixel"]==1)
                    label.text = @"640x640";
                else if ([defaults integerForKey:@"pixel"]==0) {
                    label.text = @"1280x1280";
                }
                else if ([defaults integerForKey:@"pixel"]==2){
                    label.text = @"2560x2560";
                }
            }
            
        }
        if (indexPath.section == 1) {
            if(indexPath.row==0){
                [cell.textLabel setText:[editArr objectAtIndex:4]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==1){
                [cell.textLabel setText:[editArr objectAtIndex:5]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if (indexPath.row==2) {
                [cell.textLabel setText:[editArr objectAtIndex:6]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }
        if (indexPath.section == 2) {
            if(indexPath.row==0){
                [cell.textLabel setText:[editArr objectAtIndex:7]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==1){
                [cell.textLabel setText:[editArr objectAtIndex:8]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if(indexPath.row==2){
                [cell.textLabel setText:[editArr objectAtIndex:9]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            
        }

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        if (indexPath.row==0) {
//            [self frameActionSettings];
//        }

        if (indexPath.row==0) {
            [self backgroundColorAction];
        }
//        if (indexPath.row==2) {
//            [self filterAction];
//        }
        if (indexPath.row==3){
            [self pixelAction];
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
- (void)flip {
    
    if (savePhoto.on) {  //if 1 then  save
        NSLog(@"save");
        [defaults setBool:NO forKey:@"savePhoto"];
    }
    else {   //if 0 then don't save
        NSLog(@"dont save");
        [defaults setBool:YES forKey:@"savePhoto"];
        [Flurry logEvent:@"NoSave"];
    }
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
//    if ([MKStoreManager isFeaturePurchased:kFeature0])
//        [defaults setBool:YES forKey:kFeature0];
//    else
//        [defaults setBool:NO forKey:kFeature0];
//    
//    if([MKStoreManager isFeaturePurchased:kFeature1])
//        [defaults setBool:YES forKey:kFeature1];
//    else
//        [defaults setBool:NO forKey:kFeature1];
    
    if([MKStoreManager isFeaturePurchased:kFeature2])
        [defaults setBool:YES forKey:kFeature2];
    else
        [defaults setBool:NO forKey:kFeature2];
    
}




-(void)frameActionSettings
{
    UIActionSheet *popupQuery;
    popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Fill Frame",@"Fit Frame",nil];
    popupQuery.tag=0;
    [popupQuery showInView:self.view];
}

-(void)backgroundColorAction
{
    UIActionSheet *popupQuery;
    popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"White",@"Black",nil];
    popupQuery.tag=1;
    [popupQuery showInView:self.view];
}
-(void)filterAction
{
    UIActionSheet *popupQuery;
    popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Auto Filter",@"No Filter",nil];
    popupQuery.tag=2;
    [popupQuery showInView:self.view];
}
-(void)pixelAction
{
    UIActionSheet *popupQuery;
    popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"640x640",@"1280x1280",@"2560x2560",nil];
    popupQuery.tag=4;
    [popupQuery showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (actionSheet.tag == 0) {
            if (buttonIndex==0){
                [defaults setBool:NO forKey:@"fill"];
            }
            else if (buttonIndex==1)[defaults setBool:YES forKey:@"fill"];
            
        }
        else if (actionSheet.tag == 1){
            if (buttonIndex==0){
                [defaults setBool:NO forKey:@"white"];
            }
            else if (buttonIndex==1)[defaults setBool:YES forKey:@"white"];
        }
        else if (actionSheet.tag == 2){
            if (buttonIndex==0){
                [defaults setBool:NO forKey:@"filter"];
            }
            else if (buttonIndex==1)[defaults setBool:YES forKey:@"filter"];
        }
        else if (actionSheet.tag == 3) {
            if (buttonIndex==1){
                [self inAppBuyAction:actionSheet.tag];
            }
        }
        else if (actionSheet.tag == 4) {
            if (buttonIndex==0){
                [defaults setInteger:1 forKey:@"pixel"];
            }
            else if (buttonIndex==1)
                [defaults setInteger:0 forKey:@"pixel"];
            else if (buttonIndex==2)
                [defaults setInteger:2 forKey:@"pixel"];
        }
    
    UILabel *label1 = (UILabel *) [self.view viewWithTag:100];
    UILabel *label2 = (UILabel *) [self.view viewWithTag:101];
    UILabel *label3 = (UILabel *) [self.view viewWithTag:102];
    UILabel *label4 = (UILabel *) [self.view viewWithTag:103];
    [label1 removeFromSuperview];
    [label2 removeFromSuperview];
    [label3 removeFromSuperview];
    [label4 removeFromSuperview];

    [self.settingsTableView reloadData];

}








@end
