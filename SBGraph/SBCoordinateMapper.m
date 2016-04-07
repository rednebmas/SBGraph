//
//  SBCoordinateMapper.m
//  Pods
//
//  Created by Sam Bender on 4/2/16.
//
// For converting graphing coordinates (y+ is up, x+ is right)
//               to screen coordinates (y+ - down, x+ is right)

#import "SBCoordinateMapper.h"

@interface SBCoordinateMapper()

@property (nonatomic) CGRect screenRect;
@property (nonatomic) CGRect graphRect;
@property (nonatomic) CGPoint screenToGraphScaleFactor;
@property (nonatomic) CGPoint graphToScreenScaleFactor;

@end

@implementation SBCoordinateMapper

- (id) initWithScreenFrame:(CGRect)screenRect
                graphFrame:(CGRect)graphRect
{
    self = [self init];
    if (self)
    {
        [self setScreenFrame:screenRect graphFrame:graphRect];
    }
    return self;
}

#pragma mark - Setters

- (void) setScreenFrame:(CGRect)screenRect
             graphFrame:(CGRect)graphRect
{
    self.screenRect = screenRect;
    self.graphRect = graphRect;
    
    self.screenToGraphScaleFactor = CGPointMake(
                                                graphRect.size.width / screenRect.size.width,
                                                graphRect.size.height / screenRect.size.height
                                                );
    self.graphToScreenScaleFactor = CGPointMake(
                                                screenRect.size.width / graphRect.size.width,
                                                screenRect.size.height / graphRect.size.height
                                                );
}

#pragma mark - Getters

- (CGPoint) screenPointForGraphPoint:(CGPoint)graphPoint
{
    CGFloat screenHeightInGraphHeight = self.screenRect.size.height * self.screenToGraphScaleFactor.y;
    CGPoint screenPoint = CGPointMake(
                                      (graphPoint.x - self.graphRect.origin.x) * self.graphToScreenScaleFactor.x + self.screenRect.origin.x,
                                      (screenHeightInGraphHeight - graphPoint.y + self.graphRect.origin.y) * self.graphToScreenScaleFactor.y + self.screenRect.origin.y
                                      );
    return screenPoint;
}

- (CGPoint) graphPointForScreenPoint:(CGPoint)screenPoint
{
    CGPoint graphPoint = CGPointMake(
                                      (screenPoint.x - self.screenRect.origin.x) * self.screenToGraphScaleFactor.x + self.graphRect.origin.x,
                                      -(screenPoint.y - self.screenRect.size.height - self.screenRect.origin.y) * self.screenToGraphScaleFactor.y + self.graphRect.origin.y
                                      );
    return graphPoint;
}

@end
