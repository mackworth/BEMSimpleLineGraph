//
//  BEMSimpleLineGraphView.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMSimpleLineGraphView.h"
#import "BEMGraphCalculator.h"  //just for deprecation warnings; should be removed

const CGFloat BEMNullGraphValue = CGFLOAT_MAX;


#if !__has_feature(objc_arc)
// Add the -fobjc-arc flag to enable ARC for only these files, as described in the ARC documentation: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
#error BEMSimpleLineGraph is built with Objective-C ARC. You must enable ARC for these files.
#endif

typedef NS_ENUM(NSInteger, BEMInternalTags)
{
    DotFirstTag100 = 100,
};

@interface BEMSimpleLineGraphView ()

#pragma mark Properties to store data and computed locations
/// The number of Points in the Graph
/// Set by layoutself.numberOfPoints
@property (assign, nonatomic ) NSInteger numberOfPoints;

/// All of the Data Points from datasource (Y values)
/// Set by getData and used throughout.
@property (strong, nonatomic ) NSArray <NSValue *> *dataPoints;

/// All of the Y-Axis Values as scaled to current view
// Set by getData; used by circleDotAtIndex, and handled to BEM to draw mainLine
@property (strong, nonatomic ) NSArray <NSValue *> *locations;

#pragma mark Properties to store main views (yAxis, xAxis, actual line, dots layer and labels layers
// Stores the background X Axis view
@property (strong, nonatomic ) UIView *backgroundXAxis;

// Stores the background Y Axis view
@property (strong, nonatomic) UIView *backgroundYAxis;

/// The line itself and decorators; these three views share same size and overlay each other.
@property (strong, nonatomic) BEMLine * masterLine;
///Container for all BEMCircle dots
@property (strong, nonatomic) UIView *dotsView;
///Container for all labels on dots and gestures
@property (strong, nonatomic) UIView *labelsView;

#pragma mark Properties to store all subviews; used to avoid recreating each time.
/// All of the Y-Axis Labels
@property (strong, nonatomic) NSArray <UILabel *> *yAxisLabels;

/// All of the X-Axis Labels
@property (strong, nonatomic) NSArray <UILabel *> *xAxisLabels;

/// All of the X-Axis label texts (for testing)
@property (strong, nonatomic) NSArray <NSString *> *xAxisLabelTexts;

/// All of the dataPoint Labels
@property (strong, nonatomic) NSArray <UILabel *> *permanentPopups;

/// All of the dataPoint dots
@property (strong, nonatomic) NSArray <BEMCircle *> *circleDots;

/// The vertical line which appears when the user drags across the graph
@property (strong, nonatomic) UIView *touchInputLine;

/// Label to display when there is no data
@property (strong, nonatomic) UILabel *noDataLabel;

/// The label displayed when enablePopUpReport is set to YES
@property (strong, nonatomic) UILabel *popUpLabel;

// Possible custom View displayed instead of popUpLabel
@property (strong, nonatomic) UIView *customPopUpView;

#pragma mark Gesture Recognizers and supporting globals

/// The gesture recognizer picking up the pan in the graph view
@property (strong, nonatomic) UIPanGestureRecognizer *touchReportPanGesture;

/// This gesture recognizer picks up the initial touch on the graph view
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;

@property (strong, nonatomic) UIPinchGestureRecognizer *zoomGesture;
@property (strong, nonatomic) UIPanGestureRecognizer * zoomPanGesture;

// set by zoomPanGesture to pan along X axis
@property (nonatomic) CGFloat panMovementBase;
@property (nonatomic) CGFloat panMovement;

//used during zoom to remember original anchor point and corresponding value
@property (nonatomic) CGFloat zoomCenterLocation;
@property (nonatomic) CGFloat zoomCenterValue;

//used to restore zoom
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGesture;
// set by doubleTap to remember previous scale
@property (nonatomic) CGFloat doubleTapScale;
@property (nonatomic) CGFloat doubleTapPanMovement;

#pragma mark Calculated min/max properties; set by getData

/// The biggest value out of all of the data points
@property (nonatomic) CGFloat maxYValue;

/// The smallest value out of all of the data points
@property (nonatomic) CGFloat minYValue;

/// The biggest value on the X axis
@property (nonatomic) CGFloat maxXValue;

/// The smallest value on the X axis
@property (nonatomic) CGFloat minXValue;

// Stores the current view size to detect whether a redraw is needed in layoutSubviews
@property (nonatomic) CGSize currentViewSize;

@end


@implementation BEMSimpleLineGraphView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self commonInit];
    [self restorePropertyWithCoder:coder];
    return self;
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    [self restorePropertyWithCoder:coder];
}

