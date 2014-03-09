//
//  DekoLogoView.h
//  deko
//
//  Created by Johan Halin on 26.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DekoLogoView : UIView

- (void)setup;
- (void)animateLogoWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

@end
