//
//  SBLine.h
//  Pods
//
//  Created by Sam Bender on 4/1/16.
//
//

@import UIKit;
#import <Foundation/Foundation.h>

@interface SBLine : NSObject

// if greater than zero, a circle will be drawn on the points witht the specified radius
@property (nonatomic) CGFloat pointRadius;
// default nil
@property (nonatomic, retain) UIColor *pointColor;

// CGPoints stored as NSValue
@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) UIColor *color;

@end