- (void)restorePropertyWithCoder:(NSCoder *)coder {

#define RestoreProperty(property, type) \
if ([coder containsValueForKey:@#property]) { \
self.property = [coder decode ## type ##ForKey:@#property]; \
}\

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"

    RestoreProperty (animationGraphEntranceTime, Float);
    RestoreProperty (animationGraphStyle, Integer);
    
    RestoreProperty (colorXaxisLabel, Object);
    RestoreProperty (colorYaxisLabel, Object);
    RestoreProperty (colorTop, Object);
    RestoreProperty (colorLine, Object);
    RestoreProperty (colorBottom, Object);
    RestoreProperty (colorPoint, Object);
    RestoreProperty (colorTouchInputLine, Object);
    RestoreProperty (colorBackgroundPopUplabel, Object);
    RestoreProperty (colorBackgroundYaxis, Object);
    RestoreProperty (colorBackgroundXaxis, Object);
    RestoreProperty (averageLine.color, Object);

    RestoreProperty (alphaTop, Float);  //float is sufficent, and works on 32-bit
    RestoreProperty (alphaLine, Float);
    RestoreProperty (alphaTouchInputLine, Float);
    RestoreProperty (alphaBackgroundXaxis, Float);
    RestoreProperty (alphaBackgroundYaxis, Float);

    RestoreProperty (widthLine, Float);
    RestoreProperty (widthReferenceLines, Float);
    RestoreProperty (sizePoint, Float);
    RestoreProperty (widthTouchInputLine, Float);

    RestoreProperty (enableTouchReport, Bool);
    RestoreProperty (enablePopUpReport, Bool);
    RestoreProperty (enableUserScaling, Bool);
    RestoreProperty (enableBezierCurve, Bool);
    RestoreProperty (enableXAxisLabel, Bool);
    RestoreProperty (enableYAxisLabel, Bool);
    RestoreProperty (autoScaleYAxis, Bool);
    RestoreProperty (alwaysDisplayDots, Bool);
    RestoreProperty (alwaysDisplayPopUpLabels, Bool);
    RestoreProperty (enableLeftReferenceAxisFrameLine, Bool);
    RestoreProperty (enableBottomReferenceAxisFrameLine, Bool);
    RestoreProperty (interpolateNullValues, Bool);
    RestoreProperty (displayDotsOnly, Bool);
    RestoreProperty (displayDotsWhileAnimating, Bool);

    RestoreProperty (touchReportFingersRequired, Int);
    RestoreProperty (formatStringForValues, Object);

    RestoreProperty (averageLine, Object);
#pragma clang diagnostic pop
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [self encodePropertiesWithCoder:coder];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [self encodePropertiesWithCoder:coder];
}

- (void)encodePropertiesWithCoder:(NSCoder *)coder {

#define EncodeProperty(property, type) [coder encode ## type: self.property forKey:@#property]

    EncodeProperty (labelFont, Object);
    EncodeProperty (animationGraphEntranceTime, Double);
    EncodeProperty (animationGraphStyle, Integer);

    EncodeProperty (colorXaxisLabel, Object);
    EncodeProperty (colorYaxisLabel, Object);
    EncodeProperty (colorTop, Object);
    EncodeProperty (colorLine, Object);
    EncodeProperty (colorBottom, Object);
    EncodeProperty (colorPoint, Object);
    EncodeProperty (colorTouchInputLine, Object);
    EncodeProperty (colorBackgroundPopUplabel, Object);
    EncodeProperty (colorBackgroundYaxis, Object);
    EncodeProperty (colorBackgroundXaxis, Object);
    EncodeProperty (averageLine.color, Object);

    EncodeProperty (alphaTop, Double);
    EncodeProperty (alphaLine, Double);
    EncodeProperty (alphaTouchInputLine, Double);
    EncodeProperty (alphaBackgroundXaxis, Double);
    EncodeProperty (alphaBackgroundYaxis, Double);

    EncodeProperty (widthLine, Double);
    EncodeProperty (widthReferenceLines, Double);
    EncodeProperty (sizePoint, Double);
    EncodeProperty (widthTouchInputLine, Double);

    EncodeProperty (enableTouchReport, Bool);
    EncodeProperty (enablePopUpReport, Bool);
    EncodeProperty (enableUserScaling, Bool);
    EncodeProperty (enableBezierCurve, Bool);
    EncodeProperty (enableXAxisLabel, Bool);
    EncodeProperty (enableYAxisLabel, Bool);
    EncodeProperty (autoScaleYAxis, Bool);
    EncodeProperty (alwaysDisplayDots, Bool);
    EncodeProperty (alwaysDisplayPopUpLabels, Bool);
    EncodeProperty (enableLeftReferenceAxisFrameLine, Bool);
    EncodeProperty (enableBottomReferenceAxisFrameLine, Bool);
    EncodeProperty (enableTopReferenceAxisFrameLine, Bool);
    EncodeProperty (enableRightReferenceAxisFrameLine, Bool);
    EncodeProperty (interpolateNullValues, Bool);
    EncodeProperty (displayDotsOnly, Bool);
    EncodeProperty (displayDotsWhileAnimating, Bool);

    [coder encodeInt: (int)(self.touchReportFingersRequired) forKey:@"touchReportFingersRequired"];
    EncodeProperty (formatStringForValues, Object);
    EncodeProperty (averageLine, Object);
}

- (void)commonInit {
    // Do any initialization that's common to both -initWithFrame: and -initWithCoder: in this method

    // Set the X Axis label font
    _labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    // Set Animation Values
    _animationGraphEntranceTime = 1.5;

    // Set Color Values
    _colorXaxisLabel = [UIColor blackColor];
    _colorYaxisLabel = [UIColor blackColor];
    _colorTop = [UIColor colorWithRed:0 green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    _colorLine = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    _colorBottom = [UIColor colorWithRed:0 green:122.0f/255.0f blue:255.0f/255.0f alpha:1];
    _colorPoint = [UIColor colorWithWhite:1.0f alpha:0.7f];
    _colorTouchInputLine = [UIColor grayColor];
    _colorBackgroundPopUplabel = [UIColor whiteColor];
    _alphaTouchInputLine = 0.2f;
    _widthTouchInputLine = 1.0;
    _colorBackgroundXaxis = nil;
    _alphaBackgroundXaxis = 1.0;
    _colorBackgroundYaxis = nil;
    _alphaBackgroundYaxis = 1.0;
    _displayDotsWhileAnimating = YES;

    // Set Alpha Values
    _alphaTop = 1.0;
    _alphaBottom = 1.0;
    _alphaLine = 1.0;

    // Set Size Values
    _widthLine = 1.0;
    _widthReferenceLines = 1.0;
    _sizePoint = 10.0;

    // Set Default Feature Values
    _enableTouchReport = NO;
    _touchReportFingersRequired = 1;
    _enablePopUpReport = NO;
    _enableBezierCurve = NO;
    _enableXAxisLabel = YES;
    _enableYAxisLabel = NO;
    _autoScaleYAxis = YES;
    _alwaysDisplayDots = NO;
    _alwaysDisplayPopUpLabels = NO;
    _enableLeftReferenceAxisFrameLine = YES;
    _enableBottomReferenceAxisFrameLine = YES;
    _formatStringForValues = @"%.0f";
    _interpolateNullValues = YES;
    _displayDotsOnly = NO;
    _enableUserScaling = NO;
    _zoomScale = 1.0;
    _panMovement = 0;
    _panMovementBase = 0;
    _doubleTapScale = 1.0;
    _doubleTapPanMovement = 0;
    _zoomCenterLocation = 0;
    _zoomCenterValue = 0;


    // Initialize BEM Objects
    _averageLine = [[BEMAverageLine alloc] init];

    if (!self.backgroundYAxis) self.backgroundYAxis = [[UIView alloc] initWithFrame:CGRectZero];
    if (!self.backgroundXAxis) self.backgroundXAxis = [[UIView alloc] initWithFrame:CGRectZero];
    if (!self.masterLine)  self.masterLine = [[BEMLine alloc] initWithFrame:CGRectZero];
    if (!self.dotsView)   self.dotsView = [[UIView alloc] initWithFrame:CGRectZero];
    if (!self.labelsView) self.labelsView = [[UIView alloc] initWithFrame:CGRectZero];

    [self addSubview: self.backgroundYAxis];
    [self addSubview: self.backgroundXAxis];
    [self addSubview: self.masterLine];
    [self addSubview: self.dotsView];
    [self addSubview: self.labelsView];

}

- (void)drawGraph {
    // Let the delegate know that the graph began layout updates
    if ([self.delegate respondsToSelector:@selector(lineGraphDidBeginLoading:)])
        [self.delegate lineGraphDidBeginLoading:self];

    // Get the number of points in the graph
    self.numberOfPoints = [self getNumberOfPoints];

    if (self.numberOfPoints <= 0) {
        [self showNoData];
    } else {
        [self clearNoData];
        // Draw the graph
        [self drawEntireGraph];

        // Setup the touch report
        [self layoutTouchReport];
        [self startUserScaling];
    }
    // Let the delegate know that the graph finished updates
    if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
        [self.delegate lineGraphDidFinishLoading:self];
    [self didFinishDrawingWithAnimation: self.numberOfPoints > 0];

}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (CGSizeEqualToSize(self.currentViewSize, self.bounds.size))  return;
    self.currentViewSize = self.bounds.size;

    [self drawGraph];
}

- (void)clearGraph {
    for (UIView * subView in self.subviews) {
        for (UIView * subSubView in subView.subviews) {
            [subSubView removeFromSuperview];
        }
    }
    self.masterLine.points = @[];
    [self.masterLine setNeedsDisplay];
}

- (NSInteger)getNumberOfPoints {
    // Get the total number of data points from the delegate
#ifndef TARGET_INTERFACE_BUILDER
    if ([self.dataSource respondsToSelector:@selector(numberOfPointsInLineGraph:)]) {
        return [self.dataSource numberOfPointsInLineGraph:self];
    } else {
        return 0;
    }
#else
    return 10;
#endif
}

- (void)clearNoData {
    [self.noDataLabel removeFromSuperview];
}

- (void)showNoData {
   // There are no points to load
    [self clearGraph];
   if (self.delegate &&
       [self.delegate respondsToSelector:@selector(noDataLabelEnableForLineGraph:)] &&
       ![self.delegate noDataLabelEnableForLineGraph:self]) {
       return ;
   }

   NSLog(@"[BEMSimpleLineGraph] Data source contains no data. A no data label will be displayed and drawing will stop. Add data to the data source and then reload the graph.");
   if (!self.noDataLabel) {
       self.noDataLabel = [[UILabel alloc] initWithFrame:self.bounds];
       self.noDataLabel.backgroundColor = [UIColor clearColor];
       self.noDataLabel.textAlignment = NSTextAlignmentCenter;
   }
   NSString *noDataText = NSLocalizedString(@"No Data", nil);
   if ([self.delegate respondsToSelector:@selector(noDataLabelTextForLineGraph:)]) {
       noDataText = [self.delegate noDataLabelTextForLineGraph:self];
   }
   self.noDataLabel.text = noDataText;
   self.noDataLabel.font = self.noDataLabelFont ?: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
   self.noDataLabel.textColor = self.noDataLabelColor ?: (self.colorXaxisLabel ?: [UIColor blackColor]);

   [self addSubview:self.noDataLabel];
}

- (void)startUserScaling {
    if (self.enableUserScaling) {
        if (!self.zoomGesture) {
            _zoomScale = 1.0;
            self.zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomGestureAction:)];
            self.zoomGesture.delegate = self;
            [self.labelsView addGestureRecognizer:self.zoomGesture];

            self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureAction:)];
            self.doubleTapGesture.delegate = self;
            self.doubleTapGesture.numberOfTapsRequired = 2;
            [self.labelsView addGestureRecognizer:self.doubleTapGesture];

            self.zoomPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
            self.zoomPanGesture.delegate = self;
            self.zoomPanGesture.minimumNumberOfTouches = 2;
            [self.labelsView addGestureRecognizer:self.zoomPanGesture];

        }
    } else {
        _zoomScale = 1.0;
        if (self.zoomGesture) {
            self.zoomGesture.delegate = nil;
            [self.labelsView removeGestureRecognizer:self.zoomGesture];
            self.zoomGesture = nil;
            [self drawEntireGraph];  // was on, now off, so need to redraw
        }
        if (self.doubleTapGesture) {
            self.doubleTapGesture.delegate = nil;
            [self.labelsView removeGestureRecognizer:self.doubleTapGesture];
            self.doubleTapGesture = nil;
        }
    }
}

- (void)layoutTouchReport {
    // If the touch report is enabled, set it up
    if (self.enableTouchReport == YES || self.enablePopUpReport == YES) {
        // Initialize the vertical gray line that appears where the user touches the graph.
        if (!self.touchInputLine) {
            self.touchInputLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.widthTouchInputLine, self.labelsView.bounds.size.height)];
        }
        self.touchInputLine.alpha = 0;
        self.touchInputLine.backgroundColor = self.colorTouchInputLine;
        [self.labelsView addSubview:self.touchInputLine];

        if (!self.touchReportPanGesture) {
            self.touchReportPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
            self.touchReportPanGesture.delegate = self;
            [self.touchReportPanGesture setMaximumNumberOfTouches:1];
            [self.labelsView addGestureRecognizer:self.touchReportPanGesture];

            self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
            self.longPressGesture.minimumPressDuration = 0.1f;
            [self.labelsView addGestureRecognizer:self.longPressGesture];
        }
    } else {
        [self.touchInputLine removeFromSuperview];
        if (self.touchReportPanGesture) {
            self.touchReportPanGesture.delegate = nil;
            [self.labelsView removeGestureRecognizer:self.touchReportPanGesture];
            self.touchReportPanGesture = nil;
            self.longPressGesture.delegate = nil;
            [self.labelsView removeGestureRecognizer: self.longPressGesture];
            self.longPressGesture = nil;
        }
    }
}

#pragma mark - Drawing

- (void)didFinishDrawingWithAnimation:(BOOL)animated {
    NSTimeInterval animateTime = animated ? self.animationGraphEntranceTime : 0.01;
    if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishDrawing:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (animateTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Let the delegate know that the graph finished rendering
            [self.delegate lineGraphDidFinishDrawing:self];

        });
    }
}

