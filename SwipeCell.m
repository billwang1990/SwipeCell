//
//  SwipeCell.m
//  BookFinder
//
//  Created by niko on 13-7-8.
//  Copyright (c) 2013年 billwang@gmail.com. All rights reserved.
//

#import "SwipeCell.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat const kIconHorizontalPadding = 15;
static CGFloat const kDefaultIconSize = 40;
static CGFloat const kMaxBounceAmount = 8;

@interface SwipeCell ()<UIGestureRecognizerDelegate>

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGFloat dragStart;
@property (nonatomic) UIImageView *icon;
@property (nonatomic) CGFloat shortSwipeLength;
@property (nonatomic) SwipeType currentSwipe;

@end

@implementation SwipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self cellConfig];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self cellConfig];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.contentView.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.center.y);
    self.currentSwipe = SwipeTypeNone;
}

-(void)cellConfig
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!self.backgroundView)
	{
		self.backgroundView = [[UIView alloc] init];
        
		self.backgroundView.backgroundColor = [UIColor clearColor];
	}
    if(!self.icon)
    {
        self.icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDefaultIconSize, kDefaultIconSize)];
        [self.backgroundView addSubview:self.icon];
    }
    
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHappened:)];
    self.panGesture.delegate = self;
    
    self.shortSwipeLength = self.contentView.frame.size.width * 0.66;
    
    self.colorSet = [self defaultColorSet];
    self.imageSet =  SwipeCellImageSetMake([UIImage imageNamed:@"trash-empty"], [UIImage imageNamed:@"trash-empty"]);
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addGestureRecognizer:self.panGesture];

}

- (SwipeCellColorSet*)defaultColorSet
{
	return SwipeCellColorSetMake([UIColor lightGrayColor], MAIN_COLOR);
}

-(void)gestureHappened:(UIPanGestureRecognizer *)sender
{
    CGPoint trans = [sender translationInView:self];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
            self.dragStart = sender.view.center.x;
            
            break;
        case UIGestureRecognizerStateChanged:
            
            if (trans.x < 0) {
                
                self.contentView.center = CGPointMake(self.dragStart + trans.x, self.contentView.center.y);
                
                CGFloat diff = trans.x;
                
                if (diff >=  -(self.icon.frame.size.width + (kIconHorizontalPadding *2))) {
                    self.icon.image = self.imageSet.shortLeftSwipeImage;
					self.icon.center = CGPointMake(self.frame.size.width - ((self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentView.frame.size.height / 2);					self.icon.alpha = fabs(diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 3)));
                    self.currentSwipe = SwipeTypeNone;
                                
                    self.backgroundView.backgroundColor = self.colorSet.shortLeftSwipeColor;
                    
                }
                else
                {
                    self.backgroundView.backgroundColor = self.colorSet.longLeftSwipeColor;
                    self.icon.image = self.imageSet.longLeftSwipeImage;
                    self.currentSwipe = SwipeTypeShortLeft;
                    
                    self.icon.center = CGPointMake((self.contentView.frame.origin.x + self.contentView.frame.size.width) + ((self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentView.frame.size.height / 2);
                    
                    self.icon.alpha = 1;
                    
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.currentSwipe != SwipeTypeNone) {
                [self runSwipeAnimationForType:self.currentSwipe];
            }else
            {
                [self runBounceAnimationFromPoint:trans];
            }
            
            break;
            
        default:
            break;
    }
    
}

- (void)runSwipeAnimationForType:(SwipeType)type
{
    CGFloat newIconCenterX = 0;
    CGFloat newViewCenterX = 0;
    CGFloat iconAlpha = 1;
    
    self.icon.center = CGPointMake(self.contentView.center.x + (self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding, self.contentView.frame.size.height / 2);
    newIconCenterX = -((self.icon.frame.size.width / 2) + kIconHorizontalPadding);
    newViewCenterX = newIconCenterX - ((self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding);
    
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.icon.center = CGPointMake(newIconCenterX, self.contentView.frame.size.height /2);
        
        self.contentView.center = CGPointMake(newViewCenterX, self.contentView.center.y);
        self.icon.alpha = iconAlpha;
        
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)]) {
            [self.delegate swipeCell:self triggeredSwipeWithType:type];
            self.dragStart = CGFLOAT_MIN;
            
        }
    }];
}

- (void)runBounceAnimationFromPoint:(CGPoint)point
{
	CGFloat diff = point.x;
	CGFloat pct = diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 2));
	CGFloat bouncePoint = pct * kMaxBounceAmount;
	CGFloat bounceTime1 = 0.25;
	CGFloat bounceTime2 = 0.15;
	
	[UIView animateWithDuration:bounceTime1
					 animations:^{
						 self.contentView.center = CGPointMake(self.dragStart - bouncePoint, self.contentView.center.y);
						 self.icon.alpha = 0;
					 } completion:^(BOOL finished) {
						 [UIView animateWithDuration:bounceTime2
										  animations:^{
											  self.contentView.center = CGPointMake(self.dragStart, self.contentView.center.y);
										  } completion:^(BOOL finished) {
											  
										  }];
					 }];
}

#pragma mark - UIGestureRecongnizerDelegate methods

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
		return YES;
    
    CGPoint tranlation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
    
    return fabs(tranlation.y) < fabs(tranlation.x);
}

@end

@implementation SwipeCellImageSet
@end

@implementation SwipeCellColorSet

@end

