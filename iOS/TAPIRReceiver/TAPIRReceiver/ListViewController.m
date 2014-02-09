//
//  ListViewController.m
//  TAPIRReceiver
//
//  Created by dilu on 2/9/14.
//  Copyright (c) 2014 dilu. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if(indexPath.row==0){
        CellIdentifier = @"Cell1";
    }else if(indexPath.row==1){
        CellIdentifier = @"Cell2";
    }else if(indexPath.row==2){
        CellIdentifier = @"Cell3";
    }else if(indexPath.row==3){
        CellIdentifier = @"Cell4";
    }else if(indexPath.row==4){
        CellIdentifier = @"Cell5";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HTMLViewController* vc = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"1"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/1.html"];
    }else if([segue.identifier isEqualToString:@"2"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/2.html"];
    }else if([segue.identifier isEqualToString:@"3"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/3.html"];
    }else if([segue.identifier isEqualToString:@"4"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/4.html"];
    }else if([segue.identifier isEqualToString:@"5"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/5.html"];
    }
}

@end
