//
//  HarmonyStaticView.m
//  harmonyvisualengine
//
//  Created by Johan Halin on 8.11.2012.
//  Copyright (c) 2012 Aero Deko. All rights reserved.
//

#import "HarmonyStaticView.h"
#import "HarmonyShapeFunctions.h"
#import "HarmonyShape.h"
#import "HarmonyColorGenerator.h"
#import "HarmonyCanvasSettings.h"

@interface HarmonyStaticView ()
@property (nonatomic) HarmonyCanvasSettings *settings;
@end

const NSInteger DekoMaximumAttempts = 15;
const NSInteger DekoMaximumFreeAmount = 5000;
const NSTimeInterval DekoMaximumPhoneTime = 7.0;
const NSTimeInterval DekoMaximumPadTime = 10.0;

@implementation HarmonyStaticView

#pragma mark - Private

- (UIColor *)_shapeColor
{
	return [self.colorGenerator colorWithStartingHue:self.settings.hue
										   colorType:self.settings.colorType
									  brightnessType:self.settings.brightnessType
									  saturationType:self.settings.saturationType
										  mixingType:self.settings.mixingType
										  background:NO];
}

- (CGFloat)_valueForTransformType:(HarmonyShapeTransformType)type
{
	AEAssertV(type < HarmonyShapeTransformTypeMax, 0);
	
	if (type == HarmonyShapeTransformTypeStraight)
	{
		return self.settings.baseSize;
	}
	else if (type == HarmonyShapeTransformTypeSkew || type == HarmonyShapeTransformTypeStretch)
	{
		return (self.settings.baseSize + arc4random() % (NSInteger)self.settings.baseSize);
	}

	return 0;
}

- (CGFloat)_sizeValueForType:(HarmonySizeType)sizeType
{
	AEAssertV(sizeType < HarmonySizeTypeMax, 0);
	
	if (sizeType == HarmonySizeTypeUniform)
	{
		return self.settings.baseSize;
	}
	else if (sizeType == HarmonySizeTypeVariable)
	{
		return (CGFloat)((arc4random() % (NSInteger)self.settings.baseSize) + DekoMinimumShapeSize);
	}
	
	return -1;
}

- (CGFloat)_randomAngle
{
	NSInteger maximumRotation = (NSInteger)((M_PI * 2.0) * 1000000);
	CGFloat rotation = (arc4random() % maximumRotation) / 1000000.0;
	
	return rotation;
}

- (HarmonyShape *)_triangleWithLeftShape:(HarmonyShape *)leftShape
								topShape:(HarmonyShape *)topShape
						   topRightShape:(HarmonyShape *)topRightShape
						   transformType:(HarmonyShapeTransformType)transformType
							columnModulo:(NSInteger)modulo
{
	CGPoint p1 = CGPointZero;
	CGPoint p2 = CGPointZero;
	CGPoint p3 = CGPointZero;
	CGFloat width = [self _valueForTransformType:transformType];
	CGFloat height = [self _valueForTransformType:transformType];
	
	if (leftShape == nil && topRightShape == nil)
	{
		p2.y = p1.y + [self _valueForTransformType:transformType];
		p3.x = p1.x + [self _valueForTransformType:transformType];
	}
	else if (topRightShape == nil)
	{
		p1 = leftShape.p2;
		p2 = leftShape.p3;
		
		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p3.x = modulo == 1 ? p2.x + width: p1.x + width;
			p3.y = p1.y;
		}
		else
		{
			for (NSInteger attempts = 0; attempts < DekoMaximumAttempts; attempts++)
			{
				p3.x = p1.x + [self _valueForTransformType:transformType];
				if (modulo == 1)
					p3.y = p2.y + [self _valueForTransformType:transformType];
				
				if (![leftShape.bezierPath containsPoint:p3])
					break;
			}
		}
	}
	else if (leftShape == nil)
	{
		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p1 = topShape.p2;
			p2.y = p1.y + height;
			p3.x = p1.x + width;
			p3.y = p1.y;
		}
		else
		{
			p1 = topRightShape.p1;
			p2.y = p1.y + [self _valueForTransformType:transformType];
			p3 = topRightShape.p3;
		}
	}
	else
	{
		p1 = leftShape.p2;
		p2 = leftShape.p3;
		
		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p3.x = modulo == 1 ? p2.x + width: p1.x + width;
			p3.y = p1.y;
		}
		else
		{
			if (modulo == 0)
			{
				p3 = topRightShape.p3;
			}
			else
			{
				for (NSInteger attempts = 0; attempts < DekoMaximumAttempts; attempts++)
				{
					p3.x = p1.x + [self _valueForTransformType:transformType];
					p3.y = p2.y + [self _valueForTransformType:transformType];
					
					if (!([leftShape.bezierPath containsPoint:p3] || [topShape.bezierPath containsPoint:p3] || [topRightShape.bezierPath containsPoint:p3]))
						break;
				}
			}
		}
	}
		
	HarmonyShape *shape = [[HarmonyShape alloc] init];
	shape.p1 = p1;
	shape.p2 = p2;
	shape.p3 = p3;
	shape.bezierPath = triangle(p1, p2, p3, 0, [self _shapeColor]);
	
	return shape;
}