- (void)divideUpView {
    //carves up main view into axes and graph areas
    CGRect frameForRest = self.bounds;

    CGRect frameForBackgroundYAxis = CGRectZero;
    if (self.enableYAxisLabel) {
        CGFloat yAxisWidth = [self calculateWidestLabel] + 2.0f;
        CGRectEdge edge = self.positionYAxisRight ? CGRectMaxXEdge : CGRectMinXEdge;
        CGRectDivide(self.bounds, &frameForBackgroundYAxis, &frameForRest, yAxisWidth, edge);
    }

    CGRect frameForBackgroundXAxis = CGRectZero;
    if (self.enableXAxisLabel) {
        CGFloat xAxisHeight  =  self.labelFont.pointSize + 8.0f;
        CGRectEdge edge = self.positionXAxisTop ? CGRectMinYEdge : CGRectMaxYEdge;
        CGRectDivide(frameForRest, &frameForBackgroundXAxis, &frameForRest, xAxisHeight, edge);
    }

    self.backgroundYAxis.frame = frameForBackgroundYAxis;
    self.backgroundXAxis.frame = frameForBackgroundXAxis;
    self.masterLine.frame = frameForRest;
    self.dotsView.frame = frameForRest;
    self.labelsView.frame = frameForRest;

    [self addSubview: self.backgroundYAxis];
    [self addSubview: self.backgroundXAxis];
    [self addSubview: self.masterLine];
    [self addSubview: self.dotsView];
    [self addSubview: self.labelsView];
}

- (void)drawEntireGraph {
    // The following method calls are in this specific order for a reason
    // Changing the order of the method calls below can result in drawing glitches and even crashes

    self.dataPoints = [self getData];
    [self calculateMinMax];

    [self divideUpView];  //requires dataPoints and Min/Max

    self.locations = [self layoutPoints]; //requires main views to be sized

    // Draw the Y-Axis
    [self drawYAxis];

   // Draw the X-Axis
    [self drawXAxis];

    // Draw line with bottom and top fill
    [self drawLine];

    // Draw the data points and labels
    [self drawDots];

}

- (CGFloat)labelWidthForValue:(CGFloat)value {
    NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};
    NSString *valueString = [self yAxisTextForValue:value];
    NSString *labelString = [valueString stringByReplacingOccurrencesOfString:@"[0-9-]" withString:@"N" options:NSRegularExpressionSearch range:NSMakeRange(0, [valueString length])];
    return [labelString sizeWithAttributes:attributes].width;
}

- (CGFloat)calculateWidestLabel {
    NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};
    CGFloat widestNumber;
    if (self.autoScaleYAxis == YES){
        widestNumber = MAX([self labelWidthForValue:self.maxYValue],
                           [self labelWidthForValue:self.minYValue]);
    } else {
        widestNumber  = [self labelWidthForValue:CGRectGetMaxY(self.backgroundYAxis.bounds)] ;
    }
    if (self.averageLine.enableAverageLine) {
        return MAX(widestNumber,    [self.averageLine.title sizeWithAttributes:attributes].width);
    } else {
        return widestNumber;
    }
}

- (BEMCircle *)circleDotAtIndex:(NSUInteger)index   {

    BEMCircle * circleDot = nil;
    CGRect dotFrame = CGRectMake(0, 0, self.sizePoint, self.sizePoint);
    if (index < self.circleDots.count) {
        circleDot = self.circleDots[index];
        circleDot.frame = dotFrame;
        [circleDot setNeedsDisplay];
    } else {
        circleDot = [[BEMCircle alloc] initWithFrame:dotFrame];
    }
    circleDot.frame = dotFrame;
    circleDot.tag = (NSInteger) index + DotFirstTag100;
    [self.dotsView addSubview:circleDot];

    CGFloat dotValue = self.dataPoints[index].CGPointValue.y;
    circleDot.absoluteValue = dotValue;
    if (dotValue >= BEMNullGraphValue) {
        // If we're dealing with an null value, don't draw the dot (but put it in yAxis to interpolate line)
        [circleDot removeFromSuperview];
        return circleDot;
    }

    CGFloat positionOnXAxis =  self.locations[index].CGPointValue.x;
    if (positionOnXAxis < -self.sizePoint/2 ||  positionOnXAxis > self.dotsView.bounds.size.width + self.sizePoint/2 ) {
        //off screen so not visible
        [circleDot removeFromSuperview];
        return circleDot;
    }

    CGFloat positionOnYAxis = self.locations[index].CGPointValue.y;
    circleDot.center = CGPointMake(positionOnXAxis, positionOnYAxis);
    circleDot.color = self.colorPoint;

    return circleDot;
}

- (void)drawDots {
    // Loop through each point and add it to the graph
    NSUInteger numPoints = (NSUInteger) self.numberOfPoints;
    NSMutableArray <UILabel *> *newPopups = [NSMutableArray arrayWithCapacity:numPoints];
    NSMutableArray <UIView *> *newDots = [NSMutableArray arrayWithCapacity:numPoints];
    @autoreleasepool {
        for (NSUInteger index = 0; index < numPoints; index++) {

            BEMCircle * circleDot = [self circleDotAtIndex: index];
            [newDots addObject:circleDot];

            UILabel * label = nil;
            if (index < self.permanentPopups.count) {
                label = self.permanentPopups[index];
            } else {
                label = [[UILabel alloc] initWithFrame:CGRectZero];
            }

            if (circleDot.superview) {

                if ((self.alwaysDisplayPopUpLabels == YES)  &&
                    (![self.delegate respondsToSelector:@selector(lineGraph:alwaysDisplayPopUpAtIndex:)] ||
                      [self.delegate lineGraph:self alwaysDisplayPopUpAtIndex:(NSInteger)index])) {
                        label = [self configureLabel:label forPoint: circleDot avoiding: newPopups ];

                } else {
                    //not showing labels this time, so remove if any
                    [label removeFromSuperview];
                }

                // Dot and/or label entrance animation
                circleDot.alpha = 0.0f;
                label.alpha = 0.0f;
                BOOL displayDots = self.alwaysDisplayDots || self.numberOfPoints == 1;
                if (self.animationGraphEntranceTime <= 0) {
                    if (displayDots) {
                        circleDot.alpha = 1.0f;
                    }
                   if (label) label.alpha = 1.0f;
                } else if (!_displayDotsWhileAnimating && displayDots) {
                    //turn all dots/labels on after main animation.
                    [UIView animateWithDuration:0.3
                                          delay:self.animationGraphEntranceTime - 0.3
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         circleDot.alpha = 1.0;
                                         label.alpha = 1.0;
                                     }
                                     completion:nil ];
                } else if (label || self.displayDotsWhileAnimating || displayDots) {
                    [UIView animateWithDuration: MAX(0.3,self.animationGraphEntranceTime/self.numberOfPoints)
                                          delay: self.animationGraphEntranceTime*(circleDot.center.x/CGRectGetMaxX(self.dotsView.bounds))
                                        options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            if (self.displayDotsWhileAnimating) {
                                circleDot.alpha = 1.0;
                                if (label) label.alpha = 1.0;
                            }
                    } completion:^(BOOL finished) {
                        if (displayDots != self.displayDotsWhileAnimating ||
                            (label && !self.displayDotsWhileAnimating)  ) {
                            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                circleDot.alpha = displayDots ? 1 : 0;
                                if (label) label.alpha = 1.0;
                            } completion:nil];
                        }
                    }];
                }

            } else {
                [label removeFromSuperview];
            }
            [newPopups addObject:label ];
       }
        for (NSUInteger i = numPoints; i < self.circleDots.count;  i++) {
            [self.permanentPopups[i] removeFromSuperview]; //no harm if not showing
            [self.circleDots [i] removeFromSuperview];
        }
        self.permanentPopups = [newPopups copy]; //save for next time
        self.circleDots = [newDots copy];
    }
}

- (void)drawLine {
    BEMLine * line = self.masterLine;
    line.opaque = NO;
    line.alpha = 1;
    line.backgroundColor = [UIColor clearColor];
    line.topColor = self.colorTop;
    line.bottomColor = self.colorBottom;
    line.topAlpha = self.alphaTop;
    line.bottomAlpha = self.alphaBottom;
    line.topGradient = self.gradientTop;
    line.bottomGradient = self.gradientBottom;
    line.lineWidth = self.widthLine;
    line.referenceLineWidth = self.widthReferenceLines > 0.0 ? self.widthReferenceLines : (self.widthLine/2);
    line.lineAlpha = self.alphaLine;
    line.bezierCurveIsEnabled = self.enableBezierCurve;
    line.points = self.locations;
    line.lineDashPatternForReferenceYAxisLines = self.lineDashPatternForReferenceYAxisLines;
    line.lineDashPatternForReferenceXAxisLines = self.lineDashPatternForReferenceXAxisLines;
    line.interpolateNullValues = self.interpolateNullValues;

    line.enableReferenceFrame = self.enableReferenceAxisFrame;
    line.enableRightReferenceFrameLine = self.enableRightReferenceAxisFrameLine;
    line.enableTopReferenceFrameLine = self.enableTopReferenceAxisFrameLine;
    line.enableLeftReferenceFrameLine = self.enableLeftReferenceAxisFrameLine;
    line.enableBottomReferenceFrameLine = self.enableBottomReferenceAxisFrameLine;

    if (self.enableReferenceXAxisLines || self.enableReferenceYAxisLines) {
        line.enableReferenceLines = YES;
        line.referenceLineColor = self.colorReferenceLines;
        //Note that arrayOfVerticalReferenceLinePioints (and horizontal) must be set already by drawYaxis and drawXAxis
    } else {
        line.enableReferenceLines = NO;
    }

    line.color = self.colorLine;
    line.lineGradient = self.gradientLine;
    line.lineGradientDirection = self.gradientLineDirection;
    line.animationTime = self.animationGraphEntranceTime;
    line.animationType = self.animationGraphStyle;

    if (self.averageLine.enableAverageLine == YES) {
        line.averageLineYCoordinate = [self yPositionForDotValue:self.averageLine.yValue];
    }
    line.averageLine = self.averageLine;

    line.disableMainLine = self.displayDotsOnly && self.numberOfPoints > 1;

    [self.masterLine setNeedsDisplay];

}

