//
//  SBGraphTests.m
//  SBGraphTests
//
//  Created by Sam Bender on 4/7/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBCoordinateMapper.h"

@interface SBGraphTests : XCTestCase

@end

@implementation SBGraphTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testSBCoordinateMapperSameAspectRatio
{
    CGRect screen = CGRectMake(0, 0, 100, 500);
    CGRect graph = CGRectMake(0, 0, 10, 50);
    
    SBCoordinateMapper *cm = [[SBCoordinateMapper alloc] initWithScreenFrame:screen
                                                                  graphFrame:graph];
    
    //
    // Graph to screen
    //
    
    CGPoint g2sLowerLeft = CGPointMake(0, 0);
    CGPoint g2sLowerLeftOut = [cm screenPointForGraphPoint:g2sLowerLeft];
    XCTAssert(g2sLowerLeftOut.x == 0 && g2sLowerLeftOut.y == 500,
              @"g2sLowerLeft (%.2f,%.2f)", g2sLowerLeftOut.x, g2sLowerLeftOut.y);
    
    CGPoint g2sLowerRight = CGPointMake(10, 0);
    CGPoint g2sLowerRightOut = [cm screenPointForGraphPoint:g2sLowerRight];
    XCTAssert(g2sLowerRightOut.x == 100.0 && g2sLowerRightOut.y == 500.0,
              @"g2sLowerRight (%.2f,%.2f)", g2sLowerRightOut.x, g2sLowerRightOut.y);
    
    CGPoint g2sUpperRight = CGPointMake(10, 50);
    CGPoint g2sUpperRightOut = [cm screenPointForGraphPoint:g2sUpperRight];
    XCTAssert(g2sUpperRightOut.x == 100.0 && g2sUpperRightOut.y == 0.0,
              @"g2sUpperRight (%.2f,%.2f)", g2sUpperRightOut.x, g2sUpperRightOut.y);
    
    CGPoint g2sUpperLeft = CGPointMake(0, 50);
    CGPoint g2sUpperLeftOut = [cm screenPointForGraphPoint:g2sUpperLeft];
    XCTAssert(g2sUpperLeftOut.x == 0.0 && g2sUpperLeftOut.y == 0.0,
              @"g2sUpperLeft (%.2f,%.2f)", g2sUpperLeftOut.x, g2sUpperLeftOut.y);
    
    CGPoint g2sCenter = CGPointMake(5, 25);
    CGPoint g2sCenterOut = [cm screenPointForGraphPoint:g2sCenter];
    XCTAssert(g2sCenterOut.x == 50.0 && g2sCenterOut.y == 250.0,
              @"g2sCenter (%.2f,%.2f)", g2sCenterOut.x, g2sCenterOut.y);
    
    CGPoint g2sG25PercentLowerLeft = CGPointMake(2.5, 50.0/4);
    CGPoint g2sG25PercentLowerLeftOut = [cm screenPointForGraphPoint:g2sG25PercentLowerLeft];
    XCTAssert(g2sG25PercentLowerLeftOut.x == 25.0 && g2sG25PercentLowerLeftOut.y == 375.0,
              @"g2sG25PercentLowerLeft (%.2f,%.2f)", g2sG25PercentLowerLeftOut.x, g2sG25PercentLowerLeftOut.y);
    
    //
    // Screen to graph
    //
    
    CGPoint s2gUpperLeft = CGPointMake(0, 0);
    CGPoint s2gUpperLeftOut = [cm graphPointForScreenPoint:s2gUpperLeft];
    XCTAssert(s2gUpperLeftOut.x == 0.0 && s2gUpperLeftOut.y == 50.0,
              @"g2sG25PercentUpperLeft (%.2f,%.2f)", s2gUpperLeftOut.x, s2gUpperLeftOut.y);
    
    CGPoint s2gLowerLeft = CGPointMake(0, 500);
    CGPoint s2gLowerLeftOut = [cm graphPointForScreenPoint:s2gLowerLeft];
    XCTAssert(s2gLowerLeftOut.x == 0.0 && s2gLowerLeftOut.y == 0.0,
              @"g2sG25PercentLowerLeft (%.2f,%.2f)", s2gLowerLeftOut.x, s2gLowerLeftOut.y);
    
    CGPoint s2gLowerRight = CGPointMake(100, 500);
    CGPoint s2gLowerRightOut = [cm graphPointForScreenPoint:s2gLowerRight];
    XCTAssert(s2gLowerRightOut.x == 10.0 && s2gLowerRightOut.y == 0.0,
              @"g2sG25PercentLowerRight (%.2f,%.2f)", s2gLowerRightOut.x, s2gLowerRightOut.y);
    
    CGPoint s2gUpperRight = CGPointMake(100, 0);
    CGPoint s2gUpperRightOut = [cm graphPointForScreenPoint:s2gUpperRight];
    XCTAssert(s2gUpperRightOut.x == 10.0 && s2gUpperRightOut.y == 50.0,
              @"g2sG25PercentUpperRight (%.2f,%.2f)", s2gUpperRightOut.x, s2gUpperRightOut.y);
    
    CGPoint s2gCenter = CGPointMake(50, 250);
    CGPoint s2gCenterOut = [cm graphPointForScreenPoint:s2gCenter];
    XCTAssert(s2gCenterOut.x == 5.0 && s2gCenterOut.y == 25.0,
              @"g2sG25PercentCenter (%.2f,%.2f)", s2gCenterOut.x, s2gCenterOut.y);
    
    CGPoint s2gS25PercentUpperLeft = CGPointMake(25, 125);
    CGPoint s2gS25PercentUpperLeftOut = [cm graphPointForScreenPoint:s2gS25PercentUpperLeft];
    XCTAssert(s2gS25PercentUpperLeftOut.x == 2.5 && s2gS25PercentUpperLeftOut.y == 37.5,
              @"g2sG25PercentS25PercentUpperLeft (%.2f,%.2f)", s2gS25PercentUpperLeftOut.x, s2gS25PercentUpperLeftOut.y);
}


