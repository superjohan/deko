//
//  HarmonyShapeFunctions.m
//  harmonyvisualengine
//
//  Created by Johan Halin on 8.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#include "HarmonyShapeFunctions.h"

UIBezierPath * triangle(CGPoint p1, CGPoint p2, CGPoint p3, CGFloat angle, UIColor *color)
{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:p1];
	[bezierPath addLineToPoint:p2];
	[bezierPath addLineToPoint:p3];
	[bezierPath closePath];

	if (angle > 0.00000001 || angle < 0.00000001)
	{
		CGRect bounds = bezierPath.bounds;
		[bezierPath applyTransform:CGAffineTransformMakeRotation(angle)];
		CGFloat x = CGRectGetMidX(bounds) - CGRectGetMidX(bezierPath.bounds);
		CGFloat y = CGRectGetMidY(bounds) - CGRectGetMidY(bezierPath.bounds);
		[bezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];
	}
	
	[color set];
	[bezierPath fill];
	
	return bezierPath;
}

UIBezierPath * quad(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4, CGFloat angle, UIColor *color)
{
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
	
	[bezierPath moveToPoint:p1];
	[bezierPath addLineToPoint:p2];
	[bezierPath addLineToPoint:p3];
	[bezierPath addLineToPoint:p4];
	[bezierPath closePath];

	if (angle > 0.00000001 || angle < 0.00000001)
	{
		CGRect bounds = bezierPath.bounds;
		[bezierPath applyTransform:CGAffineTransformMakeRotation(angle)];
		CGFloat x = CGRectGetMidX(bounds) - CGRectGetMidX(bezierPath.bounds);
		CGFloat y = CGRectGetMidY(bounds) - CGRectGetMidY(bezierPath.bounds);
		[bezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];
	}
	
	[color set];
	[bezierPath fill];
	
	return bezierPath;
}

UIBezierPath * circle(CGPoint center, CGFloat radius, UIColor *color)
{
	CGRect ovalRect = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
	[color set];
	[bezierPath fill];
	
	return bezierPath;
}
