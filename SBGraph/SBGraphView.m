//
//  SBGraphView.m
//  SBGraph
//
//  Created by Sam Bender on 3/31/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "SBGraphView.h"
#import "SBLine.h"
#import "SBCoordinateMapper.h"

typedef struct {
    CGPoint *points;
    int size;
} CGPointArray;

@interface SBGraphView()

// The rect that the data will reside in, relative to this view
@property (nonatomic) CGRect graphDataBounds;
@property (nonatomic, retain) UIView *touchInputLine;
@property (nonatomic, retain) UIView *touchInputPoint;
@property (nonatomic, retain) UILabel *touchInputInfo;
@property (nonatomic, retain) SBCoordinateMapper *coordinateMapper;
@property (nonatomic, retain) NSArray *yValues;

@end

@implementation SBGraphView

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.coordinateMapper = [[SBCoordinateMapper alloc] init];
    
    // colors
    self.colorTouchInputLine = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    self.colorTouchInputPoint = [UIColor whiteColor];
    self.colorTouchInputInfo = [UIColor whiteColor];
    self.colorVerticalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorHorizontalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorGraphBoundsLines = [[UIColor whiteColor] colorWithAlphaComponent:.9];
    self.colorDataLine = [UIColor whiteColor];
    self.colorDataPoints = [UIColor whiteColor];
    self.colorLabelText = [UIColor whiteColor];
    
    // touch input line
    self.touchInputLine = [[UIView alloc] init];
    self.touchInputLine.hidden = YES;
    self.touchInputLine.backgroundColor = self.colorTouchInputLine;
    [self addSubview:self.touchInputLine];
    
    // touch input line point
    _touchInputPointRadius = 3.0;
    self.touchInputPoint = [[UIView alloc]
                                initWithFrame:CGRectMake(-self.touchInputPointRadius,
                                                         0,
                                                         self.touchInputPointRadius * 2,
                                                         self.touchInputPointRadius * 2)];
    self.touchInputPoint.hidden = YES;
    self.touchInputPoint.backgroundColor = self.colorTouchInputPoint;
    self.touchInputPoint.layer.cornerRadius = self.touchInputPointRadius;
    [self addSubview:self.touchInputPoint];
    
    // touch input info
    self.touchInputInfo = [[UILabel alloc] initWithFrame:self.touchInputPoint.frame];
    self.touchInputInfo.clipsToBounds = YES;
    self.touchInputInfo.hidden = YES;
    self.touchInputInfo.layer.cornerRadius = 3.0;
    self.touchInputInfo.backgroundColor = self.colorTouchInputInfo;
    [self.touchInputInfo setFont:[UIFont systemFontOfSize:12.0]];
    [self.touchInputInfo setTextAlignment:NSTextAlignmentCenter];
    [self.touchInputInfo sizeToFit];
    [self addSubview:self.touchInputInfo];
    
    // primitives
    self.enableGraphBoundsLines = YES;
    self.enableYAxisLabels = YES;
    self.enableXAxisLabels = YES;
    self.gridLinesWidth = 1.0;
    self.dataPointRadius = 0.0;
    
    SBGraphMargins margins;
    margins.left = 35;
    margins.bottom = 35;
    self.margins = margins;
    
    // redraw on rotate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Drawing

/**
 * Redraw on rotate
 */
- (void) didRotate
{
    [self setNeedsDisplay];
}

/**
 * The general idea here is to get all the points for all the lines we want to draw, then draw them.
 */