- (void) testSBCoordinateMapperDifferentAspectRatio
{
    CGRect screen = CGRectMake(0, 0, 100, 100);
    CGRect graph = CGRectMake(0, 0, 200, 400);
    
    SBCoordinateMapper *cm = [[SBCoordinateMapper alloc] initWithScreenFrame:screen
                                                                  graphFrame:graph];
    
    //
    // Graph to screen
    //
    
    CGPoint g2sCenter = CGPointMake(100, 200);
    CGPoint g2sCenterOut = [cm screenPointForGraphPoint:g2sCenter];
    XCTAssert(g2sCenterOut.x == 50.0 && g2sCenterOut.y == 50.0,
              @"g2sCenter (%.2f,%.2f)", g2sCenterOut.x, g2sCenterOut.y);
    
    //
    // Screen to graph
    //
    
    CGPoint s2gCenter = CGPointMake(50, 50);
    CGPoint s2gCenterOut = [cm graphPointForScreenPoint:s2gCenter];
    XCTAssert(s2gCenterOut.x == 100.0 && s2gCenterOut.y == 200.0,
              @"g2sG25PercentCenter (%.2f,%.2f)", s2gCenterOut.x, s2gCenterOut.y);
}

- (void) testSBCoordinateMapperNonzeroOrigin
{
    CGRect screen = CGRectMake(0, 0, 100, 100);
    CGRect graph = CGRectMake(100, 100, 200, 200);
    
    SBCoordinateMapper *cm = [[SBCoordinateMapper alloc] initWithScreenFrame:screen
                                                                  graphFrame:graph];
    
    //
    // Graph to screen
    //
    
    CGPoint g2sCenter = CGPointMake(200, 200);
    CGPoint g2sCenterOut = [cm screenPointForGraphPoint:g2sCenter];
    XCTAssert(g2sCenterOut.x == 50.0 && g2sCenterOut.y == 50.0,
              @"g2sCenter (%.2f,%.2f)", g2sCenterOut.x, g2sCenterOut.y);
    
    CGPoint g2sUpperLeft = CGPointMake(100, 300);
    CGPoint g2sUpperLeftOut = [cm screenPointForGraphPoint:g2sUpperLeft];
    XCTAssert(g2sUpperLeftOut.x == 0.0 && g2sUpperLeftOut.y == 0.0,
              @"g2sUpperLeft (%.2f,%.2f)", g2sUpperLeftOut.x, g2sUpperLeftOut.y);
    
    //
    // Screen to graph
    //
    
    screen = CGRectMake(200, 100, 100, 100);
    [cm setScreenFrame:screen graphFrame:graph];
    
    CGPoint s2gCenter = CGPointMake(250, 150);
    CGPoint s2gCenterOut = [cm graphPointForScreenPoint:s2gCenter];
    XCTAssert(s2gCenterOut.x == 200.0 && s2gCenterOut.y == 200.0,
              @"g2sG25PercentCenter (%.2f,%.2f)", s2gCenterOut.x, s2gCenterOut.y);
}

@end
