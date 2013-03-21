//
//  IconActionSheet.m
//
//
//  Created by Bernard Hommer Esquivel on 3/15/13.
//
//

#import "IconActionSheet.h"
#import "cocos2d.h"

@interface IconActionSheet (PrivateMethods)
-(void)animateView:(CGRect) rect;
-(UIImage*) makeaShot;
-(void)postTweetWithImage:(UIImage*)image;
-(void)postFacebookWithImage:(UIImage*)image;
-(void)postFacebookWithImageIOS6Below:(UIImage*)image;
@end


@implementation IconActionSheet

@synthesize blocks;
@synthesize collectionView;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

static NSString *cellIdentifier = @"ActionCell";

#pragma mark - init

+ (void)initialize
{
    if (self == [IconActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight];
        titleFont = kActionSheetTitleFont;
        buttonFont = kActionSheetButtonFont;
        
    }
}

+ (id)sheetWithTitle:(NSString *)title isLandscape:(NSInteger)orientation
{
    return [[IconActionSheet alloc] initWithTitle:title isLandscape:orientation];
}

- (id)initWithTitle:(NSString *)title isLandscape:(NSInteger)orientation
{
    CGRect frame = [[UIApplication sharedApplication] keyWindow].bounds;
    
    if ((self = [super initWithFrame:frame]))
    {
        switch (orientation)
        {
            case UIDeviceOrientationPortrait: break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(180));
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90));
                break;
            case UIDeviceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90));
                break;
            case UIDeviceOrientationUnknown:
                break;
            case UIDeviceOrientationFaceUp:
                break;
            case UIDeviceOrientationFaceDown:
                break;
        }
        
        self.blocks = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;
        
        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, frame.size.width-kActionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            [self addSubview:labelView];
            
            _height += size.height + 5;
        }
    }
    
    return self;
}

- (void)addIconWithTitle:(NSString *)title image:(UIImage*)image iASAction:(IASSocialAction) action atIndex:(NSInteger)index
{
    if (index >= 0)
    {
        [self.blocks insertObject:[NSArray arrayWithObjects:
                               [NSNumber numberWithInteger:action],
                               title,
                               image,
                               nil]
                      atIndex:index];
    }
    else
    {
        [self.blocks addObject:[NSArray arrayWithObjects:
                            [NSNumber numberWithInteger:action],
                            title,
                            image,
                            nil]];
    }
}

- (void)dismissView
{
    CGPoint center = self.center;
    
    //   UIDeviceOrientation orientation = [[CCDirectorIOS sharedDirector] deviceOrientation];
    
    //use if above is deprecated
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            center.y += self.bounds.size.height;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            center.y -= self.bounds.size.height;
            break;
        case UIDeviceOrientationLandscapeLeft:
            center.x -= _height + kActionSheetBounce + 100;
            break;
        case UIDeviceOrientationLandscapeRight:
            center.x += _height + kActionSheetBounce + 100;
             break;
        case UIDeviceOrientationUnknown: break;
        case UIDeviceOrientationFaceUp: break;
        case UIDeviceOrientationFaceDown: break;
    }
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.center = center;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)showInView:(UIView *)parentView
{
    
    CGRect kBGFrameTransformed;
    int hgt_phone;
    if(IS_IPHONE_5){
        hgt_phone = 568;
    }else{
        hgt_phone = 480;
    }
//   UIDeviceOrientation orientation = [[CCDirectorIOS sharedDirector] deviceOrientation];
  
    //use if above is deprecated
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            kBGFrameTransformed =  CGRectMake(0, 0, 320, hgt_phone);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            kBGFrameTransformed =  CGRectMake(320, hgt_phone, 320, hgt_phone);
            break;
        case UIDeviceOrientationLandscapeLeft:
            kBGFrameTransformed =  CGRectMake(0, 0, hgt_phone, 320);
            break;
        case UIDeviceOrientationLandscapeRight:
            kBGFrameTransformed =  CGRectMake(320, hgt_phone, hgt_phone, 320);
            break;
        case UIDeviceOrientationUnknown: break;
        case UIDeviceOrientationFaceUp: break;
        case UIDeviceOrientationFaceDown: break;
    }
    PSTCollectionViewFlowLayout *flowLayout = [[PSTCollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:PSTCollectionViewScrollDirectionHorizontal];
    int insetSideMargin;
    if(blocks.count < 5){
        insetSideMargin = (kBGFrameTransformed.size.width - (80 * blocks.count))/2;
    }else{
        insetSideMargin = 30;
    }
    NSLog(@"inset %d", insetSideMargin);
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, insetSideMargin - kLineSpacing, 0, 0)];
    [flowLayout setItemSize:CGSizeMake(kCellWidth, kCellHeight)];
    [flowLayout setMinimumInteritemSpacing:kItemSpacing];
    //Increased icon border to be close to apple implementation
    [flowLayout setMinimumLineSpacing:kLineSpacing];
    
    double columns = floor((kBGFrameTransformed.size.width-kActionSheetBorder*2) / (kCellWidth+kItemSpacing));
    double rows = ceil(blocks.count / columns);
    
    //Limit maximum rows to 3
    rows = rows > 1 ? 1 : rows;
    

    int flowheight = rows * (kCellHeight+kLineSpacing);
    
    self.collectionView = [[PSTCollectionView alloc] initWithFrame:CGRectMake(kActionSheetBorder+8, _height, kBGFrameTransformed.size.width-(kActionSheetBorder+8)*2,flowheight) collectionViewLayout:flowLayout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBounces:NO];
    [self.collectionView registerClass:[ActionCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView setPagingEnabled:YES];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.collectionView];
    
    _height += self.collectionView.frame.size.height + kActionSheetBorder;
    
    //Create Cancel button
    NSString *title = @"Cancel";
    
    UIImage *image = [UIImage imageNamed:@"action-black-button.png"];
    image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kActionSheetBorder, _height, kBGFrameTransformed.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
    button.titleLabel.font = buttonFont;
    //button.titleLabel.minimumFontSize = 6;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
    button.backgroundColor = [UIColor clearColor];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
    [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;
    
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    _height += button.frame.size.height + kActionSheetBorder;    
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:kBGFrameTransformed];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [self insertSubview:modalBackground atIndex:0];

    [parentView addSubview:self];
    
    [self animateView:kBGFrameTransformed];
}


