//
//  CASCustomColorFunctions.m
//  ClassyTests
//
//  Created by Keith Norman on 7/5/15.
//  Copyright (c) 2015 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"
#import "XCTest+Spec.h"
#import "CASExampleView.h"

@interface UIColor(transformation)

- (UIColor *)alpha:(NSNumber *)value;

@end

@implementation UIColor(transformation)

- (UIColor *)alpha:(NSNumber *)value {
    return [self colorWithAlphaComponent:value.floatValue];
}

@end

SpecBegin(CASCustomColorFunctions)

- (void)testViewCustomColorFunctions {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"CustomColorFunctions.cas" ofType:nil];
    UIView *view = UIView.new;
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor colorWithRed:0 green:255 blue:0 alpha:0.5]);
}

SpecEnd