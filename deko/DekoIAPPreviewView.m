//
//  DekoIAPPreviewView.m
//  deko
//
//  Created by Johan Halin on 9.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoIAPPreviewView.h"
#import "DekoConstants.h"

@interface DekoIAPPreviewView ()
@property (nonatomic) UIImageView *low;
@property (nonatomic) UIImageView *high;
@property (nonatomic) UIView *border;
@property (nonatomic) UIPanGestureRecognizer *panRecognizer;
@end

@implementation DekoIAPPreviewView

#pragma mark - Private

- (void)_updateBorderPositionWithX:(CGFloat)x
{
	self.high.frame = CGRectMake(self.bounds.origin.x,
								 self.bounds.origin.y,
								 x,
								 CGRectGetHeight(self.bounds));
	self.border.frame = CGRectMake(CGRectGetWidth(self.high.bounds),
								   self.high.bounds.origin.y,
								   3.0,
								   CGRectGetHeight(self.high.bounds));
}

- (void)_panRecognized:(UIPanGestureRecognizer *)recognizer
{
	CGPoint location = [recognizer locationInView:self];
	
	[self _updateBorderPositionWithX:location.x];
}

#pragma mark - Public

- (instancetype)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		_low = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iappreview-low"]];
		_low.contentMode = UIViewContentModeTopLeft;
		_low.clipsToBounds = YES;
		[self addSubview:_low];
		
		_high = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iappreview-high"]];
		_high.contentMode = _low.contentMode;
		_high.clipsToBounds = _low.clipsToBounds;
		[self addSubview:_high];
		
		_border = [[UIView alloc] initWithFrame:CGRectZero];
		_border.backgroundColor = [UIColor colorWithWhite:DekoBackgroundColor alpha:1.0];
		[self addSubview:_border];
		
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panRecognized:)];
		[self addGestureRecognizer:_panRecognizer];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

	[self _updateBorderPositionWithX:CGRectGetMidX(self.bounds)];

	self.low.frame = CGRectMake(self.bounds.origin.x,
								self.bounds.origin.y,
								CGRectGetWidth(self.bounds),
								CGRectGetHeight(self.bounds));
}

@end