- (void)animateView:(CGRect) rect
{
    CGRect frame = rect;
    __block CGPoint center;
    
    //   UIDeviceOrientation orientation = [[CCDirectorIOS sharedDirector] deviceOrientation];
    
    //use if above is deprecated
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            frame.origin.y = rect.size.height;
            frame.size.height = _height + kActionSheetBounce;
            self.frame = frame;
            center = self.center;
            center.y -= _height + kActionSheetBounce;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            frame.origin.y = -(rect.size.height);
            frame.size.height = -(_height + kActionSheetBounce);
            self.frame = frame;
            center = self.center;
            center.y += _height + kActionSheetBounce;
            break;
        case UIDeviceOrientationLandscapeLeft:
            frame.origin.x = -200;
            frame.size.height = 480;
            frame.size.width = _height + kActionSheetBounce;
            self.frame = frame;
            center = self.center;
            center.x += 200;
            break;
        case UIDeviceOrientationLandscapeRight:
            frame.origin.x = frame.origin.x + 200;
            frame.size.height = -(480);
            frame.size.width = -(_height + kActionSheetBounce);
            self.frame = frame;
            NSLog(@"frame %@", NSStringFromCGRect(self.frame));
            center = self.center;
            center.x -= 200;
            break;
        case UIDeviceOrientationUnknown: break;
        case UIDeviceOrientationFaceUp: break;
        case UIDeviceOrientationFaceDown: break;
    }
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         self.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              //   UIDeviceOrientation orientations = [[CCDirectorIOS sharedDirector] deviceOrientation];
                                              
                                              //use if above is deprecated
                                              UIDeviceOrientation orientations = [[UIDevice currentDevice] orientation];
                                              switch (orientations)
                                              {
                                                  case UIDeviceOrientationPortrait:
                                                      center.y += kActionSheetBounce;
                                                      break;
                                                  case UIDeviceOrientationPortraitUpsideDown:
                                                      center.y -= kActionSheetBounce;
                                                      break;
                                                  case UIDeviceOrientationLandscapeLeft:
                                                      center.x -= kActionSheetBounce;
                                                      break;
                                                  case UIDeviceOrientationLandscapeRight:
                                                      center.x += kActionSheetBounce;
                                                      break;
                                                  case UIDeviceOrientationUnknown: break;
                                                  case UIDeviceOrientationFaceUp: break;
                                                  case UIDeviceOrientationFaceDown: break;
                                              }

                                              self.center = center;
                                          } completion:nil];
                     }];

}

#pragma mark - Action

- (void)buttonClicked:(id)sender
{
    [self dismissView];
}

#pragma mark - View Collection Methods

-(NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return blocks.count;

}

-(PSTCollectionViewCell *) collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = [blocks objectAtIndex:indexPath.row];
    
    ActionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.label.text = [data objectAtIndex:1];
    cell.image.image = [data objectAtIndex:2];
    
    return cell;
}
-(void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [[self.blocks objectAtIndex:indexPath.row] objectAtIndex:0];
        UIImage *image = [self makeaShot];
        switch ([obj integerValue])
        {
            case IASSocialActionTwitter:
                NSLog(@"Twitter PRessed");
                if ([TWTweetComposeViewController canSendTweet])
                {
                    [self postTweetWithImage:image];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:@"Sorry"
                                              message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                              delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                }
                
                break;
            case IASSocialActionFacebook:
                NSLog(@"Facebook Pressed");
                if (![UIDevice de_isIOS6]) {
                    [self postFacebookWithImageIOS6Below:image];
                }else{
                    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
//
                        [self postFacebookWithImage:image];
                    }else{
                        UIAlertView *alertView = [[UIAlertView alloc]
                                                initWithTitle:@"Sorry"
                                                message:@"You can't post a timeline right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                                delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                        [alertView show];
                        [alertView release];
                    }
                }
                break;
            case IASSocialActionUnknown:
                NSLog(@"Unknown pressed");
                break;
        }

    [self dismissView];
}


