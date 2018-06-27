//
//  DekoLocalizationManager.h
//  deko
//
//  Created by Johan Halin on 8.2.2013.
//  Copyright (c) 2013 Aero Deko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DekoLocalizationManager : NSObject

@property (nonatomic, readonly) BOOL useSinaWeibo;

- (UIFont *)localizedFontWithSize:(CGFloat)size;

@end