- (void)drawXAxis {

    for (UILabel * label in self.xAxisLabels) {
        [label removeFromSuperview];
    }
    self.xAxisLabels = nil;

    if (!self.enableXAxisLabel) {
        [self.backgroundXAxis removeFromSuperview];
        self.masterLine.arrayOfVerticalReferenceLinePoints = [NSArray array];
        return;
    }
    if (!([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)] ||
          [self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForLocation:)])) return;

    // Draw X-Axis Background Area

    if (self.colorBackgroundXaxis) {
        self.backgroundXAxis.backgroundColor = self.colorBackgroundXaxis;
        self.backgroundXAxis.alpha = self.alphaBackgroundXaxis;
    } else {
        self.backgroundXAxis.backgroundColor = self.colorBottom;
        self.backgroundXAxis.alpha = self.alphaBottom;
    }

    //labels can be one of three kinds.
    //The default is evenly spaced, indexed, tied to data points, numbered 0, 1, 2... i
    //If the datapoint's x-location is specifed with lineGraph:locationForPointAtIndex, then the labels will follow (although now numbered with the x-locations).
    //If the function numberOfXAxisLabelsOnLineGraph: is also implemented, then labels move back to evenly spaced.

    NSArray <NSValue *> * allLabelLocations = nil;
    CGFloat xAxisWidth = CGRectGetWidth(self.backgroundXAxis.bounds);
    
    if ([self.delegate respondsToSelector:@selector(numberOfXAxisLabelsOnLineGraph:) ]) {
        NSInteger numberLabels = [self.delegate numberOfXAxisLabelsOnLineGraph: self];
        if (numberLabels <= 0) numberLabels = 1;
        NSMutableArray <NSValue *> * labelLocs = [NSMutableArray arrayWithCapacity:(NSUInteger)numberLabels];
        if ([self.dataSource respondsToSelector:@selector(lineGraph:locationForPointAtIndex: )]) {
            CGFloat step = xAxisWidth/(numberLabels-1);
            CGFloat positionOnXAxis = 0;
            for (NSInteger i = 0; i < numberLabels; i++) {
                [labelLocs addObject:[NSValue valueWithCGPoint:CGPointMake(positionOnXAxis, 0)]];
                positionOnXAxis += step;
            }
        } else {
            CGFloat indicesDisplayed = self.maxXDisplayedValue - self.minXDisplayedValue;
            CGFloat step = indicesDisplayed / (numberLabels-1);
            CGFloat currIndex = (CGFloat)ceil(self.minXDisplayedValue);
            for (NSInteger i = 0; i < numberLabels; i++) {
                NSUInteger index = (NSUInteger)currIndex; //default rounding
                [labelLocs addObject:self.locations[index]];
                currIndex += step;
            }
        }
        allLabelLocations = [NSArray arrayWithArray:labelLocs];
    } else {
        allLabelLocations = self.locations;
    }

    NSArray <NSNumber *> *axisIndices = nil;
    if ([self.delegate respondsToSelector:@selector(incrementPositionsForXAxisOnLineGraph:)]) {
        axisIndices = [self.delegate incrementPositionsForXAxisOnLineGraph:self];
    } else {
        NSInteger baseIndex = 0;
        NSInteger increment = 1;
        if ([self.delegate respondsToSelector:@selector(baseIndexForXAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementIndexForXAxisOnLineGraph:)]) {
            baseIndex = [self.delegate baseIndexForXAxisOnLineGraph:self];
            increment = [self.delegate incrementIndexForXAxisOnLineGraph:self];
        } else if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabelsOnLineGraph:)]) {
            increment = [self.delegate numberOfGapsBetweenLabelsOnLineGraph:self] + 1;
            if (increment >= self.numberOfPoints -1) {
                //need at least two points
                baseIndex = 0;
                increment = self.numberOfPoints - 1;
            } else {
                NSInteger leftGap = increment - 1;
                NSInteger rightGap = self.numberOfPoints % increment;
                NSInteger offset = (leftGap-rightGap)/2;
                baseIndex = increment - 1 - offset;
            }
        }
        if (increment == 0) increment = 1;

        NSMutableArray <NSNumber *> *values = [NSMutableArray array ];
        NSInteger index = baseIndex;
        while (index < (NSInteger)allLabelLocations.count) {
            [values addObject:@(index)];
            index += increment;
        }
        axisIndices = [values copy];
    }

    NSMutableArray <NSNumber *> *newReferenceLinePoints = [NSMutableArray arrayWithCapacity:axisIndices.count];;
    NSMutableArray <NSString *> *newAxisLabelTexts =      [NSMutableArray arrayWithCapacity:axisIndices.count];
    NSMutableArray <UIView *>   *newXAxisLabels =         [NSMutableArray arrayWithCapacity:axisIndices.count];

    @autoreleasepool {
        BOOL usingLocation = [self.dataSource respondsToSelector:@selector(lineGraph:locationForPointAtIndex: )];
        BOOL locationLabels = usingLocation && [self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForLocation:)];
        BOOL indexLabels =   !usingLocation && [self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)];
        CGFloat valueRangeWidth = (self.maxXValue - self.minXValue) / self.zoomScale;

        for (NSNumber *indexNum in axisIndices) {
            NSUInteger index = indexNum.unsignedIntegerValue;
            if (index >= allLabelLocations.count) continue;
            NSString *xAxisLabelText = @"";
            CGFloat positionOnXAxis = allLabelLocations[index].CGPointValue.x ;
            CGFloat realValue = self.minXDisplayedValue + valueRangeWidth * positionOnXAxis/xAxisWidth;
            if (locationLabels) {
                if (positionOnXAxis >= 0  && positionOnXAxis <= xAxisWidth +.01) {
                //have to convert back to value from  viewLoc
                   //  CGFloat realValue = [self valueForDisplayPoint:positionOnXAxis];
                    xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForLocation:realValue];
                }
            } else {
                NSInteger realIndex = (NSInteger)(round(realValue));
                if (realIndex < 0) realIndex = 0;
                if (realIndex >= self.numberOfPoints) realIndex = self.numberOfPoints - 1;
                if (indexLabels) {
                    xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForIndex:realIndex ];
                } else {
                    xAxisLabelText = [NSString stringWithFormat:@"%lu", (long)realIndex];
                }
            }
            [newAxisLabelTexts addObject:xAxisLabelText];

            UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atLocation:positionOnXAxis  reuseNumber: index];
            [newXAxisLabels addObject:labelXAxis];

            if (positionOnXAxis >= 0  && positionOnXAxis <= xAxisWidth + .01) {
                [self.backgroundXAxis addSubview:labelXAxis];
                if (self.enableReferenceXAxisLines &&
                    (allLabelLocations[index].CGPointValue.y < BEMNullGraphValue || self.interpolateNullValues)) {
                    [newReferenceLinePoints addObject:@(positionOnXAxis)];
                }
            }
        }
    }
    self.xAxisLabels = [newXAxisLabels copy];
    self.xAxisLabelTexts = [newAxisLabelTexts copy];
    self.masterLine.arrayOfVerticalReferenceLinePoints = [newReferenceLinePoints copy];

    UILabel *prevLabel = nil;

    for (UILabel *label in self.xAxisLabels) {
        if (label == self.xAxisLabels[0]) {
            prevLabel = label; //always show first label
        } else if (label.superview) { //only look at active labels
                                      //allow at least five points betwen labels
            if (CGRectGetMaxX(prevLabel.frame) + 5 < CGRectGetMinX( label.frame))  {
                prevLabel = label;  //no overlap and inside frame, so show this one
            } else {
                [label removeFromSuperview]; // Overlapped
            }
        }
    };
}

- (NSString *)xAxisTextForIndex:(NSInteger)index {
    NSString *xAxisLabelText = @"";

    if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
        xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForIndex:index];
    }
    return xAxisLabelText;
}

- (NSString *)xAxisTextForLocation:(CGFloat)location {
    NSString *xAxisLabelText = @"";
    if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForLocation:)]) {
        xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForLocation:location];
    }
    return xAxisLabelText;
}

- (UILabel *)xAxisLabelWithText:(NSString *)text atLocation:(CGFloat)positionOnXAxis reuseNumber:(NSUInteger)xAxisLabelNumber{
    UILabel *labelXAxis;
    if (xAxisLabelNumber < self.xAxisLabels.count) {
        labelXAxis = self.xAxisLabels[xAxisLabelNumber];
    } else {
        labelXAxis = [[UILabel alloc] init];
    }

    labelXAxis.text = text;
    labelXAxis.font = self.labelFont;
    labelXAxis.textAlignment = 1;
    labelXAxis.textColor = self.colorXaxisLabel;
    labelXAxis.backgroundColor = [UIColor clearColor];

    // Add support multi-line, but this might overlap with the graph line if text have too many lines
    labelXAxis.numberOfLines = 0;
    CGRect lRect = [labelXAxis.text boundingRectWithSize:self.backgroundXAxis.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelXAxis.font} context:nil];
    CGFloat halfWidth = lRect.size.width/2;

    //if labels are partially on screen, nudge onto screen
    if (positionOnXAxis + halfWidth >= 0) positionOnXAxis = MAX(positionOnXAxis, halfWidth);
    CGFloat rightEdge = CGRectGetMaxX(self.backgroundXAxis.bounds) ;
    if (positionOnXAxis - halfWidth <= rightEdge) {
            positionOnXAxis = MIN(positionOnXAxis, rightEdge - halfWidth-.1f);
    }
    labelXAxis.frame = lRect;
    labelXAxis.center = CGPointMake(positionOnXAxis, CGRectGetMidY(self.backgroundXAxis.bounds));
    return labelXAxis;
}

