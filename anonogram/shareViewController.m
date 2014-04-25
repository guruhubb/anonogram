//
//  shareViewController.m
//  Anonogram
//
//  Created by Saswata Basu on 3/23/14.
//  Copyright (c) 2014 Saswata Basu. All rights reserved.
//
#define IS_TALL_SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define screenSpecificSetting(tallScreen, normal) ((IS_TALL_SCREEN) ? tallScreen : normal)


#import "shareViewController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

@interface shareViewController ()
@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;
@property(nonatomic, strong)  UIDocumentInteractionController* docController;
@end

@implementation shareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (!IS_TALL_SCREEN) {
//        self.shareView.frame = CGRectMake(0, 0, 320, 436);  // for 3.5 screen; remove autolayout
//    }
//    CGRect frame = CGRectMake(0, 0, 125, 40);
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    label.font = [UIFont systemFontOfSize:18.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    label.text = @"SHARE";
//    self.navigationItem.titleView = label;
	// Do any additional setup after loading the view.
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    self.image = [UIImage imageWithData:imageData];
//    NSLog(@"self.image is %@",self.image);
    [self setupCircles];

}

- (void) setupCircles {
    int radius = 30;
    self.imageView1.layer.cornerRadius = radius;
    self.imageView2.layer.cornerRadius = radius;
    self.imageView3.layer.cornerRadius = radius;
    self.imageView6.layer.cornerRadius = radius;
    self.imageView7.layer.cornerRadius = radius;
    self.imageView8.layer.cornerRadius = radius;
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated: NO completion: nil];
}




- (IBAction)postToFacebook:(id)sender {
    [Flurry logEvent:@"Facebook"];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:@"#anonogram from Anonogram app"];
        [controller addImage:self.image];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)postToTwitter:(id)sender {
    [Flurry logEvent:@"Twitter"];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {

        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"#anonogram from @anonogram"];
        [tweetSheet addImage:self.image];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (IBAction)postToInstagram:(UIButton *)sender  {

    [Flurry logEvent:@"Instagram"];
    NSString *imagePath;
        imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(self.image) writeToFile:imagePath atomically:YES];
    
    _docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    _docController.delegate=self;
    //key to open Instagram app - need to make sure docController is "strong"
    _docController.UTI = @"com.instagram.exclusivegram";
    _docController.annotation = [NSDictionary dictionaryWithObject:@"#anonogram from @anonogram" forKey:@"InstagramCaption"];
    [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
}

- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *) controller
{  _docController = nil;
}



- (IBAction)sendMail:(UIButton *)sender  
{
    [Flurry logEvent:@"Email"];
    NSLog(@"send mail");
    MFMailComposeViewController *pickerMail = [[MFMailComposeViewController alloc] init];
    pickerMail.mailComposeDelegate = self;
    
    [pickerMail setSubject:@"I'm sharing an Anonogram!"];
    
    // Fill out the email body text

    NSString *string= @"Check it out!  \n\n______\nFrom Anonogram app.  Download for FREE! \nhttp://itunes.apple.com/app/id866641636";
    
    NSString *emailBody = string;
    
    [pickerMail setMessageBody:emailBody isHTML:NO];
    
    // Attach an image to the email

    [pickerMail addAttachmentData:UIImagePNGRepresentation(self.image)  mimeType:@"image/png" fileName:@"attach"];
//     [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];

    [self presentViewController:pickerMail animated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [ self dismissViewControllerAnimated: YES completion:nil];
}



- (IBAction)showSMS:(UIButton *)sender  {
    [Flurry logEvent:@"SMS"];
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"From Anonogram app.  Download for FREE! \nhttp://itunes.apple.com/app/id866641636"];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController addAttachmentData:UIImagePNGRepresentation(self.image) typeIdentifier:@"public.data" filename:@"image.png"];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)whatsApp:(UIButton *)sender {
    [Flurry logEvent:@"Others"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
    NSURL *imageFileURL =[NSURL fileURLWithPath:getImagePath];
    NSLog(@"image %@",imageFileURL);
    [UIImagePNGRepresentation(self.image) writeToFile:getImagePath atomically:YES];

    self.documentationInteractionController.delegate = self;
//    self.documentationInteractionController.UTI = @"net.whatsapp.image";
    self.documentationInteractionController = [self setupControllerWithURL:imageFileURL usingDelegate:self];
    [self.documentationInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    self.documentationInteractionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    self.documentationInteractionController.delegate = interactionDelegate;
    return self.documentationInteractionController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
