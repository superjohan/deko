//
//  DekoMenuButton.m
//  deko
//
//  Created by Johan Halin on 24.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "DekoMenuButton.h"

@implementation DekoMenuButton

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	
	[self.delegate menuButton:self highlighted:highlighted];
}

@end
