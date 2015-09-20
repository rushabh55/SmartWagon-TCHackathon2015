//
//  ActivityTableViewController.m
//  SmartWagon
//
//  Created by Gosar, Rushabh on 9/20/15.
//  Copyright (c) 2015 Gosar, Rushabh. All rights reserved.
//

#import "ActivityTableViewController.h"

@interface ActivityTableViewController ()

@end

@implementation ActivityTableViewController

-(NSArray*)dictInit {
    NSMutableArray * dict = [[NSMutableArray alloc] init];
    [dict addObject:@"Work -> Home"];
    [dict addObject:@"Gas"];
    [dict addObject:@"Home -> Work"];
    
    self.timeSource = [[NSMutableArray alloc] init];
    [self.timeSource addObject: [NSString stringWithFormat:@"5:30pm -> 7:00pm Today"]];
     [self.timeSource addObject: [NSString stringWithFormat:@"Yesterday"]];
    [self.timeSource addObject: [NSString stringWithFormat:@"Long time ago"]];
    return dict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
    self.dataSource = [self dictInit];
    [self setNotification];
}

-(void) setNotification {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"We think your engine is overheating! Take care!";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *key = [[self dataSource] objectAtIndex:indexPath.row];
    
    // init the Cell if its null
    if ( cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        if ( !(indexPath.row & 1) )
        imgView.image = [UIImage imageNamed:@"work"];
        else
            imgView.image = [UIImage imageNamed:@"fuel"];
        cell.imageView.image = imgView.image;
        UIFont *myFont = [ UIFont fontWithName: @"Avenir-Roman" size: 27.0 ];
        cell.textLabel.font  = myFont;
        cell.detailTextLabel.font
        = [UIFont fontWithName:@"Avenir-Roman" size:21.0];
    }
    
    if (key != nil) {
        cell.textLabel.text = (NSString*)key;
        cell.detailTextLabel.text = [self.timeSource objectAtIndex:indexPath.row];
       
    }

    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}
- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
