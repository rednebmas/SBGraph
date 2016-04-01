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

// CGPoints stored as NSValue
@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) UIColor *color;

@end
