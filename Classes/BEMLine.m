//
//  BEMLine.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMLine.h"
#import "BEMSimpleLineGraphView.h"

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#else
#define CGFloatValue floatValue
#endif


@interface BEMLine()

@property (nonatomic, strong) NSMutableArray <NSValue *> *points;

@end

@implementation BEMLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _enableLeftReferenceFrameLine = YES;
        _enableBottomReferenceFrameLine = YES;
        _interpolateNullValues = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //----------------------------//
    //---- Draw Reference Lines ---//
    //----------------------------//
    self.layer.sublayers = nil;

    UIBezierPath *verticalReferenceLinesPath = [UIBezierPath bezierPath];
    UIBezierPath *horizontalReferenceLinesPath = [UIBezierPath bezierPath];
    UIBezierPath *referenceFramePath = [UIBezierPath bezierPath];

    verticalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    verticalReferenceLinesPath.lineWidth = 0.7f;

    horizontalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    horizontalReferenceLinesPath.lineWidth = 0.7f;

    referenceFramePath.lineCapStyle = kCGLineCapButt;
    referenceFramePath.lineWidth = 0.7f;

    if (self.enableReferenceFrame == YES) {
        if (self.enableBottomReferenceFrameLine) {
            // Bottom Line
            [referenceFramePath moveToPoint:CGPointMake(0, self.frame.size.height-self.referenceLineWidth/4)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height-self.referenceLineWidth/4)];
        }

        if (self.enableLeftReferenceFrameLine) {
            // Left Line
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(0+self.referenceLineWidth/4, 0)];
        }

        if (self.enableTopReferenceFrameLine) {
            // Top Line
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, self.referenceLineWidth/4)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, self.referenceLineWidth/4)];
        }

        if (self.enableRightReferenceFrameLine) {
            // Right Line
            [referenceFramePath moveToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, 0)];
        }
    }

    if (self.enableReferenceLines == YES) {
        if (self.arrayOfVerticalReferenceLinePoints.count > 0) {
            for (NSNumber *xNumber in self.arrayOfVerticalReferenceLinePoints) {
                CGFloat xValue =[xNumber doubleValue];
                CGPoint initialPoint = CGPointMake(xValue, self.frame.size.height);
                CGPoint finalPoint = CGPointMake(xValue, 0);

                [verticalReferenceLinesPath moveToPoint:initialPoint];
                [verticalReferenceLinesPath addLineToPoint:finalPoint];
            }
        }

        if (self.arrayOfHorizontalReferenceLinePoints.count > 0) {
            for (NSNumber *yNumber in self.arrayOfHorizontalReferenceLinePoints) {
                CGPoint initialPoint = CGPointMake(0, [yNumber floatValue]);
                CGPoint finalPoint = CGPointMake(self.frame.size.width, [yNumber floatValue]);

                [horizontalReferenceLinesPath moveToPoint:initialPoint];
                [horizontalReferenceLinesPath addLineToPoint:finalPoint];
            }
        }
    }


    //----------------------------//
    //----- Draw Average Line ----//
    //----------------------------//
    UIBezierPath *averageLinePath = [UIBezierPath bezierPath];
    if (self.averageLine.enableAverageLine == YES) {
        averageLinePath.lineCapStyle = kCGLineCapButt;
        averageLinePath.lineWidth = self.averageLine.width;

        CGPoint initialPoint = CGPointMake(0, self.averageLineYCoordinate);
        CGPoint finalPoint = CGPointMake(self.frame.size.width, self.averageLineYCoordinate);

        [averageLinePath moveToPoint:initialPoint];
        [averageLinePath addLineToPoint:finalPoint];
    }


    //----------------------------//
    //------ Draw Graph Line -----//
    //----------------------------//
    // LINE
    UIBezierPath *line = [UIBezierPath bezierPath];
    UIBezierPath *fillTop;
    UIBezierPath *fillBottom;

    self.points = [NSMutableArray arrayWithCapacity:self.arrayOfPoints.count];
    for (NSUInteger i = 0; i < self.arrayOfPoints.count; i++) {
        CGFloat yValue = [self.arrayOfPoints[i] CGFloatValue];;
        CGFloat xValue =[self.arrayOfXValues[i] CGFloatValue];
        if (self.arrayOfXValues && i < self.arrayOfXValues.count) xValue = self.arrayOfXValues[i].CGFloatValue;
        if (yValue >= BEMNullGraphValue  && self.interpolateNullValues) {
            //need to interpolate. For midpoints, just don't add a point
            if (i ==0) {
                //extrapolate a left edge point from next two actual values
                NSUInteger firstPos = 1; //look for first real value
                while (firstPos < self.arrayOfPoints.count && [self.arrayOfPoints[firstPos] CGFloatValue] >= BEMNullGraphValue) firstPos++;
                if (firstPos >= self.arrayOfPoints.count) break;  // all NaNs?? =>don't create any line

                CGFloat firstValue = [self.arrayOfPoints[firstPos] CGFloatValue];
                NSUInteger secondPos = firstPos+1; //look for second real value
                while (secondPos < self.arrayOfPoints.count && [self.arrayOfPoints[secondPos] CGFloatValue] >= BEMNullGraphValue) secondPos++;
                if (secondPos >= self.arrayOfPoints.count) {
                    // only one real number
                    yValue = firstValue;
                } else {
                    CGFloat delta = firstValue - [self.arrayOfPoints[secondPos] CGFloatValue];
                    yValue = firstValue + firstPos*delta/(secondPos-firstPos);
                }

            } else if (i == self.arrayOfPoints.count-1) {
                //extrapolate a right edge poit from previous two actual values
                NSInteger firstPos = i-1; //look for first real value
                while (firstPos >= 0 && [self.arrayOfPoints[firstPos] CGFloatValue] >= BEMNullGraphValue) firstPos--;
                if (firstPos < 0 ) continue;  // all NaNs?? =>don't create any line; should already be gone

                CGFloat firstValue = [self.arrayOfPoints[firstPos] CGFloatValue];
                NSInteger secondPos = firstPos-1; //look for second real value
                while (secondPos >= 0 && [self.arrayOfPoints[secondPos] CGFloatValue] >= BEMNullGraphValue) secondPos--;
                if (secondPos < 0) {
                    // only one real number
                    yValue = firstValue;
                } else {
                    CGFloat delta = firstValue - [self.arrayOfPoints[secondPos] CGFloatValue];
                    yValue = firstValue + (self.arrayOfPoints.count - firstPos-1)*delta/(firstPos - secondPos);
                }

            } else {
                continue; //skip this (middle Null) point, let graphics handle interpolation
            }
        }
        CGPoint newPoint = CGPointMake(xValue, yValue);
        [self.points addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    if (!self.disableMainLine && self.points.count > 0 ) {
        line = [BEMLine pathWithPoints2:self.points curved:self.bezierCurveIsEnabled open:YES];
    }
    //Temporarily leave background on quadratic to compare results
    //to Remove, delete PathWithPoints and rename PathWithPoints to PathWithPoints
    fillBottom = [BEMLine pathWithPoints:self.bottomPointsArray curved:self.bezierCurveIsEnabled open:NO];
    fillTop    = [BEMLine pathWithPoints:self.topPointsArray    curved:self.bezierCurveIsEnabled open:NO];

    //----------------------------//
    //----- Draw Fill Colors -----//
    //----------------------------//
    [self.topColor set];
    [fillTop fillWithBlendMode:kCGBlendModeNormal alpha:self.topAlpha];

    [self.bottomColor set];
    [fillBottom fillWithBlendMode:kCGBlendModeNormal alpha:self.bottomAlpha];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.topGradient != nil) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillTop CGPath]);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, self.topGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillTop.bounds)), (CGGradientDrawingOptions) 0);
        CGContextRestoreGState(ctx);
    }

    if (self.bottomGradient != nil) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillBottom CGPath]);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, self.bottomGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillBottom.bounds)), (CGGradientDrawingOptions) 0);
        CGContextRestoreGState(ctx);
    }


    //----------------------------//
    //------ Animate Drawing -----//
    //----------------------------//
    if (self.enableReferenceLines == YES) {
        CAShapeLayer *verticalReferenceLinesPathLayer = [CAShapeLayer layer];
        verticalReferenceLinesPathLayer.frame = self.bounds;
        verticalReferenceLinesPathLayer.path = verticalReferenceLinesPath.CGPath;
        verticalReferenceLinesPathLayer.opacity = (float)(self.lineAlpha <= 0 ? 0.1 : self.lineAlpha/2.0);
        verticalReferenceLinesPathLayer.fillColor = nil;
        verticalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;

        if (self.lineDashPatternForReferenceYAxisLines) {
            verticalReferenceLinesPathLayer.lineDashPattern = self.lineDashPatternForReferenceYAxisLines;
        }

        if (self.referenceLineColor) {
            verticalReferenceLinesPathLayer.strokeColor = self.referenceLineColor.CGColor;
        } else {
            verticalReferenceLinesPathLayer.strokeColor = self.color.CGColor;
        }

        if (self.animationTime > 0)
            [self animateForLayer:verticalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:verticalReferenceLinesPathLayer];


        CAShapeLayer *horizontalReferenceLinesPathLayer = [CAShapeLayer layer];
        horizontalReferenceLinesPathLayer.frame = self.bounds;
        horizontalReferenceLinesPathLayer.path = horizontalReferenceLinesPath.CGPath;
        horizontalReferenceLinesPathLayer.opacity = (float)(self.lineAlpha <= 0 ? 0.1 : self.lineAlpha/2.0);
        horizontalReferenceLinesPathLayer.fillColor = nil;
        horizontalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
        if(self.lineDashPatternForReferenceXAxisLines) {
            horizontalReferenceLinesPathLayer.lineDashPattern = self.lineDashPatternForReferenceXAxisLines;
        }

        if (self.referenceLineColor) {
            horizontalReferenceLinesPathLayer.strokeColor = self.referenceLineColor.CGColor;
        } else {
            horizontalReferenceLinesPathLayer.strokeColor = self.color.CGColor;
        }

        if (self.animationTime > 0)
            [self animateForLayer:horizontalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:horizontalReferenceLinesPathLayer];
    }

    CAShapeLayer *referenceLinesPathLayer = [CAShapeLayer layer];
    referenceLinesPathLayer.frame = self.bounds;
    referenceLinesPathLayer.path = referenceFramePath.CGPath;
    referenceLinesPathLayer.opacity = (float)(self.lineAlpha <= 0 ? 0.1 : self.lineAlpha/2.0);
    referenceLinesPathLayer.fillColor = nil;
    referenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;

    if (self.referenceLineColor) referenceLinesPathLayer.strokeColor = self.referenceLineColor.CGColor;
    else referenceLinesPathLayer.strokeColor = self.color.CGColor;

    if (self.animationTime > 0)
        [self animateForLayer:referenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
    [self.layer addSublayer:referenceLinesPathLayer];

    if (self.disableMainLine == NO) {
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = self.bounds;
        pathLayer.path = line.CGPath;
        pathLayer.strokeColor = self.color.CGColor;
        pathLayer.fillColor = nil;
        pathLayer.opacity = (float)self.lineAlpha;
        pathLayer.lineWidth = self.lineWidth;
        pathLayer.lineJoin = kCALineJoinBevel;
        pathLayer.lineCap = kCALineCapRound;
        if (self.animationTime > 0) [self animateForLayer:pathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
        if (self.lineGradient) [self.layer addSublayer:[self backgroundGradientLayerForLayer:pathLayer]];
        else [self.layer addSublayer:pathLayer];
    }

    if (self.averageLine.enableAverageLine == YES) {
        CAShapeLayer *averageLinePathLayer = [CAShapeLayer layer];
        averageLinePathLayer.frame = self.bounds;
        averageLinePathLayer.path = averageLinePath.CGPath;
        averageLinePathLayer.opacity = (float)self.averageLine.alpha;
        averageLinePathLayer.fillColor = nil;
        averageLinePathLayer.lineWidth = self.averageLine.width;

        if (self.averageLine.dashPattern) averageLinePathLayer.lineDashPattern = self.averageLine.dashPattern;

        if (self.averageLine.color) averageLinePathLayer.strokeColor = self.averageLine.color.CGColor;
        else averageLinePathLayer.strokeColor = self.color.CGColor;

        if (self.animationTime > 0)
            [self animateForLayer:averageLinePathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
        [self.layer addSublayer:averageLinePathLayer];
    }
}

- (NSArray <NSValue *> *) areaArrayWithEdgeAt:(CGFloat) edgeHeight  {
    CGFloat halfHeight = self.frame.size.height/2;
    CGPoint midLeftPoint = CGPointMake(0, halfHeight);
    CGPoint midRightPoint = CGPointMake(self.frame.size.width,halfHeight);
    if (self.points.count > 0) {
        midLeftPoint.y = self.points[0].CGPointValue.y;
        midRightPoint.y = [self.points lastObject].CGPointValue.y;
    }

    CGPoint topPointZero = CGPointMake(0,edgeHeight);
    CGPoint topPointFull = CGPointMake(self.frame.size.width, edgeHeight);
    NSMutableArray <NSValue *> *areaPoints = [NSMutableArray arrayWithArray:self.points];
    [areaPoints insertObject:[NSValue valueWithCGPoint:topPointZero] atIndex:0];
    [areaPoints insertObject:[NSValue valueWithCGPoint:midLeftPoint] atIndex:1];
    [areaPoints addObject:[NSValue valueWithCGPoint:midRightPoint]];
    [areaPoints addObject:[NSValue valueWithCGPoint:topPointFull]];
    return areaPoints;
}

- (NSArray <NSValue *> *)topPointsArray {
    return [self areaArrayWithEdgeAt:0];
}

- (NSArray <NSValue *> *)bottomPointsArray {
    return [self areaArrayWithEdgeAt:self.frame.size.height];
}

+ (UIBezierPath *)pathWithPoints:(NSArray <NSValue *> *)points curved:(BOOL) curved open:(BOOL) canSkipPoints {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];

    for (NSValue * point in points) {
        if (point == value) continue; //already at first point
        CGPoint p2 = [point CGPointValue];

        if (canSkipPoints && (p1.y >= BEMNullGraphValue || p2.y >= BEMNullGraphValue)) {
            [path moveToPoint:p2];
        } else if (curved) {
            CGPoint midPoint = midPointForPoints(p1, p2);
            [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
            [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        } else {
            [path addLineToPoint:p2];
        }
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    CGFloat avgY = (p1.y + p2.y) / 2.0;
    if (isinf(avgY)) avgY = BEMNullGraphValue;
    return CGPointMake((p1.x + p2.x) / 2, avgY);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = (CGFloat)fabs(p2.y - controlPoint.y);

    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;

    return controlPoint;
}
//Second algorithm


+ (UIBezierPath *)pathWithPoints2:(NSArray <NSValue *> *)points curved:(BOOL) curved open:(BOOL) open {
    //based on Roman Filippov code: http://stackoverflow.com/a/40203583/580850
    //open means allow gaps in path.
    //Also, if not open, then first/last points are for frame, and should not affect curve.
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint p1 = [points[0] CGPointValue];
    NSUInteger dataStart = open ? 1 : 2;
    NSUInteger dataEnd = points.count-(open ? 1 : 2);
    [path moveToPoint:p1];
    if (!open) {
        //skip first point (not data)
        dataStart = 2;
        p1 = [points[1] CGPointValue];
        [path addLineToPoint:p1];
    }
    CGPoint oldControlPoint = p1;
    for (NSUInteger pointIndex = dataStart; pointIndex< points.count; pointIndex++) {
        CGPoint p2 = [points[pointIndex]  CGPointValue];

        if (p1.y >= BEMNullGraphValue || p2.y >= BEMNullGraphValue) {
            if (open) {
                [path moveToPoint:p2];
            } else {
                [path addLineToPoint:p2];
            }
            oldControlPoint = p2;
        } else if (curved ) {
            CGPoint p3 = CGPointZero;
                //Don't let frame points beyond actual data affect curve.
            if (pointIndex < dataEnd) p3 = [points[pointIndex+1] CGPointValue] ;
            if (p3.y >= BEMNullGraphValue) p3 = CGPointZero;
            CGPoint newControlPoint = controlPointForPoints2(p1, p2, p3);
            if (!CGPointEqualToPoint( newControlPoint, CGPointZero)) {
                [path addCurveToPoint: p2 controlPoint1:oldControlPoint controlPoint2: newControlPoint];
                oldControlPoint = imaginForPoints( newControlPoint,  p2);
            } else {
                [path addCurveToPoint: p2 controlPoint1:oldControlPoint controlPoint2: p2];
                oldControlPoint = p2;
            }
        } else {
            [path addLineToPoint:p2];
            oldControlPoint = p2;
        }
        p1 = p2;
    }
    return path;
}

static CGPoint imaginForPoints(CGPoint point, CGPoint center) {
    //returns "mirror image" of point: the point that is symmetrical through center.
    if (CGPointEqualToPoint(point, CGPointZero) || CGPointEqualToPoint(center, CGPointZero)) {
        return CGPointZero;
    }
    CGFloat newX = center.x + (center.x-point.x);
    CGFloat newY = center.y + (center.y-point.y);
    if (isinf(newY)) {
        newY = BEMNullGraphValue;
    }
    return CGPointMake(newX,newY);
}

static CGFloat clamp(CGFloat num, CGFloat bounds1, CGFloat bounds2) {
    //ensure num is between bounds.
    if (bounds1 < bounds2) {
        return MIN(MAX(bounds1,num),bounds2);
    } else {
        return MIN(MAX(bounds2,num),bounds1);
    }
}

static CGPoint controlPointForPoints2(CGPoint p1, CGPoint p2, CGPoint p3) {
    if (CGPointEqualToPoint(p3, CGPointZero)) return CGPointZero;
    CGPoint leftMidPoint = midPointForPoints(p1, p2);
    CGPoint rightMidPoint = midPointForPoints(p2, p3);
    CGPoint imaginPoint = imaginForPoints(rightMidPoint, p2);
    CGPoint controlPoint = midPointForPoints(leftMidPoint, imaginPoint);

    controlPoint.y = clamp(controlPoint.y, p1.y, p2.y);

    CGFloat flippedP3 = p2.y + (p2.y-p3.y);

    controlPoint.y = clamp(controlPoint.y, p2.y, flippedP3);

    return controlPoint;
}

- (void)animateForLayer:(CAShapeLayer *)shapeLayer withAnimationType:(BEMLineAnimation)animationType isAnimatingReferenceLine:(BOOL)shouldHalfOpacity {
    if (animationType == BEMLineAnimationNone) return;
    else if (animationType == BEMLineAnimationFade) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        if (shouldHalfOpacity == YES) pathAnimation.toValue = [NSNumber numberWithDouble:self.lineAlpha <= 0 ? 0.1f : self.lineAlpha/2.0f];
        else pathAnimation.toValue = [NSNumber numberWithDouble:self.lineAlpha];
        [shapeLayer addAnimation:pathAnimation forKey:@"opacity"];

        return;
    } else if (animationType == BEMLineAnimationExpand) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithDouble:shapeLayer.lineWidth];
        [shapeLayer addAnimation:pathAnimation forKey:@"lineWidth"];

        return;
    } else {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];

        return;
    }
}

- (CALayer *)backgroundGradientLayerForLayer:(CAShapeLayer *)shapeLayer {
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    CGPoint start, end;
    if (self.lineGradientDirection == BEMLineGradientDirectionHorizontal) {
        start = CGPointMake(0, CGRectGetMidY(shapeLayer.bounds));
        end = CGPointMake(CGRectGetMaxX(shapeLayer.bounds), CGRectGetMidY(shapeLayer.bounds));
    } else {
        start = CGPointMake(CGRectGetMidX(shapeLayer.bounds), 0);
        end = CGPointMake(CGRectGetMidX(shapeLayer.bounds), CGRectGetMaxY(shapeLayer.bounds));
    }

    CGContextDrawLinearGradient(imageCtx, self.lineGradient, start, end, (CGGradientDrawingOptions)0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.contents = (id)image.CGImage;
    gradientLayer.mask = shapeLayer;
    return gradientLayer;
}

@end