- (void)_recursiveQuadWithPoint1:(CGPoint)p1 point2:(CGPoint)p2 point3:(CGPoint)p3 point4:(CGPoint)p4 distance:(CGFloat)distance
{
	CGPoint p1p2 = CGPointMake((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);
	CGPoint p2p3 = CGPointMake((p2.x + p3.x) / 2.0, (p2.y + p3.y) / 2.0);
	CGPoint p3p4 = CGPointMake((p3.x + p4.x) / 2.0, (p3.y + p4.y) / 2.0);
	CGPoint p4p1 = CGPointMake((p4.x + p1.x) / 2.0, (p4.y + p1.y) / 2.0);
	CGPoint mid = CGPointMake((p1.x + p2.x + p3.x + p4.x) / 4.0, (p1.y + p2.y + p3.y + p4.y) / 4.0);
	
	quad(p1, p1p2, mid, p4p1, 0, [self _shapeColor]);
	quad(p1p2, p2, p2p3, mid, 0, [self _shapeColor]);
	quad(mid, p2p3, p3, p3p4, 0, [self _shapeColor]);
	quad(p4p1, mid, p3p4, p4, 0, [self _shapeColor]);
}

- (HarmonyShape *)_quadWithLeftShape:(HarmonyShape *)leftShape
							topShape:(HarmonyShape *)topShape
					   topRightShape:(HarmonyShape *)topRightShape
					   transformType:(HarmonyShapeTransformType)transformType
							sizeType:(HarmonySizeType)sizeType
{
	CGPoint p1 = CGPointZero;
	CGPoint p2 = CGPointZero;
	CGPoint p3 = CGPointZero;
	CGPoint p4 = CGPointZero;
	CGFloat width = [self _valueForTransformType:transformType];
	CGFloat height = [self _valueForTransformType:transformType];
	CGFloat baseDistance = self.settings.baseDistance;
	
	if (leftShape == nil && topShape == nil)
	{
		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p2.x = p1.x + width;
			p3.x = p1.x + width;
			p3.y = p2.y + height;
			p4.y = p1.y + height;
		}
		else
		{
			p2.x = p1.x + [self _valueForTransformType:transformType];
			p3.x = p1.x + [self _valueForTransformType:transformType];
			p3.y = p2.y + [self _valueForTransformType:transformType];
			p4.y = p1.y + [self _valueForTransformType:transformType];
		}
	}
	else if (topShape == nil)
	{
		p1.x = leftShape.p2.x + baseDistance;
		p1.y = leftShape.p2.y;
		p4.x = leftShape.p3.x + baseDistance;
		p4.y = leftShape.p3.y;

		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p2.x = p1.x + width;
			p3.x = p1.x + width;
			p3.y = p4.y;
		}
		else
		{
			p2.x = p1.x + [self _valueForTransformType:transformType];
			p3.x = leftShape.p3.x + [self _valueForTransformType:transformType] + baseDistance;
			p3.y = p2.y + [self _valueForTransformType:transformType];
		}
	}
	else if (leftShape == nil)
	{
		p1.x = topShape.p4.x;
		p1.y = topShape.p4.y + baseDistance;

		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p2.x = p1.x + width;
			p2.y = p1.y;
			p3.x = p2.x;
			p3.y = p1.y + height;
			p4.y = p3.y;
		}
		else
		{
			p2.x = topShape.p3.x;
			p2.y = topShape.p3.y + baseDistance;
			p3.x = p1.x + [self _valueForTransformType:transformType];
			p3.y = p2.y + [self _valueForTransformType:transformType];
			p4.y = p1.y + [self _valueForTransformType:transformType];
		}
	}
	else
	{
		if (transformType == HarmonyShapeTransformTypeStretch)
		{
			p1.x = leftShape.p2.x + baseDistance;
			p1.y = leftShape.p2.y;
			p2.x = p1.x + width;
			p2.y = p1.y;
			p3.x = p2.x;
			p3.y = leftShape.p3.y;
			p4.x = p1.x;
			p4.y = p3.y;
		}
		else
		{
			p1.x = topShape.p4.x;
			p1.y = topShape.p4.y + baseDistance;
			p2.x = topShape.p3.x;
			p2.y = topShape.p3.y + baseDistance;
			p4.x = leftShape.p3.x + baseDistance;
			p4.y = leftShape.p3.y;
			
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:p1];
			[path addLineToPoint:p2];
			[path addLineToPoint:p4];
			[path closePath];
			
			for (NSInteger attempts = 0; attempts < DekoMaximumAttempts; attempts++)
			{
				p3.x = p4.x + [self _valueForTransformType:transformType];
				p3.y = p2.y + [self _valueForTransformType:transformType];
				
				if (!([path containsPoint:p3] || [leftShape.bezierPath containsPoint:p3] || [topShape.bezierPath containsPoint:p3] || [topRightShape.bezierPath containsPoint:p3]))
					break;
			}
		}
	}
	
	HarmonyShape *shape = [[HarmonyShape alloc] init];
	shape.p1 = p1;
	shape.p2 = p2;
	shape.p3 = p3;
	shape.p4 = p4;
	shape.bezierPath = quad(p1, p2, p3, p4, 0, [self _shapeColor]);
	
	return shape;
}

