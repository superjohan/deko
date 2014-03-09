//
//  HarmonyShapeFunctions.h
//  harmonyvisualengine
//
//  Created by Johan Halin on 8.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

UIBezierPath * triangle(CGPoint p1, CGPoint p2, CGPoint p3, CGFloat angle, UIColor *color);
UIBezierPath * quad(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4, CGFloat angle, UIColor *color);
UIBezierPath * circle(CGPoint center, CGFloat radius, UIColor *color);
