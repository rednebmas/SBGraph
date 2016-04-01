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
    self.colorVerticalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorHorizontalReferenceLines = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    self.colorGraphBoundsLines = [[UIColor whiteColor] colorWithAlphaComponent:.9];
    self.colorDataLine = [UIColor whiteColor];
    self.colorDataPoints = [UIColor whiteColor];
    self.gridLinesWidth = 1.0;
    
    self.enableGraphBoundsLines = YES;
    self.dataPointRadius = 0.0;
    
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
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    //
    // Optional lines
    //
    
    if (self.enableGraphBoundsLines)
    {
        SBLine *graphBoundsLine = [[SBLine alloc] init];
        graphBoundsLine.points = [self graphDataBoundsPoints];
        graphBoundsLine.color = self.colorGraphBoundsLines;
        
        [lines addObject:graphBoundsLine];
    }
    
    if ([self.delegate respondsToSelector:@selector(yValuesForReferenceLines)])
    {
        NSArray *yValues = [self.delegate yValuesForReferenceLines];
        NSArray *horizontalReferenceLines = [self horizontalReferenceLinesForYValues:yValues];
        
        [lines addObjectsFromArray:horizontalReferenceLines];
    }
    
    //
    // Data line
    //
    
    SBLine *dataLine = [[SBLine alloc] init];
    dataLine.points = [self graphDataPoints];
    dataLine.color = self.colorDataLine;
    dataLine.pointColor = self.colorDataPoints;
    dataLine.pointRadius = self.dataPointRadius;
    [lines addObject:dataLine];
    
    // draw!
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
    CGFloat leftMargin = 35;
    CGFloat bottomMargin = 35;
    // if the line goes from (0,0) to (10,0) and the width is 2, the top of the stroked line will be (0, -1) at the first point. this variable allows the full width of the data bounds to be shown on the screen.
    CGFloat halfGridLinesWidth = self.gridLinesWidth / 2;
    
    self.graphDataBounds = CGRectMake(
                                      leftMargin - halfGridLinesWidth,
                                      halfGridLinesWidth,
                                      self.bounds.size.width - leftMargin,
                                      self.bounds.size.height - bottomMargin
                                      );
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
        CGFloat xPosInDataBoundsLeft = self.graphDataBounds.origin.x;
        CGFloat yPosInDataBounds = (1 - ((yVal - yMin) / yRange)) * self.graphDataBounds.size.height;
        yPosInDataBounds += self.graphDataBounds.origin.y;
        
        CGPoint pointLeft = CGPointMake(xPosInDataBoundsLeft, yPosInDataBounds);
        CGPoint pointRight = CGPointMake(
                                         xPosInDataBoundsLeft + self.graphDataBounds.size.width,
                                         yPosInDataBounds
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

@end
