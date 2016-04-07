//
//  SBCoordinateMapper.h
//  Pods
//
//  Created by Sam Bender on 4/2/16.
//
//  Graphing is essentially just a coordinate transformation from graph coordinates to screen coordinates.
//  This class abstracts out the math.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SBCoordinateMapper : NSObject

- (id) initWithScreenFrame:(CGRect)screenRect
                graphFrame:(CGRect)graphRect;

- (void) setScreenFrame:(CGRect)screenRect
             graphFrame:(CGRect)graphRect;

- (CGPoint) screenPointForGraphPoint:(CGPoint)graphPoint;
- (CGPoint) graphPointForScreenPoint:(CGPoint)screenPoint;

@end
