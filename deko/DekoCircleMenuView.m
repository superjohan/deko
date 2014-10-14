//
//  DekoCircleMenuView.m
//  deko
//
//  Created by Johan Halin on 24.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoCircleMenuView.h"

const NSInteger kCirclesPerRow = 3;

@implementation DekoCircleMenuView

#pragma mark - Private

- (void)_drawCircleAtRow:(NSInteger)row column:(NSInteger)column rect:(CGRect)rect highlighted:(BOOL)highlighted
{
	CGRect ovalRect = CGRectMake((rect.size.width / 2.0) - (self.circleSize / 2.0) - (self.circleSize - self.overlap) + (column * (self.circleSize - self.overlap)),
								 (rect.size.height / 2.0) - (self.circleSize / 2.0) + ((self.circleSize - self.overlap) * row),
								 self.circleSize,
								 self.circleSize);
	UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
	
	CGFloat color = 1.0;
	if (highlighted)
	{
		color = 0.8;
	}
	
	[[UIColor colorWithWhite:color alpha:1.0] set];
	[oval fill];
}

- (void)_drawCirclesInRect:(CGRect)rect selected:(BOOL)selected
{
	NSInteger rows = (NSInteger)ceil((CGFloat)self.items / (CGFloat)kCirclesPerRow);
	
	for (NSInteger i = 0; i < rows; i++)
	{
		NSInteger itemsPerRow = self.items - (i * kCirclesPerRow);
		if (itemsPerRow > kCirclesPerRow)
		{
			itemsPerRow = kCirclesPerRow;
		}
		
		for (NSInteger j = 0; j < itemsPerRow; j++)
		{
			NSInteger current = 1 + (i * kCirclesPerRow) + j;

			// This is stupid but I don't really feel like fixing this right now.
			// So, FIXME if there's ever need for a two-item row.
			NSInteger column = j;
			if (itemsPerRow == 1)
			{
				column = 1;
			}
			
			if (!selected)
			{
				if (current != self.selected)
				{
					[self _drawCircleAtRow:i column:column rect:rect highlighted:NO];
				}
			}
			else
			{
				if (current == self.selected)
				{
					[self _drawCircleAtRow:i column:column rect:rect highlighted:YES];
				}
			}
		}
	}
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	[self _drawCirclesInRect:rect selected:NO];
	[self _drawCirclesInRect:rect selected:YES];
}

- (void)setSelected:(NSInteger)selected
{
	if (selected == _selected)
	{
		return;
	}
	
	_selected = selected;
	
	[self setNeedsDisplay];
}

@end