- (HarmonyShape *)_circleWithLeftShape:(HarmonyShape *)leftShape topShape:(HarmonyShape *)topShape
{
	CGPoint p = CGPointZero;
	
	HarmonyShape *shape = [[HarmonyShape alloc] init];
	CGFloat baseSize = self.settings.baseSize;
	CGFloat baseDistance = self.settings.baseDistance;
	
	if (leftShape == nil && topShape == nil)
	{
		// do nothing
	}
	else if (topShape == nil)
	{
		p.x = leftShape.p1.x + baseSize + baseDistance;
	}
	else if (leftShape == nil)
	{
		p.y = topShape.p1.y + baseSize + baseDistance;
	}
	else
	{
		p.x = topShape.p1.x;
		p.y = topShape.p1.y + baseSize + baseDistance;
	}

	shape.p1 = p;
	shape.radius = baseSize / 2.0;
	shape.bezierPath = circle(p, shape.radius, [self _shapeColor]);
	
	return shape;
}

- (void)_createGridLayoutWithShapeType:(HarmonyShapeType)shapeType
						 transformType:(HarmonyShapeTransformType)transformType
							  sizeType:(HarmonySizeType)sizeType
					  horizontalAmount:(NSInteger)horizontalAmount
						verticalAmount:(NSInteger)verticalAmount
{
	NSMutableArray *rows = [NSMutableArray array];
	for (int row = 0; row < verticalAmount; row++)
	{
		NSMutableArray *vert = [NSMutableArray array];
		[rows addObject:vert];
		
		for (int column = 0; column < horizontalAmount; column++)
		{
			HarmonyShape *topRightShape = nil;
			if (row > 0 && column < [rows[row - 1] count] - 1)
			{
				topRightShape = rows[row - 1][column + 1];
			}
			
			HarmonyShape *topShape = nil;
			if (row > 0)
			{
				topShape = rows[row - 1][column];
			}
			
			HarmonyShape *leftShape = nil;
			if (column > 0)
			{
				leftShape = rows[row][column - 1];
			}
			
			HarmonyShape *shape = nil;
			if (shapeType == HarmonyShapeTypeTriangle)
			{
				shape = [self _triangleWithLeftShape:leftShape topShape:topShape topRightShape:topRightShape transformType:transformType columnModulo:column % 2];
			}
			else if (shapeType == HarmonyShapeTypeSquare)
			{
				shape = [self _quadWithLeftShape:leftShape topShape:topShape topRightShape:topRightShape transformType:transformType sizeType:sizeType];
			}
			else if (shapeType == HarmonyShapeTypeCircle)
			{
				shape = [self _circleWithLeftShape:leftShape topShape:topShape];
			}
			
			if (shape != nil)
			{
				[vert addObject:shape];
			}
		}
	}
}

