//
//  ActionCell.m
//
//
//  Created by Bernard Hommer Esquivel on 3/15/13.
//
//

#import "ActionCell.h"
#import "CustomCellBackground.h"

@implementation ActionCell

@synthesize image;
@synthesize label;

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, kCellWidth, kCellHeight)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, 70, 18)];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:11];
        [self addSubview:self.label];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
        [self addSubview:self.image];
        
        // change to our custom selected background view
        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

@end