- (NSString *)yAxisTextForValue:(CGFloat)value {
    if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnYAxisForValue:)]) {
        return [self.dataSource lineGraph:self labelOnYAxisForValue:value];
    }

    NSString *yAxisSuffix = @"";
    NSString *yAxisPrefix = @"";
    if ([self.delegate respondsToSelector:@selector(yAxisPrefixOnLineGraph:)]) yAxisPrefix = [self.delegate yAxisPrefixOnLineGraph:self];
    if ([self.delegate respondsToSelector:@selector(yAxisSuffixOnLineGraph:)]) yAxisSuffix = [self.delegate yAxisSuffixOnLineGraph:self];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value];
#pragma clang diagnostic pop

    return [NSString stringWithFormat:@"%@%@%@", yAxisPrefix, formattedValue, yAxisSuffix];
}

- (UILabel *)yAxisLabelWithText:(NSString *)text atValue:(CGFloat)value reuseNumber:(NSInteger)reuseNumber {
    //provide a Y-Axis Label with text at Value, reusing reuseNumber'd label if it exists
    //special case: use self.Averageline.label if reuseNumber = NSIntegerMax
    CGFloat labelHeight = self.labelFont.pointSize + 7.0f;
    CGFloat backgroundWidth = self.backgroundYAxis.bounds.size.width - 1.0f;
    CGRect frameForLabelYAxis = CGRectMake(1.0f, 0.0f, backgroundWidth, labelHeight);

    CGFloat xValueForCenterLabelYAxis = backgroundWidth /2.0f;
    NSTextAlignment textAlignmentForLabelYAxis = NSTextAlignmentRight;

    UILabel *labelYAxis;
    if ( reuseNumber == NSIntegerMax) {
        if (!self.averageLine.label) {
            self.averageLine.label = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
        }
        labelYAxis = self.averageLine.label;
    } else if (reuseNumber < (NSInteger)self.yAxisLabels.count && reuseNumber >= 0) {
        labelYAxis = self.yAxisLabels[(NSUInteger)reuseNumber];
    } else {
        labelYAxis = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
    }

    labelYAxis.frame = frameForLabelYAxis;
    labelYAxis.text = text;
    labelYAxis.textAlignment = textAlignmentForLabelYAxis;
    labelYAxis.font = self.labelFont;
    labelYAxis.textColor = self.colorYaxisLabel;
    labelYAxis.backgroundColor = [UIColor clearColor];
    CGFloat yAxisPosition = [self yPositionForDotValue:value];
    if (self.enableXAxisLabel && self.positionXAxisTop) {
        //because y axis frame is independent of xaxis presence (as opposed to dot view), we have to adjust here
        yAxisPosition += CGRectGetHeight(self.backgroundXAxis.frame);
    }
    CGFloat halfLabel = labelHeight/2;
    CGFloat topEdge = CGRectGetMaxY(self.backgroundYAxis.bounds);
    //nudge partially visible top/bottom labels onto screen
    if (yAxisPosition > -halfLabel && yAxisPosition < halfLabel) {
        yAxisPosition = halfLabel;
    } else if (yAxisPosition > topEdge - halfLabel && yAxisPosition < topEdge +halfLabel) {
        yAxisPosition = topEdge - halfLabel;
    }
    labelYAxis.center = CGPointMake(xValueForCenterLabelYAxis, yAxisPosition);


    return labelYAxis;
}

- (void)drawYAxis {

    if (!self.enableYAxisLabel) {
        [self.backgroundYAxis removeFromSuperview];
        [self.averageLine.label removeFromSuperview];
        self.averageLine.label = nil;
        for (UILabel * label in self.yAxisLabels) {
            [label removeFromSuperview];
        }
        self.yAxisLabels = nil;
        return;
    }

    //Make Background for Y Axis
    if (self.colorBackgroundYaxis) {
        self.backgroundYAxis.backgroundColor = self.colorBackgroundYaxis;
        self.backgroundYAxis.alpha = self.alphaBackgroundYaxis;
    } else {
        self.backgroundYAxis.backgroundColor =  self.colorTop;
        self.backgroundYAxis.alpha = self.alphaTop;
    }

    NSInteger numberOfLabels = 3;
    if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) {
        numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        if (numberOfLabels <= 0) return;
    }

    //Now calculate baseValue and increment for all scenarios
    CGFloat dotValue;
    CGFloat increment;
    if (self.autoScaleYAxis) {
        // Plot according to min-max range

        if (numberOfLabels == 1) {
            dotValue = (self.minYValue + self.maxYValue)/2.0f;
            increment = 0; //NA
        } else {
            dotValue = self.minYValue;
            increment = (self.maxYValue - self.minYValue)/(numberOfLabels-1);
            if ([self.delegate respondsToSelector:@selector(baseValueForYAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementValueForYAxisOnLineGraph:)]) {
                dotValue = [self.delegate baseValueForYAxisOnLineGraph:self];
                increment = [self.delegate incrementValueForYAxisOnLineGraph:self];
                if (increment <= 0) increment = 1;
                numberOfLabels = (NSInteger)((self.maxYValue - dotValue)/increment)+1;
                if (numberOfLabels > 100) {
                    NSLog(@"[BEMSimpleLineGraph] Increment does not properly lay out Y axis, bailing early");
                    return;
                }
            }
        }
    } else {
        //not AutoScale
        CGFloat graphHeight = self.backgroundYAxis.bounds.size.height;
        if (numberOfLabels == 1) {
            dotValue = graphHeight/2.0f;
            increment = 0; //NA
        } else {
            increment = graphHeight / numberOfLabels;
            dotValue = increment/2;
        }
    }
    NSMutableArray <UIView *>   *newLabels = [NSMutableArray arrayWithCapacity:(NSUInteger)numberOfLabels];
    NSMutableArray <NSNumber *> *newPoints = [NSMutableArray arrayWithCapacity:(NSUInteger)numberOfLabels];

    @autoreleasepool {
        for (NSInteger index = 0; index < numberOfLabels; index++) {
            NSString *labelText = [self yAxisTextForValue:dotValue];
            UILabel *labelYAxis = [self yAxisLabelWithText:labelText
                                                   atValue:dotValue
                                               reuseNumber:index];

            [self.backgroundYAxis addSubview:labelYAxis];
            [newLabels addObject:labelYAxis];
            if (self.enableReferenceYAxisLines) {
                [newPoints addObject:@(labelYAxis.center.y)];
            }
            dotValue += increment;
        }
    }
    for (NSUInteger index = (NSUInteger)numberOfLabels; index < self.yAxisLabels.count ; index++) {
        [self.yAxisLabels[index] removeFromSuperview];
    }

    UILabel * averageLabel = nil;
    if (self.averageLine.enableAverageLine && self.averageLine.title.length > 0 && self.numberOfPoints > 1) {
        self.averageLine.yValue = self.getAverageValue;
        averageLabel = [self yAxisLabelWithText:self.averageLine.title
                                                 atValue:self.averageLine.yValue
                                             reuseNumber:NSIntegerMax];

        [self.backgroundYAxis addSubview:averageLabel];
    } else {
        [self.averageLine.label removeFromSuperview];
    }
    self.averageLine.label = averageLabel;

    // Detect overlapped labels
    UILabel * prevLabel = nil;
    for (UILabel * label in newLabels) {
        if (label == newLabels[0] || //always show first label
            (CGRectIsNull(CGRectIntersection(prevLabel.frame,              label.frame)) &&
             (!averageLabel ||
              CGRectIsNull(CGRectIntersection(averageLabel.frame,          label.frame))) &&
             CGRectContainsRect(self.backgroundYAxis.bounds,               label.frame))) {
            prevLabel = label;  //no overlap and inside frame, so show this one
        } else {
            [label removeFromSuperview];  // Overlapped
        }
    };

    self.yAxisLabels =      [newLabels copy];
    self.masterLine.arrayOfHorizontalReferenceLinePoints = [newPoints copy];

}


- (UILabel *)configureLabel:(UILabel *)oldLabel forPoint:(BEMCircle *)circleDot avoiding:(NSArray <UILabel *> *)previousLabels {

    UILabel *newPopUpLabel = oldLabel;
    if ( !newPopUpLabel) {
        newPopUpLabel =[[UILabel alloc] init];
        newPopUpLabel.alpha = 0;
    }

    newPopUpLabel.textAlignment = NSTextAlignmentCenter;
    newPopUpLabel.numberOfLines = 0;
    newPopUpLabel.font = self.labelFont;
    newPopUpLabel.backgroundColor = [UIColor clearColor];
    newPopUpLabel.layer.backgroundColor = [self.colorBackgroundPopUplabel colorWithAlphaComponent:0.7f].CGColor;
    newPopUpLabel.layer.cornerRadius = 6;

    NSInteger index = circleDot.tag - DotFirstTag100;

    // Populate the popup label text with values
    newPopUpLabel.text = nil;
    if ([self.delegate respondsToSelector:@selector(popUpTextForlineGraph:atIndex:)]) newPopUpLabel.text = [self.delegate popUpTextForlineGraph:self atIndex:index];

    // If the supplied popup label text is nil we can proceed to fill out the text using suffixes, prefixes, and the graph's data source.
    if (newPopUpLabel.text == nil) {
        NSString *prefix = @"";
        NSString *suffix = @"";

        if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
            suffix = [self.delegate popUpSuffixForlineGraph:self];

        if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)])
            prefix = [self.delegate popUpPrefixForlineGraph:self];

        double value = (index <= (NSInteger)self.dataPoints.count && index >= 0) ?  self.dataPoints[(NSUInteger)index].CGPointValue.y : 0; // @((NSInteger) circleDot.absoluteValue)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
        //note this can indeed crash if delegate provides junk for formatString (e.g. %@); try/catch doesn't work
        NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value];
