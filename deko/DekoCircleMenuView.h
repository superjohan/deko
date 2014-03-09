//
//  DekoCircleMenuView.h
//  deko
//
//  Created by Johan Halin on 24.12.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DekoCircleMenuView : UIView

@property (nonatomic, assign) CGFloat circleSize;
@property (nonatomic, assign) NSInteger items;
@property (nonatomic, assign) CGFloat overlap;
@property (nonatomic, assign) NSInteger selected;

@end
