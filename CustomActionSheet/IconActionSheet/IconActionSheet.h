//
//  IconActionSheet.h
//
//
//  Created by Bernard Hommer Esquivel on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "ActionCell.h"
#import "PSTCollectionView.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "DEFacebookComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIDevice+DEFacebookComposeViewController.h"



#ifndef IconActionSheet_h
#define IconActionSheet_h

// IconActionSheet constants

#define kActionSheetBounce         10
#define kActionSheetBorder         10
#define kActionSheetButtonHeight   45
#define kActionSheetTopMargin      30

#define kActionSheetTitleFont           [UIFont systemFontOfSize:18]
#define kActionSheetTitleTextColor      [UIColor whiteColor]
#define kActionSheetTitleShadowColor    [UIColor blackColor]
#define kActionSheetTitleShadowOffset   CGSizeMake(0, -1)

#define kActionSheetButtonFont          [UIFont boldSystemFontOfSize:20]
#define kActionSheetButtonTextColor     [UIColor whiteColor]
#define kActionSheetButtonShadowColor   [UIColor blackColor]
#define kActionSheetButtonShadowOffset  CGSizeMake(0, -1)

#define kActionSheetBackground              @"action-sheet-panel.png"
#define kActionSheetBackgroundCapHeight     30
#define kItemSpacing    10.f
#define kLineSpacing    25.f

#define kAnimationDuration          0.4

#define IS_IPHONE_5   ([[ UIScreen mainScreen ] bounds ].size.height > 480 )

#endif

typedef NS_ENUM(NSInteger, IASSocialAction) {
    IASSocialActionUnknown,
    IASSocialActionTwitter, //When Posting to Twitter
    IASSocialActionFacebook //Posting to Facebook
};

@interface IconActionSheet : UIView <PSTCollectionViewDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegateFlowLayout> {
@private
    CGFloat _height;
    CGFloat _width;
}

@property (nonatomic, retain) NSMutableArray *blocks;
@property (nonatomic, retain) PSTCollectionView *collectionView;

+ (id)sheetWithTitle:(NSString *)title isLandscape:(NSInteger)orientation;

- (id)initWithTitle:(NSString *)title isLandscape:(NSInteger)orientation;
- (void)addIconWithTitle:(NSString *)title image:(UIImage*)image iASAction:(IASSocialAction) action atIndex:(NSInteger)index;
- (void)showInView:(UIView *)view;
- (void)dismissView;


@end
