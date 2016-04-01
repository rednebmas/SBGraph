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
// the y values for the graph
- (NSArray*) yValues;

@optional

// an ordered array of (NSNumber) floats
- (NSArray*) xIndicesForReferenceLines;
// an ordered array of (NSNumber) floats
- (NSArray*) yValuesForReferenceLines;

@end

@interface SBGraphView : UIView

//
// Primitive properties
//

// default YES
@property (nonatomic) BOOL enableGraphBoundsLines;
// default 1.0
@property (nonatomic) CGFloat gridLinesWidth;
// default 0.0
@property (nonatomic) CGFloat dataPointRadius;

//
//
//

@property (nonatomic, weak) id<SBGraphViewDelegate> delegate;

//
// Colors
//

@property (nonatomic, retain) UIColor *colorDataLine;
@property (nonatomic, retain) UIColor *colorDataPoints;
@property (nonatomic, retain) UIColor *colorVerticalReferenceLines;
@property (nonatomic, retain) UIColor *colorHorizontalReferenceLines;
@property (nonatomic, retain) UIColor *colorGraphBoundsLines;

@end
