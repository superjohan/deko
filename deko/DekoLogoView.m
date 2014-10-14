//
//  DekoLogoView.m
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoLogoView.h"

typedef void(^CompletionBlock)(void);

@interface DekoLogoView ()
@property (nonatomic) NSMutableArray *logoPieces;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) CompletionBlock completion;
@end

@implementation DekoLogoView

#pragma mark - Private

- (void)_animateView:(UIView *)view
{
	AEAssert([view isKindOfClass:[UIImageView class]]);
	
	[UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^
	{
		view.alpha = 1;
	}
	completion:^(BOOL finished)
	{
		[self.logoPieces removeObject:view];
		
		if ([self.logoPieces count] == 0)
		{
			if (self.completion != nil)
			{
				self.completion();
			}
		}
	}];
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

#pragma mark - Public

- (void)setup
{	
	NSString *device = nil;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		device = @"ipad";
	}
	else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		device = @"iphone";
	}
	
	AEAssert(device != nil);
	
	self.logoPieces = [NSMutableArray array];
	
	UIView *logoContainer = [[UIView alloc] initWithFrame:CGRectZero];
	CGSize containerSize = CGSizeZero;
	
	for (NSInteger i = 1; i < 12; i++)
	{
		NSString *filename = [NSString stringWithFormat:@"logo%ld-%@", (long)i, device];
		UIImage *logoPiece = [UIImage imageNamed:filename];
		containerSize = logoPiece.size;
		UIImageView *logoPieceView = [[UIImageView alloc] initWithImage:logoPiece];
		logoPieceView.alpha = 0;
		[logoContainer addSubview:logoPieceView];
		[self.logoPieces addObject:logoPieceView];
	}
	logoContainer.frame = CGRectMake((self.bounds.size.width / 2.0) - (containerSize.width / 2.0),
									 (self.bounds.size.height / 2.0) - (containerSize.height / 2.0),
									 containerSize.width,
									 containerSize.height);
	logoContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:logoContainer];
	
	for (NSInteger i = 0; i < 20; i++)
	{
		NSInteger index1 = arc4random() % [self.logoPieces count];
		NSInteger index2 = -1;
		
		do
		{
			index2 = arc4random() % [self.logoPieces count];
		}
		while (index1 == index2);
		
		[self.logoPieces exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
	}
}

- (void)animateLogoWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
	AEAssert(self.logoPieces != nil);
	AEAssert(duration > 0);
	
	self.duration = duration;
	self.completion = completion;
	
	NSTimeInterval interval = (duration / 4.0) / (NSTimeInterval)[self.logoPieces count];
	NSInteger pieceCount = [self.logoPieces count];
	
	for (NSInteger i = 0; i < pieceCount; i++)
	{
		UIView *view = self.logoPieces[i];
		NSTimeInterval delay = i * interval;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
		{
			[self _animateView:view];
		});
	}
}

@end