- (void) drawRect:(CGRect)rect
{
    // remove axises labels
    // everytime we draw, the reference lines could be different, so we need to remove their labels
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self addSubview:self.touchInputLine];
    [self addSubview:self.touchInputPoint];
    [self addSubview:self.touchInputInfo];
    
    // get y values
    self.yValues = [self.delegate yValues];
    
    // calculate graph position rect in view including margins
    [self calculateGraphDataBounds];
    
    // reposition touch input line inside graph bounds
    self.touchInputLine.frame = CGRectMake(0, self.graphDataBounds.origin.y, 1, self.graphDataBounds.size.height);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    //
    // Data line
    //
    
    SBLine *dataLine = [[SBLine alloc] init];
    dataLine.points = [self graphDataPoints];
    dataLine.color = self.colorDataLine;
    dataLine.pointColor = self.colorDataPoints;
    dataLine.pointRadius = self.dataPointRadius;
    [lines addObject:dataLine];
    
    //
    // Optional lines
    //
    
    // graph bounds lines
    if (self.enableGraphBoundsLines)
    {
        SBLine *graphBoundsLine = [[SBLine alloc] init];
        graphBoundsLine.points = [self graphDataBoundsPoints];
        graphBoundsLine.color = self.colorGraphBoundsLines;
        
        [lines addObject:graphBoundsLine];
    }
    
    // horizontal reference lines
    if ([self.delegate respondsToSelector:@selector(yValuesForReferenceLines)])
    {
        NSArray *yValues = [self.delegate yValuesForReferenceLines];
        NSArray *horizontalReferenceLines = [self horizontalReferenceLinesForYValues:yValues];
        
        if (self.enableYAxisLabels)
        {
            [self addLabelsForHorizontalReferenceLinesForYValues:yValues];
        }
        
        [lines addObjectsFromArray:horizontalReferenceLines];
    }
    
    // vertical reference lines
    if ([self.delegate respondsToSelector:@selector(xIndicesForReferenceLines)])
    {
        NSArray *xIndices = [self.delegate xIndicesForReferenceLines];
        NSArray *verticalReferenceLines = [self
                                           verticalReferenceLinesForXIndices:xIndices
                                           andTotalNumberOfDataPoints:dataLine.points.count];
        
        if (self.enableXAxisLabels)
        {
            [self addLabelsForVerticalReferenceLinesForXIndices:xIndices];
        }
        
        [lines addObjectsFromArray:verticalReferenceLines];
    }
    
    //
    // Draw!
    //
    for (int i = 0; i < lines.count; i++)
    {
        if (lines[i] == nil) continue;
        [self drawLine:lines[i]];
    }
}

- (void) drawLine:(SBLine*)line
{
    // Draw line
    UIColor *strokeColor = line.color;
    [strokeColor setStroke];
    
    UIBezierPath *path = [self pathForLine:line];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    [path stroke];
    [self.layer addSublayer:layer];
    
    // Draw points
    if (line.pointRadius > 0.0f)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGFloat pointRadius = line.pointRadius;
        [line.pointColor set];
        
        for (NSValue *pointValue in line.points)
        {
            CGPoint point = [pointValue CGPointValue];
            CGRect pointRect = CGRectMake(
                                          point.x - pointRadius,
                                          point.y - pointRadius,
                                          pointRadius * 2,
                                          pointRadius * 2
                                          );
            CGContextAddEllipseInRect(ctx, pointRect);
        }
        
        CGContextFillPath(ctx);
    }
}

- (UIBezierPath*) pathForLine:(SBLine*)line
{
    NSArray *points = line.points;
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapButt;
    path.lineWidth = self.gridLinesWidth;

    // draw
    [path moveToPoint:[points[0] CGPointValue]];
    for (int i = 1; i < points.count; i++)
    {
        NSValue *pointValue = points[i];
        CGPoint point = [pointValue CGPointValue];
        [path addLineToPoint:point];
    }
    
    return path;
}

- (void) calculateGraphDataBounds
{
    CGFloat leftMargin = self.margins.left;
    CGFloat bottomMargin = self.margins.bottom;
    CGFloat rightMargin = self.margins.right;
    CGFloat topMargin = self.margins.top;
    
    // if the line goes from (0,0) to (10,0) and the width is 2, the top of the stroked line will be (0, -1) at the first point. this variable allows the full width of the data bounds to be shown on the screen.
    CGFloat halfGridLinesWidth = self.gridLinesWidth / 2;
    
    self.graphDataBounds = CGRectMake(
                                      leftMargin - halfGridLinesWidth,
                                      halfGridLinesWidth + topMargin,
                                      self.bounds.size.width - leftMargin - rightMargin,
                                      self.bounds.size.height - bottomMargin - topMargin
                                      );
    
    // configure coordinate mapper
    CGFloat yMin = [self.delegate yMin];
    CGFloat yMax = [self.delegate yMax];
    CGRect graphFrame = CGRectMake(0, yMin, self.yValues.count - 1, yMax - yMin);
    [self.coordinateMapper setScreenFrame:self.graphDataBounds graphFrame:graphFrame];
}

- (void) addLabelsForHorizontalReferenceLinesForYValues:(NSArray*)yValues
{
    for (int i = 0; i < yValues.count; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:self.colorLabelText];
        
        // get label text
        CGFloat yVal = [yValues[i] floatValue];
        if ([self.delegate respondsToSelector:@selector(label:forYValue:)])
        {
            [self.delegate label:label forYValue:yVal];
        }
        else
        {
            NSString *labelText = [NSString stringWithFormat:@"%.1f", yVal];
            [label setFont:[UIFont systemFontOfSize:10.0]];
            [label setText:labelText];
        }
        
        [label sizeToFit];
        
        CGPoint labelPosYONLY = [self.coordinateMapper screenPointForGraphPoint:CGPointMake(0, yVal)];
        label.center = CGPointMake(self.graphDataBounds.origin.x / 2, labelPosYONLY.y);
        label.center = CGPointMake(lroundf(self.graphDataBounds.origin.x / 2), lroundf(labelPosYONLY.y));
        [self addSubview:label];
    }
}

