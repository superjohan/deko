//
//  DekoFlowLayout.m
//  deko
//
//  Created by Johan Halin on 27.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoFlowLayout.h"

@implementation DekoFlowLayout

// from http://openradar.appspot.com/12433891

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *unfilteredPoses = [super layoutAttributesForElementsInRect:rect];
	id filteredPoses[unfilteredPoses.count];
	NSUInteger filteredPosesCount = 0;
	
	for (UICollectionViewLayoutAttributes *pose in unfilteredPoses)
	{
		CGRect frame = pose.frame;
		
		if (frame.origin.x + frame.size.width <= rect.size.width)
		{
			filteredPoses[filteredPosesCount++] = pose;
		}
	}
	
	return [NSArray arrayWithObjects:filteredPoses count:filteredPosesCount];
}

@end
