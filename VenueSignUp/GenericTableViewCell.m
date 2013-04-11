//
//  GenericTableViewCell.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "GenericTableViewCell.h"

@implementation GenericTableViewCell

@synthesize nameLabel = _nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Set custom font
    [self.nameLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Bold" size: 14.0]];
}

@end
