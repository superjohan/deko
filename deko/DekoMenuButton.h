//
//  DekoMenuButton.h
//  deko
//
//  Created by Johan Halin on 24.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DekoMenuButton;

@protocol DekoMenuButtonDelegate <NSObject>

@required
- (void)menuButton:(DekoMenuButton *)menuButton highlighted:(BOOL)highlighted;

@end

@interface DekoMenuButton : UIButton

@property (nonatomic, weak) NSObject<DekoMenuButtonDelegate> *delegate;

@end