#pragma clang diagnostic pop
        newPopUpLabel.text = [NSString stringWithFormat:@"%@%@%@", prefix, formattedValue, suffix];
    }
    CGSize requiredSize = [newPopUpLabel sizeThatFits:CGSizeMake(100.0f, CGFLOAT_MAX)];
    newPopUpLabel.frame = CGRectMake(10, 10, requiredSize.width+10.0f, requiredSize.height+10.0f);

    [self adjustXLocForLabel:newPopUpLabel avoidingDot:circleDot.frame];

    if ( [self adjustYLocForLabel:newPopUpLabel
                          atIndex:index
                       avoidingDot:circleDot.frame
                        andLabels: previousLabels] ) {
        [self.labelsView addSubview:newPopUpLabel];
    } else {
       [newPopUpLabel removeFromSuperview];
    }

    return newPopUpLabel;
}

- (void)adjustXLocForLabel:(UIView *)popUpLabel avoidingDot:(CGRect)circleDotFrame {

    //now fixup left/right layout issues
    CGFloat xCenter = CGRectGetMidX(circleDotFrame);
    CGFloat halfLabelWidth = popUpLabel.frame.size.width/2 ;
    CGFloat rightEdge = CGRectGetMaxX(self.labelsView.bounds);
    if ((xCenter - halfLabelWidth <= 0) && (xCenter + halfLabelWidth > 0)) {
        //When bumping into left Y axis or edge, but not all the way off
        xCenter = halfLabelWidth + 4.0f;
    } else if ((xCenter + halfLabelWidth >= rightEdge) &&  (xCenter + halfLabelWidth > rightEdge)) {
        //When bumping into right Y axis or edge, but not all the way off
        xCenter = rightEdge - halfLabelWidth - 4.0f;
    }
    popUpLabel.center = CGPointMake(xCenter, popUpLabel.center.y);
}

- (BOOL)adjustYLocForLabel:(UIView *)popUpLabel atIndex:(NSInteger)myIndex avoidingDot:(CGRect)dotFrame andLabels:(NSArray <UILabel *> *)previousLabels {
    //returns YES if it can avoid neighbors to left
    //note: index < 0 for no checking neighbors
    //check for bumping into top OR overlap with left neighbors
    //default Y is above point
    //check above and below dot
    CGFloat halfLabelHeight = popUpLabel.frame.size.height/2.0f;
    popUpLabel.center = CGPointMake(popUpLabel.center.x, CGRectGetMinY(dotFrame) - 12.0f - halfLabelHeight );
    CGFloat leftEdge = CGRectGetMinX(popUpLabel.frame);

    if (CGRectGetMinY(popUpLabel.frame) > 2.0f) {
        BOOL noConflict = YES;
        if (myIndex < 0) return YES;
        for (UILabel * neighbor in previousLabels.reverseObjectEnumerator) {
            if (!neighbor.superview) continue;
            if (leftEdge > CGRectGetMaxX(neighbor.frame)) {
                return YES; //no conflicts found at all
            }
            if (!CGRectIsEmpty(CGRectIntersection(popUpLabel.frame, neighbor.frame))) {
                noConflict = NO;
                break; // conflict with neighbor
            }
        }
        if (noConflict) return YES;
    }
    //conflict (or too high), try below point instead
    CGRect frame = popUpLabel.frame;
    frame.origin.y = CGRectGetMaxY(dotFrame)+12.0f;
    popUpLabel.frame = frame;
    //check for bottom and again for overlap with neighbors
    if (CGRectGetMaxY(frame) < CGRectGetMaxY(self.labelsView.bounds)) {
        BOOL noConflict = YES;
        if (myIndex < 0) return YES;
       for (UILabel * neighbor in previousLabels.reverseObjectEnumerator ) {
           if (!neighbor.superview) continue;
            if (leftEdge > CGRectGetMaxX(neighbor.frame)) {
                return YES; //no conflicts found at all
            }
            if (!CGRectIsEmpty(CGRectIntersection(popUpLabel.frame, neighbor.frame))) {
                noConflict = NO;
                break; // conflict with neighbor
            }
        }
        return noConflict;
    } else {
        return NO;
    }
}


- (UIImage *)graphSnapshotImage {
    return [self graphSnapshotImageRenderedWhileInBackground:NO];
}

- (UIImage *)graphSnapshotImage:(CGSize)size {
    CGRect testRect = CGRectMake(0, 0, size.height, size.width);
    CGRect savedRect = self.frame;
    CGFloat savedAnimationTime = self.animationGraphEntranceTime;
    self.animationGraphEntranceTime = 0.0;
    self.frame = testRect;

    UIImage * result =  [self graphSnapshotImageRenderedWhileInBackground:NO];
    self.animationGraphEntranceTime = savedAnimationTime;
    self.frame = savedRect;
    return result;
}

- (UIImage *)graphSnapshotImageRenderedWhileInBackground:(BOOL)appIsInBackground {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);

    if (appIsInBackground == NO) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) [self.layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Data Source

- (void)reloadGraph {
    [self drawGraph];
    //    [self setNeedsLayout];
}

#pragma mark - Values

- (NSArray <NSString *> *)graphValuesForXAxis {
    return self.xAxisLabelTexts;
}

- (NSArray <NSNumber *> *)graphValuesForDataPoints {
    NSMutableArray * points = [NSMutableArray arrayWithCapacity:self.dataPoints.count];
    for (NSValue * point in self.dataPoints) {
        [points addObject:@(point.CGPointValue.y)];
    }
    return [points copy];
}

- (NSArray <UILabel *> *)graphLabelsForXAxis {
    return self.xAxisLabels;
}

- (NSArray <UILabel *> *)graphLabelsForYAxis {
    return self.yAxisLabels;
}

- (void)setAnimationGraphStyle:(BEMLineAnimation)animationGraphStyle {
    _animationGraphStyle = animationGraphStyle;
    if (_animationGraphStyle == BEMLineAnimationNone)
        self.animationGraphEntranceTime = 0.f;
}


#pragma mark - Touch Gestures

- (CGFloat)xValueForLocation:(CGFloat)location {

    CGFloat xAxisWidth = CGRectGetMaxX(self.labelsView.bounds);
    CGFloat valueRangeWidth = (self.maxXValue - self.minXValue) / self.zoomScale;
    return self.minXDisplayedValue + valueRangeWidth * location/xAxisWidth;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGFloat xLoc = [gestureRecognizer locationInView:self.labelsView].x;
    if ([gestureRecognizer isEqual:self.touchReportPanGesture]) {
        if ((NSInteger)gestureRecognizer.numberOfTouches >= self.touchReportFingersRequired) {
            CGPoint translation = [self.touchReportPanGesture velocityInView:self.labelsView];
            return fabs(translation.y) < fabs(translation.x);
        } else {
            return NO;
        }
    } else if ([gestureRecognizer isEqual:self.zoomGesture]) {
        ((UIPinchGestureRecognizer *)gestureRecognizer).scale = self.zoomScale;
        self.doubleTapScale = 1.0;
        self.zoomCenterLocation = xLoc;
        self.zoomCenterValue = [self xValueForLocation:xLoc];
       return YES;
    } else if ([gestureRecognizer isEqual:self.zoomPanGesture]) {
       self.doubleTapPanMovement = 0;
        self.panMovementBase = xLoc;
        return YES;
    } else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
- (void)setZoomScale:(CGFloat)zoomScale {
    if (zoomScale !=_zoomScale ) {
        if (self.labelsView) {
            [self handleZoom:zoomScale orMovement:self.panMovement checkDelegate:NO];
        } else {
            _zoomScale = zoomScale;
        }
    }
}

- (void)setPanMovement:(CGFloat)panMovement {
    if (panMovement != _panMovement ) {
        if (self.labelsView) {
            [self handleZoom:self.zoomScale orMovement:panMovement checkDelegate:NO];
        } else {
            _panMovement = panMovement;
        }
    }
}
#pragma clang diagnostic pop

#pragma mark Handle zoom gesture
- (void)handleZoomGestureAction:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.numberOfTouches < 2) return;  //avoid dragging when lifting fingers off
    [self handleZoom: MAX(1.0f, recognizer.scale) orMovement:self.panMovement checkDelegate:YES];

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.zoomCenterLocation =  0 ;
        self.zoomCenterValue = [self xValueForLocation:0];
    }
}

- (void)handlePanGestureAction:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.numberOfTouches < 2) return;  //avoid dragging when lifting fingers off
    CGFloat currentX = [recognizer locationInView:self.labelsView].x;

    CGFloat newPanMovement = self.panMovement + (currentX - self.panMovementBase);
    if ([self handleZoom: self.zoomScale orMovement:newPanMovement checkDelegate:YES]) {
        self.panMovementBase = currentX;
    }
}

