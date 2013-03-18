//
//  ActionCell.h
//
//
//  Created by Bernard Hommer Esquivel on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import "PSTCollectionViewCell.h"

//ActionCell Constants

#define kCellWidth      70
#define kCellHeight     80

@interface ActionCell : PSTCollectionViewCell

@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UILabel *label;

@end
