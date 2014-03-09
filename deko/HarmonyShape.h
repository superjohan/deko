//
//  HarmonyShape.h
//  harmonyvisualengine
//
//  Created by Johan Halin on 8.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HarmonyShapeType)
{
	HarmonyShapeTypeCircle,
	HarmonyShapeTypeSquare,
	HarmonyShapeTypeTriangle,
	HarmonyShapeTypeMax,
};

@interface HarmonyShape : NSObject
@property (nonatomic, assign) CGPoint p1;
@property (nonatomic, assign) CGPoint p2;
@property (nonatomic, assign) CGPoint p3;
@property (nonatomic, assign) CGPoint p4;
@property (nonatomic, assign) CGFloat radius; // only for circles
@property (nonatomic, assign) HarmonyShapeType shapeType;
@property (nonatomic) UIBezierPath *bezierPath;
@end