- (void) addLabelsForVerticalReferenceLinesForXIndices:(NSArray*)xIndices
{
    for (int i = 0; i < xIndices.count; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:self.colorLabelText];
        
        // get label text
        NSInteger xIndex = [xIndices[i] integerValue];
        if ([self.delegate respondsToSelector:@selector(label:forXIndex:)])
        {
            [self.delegate label:label forXIndex:xIndex];
        }
        else
        {
            NSString *labelText = [NSString stringWithFormat:@"%d", (int)xIndex];
            [label setFont:[UIFont systemFontOfSize:10.0]];
            [label setText:labelText];
        }
        
        [label sizeToFit];
        
        CGPoint labelPos = [self.coordinateMapper screenPointForGraphPoint:CGPointMake((float)xIndex, 0)];
        labelPos.y = self.graphDataBounds.origin.y + self.graphDataBounds.size.height
                     + label.frame.size.height;
        
        label.center = CGPointMake(lroundf(labelPos.x), lroundf(labelPos.y));
        [self addSubview:label];
    }
}

#pragma mark - Point generation

- (NSArray*) graphDataPoints
{
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:self.yValues.count];
    for (int i = 0; i < self.yValues.count; i++)
    {
        CGFloat yVal = [self.yValues[i] floatValue];
        CGPoint point = [self.coordinateMapper screenPointForGraphPoint:CGPointMake((float)i, yVal)];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return points;
}

/** 
 * Calculates the points for graph data bounds
 * @return An array of CGPoints that correspond to the corners of the graph
 */
- (NSArray*) graphDataBoundsPoints
{
    CGPoint ul = CGPointMake(
                             self.graphDataBounds.origin.x,
                             self.graphDataBounds.origin.y
                             );
    CGPoint ur = CGPointMake(
                             self.graphDataBounds.origin.x + self.graphDataBounds.size.width,
                             self.graphDataBounds.origin.y
                             );
    CGPoint ll = CGPointMake(
                             self.graphDataBounds.origin.x,
                             self.graphDataBounds.origin.y + self.graphDataBounds.size.height
                             );
    CGPoint lr = CGPointMake(
                             self.graphDataBounds.origin.x + self.graphDataBounds.size.width,
                             self.graphDataBounds.origin.y + self.graphDataBounds.size.height
                             );
    
    NSArray *points = @[
                        [NSValue valueWithCGPoint:ul],
                        [NSValue valueWithCGPoint:ll],
                        [NSValue valueWithCGPoint:lr],
                        [NSValue valueWithCGPoint:ur],
                        [NSValue valueWithCGPoint:ul]
                        ];
    
    return points;
}

/**
 * @return An array of SBLine objects for the horizontal reference lines at the specified y values.
 */
- (NSArray*) horizontalReferenceLinesForYValues:(NSArray*)yValues
{
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:yValues.count];
    for (int i = 0; i < yValues.count; i++)
    {
        CGFloat yVal = [yValues[i] floatValue];
        CGPoint pointLeft = [self.coordinateMapper screenPointForGraphPoint:CGPointMake(0, yVal)];
        CGPoint pointRight = CGPointMake(
                                         pointLeft.x + self.graphDataBounds.size.width,
                                         pointLeft.y
                                         );
        
        SBLine *line = [[SBLine alloc] init];
        line.points = @[
                        [NSValue valueWithCGPoint:pointLeft],
                        [NSValue valueWithCGPoint:pointRight]
                        ];
        line.color = self.colorHorizontalReferenceLines;
        
        [lines addObject:line];
    }
    
    return lines;
}

/**
 * @return An array of SBLine objects for the horizontal reference lines at the specified y values.
 */
- (NSArray*) verticalReferenceLinesForXIndices:(NSArray*)xIndices
                    andTotalNumberOfDataPoints:(size_t)dataPointsCount
{
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:xIndices.count];
    
    for (int i = 0; i < xIndices.count; i++)
    {
        CGFloat referenceLineXIndex = [xIndices[i] floatValue];
        CGPoint pointBottom = [self.coordinateMapper
                               screenPointForGraphPoint:CGPointMake(referenceLineXIndex, 0)];
        CGPoint pointTop = CGPointMake(
                                         pointBottom.x,
                                         self.graphDataBounds.origin.y
                                         );
        
        SBLine *line = [[SBLine alloc] init];
        line.points = @[
                        [NSValue valueWithCGPoint:pointBottom],
                        [NSValue valueWithCGPoint:pointTop]
                        ];
        line.color = self.colorVerticalReferenceLines;
        
        [lines addObject:line];
    }
    
    return lines;
}