- (HarmonyShape *)_shapeWithType:(HarmonyShapeType)shapeType sizeType:(HarmonySizeType)sizeType rotationType:(HarmonyRotationType)rotationType startPoint:(CGPoint)startPoint
{
	HarmonyShape *shape = [[HarmonyShape alloc] init];
	
	// TODO: transform type
	
	if (shapeType == HarmonyShapeTypeCircle)
	{
		shape.shapeType = HarmonyShapeTypeCircle;
		shape.p1 = startPoint;
		shape.radius = [self _sizeValueForType:sizeType];
		shape.bezierPath = circle(shape.p1, shape.radius, [self _shapeColor]);
	}
	else if (shapeType == HarmonyShapeTypeTriangle)
	{
		shape.shapeType = HarmonyShapeTypeTriangle;
		CGFloat length = [self _sizeValueForType:sizeType];
		CGPoint p1 = startPoint;
		CGPoint p2 = CGPointMake(p1.x + length, p1.y);
		CGPoint p3 = CGPointMake(p1.x + (length / 2.0), p1.y - ((length * sqrt(3)) / 2.0));
		
		CGFloat angle = 0;
		if (rotationType == HarmonyRotationTypeStraight)
		{
			angle = M_PI_2 * (CGFloat)(arc4random() % 4);
		}
		else if (rotationType == HarmonyRotationTypeDiagonal)
		{
			angle = M_PI_4 * (CGFloat)(arc4random() % 8);
		}
		else if (rotationType == HarmonyRotationTypeFree)
		{
			angle = [self _randomAngle];
		}
		
		shape.bezierPath = triangle(p1, p2, p3, angle, [self _shapeColor]);
	}
	else if (shapeType == HarmonyShapeTypeSquare)
	{
		shape.shapeType = HarmonyShapeTypeSquare;
		
		CGFloat length = [self _sizeValueForType:sizeType];
		CGPoint p1 = startPoint;
		CGPoint p2 = CGPointMake(p1.x + length, p1.y);
		CGPoint p3 = CGPointMake(p2.x, p2.y + length);
		CGPoint p4 = CGPointMake(p3.x - length, p3.y);
		
		CGFloat angle = 0;
		if (rotationType == HarmonyRotationTypeDiagonal)
		{
			if (arc4random() % 2)
			{
				angle = M_PI_4;
			}
		}
		else if (rotationType == HarmonyRotationTypeFree)
		{
			angle = [self _randomAngle];
		}
		
		shape.bezierPath = quad(p1, p2, p3, p4, angle, [self _shapeColor]);
	}
	
	return shape;
}

