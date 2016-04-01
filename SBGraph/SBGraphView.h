//
//  SBGraphView.h
//  SBGraph
//
//  Created by Sam Bender on 3/31/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBGraphViewDelegate <NSObject>

- (CGFloat) yMin;
- (CGFloat) yMax;
// an ordered array of (NSNumber) floats
- (NSArray*) xIndicesForReferenceLines;
// an ordered array of (NSNumber) floats
- (NSArray*) yValuesForReferenceLines;

@end

@interface SBGraphView : UIView

//
//
//

// default true
@property (nonatomic) BOOL enableGraphBoundsLines;
// default 1.0
@property (nonatomic) CGFloat gridLinesWidth;

//
// Colors
//

@property (nonatomic, retain) UIColor *colorVerticalReferenceLines;
@property (nonatomic, retain) UIColor *colorHorizontalReferenceLines;
@property (nonatomic, retain) UIColor *colorGraphBoundsLines;

@end
