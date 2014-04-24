//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "PageContentViewController.h"
#import "Cell.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];

//    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
//    self.titleLabel.text = self.titleText;
//
//}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createContentPages];
}

- (void) createContentPages
{
    NSMutableArray *pageStrings = [[NSMutableArray alloc] init];
    for (int i = 1; i < 4; i++)
    {
        NSString *contentString = [[NSString alloc]initWithFormat:@"Chapter %d \nThis is the page %d of content displayed using UIPageViewController in iOS 5.", i, i];
        [pageStrings addObject:contentString];
    }
    _pageContent = [[NSArray alloc] initWithArray:pageStrings];
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
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