- (void)_createFreeLayoutWithShapeType:(HarmonyShapeType)shapeType
						 transformType:(HarmonyShapeTransformType)transformType
							  sizeType:(HarmonySizeType)sizeType
						  rotationType:(HarmonyRotationType)rotationType
								amount:(NSInteger)amount
{
	NSMutableArray *shapes = [NSMutableArray array];
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval maximumTime = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? DekoMaximumPadTime : DekoMaximumPhoneTime;
	
	for (NSInteger i = 0; i < amount; i++)
	{
		HarmonyShape *shape = [self _shapeWithType:shapeType
										  sizeType:sizeType
									  rotationType:rotationType
										startPoint:CGPointMake(arc4random() % (NSInteger)self.bounds.size.width, arc4random() % (NSInteger)self.bounds.size.height)];
		[shapes addObject:shape];
		
		NSTimeInterval timeSinceStartTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
		if (timeSinceStartTime > maximumTime)
		{
			AELOG_DEBUG(@"Rendering time longer than %f seconds. Bailing out.", maximumTime);
			break;
		}
	}
}

- (void)_createStripeLayoutWithSizeType:(HarmonySizeType)sizeType
{
	NSMutableArray *shapes = [[NSMutableArray alloc] init];
	NSInteger amount = floor(CGRectGetHeight(self.bounds) / DekoMinimumShapeSize);
	HarmonyShape *previousShape = nil;
	
	for (NSInteger i = 0; i < amount; i++)
	{
		HarmonyShape *shape = [[HarmonyShape alloc] init];
		CGFloat height = [self _sizeValueForType:sizeType];
		shape.p1 = CGPointMake(0, previousShape.p4.y + self.settings.baseDistance);
		shape.p2 = CGPointMake(CGRectGetWidth(self.bounds), shape.p1.y);
		shape.p3 = CGPointMake(shape.p2.x, shape.p2.y + height);
		shape.p4 = CGPointMake(shape.p1.x, shape.p3.y);
		shape.bezierPath = quad(shape.p1, shape.p2, shape.p3, shape.p4, 0, [self _shapeColor]);
		shape.shapeType = HarmonyShapeTypeSquare;
		[shapes addObject:shape];
		previousShape = shape;
	}
}

- (void)_createClusterLayoutWithShapeType:(HarmonyShapeType)shapeType
								 sizeType:(HarmonySizeType)sizeType
							 rotationType:(HarmonyRotationType)rotationType
							transformType:(HarmonyShapeTransformType)transformType
								   amount:(NSInteger)amount
{
	
	NSMutableArray *shapes = [[NSMutableArray alloc] init];
	CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	CGFloat length = (fabs(self.settings.baseDistance) * 5.0) + 1.0;
	centerPoint.x += length - (arc4random() % (NSInteger)(length * 2));
	centerPoint.y += length - (arc4random() % (NSInteger)(length * 2));
	CGPoint startPoint = CGPointZero;
	CGFloat xOffset = 0;
	CGFloat yOffset = 0;
	CGFloat size = self.settings.baseSize;
	
	for (NSInteger i = 0; i < amount; i++)
	{	
		if (shapeType == HarmonyShapeTypeCircle)
		{
			xOffset = (arc4random() % (NSInteger)size) - (size / 2.0);
			yOffset = (arc4random() % (NSInteger)size) - (size / 2.0);
		}
		else if (shapeType == HarmonyShapeTypeSquare)
		{
			xOffset = (arc4random() % (NSInteger)size) - size;
			yOffset = (arc4random() % (NSInteger)size) - size;
		}
		else
		{
			xOffset = (arc4random() % (NSInteger)size) - size;
			yOffset = (arc4random() % (NSInteger)size);
		}

		startPoint = CGPointMake(centerPoint.x + xOffset, centerPoint.y + yOffset);
		
		HarmonyShape *shape = [self _shapeWithType:shapeType sizeType:sizeType rotationType:rotationType startPoint:startPoint];
		[shapes addObject:shape];
	}
}