- (BOOL)handleZoom:(CGFloat)newScale orMovement:(CGFloat)newPanMovement checkDelegate:(BOOL)checkDelegate {

    if (newScale <= 1.0) {
        newScale = 1.0;
        newPanMovement = 0;
    } else if (newScale > self.numberOfPoints/2) {
        //don't allow scaling beyond showing less than 2 points (on average)
        newScale = self.numberOfPoints/2;
    }
    //assumes we're zooming around fixed point self.zoomCenterValue which is currently displayed at self.zoomCenterLocation
    //Now with newScale and newPanMovement,
    //1) adjust self.zoomCenterLocation by change in panMovement
    //2) calculate lowest value that will now be displayed (newMinXDisplayed)
    //3) that lets us check if min or max X values  will be located in middle of screen,  adjust if necessary.
    //4) finally ask permission for new panZoom and update geometry globals
    CGFloat xAxisWidth =  CGRectGetMaxX(self.labelsView.bounds);
    CGFloat totalValueRangeWidth = self.maxXValue - self.minXValue;
    if (xAxisWidth <= 0 || totalValueRangeWidth <= 0) return NO; 

    CGFloat newValueRangeWidth = (totalValueRangeWidth) / newScale;
    CGFloat displayRatio = xAxisWidth/newValueRangeWidth;

    CGFloat newZoomCenterLocation = self.zoomCenterLocation +(newPanMovement - self.panMovement);
    CGFloat newMinXDisplayed  = self.zoomCenterValue - newZoomCenterLocation/displayRatio;

    CGFloat deltaPan = NAN;
    CGFloat newMaxXLocation = (self.maxXValue - newMinXDisplayed) * displayRatio;
    CGFloat newMinXLocation = (self.minXValue - newMinXDisplayed) * displayRatio;
    if (newMaxXLocation < xAxisWidth )  {
        //clamping High
        deltaPan = xAxisWidth - newMaxXLocation;
    } else if (newMinXLocation > 0) {
        //clamping low
        deltaPan = -newMinXLocation;
    }
    if (!isnan(deltaPan) ) {
        //now recalculate new geometry with clamped panMovement
        newPanMovement += deltaPan;
        newZoomCenterLocation += deltaPan;
        newMinXDisplayed  -= deltaPan/displayRatio;
    }

    if (fabs(self.zoomScale    - newScale       ) > 0.01 ||
        fabs(self.panMovement - newPanMovement) > 0.5  ) {
        if (!checkDelegate ||
            ![self.delegate respondsToSelector:@selector(lineGraph:shouldScaleFrom:to:showingFromXMinValue:toXMaxValue:)] ||
            [self.delegate   lineGraph: self
                       shouldScaleFrom: self.zoomScale
                                    to: newScale
                  showingFromXMinValue: newMinXDisplayed
                           toXMaxValue: newMinXDisplayed + newValueRangeWidth]) {

            _zoomScale = newScale;
            _panMovement = newPanMovement;
            self.zoomCenterLocation = newZoomCenterLocation;
            self.minXDisplayedValue = newMinXDisplayed;
            _maxXDisplayedValue = newMinXDisplayed + newValueRangeWidth;
            CGFloat saveAnimation = self.animationGraphEntranceTime;
            self.animationGraphEntranceTime = 0;
            [self reloadGraph];
            self.animationGraphEntranceTime = saveAnimation;
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}


- (void)handleDoubleTapGestureAction:(UITapGestureRecognizer *)recognizer {

    if (self.zoomScale < 1.01) {
        if (![self.delegate respondsToSelector:@selector(lineGraph:shouldScaleFrom:to:showingFromXMinValue:toXMaxValue:)] ||
            [self.delegate   lineGraph: self
                       shouldScaleFrom: self.zoomScale
                                    to: self.doubleTapScale
                  showingFromXMinValue: self.minXDisplayedValue
                           toXMaxValue: self.maxXDisplayedValue]) {
            _zoomScale = self.doubleTapScale;
            _panMovement = self.doubleTapPanMovement ;
            self.doubleTapScale = 1.0;
            }
    } else {
        if (![self.delegate respondsToSelector:@selector(lineGraph:shouldScaleFrom:to:showingFromXMinValue:toXMaxValue:)] ||
            [self.delegate   lineGraph: self
                       shouldScaleFrom: self.zoomScale
                                    to: 1.0
                  showingFromXMinValue: self.minXValue
                           toXMaxValue: self.maxXValue]) {
            self.doubleTapPanMovement = self.panMovement;
            self.doubleTapScale = self.zoomScale;
            _panMovement = 0;
            _zoomScale = 1.0;
            }
    }
    [self reloadGraph];
}

- (void)handleGestureAction:(UIGestureRecognizer *)recognizer {
    CGFloat translation = [recognizer locationInView:self.labelsView].x;
    CGFloat leftEdge = CGRectGetMinX(self.labelsView.bounds);
    CGFloat rightEdge = CGRectGetMaxX(self.labelsView.bounds);
    if (translation >= leftEdge && translation <= rightEdge) { // To make sure the vertical line doesn't go beyond the frame of the graph.
        self.touchInputLine.frame = CGRectMake(translation - self.widthTouchInputLine/2, 0, self.widthTouchInputLine, CGRectGetMaxY(self.labelsView.bounds));
    }

    self.touchInputLine.alpha = self.alphaTouchInputLine;

    BEMCircle *closestDot = [self closestDotFromTouchInputLine:self.touchInputLine];
    NSInteger index = 0;
    if (closestDot.tag > DotFirstTag100) {
        index = closestDot.tag - DotFirstTag100;
    } else {
        if (self.numberOfPoints == 0) return; //something's very wrong
    }
    closestDot.alpha = 0.8f;

    if (recognizer.state != UIGestureRecognizerStateEnded) {
        //ON START OR MOVE
        if (self.enablePopUpReport == YES  && self.alwaysDisplayPopUpLabels == NO) {
            if ([self.delegate respondsToSelector:@selector(popUpViewForLineGraph:)] ) {
                UIView * newCustom = [self.delegate popUpViewForLineGraph:self];
                if (newCustom != self.customPopUpView) {
                    [self.customPopUpView removeFromSuperview];
                    self.customPopUpView = newCustom;
                }
            }
            if (self.customPopUpView) {
                [self.labelsView addSubview:self.customPopUpView];
                [self adjustXLocForLabel:self.customPopUpView avoidingDot:closestDot.frame];
                [self adjustYLocForLabel:self.customPopUpView atIndex: -1 avoidingDot:closestDot.frame andLabels:self.permanentPopups ];
                if ([self.delegate respondsToSelector:@selector(lineGraph:modifyPopupView:forIndex:)]) {
                    self.customPopUpView.alpha = 1.0f;
                    [self.delegate lineGraph:self modifyPopupView:self.customPopUpView forIndex:index];
                } else {
                    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        self.customPopUpView.alpha = 1.0f;
                    } completion:nil];
                }
            } else {
                if (!self.popUpLabel) {
                    self.popUpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                }
                [self.labelsView addSubview: self.popUpLabel ];
                self.popUpLabel = [self configureLabel:self.popUpLabel forPoint:closestDot avoiding:self.permanentPopups];
                [self adjustXLocForLabel:self.popUpLabel avoidingDot:closestDot.frame];
                [self adjustYLocForLabel:self.popUpLabel atIndex: -1 avoidingDot:closestDot.frame andLabels:self.permanentPopups];
                [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.popUpLabel.alpha = 1.0f;
                } completion:nil];
            }
        }

        if (self.enableTouchReport && [self.delegate respondsToSelector:@selector(lineGraph:didTouchGraphWithClosestIndex:)]) {
            [self.delegate lineGraph:self didTouchGraphWithClosestIndex:index];
        }
    } else {
        // ON RELEASE
        if (self.enableTouchReport && [self.delegate respondsToSelector:@selector(lineGraph:didReleaseTouchFromGraphWithClosestIndex:)]) {
            [self.delegate lineGraph:self didReleaseTouchFromGraphWithClosestIndex:index];
        }

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO && self.numberOfPoints > 1) {
                closestDot.alpha = 0;
            }
            self.touchInputLine.alpha = 0;
            self.popUpLabel.alpha = 0;
            self.customPopUpView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.customPopUpView removeFromSuperview];
            self.customPopUpView = nil;
        }];
    }
}

#pragma mark - Graph Calculations

- (BEMCircle *)closestDotFromTouchInputLine:(UIView *)touchInputLine {
    BEMCircle * closestDot = nil;
    CGFloat currentlyCloser = CGFLOAT_MAX;
    for (BEMCircle *point in self.circleDots) {
        if (!point.superview) continue;
        if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO && self.numberOfPoints > 1) {
            point.alpha = 0;
        }
        CGFloat distance = (CGFloat)fabs(point.center.x - touchInputLine.center.x) ;
        if (distance < currentlyCloser) {
            currentlyCloser = distance;
            closestDot = point;
        }
    }
    return closestDot;
}

- (NSArray <NSValue *> *)getData {
    // Remove all data points before adding them to the array
    NSMutableArray <NSValue *> * newDataPoints = [NSMutableArray arrayWithCapacity:(NSUInteger)self.numberOfPoints];

    for (NSInteger index = 0; index < self.numberOfPoints; index++) {
        CGFloat dotValue = 0;

    #ifndef TARGET_INTERFACE_BUILDER
        if ([self.dataSource respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
            dotValue = [self.dataSource lineGraph:self valueForPointAtIndex:index];

        } else {
            [NSException raise:@"lineGraph:valueForPointAtIndex: protocol method is not implemented in the data source. Throwing exception here before the system throws a CALayerInvalidGeometry Exception." format:@"Value for point %f at index %lu is invalid. CALayer position may contain NaN: [0 nan]", dotValue, (unsigned long)index];
        }
    #else
        dotValue = (int)(arc4random() % 10000);
    #endif
        CGFloat xValue = index;
        if ([self.dataSource respondsToSelector:@selector(lineGraph:locationForPointAtIndex:)]){
            xValue = [self.dataSource  lineGraph:self locationForPointAtIndex:index];
        }
        [newDataPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xValue, dotValue)]];

    }
    return [newDataPoints copy];
}

