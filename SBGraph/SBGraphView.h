//
//  SBGraphView.h
//  SBGraph
//
//  Created by Sam Bender on 3/31/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct
{
    // measured in points
    CGFloat left;
    CGFloat bottom;
    
    // I have not had a need to use these yet...
    // If you do, don't forget to modify calculateGraphDataBounds 
    CGFloat right;
    CGFloat top;
} SBGraphMargins;

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
// provide a custom string for the y value labels
// ex: add units or specify the number of decimals
- (void) label:(UILabel*)label forYValue:(CGFloat)yValue;
- (void) label:(UILabel*)label forXIndex:(CGFloat)yValue;

@end

@interface SBGraphView : UIView

//
// Primitive properties
//

// default YES
@property (nonatomic) BOOL enableGraphBoundsLines;
// default YES
@property (nonatomic) BOOL enableYAxisLabels;
// default YES
@property (nonatomic) BOOL enableXAxisLabels;
// default 1.0
@property (nonatomic) CGFloat gridLinesWidth;
// default 0.0
@property (nonatomic) CGFloat dataPointRadius;
// default: { left: 35, top: 0, bottom: 35, right: 0 }
@property (nonatomic) SBGraphMargins margins;

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
@property (nonatomic, retain) UIColor *colorTouchInputLine;
@property (nonatomic, retain) UIColor *colorLabelText;

@end
