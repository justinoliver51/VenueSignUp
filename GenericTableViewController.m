//
//  GenericTableViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "GenericTableViewController.h"
#import "GenericTableViewCell.h"

@interface GenericTableViewController ()

@end

@implementation GenericTableViewController
{
    BOOL flashVenueBackground;
    BOOL didSelectVenue;
    
    GenericTableViewCell *selectedCell;
    NSString *selectedCellName;
    int flashCount;
}

@synthesize model = _model;
//@synthesize venuesGlowBackgroundImageView = _venuesGlowBackgroundImageView;

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
    
    selectedCell = nil;
    didSelectVenue = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_model count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GenericCell";
    GenericTableViewCell *cell;
    
    cell = (GenericTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set the venue's name
    cell.nameLabel.text = [_model objectAtIndex:indexPath.row];
    
    if((indexPath.row  == 0) && (!selectedCellName))
    {
        cell.nameLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        selectedCell = cell;
        selectedCellName = cell.nameLabel.text;
    }
    else if([selectedCellName isEqualToString:cell.nameLabel.text])
    {
        cell.nameLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        selectedCell = cell;
    }
    else
    {
        cell.nameLabel.textColor = [UIColor grayColor];
    }
    
    // No highlighting when a cell is clicked
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    GenericTableViewCell *cell = (GenericTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.nameLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    if([selectedCellName isEqualToString:cell.nameLabel.text] == NO)
    {
        selectedCell.nameLabel.textColor = [UIColor grayColor];
        selectedCell = cell;
        selectedCellName = cell.nameLabel.text;
    }
    
    didSelectVenue = YES;
}

@end