- (void)calculateMinMax {
#ifndef TARGET_INTERFACE_BUILDER
    self.maxYValue = [self getMaximumYValue]; if (self.maxYValue <= -FLT_MAX) self.maxYValue = 0;
    self.minYValue = [self getMinimumYValue]; if (self.minYValue >= INFINITY) self.minYValue = 0;
    self.maxXValue = [self getMaximumXValue]; if (self.maxXValue <= -FLT_MAX) self.maxXValue = 0;
    self.minXValue = [self getMinimumXValue]; if (self.minXValue >= INFINITY) self.minXValue = 0;
    if (self.maxYValue < self.minYValue) self.maxYValue = self.minYValue;
    if (self.maxXValue < self.minXValue) self.maxXValue = self.minXValue;

    if (self.zoomScale <= 1.0 || isnan(self.minXDisplayedValue )) {
        _zoomScale = 1.0;
        _minXDisplayedValue = self.minXValue;
        _maxXDisplayedValue = self.maxXValue;
        _panMovement = 0;
    }
#else
    self.minYValue = 0.0f;
    self.maxYValue = 10000.0f;
    self.minXValue = 0;
    self.maxXValue = self.numberOfPoints-1;
#endif

    if (self.minXDisplayedValue < self.minXValue || self.minXDisplayedValue > self.maxXValue) {
        //possibly caller changed all our data out from under us...
        self.minXDisplayedValue = self.minXValue;
    }
}

- (NSArray <NSValue *> *)layoutPoints {
    //now calculate point locations in view
    NSMutableArray <NSValue *> * newLocs = [NSMutableArray arrayWithCapacity:(NSUInteger)self.numberOfPoints];

    CGFloat xAxisWidth = CGRectGetMaxX(self.dotsView.bounds);
    CGFloat totalValueRangeWidth = self.maxXValue - self.minXValue;
    CGFloat valueRangeWidth  = totalValueRangeWidth / self.zoomScale;
    if (totalValueRangeWidth <= 0) {    //all x values same, e.g. only one point
        valueRangeWidth = xAxisWidth;
    }
    CGFloat displayRatio = xAxisWidth/valueRangeWidth;

    for (NSValue * value in self.dataPoints) {
        CGFloat positionOnXAxis = (value.CGPointValue.x - self.minXDisplayedValue) * displayRatio ;
        if (totalValueRangeWidth <= 0) positionOnXAxis = xAxisWidth/2;
        CGFloat positionOnYAxis = [self yPositionForDotValue:value.CGPointValue.y];
        [newLocs addObject:[NSValue valueWithCGPoint: CGPointMake(positionOnXAxis, positionOnYAxis)]];
    }
    return [newLocs copy];
}

- (CGFloat)getMaximumYValue {
    if ([self.delegate respondsToSelector:@selector(maxValueForLineGraph:)]) {
        return [self.delegate maxValueForLineGraph:self];
    } else {
        CGFloat maxValue = -FLT_MAX;
        for (NSValue * value in self.dataPoints) {
            CGFloat dotValue = value.CGPointValue.y;
            if (dotValue >= BEMNullGraphValue) continue;
            if (dotValue > maxValue) maxValue = dotValue;
        }
        return maxValue;
    }
}

- (CGFloat)getMinimumYValue {
    if ([self.delegate respondsToSelector:@selector(minValueForLineGraph:)]) {
        return [self.delegate minValueForLineGraph:self];
    } else {
        CGFloat minValue = INFINITY;
        for (NSNumber * value in self.dataPoints) {
            CGFloat dotValue = value.CGPointValue.y;
            if (dotValue >= BEMNullGraphValue) continue;
            if (dotValue < minValue) minValue = dotValue;
        }
        return minValue;
    }
}

- (CGFloat)getMaximumXValue {
    if ([self.delegate respondsToSelector:@selector(maxXValueForLineGraph:)]) {
        return [self.delegate maxXValueForLineGraph:self];
    } else {
        CGFloat maxValue = -FLT_MAX;
        for (NSValue * value in self.dataPoints) {
            CGFloat dotValue = value.CGPointValue.x;
            if (dotValue >= BEMNullGraphValue) continue;
            if (dotValue > maxValue) maxValue = dotValue;
        }
        return maxValue;
    }
}

- (CGFloat)getMinimumXValue {
    if ([self.delegate respondsToSelector:@selector(minXValueForLineGraph:)]) {
        return [self.delegate minXValueForLineGraph:self];
    } else {
        CGFloat minValue = INFINITY;
        for (NSValue * value in self.dataPoints) {
            CGFloat dotValue = value.CGPointValue.x;
            if (dotValue >= BEMNullGraphValue) continue;
            if (dotValue < minValue) minValue = dotValue;
        }
        return minValue;
    }
}

- (CGFloat)getAverageValue {
    if ([self.delegate respondsToSelector:@selector(averageValueForLineGraph:)]) {
        return [self.delegate averageValueForLineGraph:self];
    } else {
        CGFloat sumValue = 0.0f;
        int numPoints = 0;
        for (NSValue * value in self.dataPoints) {
            CGFloat dotValue = value.CGPointValue.y;
            if (dotValue >= BEMNullGraphValue) continue;
            sumValue += dotValue;
            numPoints++;
        }
        if (numPoints > 0) {
            return sumValue/numPoints;
        } else {
            return NAN;
        }
    }
}

- (CGFloat)yPositionForDotValue:(CGFloat)dotValue {
    CGFloat height = self.dotsView.bounds.size.height;
    CGFloat positionOnYAxis; // The position on the Y-axis of the point currently being created.
    CGFloat padding = MIN(90.0f, height/2);

    if ([self.delegate respondsToSelector:@selector(staticPaddingForLineGraph:)]) {
        padding = [self.delegate staticPaddingForLineGraph:self];
    }

    if (self.autoScaleYAxis) {
        if (self.minYValue >= self.maxYValue ) {
            positionOnYAxis = height/2;
        } else {
            if (isnan(dotValue) || dotValue >= BEMNullGraphValue) {
                return BEMNullGraphValue;
            }
            CGFloat percentValue = (dotValue - self.minYValue) / (self.maxYValue - self.minYValue);
            CGFloat bottomOfChart = CGRectGetMaxY(self.dotsView.bounds)- padding/2.0f;
            CGFloat sizeOfChart = CGRectGetMaxY(self.dotsView.bounds) - padding;
            positionOnYAxis = bottomOfChart - percentValue * sizeOfChart;
        }
    } else {
        positionOnYAxis = (height - dotValue);
    }
    
    return positionOnYAxis;
}

#pragma mark - Deprecated Methods


 - (NSNumber *)calculatePointValueSum {
    [self printDeprecationTransitionWarningForOldMethod:@"calculatePointValueSum" replacementMethod:@"calculatePointValueSumOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculatePointValueSumOnGraph:self];
}

- (NSNumber *)calculatePointValueMode {
    [self printDeprecationTransitionWarningForOldMethod:@"calculatePointValueMode" replacementMethod:@"calculatePointValueModeOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculatePointValueModeOnGraph:self];
}

- (NSNumber *)calculatePointValueMedian {
    [self printDeprecationTransitionWarningForOldMethod:@"calculatePointValueMedian" replacementMethod:@"calculatePointValueMedianOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculatePointValueMedianOnGraph:self];
}

- (NSNumber *)calculatePointValueAverage {
    [self printDeprecationTransitionWarningForOldMethod:@"calculatePointValueAverage" replacementMethod:@"calculatePointValueAverageOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculatePointValueAverageOnGraph:self];
}

- (NSNumber *)calculateMinimumPointValue {
    [self printDeprecationTransitionWarningForOldMethod:@"calculateMinimumPointValue" replacementMethod:@"calculatePointValueAverageOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculateMinimumPointValueOnGraph:self];
}

- (NSNumber *)calculateMaximumPointValue {
    [self printDeprecationTransitionWarningForOldMethod:@"calculateMaximumPointValue" replacementMethod:@"calculateMaximumPointValueOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculateMaximumPointValueOnGraph:self];
}

- (NSNumber *)calculateLineGraphStandardDeviation {
    [self printDeprecationTransitionWarningForOldMethod:@"calculateLineGraphStandardDeviation" replacementMethod:@"calculateStandardDeviationOnGraph:" newObject:@"BEMGraphCalculator" sharedInstance:YES];
    return [[BEMGraphCalculator sharedCalculator] calculateStandardDeviationOnGraph:self];
}

- (void)printDeprecationAndUnavailableWarningForOldMethod:(NSString *)oldMethod {
    NSLog(@"[BEMSimpleLineGraph] UNAVAILABLE, DEPRECATION ERROR. The delegate method, %@, is both deprecated and unavailable. It is now a data source method. You must implement this method from BEMSimpleLineGraphDataSource. Update your delegate method as soon as possible. One of two things will now happen: A) an exception will be thrown, or B) the graph will not load.", oldMethod);
}

- (void)printDeprecationWarningForOldMethod:(NSString *)oldMethod andReplacementMethod:(NSString *)replacementMethod {
    NSLog(@"[BEMSimpleLineGraph] DEPRECATION WARNING. The delegate method, %@, is deprecated and will become unavailable in a future version. Use %@ instead. Update your delegate method as soon as possible. An exception will be thrown in a future version.", oldMethod, replacementMethod);
}

- (void)printDeprecationTransitionWarningForOldMethod:(NSString *)oldMethod replacementMethod:(NSString *)replacementMethod newObject:(NSString *)newObjectName sharedInstance:(BOOL)isSharedInstance {
    if (isSharedInstance == YES) NSLog(@"[BEMSimpleLineGraph] %@ is deprecated. Please use %@ on the shared instance of %@.", oldMethod, replacementMethod, newObjectName);
    else NSLog(@"[BEMSimpleLineGraph] %@ is deprecated. Please use %@ on the %@ class.", oldMethod, replacementMethod, newObjectName);
}

@end