- (void)_createCanvasWithShapeType:(HarmonyShapeType)shapeType
					 transformType:(HarmonyShapeTransformType)transformType
					  positionType:(HarmonyPositionType)positionType
						  sizeType:(HarmonySizeType)sizeType
					  rotationType:(HarmonyRotationType)rotationType
						mixingType:(HarmonyMixingType)mixingType
{
    NSInteger horizontalAmount = floor(self.frame.size.width / (self.settings.baseSize / 2.0));
	if (horizontalAmount % 2 == 1)
		horizontalAmount++;
	NSInteger verticalAmount = floor(self.frame.size.height / (self.settings.baseSize / 2.0));
	if (verticalAmount % 2 == 1)
		verticalAmount++;
	
	if (mixingType == HarmonyMixingTypeOverlay)
	{
		CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeOverlay);
	}
	else if (mixingType == HarmonyMixingTypeEvenOdd)
	{
		CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
	}
	else if (mixingType == HarmonyMixingTypeMask)
	{
		CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeSoftLight);
	}
	else if (mixingType == HarmonyMixingTypeOverlap)
	{
		CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeLuminosity);
	}

	if (positionType == HarmonyPositionTypeGrid)
	{
		[self _createGridLayoutWithShapeType:shapeType transformType:transformType sizeType:sizeType horizontalAmount:horizontalAmount verticalAmount:verticalAmount];
	}
	else if (positionType == HarmonyPositionTypeFree)
	{
		NSInteger amount = horizontalAmount * verticalAmount;
		if (amount > DekoMaximumFreeAmount)
			amount = DekoMaximumFreeAmount;
		
		[self _createFreeLayoutWithShapeType:shapeType transformType:transformType sizeType:sizeType rotationType:rotationType amount:amount];
	}
	else if (positionType == HarmonyPositionTypeStripe)
	{
		[self _createStripeLayoutWithSizeType:sizeType];
	}
	else if (positionType == HarmonyPositionTypeCluster)
	{
		[self _createClusterLayoutWithShapeType:shapeType sizeType:sizeType rotationType:rotationType transformType:transformType amount:MAX(horizontalAmount, verticalAmount)];
	}
	else
	{
		NSLog(@"Unknown position type: %ld", (long)positionType);
	}
}

- (void)_drawBackgroundInRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
	
	UIColor *color1 = nil;
	UIColor *color2 = nil;
	CGFloat almostZero = 0.000001; // for backwards compatibility
	if (self.settings.background1Hue < almostZero &&
		self.settings.background1Saturation < almostZero &&
		self.settings.background1Brightness < almostZero &&
		self.settings.background2Hue < almostZero &&
		self.settings.background2Saturation < almostZero &&
		self.settings.background2Brightness < almostZero)
	{
		color1 = [self.colorGenerator colorWithStartingHue:self.settings.hue
												 colorType:self.settings.colorType
											brightnessType:self.settings.brightnessType
											saturationType:self.settings.saturationType
												mixingType:self.settings.mixingType
												background:YES];
		color2 = [self.colorGenerator colorWithStartingHue:self.settings.hue
												 colorType:self.settings.colorType
											brightnessType:self.settings.brightnessType
											saturationType:self.settings.saturationType
												mixingType:self.settings.mixingType
												background:YES];
	}
	else
	{
		color1 = [UIColor colorWithHue:self.settings.background1Hue saturation:self.settings.background1Saturation brightness:self.settings.background1Brightness alpha:1.0];
		color2 = [UIColor colorWithHue:self.settings.background2Hue saturation:self.settings.background2Saturation brightness:self.settings.background2Brightness alpha:1.0];
	}
	
    NSArray *colors = @[(id)color1.CGColor, (id)color2.CGColor];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
#ifdef DEBUG
	NSTimeInterval time1 = [NSDate timeIntervalSinceReferenceDate];
#endif
	
	[self _drawBackgroundInRect:rect];
	[self _createCanvasWithShapeType:self.settings.shapeType
					   transformType:self.settings.transformType
						positionType:self.settings.positionType
							sizeType:self.settings.sizeType
						rotationType:self.settings.rotationType
						  mixingType:self.settings.mixingType];

#ifdef DEBUG
	NSTimeInterval time2 = [NSDate timeIntervalSinceReferenceDate];
	AELOG_DEBUG(@"took %f seconds to render", time2 - time1);
#endif
}

#pragma mark - Public

- (void)updateCanvasWithSettings:(HarmonyCanvasSettings *)settings
{
	AEAssert(settings != nil);
	
	self.settings = settings;
	
	[self setNeedsDisplay];
	
	self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, self.settings.angle);
}

@end
