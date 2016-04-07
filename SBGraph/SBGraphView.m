//
//  SBGraphView.m
//  SBGraph
//
//  Created by Sam Bender on 3/31/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "SBGraphView.h"
#import "SBLine.h"

typedef struct {
    CGPoint *points;
    int size;
} CGPointArray;

@interface SBGraphView()

@property (nonatomic) CGRect graphDataBounds;
@property (nonatomic, retain) UIView *touchInputLine;

@end

@implementation SBGraphView

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
    self.colorTouchInputLine = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    self.colorVerticalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorHorizontalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorGraphBoundsLines = [[UIColor whiteColor] colorWithAlphaComponent:.9];
    self.colorDataLine = [UIColor whiteColor];
    self.colorDataPoints = [UIColor whiteColor];
    self.colorLabelText = [UIColor whiteColor];
    
    self.touchInputLine = [[UIView alloc] init];
    self.touchInputLine.hidden = YES;
    self.touchInputLine.backgroundColor = self.colorTouchInputLine;
    [self addSubview:self.touchInputLine];
    
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

// redraw on rotate
- (void) didRotate
{
    [self setNeedsDisplay];
}

/**
 * The general idea here is to get all the points for all the lines we want to draw, then draw them.
 */
- (void) drawRect:(CGRect)rect
{
    [self calculateGraphDataBounds];
    self.touchInputLine.frame = CGRectMake(0, 0, 1, self.graphDataBounds.size.height);
    
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
    
    // if the line goes from (0,0) to (10,0) and the width is 2, the top of the stroked line will be (0, -1) at the first point. this variable allows the full width of the data bounds to be shown on the screen.
    CGFloat halfGridLinesWidth = self.gridLinesWidth / 2;
    
    self.graphDataBounds = CGRectMake(
                                      leftMargin - halfGridLinesWidth,
                                      halfGridLinesWidth,
                                      self.bounds.size.width - leftMargin,
                                      self.bounds.size.height - bottomMargin
                                      );
}

- (void) addLabelsForHorizontalReferenceLinesForYValues:(NSArray*)yValues
{
    CGFloat yMin = [self.delegate yMin];
    CGFloat yMax = [self.delegate yMax];
    CGFloat yRange = yMax - yMin;

    for (int i = 0; i < yValues.count; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:self.colorLabelText];
        
        // get label text
        CGFloat yValue = [yValues[i] floatValue];
        if ([self.delegate respondsToSelector:@selector(label:forYValue:)])
        {
            [self.delegate label:label forYValue:yValue];
        }
        else
        {
            NSString *labelText = [NSString stringWithFormat:@"%.1f", yValue];
            [label setFont:[UIFont systemFontOfSize:10.0]];
            [label setText:labelText];
        }
        
        [label sizeToFit];
        
        CGFloat yPos = (1 - ((yValue - yMin) / yRange)) * self.graphDataBounds.size.height;
        yPos += self.graphDataBounds.origin.y;
        
        label.center = CGPointMake(self.graphDataBounds.origin.x / 2, yPos);
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
        CGFloat xIndex = [xIndices[i] floatValue];
        if ([self.delegate respondsToSelector:@selector(label:forXIndex:)])
        {
            [self.delegate label:label forXIndex:xIndex];
        }
        else
        {
            NSString *labelText = [NSString stringWithFormat:@"%.1f", xIndex];
            [label setFont:[UIFont systemFontOfSize:10.0]];
            [label setText:labelText];
        }
        
        [label sizeToFit];
        
        CGFloat xPos = (xIndex / (float)xIndices.count) * self.graphDataBounds.size.width;
        // CGFloat yPos= self.graphDataBounds.size.height + self;
        
//        xPos += self.graphDataBounds.origin.x;
//        yPosBottom += self.graphDataBounds.origin.y;
        
        // label.center = CGPointMake(self.graphDataBounds.origin.x / 2, yPos);
        [self addSubview:label];
    }
}

#pragma mark - Point generation

- (NSArray*) graphDataPoints
{
    CGFloat yMin = [self.delegate yMin];
    CGFloat yMax = [self.delegate yMax];
    CGFloat yRange = yMax - yMin;
    NSArray *yValues = [self.delegate yValues];
    
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:yValues.count];
    for (int i = 0; i < yValues.count; i++)
    {
        CGFloat yVal = [yValues[i] floatValue];
        CGFloat yPosInDataBounds = (1 - ((yVal - yMin) / yRange)) * self.graphDataBounds.size.height;
        CGFloat xPosInDataBounds = ((float)i / (yValues.count - 1)) * self.graphDataBounds.size.width;
        xPosInDataBounds += self.graphDataBounds.origin.x;
        yPosInDataBounds += self.graphDataBounds.origin.y;
        CGPoint point = CGPointMake(xPosInDataBounds, yPosInDataBounds);
        
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
    CGFloat yMin = [self.delegate yMin];
    CGFloat yMax = [self.delegate yMax];
    CGFloat yRange = yMax - yMin;
    
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:yValues.count];
    for (int i = 0; i < yValues.count; i++)
    {
        
        CGFloat yVal = [yValues[i] floatValue];
        CGFloat xPosLeft = self.graphDataBounds.origin.x;
        CGFloat yPos = (1 - ((yVal - yMin) / yRange)) * self.graphDataBounds.size.height;
        yPos += self.graphDataBounds.origin.y;
        
        CGPoint pointLeft = CGPointMake(xPosLeft, yPos);
        CGPoint pointRight = CGPointMake(
                                         xPosLeft + self.graphDataBounds.size.width,
                                         yPos
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
    CGFloat totalDataPointsMinusOne = (float)dataPointsCount - 1;
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:xIndices.count];
    
    for (int i = 0; i < xIndices.count; i++)
    {
        CGFloat referenceLineXIndex = [xIndices[i] floatValue];
        CGFloat xPos = (referenceLineXIndex / totalDataPointsMinusOne) * self.graphDataBounds.size.width;
        CGFloat yPosBottom = self.graphDataBounds.size.height;
        
        xPos += self.graphDataBounds.origin.x;
        yPosBottom += self.graphDataBounds.origin.y;
        
        CGPoint pointBottom = CGPointMake(xPos, yPosBottom);
        CGPoint pointTop = CGPointMake(
                                         xPos,
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
    }
}

- (void) handleTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint locationInView = [touch locationInView:self];
    if (locationInView.x > self.graphDataBounds.origin.x
        && locationInView.x < self.frame.size.width)
    {
        CGRect touchRect = self.touchInputLine.frame;
        touchRect.origin.x = locationInView.x;
        self.touchInputLine.frame = touchRect;
    }
}


@end
