//
//  SBGraphView.m
//  SBGraph
//
//  Created by Sam Bender on 3/31/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "SBGraphView.h"

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
    self.colorGraphBoundsLines = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.gridLinesWidth = 1.0;
}

#pragma mark - Drawing

- (void) drawRect:(CGRect)rect
{
    [self calculateGraphDataBounds];
    
    // Drawing code
    NSArray *linePoints;
    NSArray *lineColors;
    linePoints = @[
                   [self graphDataBoundsPoints]
                   ];
    lineColors = @[
                   self.colorGraphBoundsLines
                   ];
    
    for (int i = 0; i < linePoints.count; i++)
    {
        UIColor *strokeColor = lineColors[i];
        [strokeColor setStroke];
        
        UIBezierPath *path = [self pathForPoints:linePoints[i]];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.path = path.CGPath;
        layer.fillColor = [UIColor clearColor].CGColor;
        
        [path stroke];
        [self.layer addSublayer:layer];
    }
}

- (UIBezierPath*) pathForPoints:(NSArray*)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapButt;
    path.lineWidth = 1.0;

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
    // get graph bounds
    CGFloat leftMargin = 35;
    CGFloat bottomMargin = 35;
    self.graphDataBounds = CGRectMake(
                                      leftMargin - self.gridLinesWidth / 2,
                                      0 + self.gridLinesWidth / 2,
                                      self.frame.size.width - leftMargin,
                                      self.frame.size.height - bottomMargin
                                      );
}

#pragma mark - Point generation

/** 
 * Calculates the points for graph data bounds
 * @return An array of CGPoints that correspond to the corners of the graph within the reference from of this view
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

@end
