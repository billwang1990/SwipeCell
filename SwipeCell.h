//
//  SwipeCell.h
//  BookFinder
//
//  Created by niko on 13-7-8.
//  Copyright (c) 2013年 billwang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	SwipeTypeNone,
	SwipeTypeShortLeft,
	SwipeTypeLongLeft
} SwipeType;

@interface SwipeCellImageSet : NSObject

@property (nonatomic, strong) UIImage *shortLeftSwipeImage;
@property (nonatomic, strong) UIImage *longLeftSwipeImage;

@end

NS_INLINE SwipeCellImageSet* SwipeCellImageSetMake(UIImage *shortLeftSwipeImage, UIImage *longLeftSwipeImage)
{
	SwipeCellImageSet *is = [[SwipeCellImageSet alloc] init];
	is.shortLeftSwipeImage = shortLeftSwipeImage;
	is.longLeftSwipeImage = longLeftSwipeImage;
	return is;
}


@interface SwipeCellColorSet : NSObject
@property (nonatomic, strong) UIColor *shortRightSwipeColor;
@property (nonatomic, strong) UIColor *longRightSwipeColor;
@property (nonatomic, strong) UIColor *shortLeftSwipeColor;
@property (nonatomic, strong) UIColor *longLeftSwipeColor;
@end


NS_INLINE SwipeCellColorSet* SwipeCellColorSetMake(UIColor *shortLeftSwipeColor, UIColor *longLeftSwipeColor)
{
	SwipeCellColorSet *cs = [[SwipeCellColorSet alloc] init];
	cs.shortLeftSwipeColor = shortLeftSwipeColor;
	cs.longLeftSwipeColor = longLeftSwipeColor;
	return cs;
}


@class  SwipeCell;
@protocol SwipeCellDelegate <NSObject>

- (void)swipeCell:(SwipeCell*)cell triggeredSwipeWithType:(SwipeType)swipeType;

@end

@interface SwipeCell : UITableViewCell

@property (nonatomic, weak) id<SwipeCellDelegate> delegate;

@property (nonatomic, strong) SwipeCellImageSet *imageSet;
@property (nonatomic, strong) SwipeCellColorSet *colorSet;


@end