#pragma mark - Touch input line

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchInputLine.hidden = NO;
    self.touchInputPoint.hidden = NO;
    self.touchInputInfo.hidden = NO;
    [self handleTouches:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.touchInputLine.hidden == NO)
    {
        self.touchInputLine.hidden = YES;
        self.touchInputPoint.hidden = YES;
        self.touchInputInfo.hidden = YES;
    }
}

- (void) handleTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint locationInView = [touch locationInView:self];
    
    NSInteger closestDataPointIndex = [self closestDataPointIndexForLocationInView:locationInView];
    
    // set text for touch input info label
    CGFloat yValue = [self.yValues[closestDataPointIndex] floatValue];
    NSString *text = [NSString stringWithFormat:@"(%d, %.f)", closestDataPointIndex, yValue];
    [self.touchInputInfo setText:text];
    
    // fill the label text
    if ([self.delegate respondsToSelector:@selector(touchInputInfoLabel:forXIndex:)])
    {
        [self.delegate touchInputInfoLabel:self.touchInputInfo forXIndex:closestDataPointIndex];
    }
    
    // get data point coordinates
    CGPoint graphPoint = CGPointMake(
                                     closestDataPointIndex,
                                     [self.yValues[closestDataPointIndex] floatValue]
                                     );
    CGPoint screenPointForClosestDataPoint = [self.coordinateMapper
                                              screenPointForGraphPoint:graphPoint];
    
    //
    // move touch input line
    //
    CGRect touchRect = self.touchInputLine.frame;
    touchRect.origin.x = locationInView.x;
    touchRect.origin.x = screenPointForClosestDataPoint.x;
    self.touchInputLine.frame = touchRect;
    
    //
    // move touch input point
    //
    CGRect touchPointRect = self.touchInputPoint.frame;
    touchPointRect.origin.x = screenPointForClosestDataPoint.x - self.touchInputPointRadius;
    touchPointRect.origin.y = screenPointForClosestDataPoint.y - self.touchInputPointRadius;
    self.touchInputPoint.frame = touchPointRect;
    
    //
    // touch input info
    //
    [self.touchInputInfo sizeToFit];
    CGRect touchInfoRect = self.touchInputInfo.frame;
    CGFloat yDirection = screenPointForClosestDataPoint.y > touchInfoRect.size.height + 2 ? 22.0 : -15.0;
    
    touchInfoRect.origin.x = screenPointForClosestDataPoint.x - touchInfoRect.size.width / 2.0;
    touchInfoRect.origin.y = touchPointRect.origin.y - yDirection;
    touchInfoRect = [self padLabel:touchInfoRect];
    
    // keep the touch input info view inside this view
    if (touchInfoRect.origin.x < 1)
    {
        touchInfoRect.origin.x = 1;
    }
    if (touchInfoRect.origin.x > self.frame.size.width - touchInfoRect.size.width - 1)
    {
        touchInfoRect.origin.x = self.frame.size.width - touchInfoRect.size.width - 1;
    }
    
    // set frame
    self.touchInputInfo.frame = touchInfoRect;
}

- (NSInteger) closestDataPointIndexForLocationInView:(CGPoint)point
{
    CGFloat percentage = (point.x - self.graphDataBounds.origin.x) / self.graphDataBounds.size.width;
    CGFloat percentIndex = percentage * ((float)self.yValues.count-1.0);
    NSInteger index = lroundf((float)percentIndex);
    
    if (percentage < 0)
    {
        index = 0;
    }
    if (percentage > 1)
    {
        index = self.yValues.count-1;
    }
    
    return index;
}

- (CGRect) padLabel:(CGRect)labelRect
{
    CGFloat leftRight = 6.0;
    CGFloat bottomTop = 2.0;
    
    labelRect.origin.x -= leftRight;
    labelRect.origin.y -= bottomTop;
    labelRect.size.width += 2 * leftRight;
    labelRect.size.height += 2 * bottomTop;
    
    return labelRect;
}

#pragma mark - Setters

// --------------------------------------------------
// Public
// --------------------------------------------------

- (void) setGradientToFromColor:(UIColor*)from toColor:(UIColor*)to
{
    
}

// --------------------------------------------------
// Private
// --------------------------------------------------

- (void) setTouchInputPointRadius:(CGFloat)touchInputPointRadius
{
    _touchInputPointRadius = touchInputPointRadius;
    self.touchInputPoint.layer.cornerRadius = self.touchInputPointRadius;
    
    CGRect frame = self.touchInputPoint.frame;
    frame.size.width = touchInputPointRadius * 2;
    frame.size.height = touchInputPointRadius * 2;
    self.touchInputPoint.frame = frame;
}

@end
