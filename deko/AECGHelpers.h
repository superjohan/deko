//
//  AECGHelpers.h
//
//  Created by Johan Halin on 3.3.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline CGRect AECGRectPlace(CGRect rect, CGFloat x, CGFloat y)
{
	return CGRectMake(x, y, rect.size.width, rect.size.height);
}

static inline CGRect AECGRectPlaceX(CGRect rect, CGFloat x)
{
	return AECGRectPlace(rect, x, rect.origin.y);
}

static inline CGRect AECGRectPlaceY(CGRect rect, CGFloat y)
{
	return AECGRectPlace(rect, rect.origin.x, y);
}

static inline CGRect AECGRectWithSize(CGRect rect, CGFloat width, CGFloat height)
{
	return CGRectMake(rect.origin.x, rect.origin.y, width, height);
}

static inline CGRect AECGRectWithWidth(CGRect rect, CGFloat width)
{
	return AECGRectWithSize(rect, width, rect.size.height);
}

static inline CGRect AECGRectWithHeight(CGRect rect, CGFloat height)
{
	return AECGRectWithSize(rect, rect.size.width, height);
}