#pragma mark Social Post

-(void)postTweetWithImage:(UIImage*)image
{
    TWTweetComposeViewController *tweetSheet =
    [[TWTweetComposeViewController alloc] init];
    [tweetSheet setInitialText:
     @"Screenshot testing"];
    [tweetSheet addImage:image];
    
    UIViewController* _tmpView = [[UIViewController alloc] initWithNibName:nil bundle:nil];
//    [[[CCDirector sharedDirector] openGLView] addSubview:_tmpView.view];
    //Use if deprecated
    [[[CCDirector sharedDirector] view] addSubview:_tmpView.view];
    
    [_tmpView presentModalViewController:tweetSheet animated:YES];
    // Setting a Completing Handler
    [tweetSheet setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        if (result == TWTweetComposeViewControllerResultDone) {
            // Composed
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Congratulations"
                                      message:@"Post has already been sent!"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            [_tmpView dismissModalViewControllerAnimated:YES];
        } else if (result == TWTweetComposeViewControllerResultCancelled) {
            // Cancelled
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Cancelled"
                                      message:@"Post has been cancelled!"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            [_tmpView dismissModalViewControllerAnimated:YES];
        }
    }];

}

-(void) postFacebookWithImage:(UIImage *)image
{
     SLComposeViewController *fbComposer =
    [SLComposeViewController
     composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    UIViewController* _tmpView = [[UIViewController alloc] initWithNibName:nil bundle:nil];
//    [[[CCDirector sharedDirector] openGLView] addSubview:_tmpView.view];
    
    //Use if above is deprecated
    [[[CCDirector sharedDirector] view] addSubview:_tmpView.view];
    
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result){
            
            [fbComposer dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Post has already been sent!"
                                                           otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                    break;
            }};
        
        [fbComposer addImage:image];
        [fbComposer setInitialText:@"Can you beat me?"];
//        [fbComposer addURL:[NSURL URLWithString:@"https://developers.facebook.com/ios"]];
        [fbComposer setCompletionHandler:completionHandler];
        [_tmpView presentModalViewController:fbComposer animated:YES];
        [fbComposer release];
   
}

-(void)postFacebookWithImageIOS6Below:(UIImage *)image
{
    DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] init];
    UIViewController* _tmpView = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    //    [[[CCDirector sharedDirector] openGLView] addSubview:_tmpView.view];
    
    //Use if above is deprecated
    [[[CCDirector sharedDirector] view] addSubview:_tmpView.view];
    
    [facebookViewComposer setInitialText:@"Can you beat me?"];
    _tmpView.modalPresentationStyle = UIModalPresentationCurrentContext;
    // optional
    [facebookViewComposer addImage:image];
    // and/or
    // optional
    //    [facebookViewComposer addURL:[NSURL URLWithString:@"http://applications.3d4medical.com/heart_pro.php"]];
    [facebookViewComposer setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
        switch (result) {
            case DEFacebookComposeViewControllerResultCancelled:
                NSLog(@"Facebook Result: Cancelled");
                break;
            case DEFacebookComposeViewControllerResultDone:
                NSLog(@"Posted....");
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"Post has already been sent!"
                                                       otherButtonTitles: nil];
                [alert show];
                [alert release];
                break;
        }
        
        [_tmpView dismissModalViewControllerAnimated:YES];
    }];
    [_tmpView presentModalViewController:facebookViewComposer animated:YES];
    [facebookViewComposer release];
}

-(void)postFacebookOpenGraph:(UIImage*)image
{
//    [FacebookUnityManager sharedManager] postUserFeed];
}

#pragma mark Screencapture

-(UIImage*) makeaShot
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
//    CCColorLayer *whitePage = [CCColorLayer layerWithColor:ccc4(255, 255, 255, 0) width:winSize.width height:winSize.height];
    //use if above is deprecated
    CCLayerColor *whitePage = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0) width:winSize.width height:winSize.height];
    whitePage.position = ccp(winSize.width/2, winSize.height/2);
    
    CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [rtx begin];
    [whitePage visit];
    [[[CCDirector sharedDirector] runningScene] visit];
    [rtx end];
    
//    return [rtx getUIImageFromBuffer];
    //use if above is deprecated
    return [rtx getUIImage];
}

@end