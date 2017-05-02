//
//  DetailViewController.m
//  SimpleLineChart
//
//  Created by Hugh Mackworth on 5/19/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

#import "DetailViewController.h"
#import "StatsViewController.h"
#import "BEMGraphCalculator.h"

@interface DetailViewController ()

@property (strong, nonatomic) NSDate * oldestDate, * newestDate;
@property (assign, nonatomic) CGFloat smallestValue, biggestValue;
@property (nonatomic, assign) NSInteger numberOfPoints;


@property (weak, nonatomic) IBOutlet UIStepper *graphObjectIncrement;

@property (strong, nonatomic) NSMutableArray <NSNumber *> *arrayOfValues;
@property (strong, nonatomic) NSMutableArray <NSDate *> *arrayOfDates;

@property (strong, nonatomic) IBOutlet UILabel *labelValues;
@property (strong, nonatomic) IBOutlet UILabel *labelDates;

@property (nonatomic) NSInteger totalNumber;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
@property (strong, nonatomic) IBOutlet UIView * customView;
@property (weak, nonatomic) IBOutlet UILabel * customViewLabel;

@property (strong, nonatomic) NSDateFormatter * dateFormatterYears;
@property (strong, nonatomic) NSDateFormatter * dateFormatterMonths;
@property (strong, nonatomic) NSDateFormatter * dateFormatterDays;
@property (strong, nonatomic) NSDateFormatter * dateFormatterHours;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;

    self.maxValue = -1.0;
    self.minValue = -1.0;
    self.maxXValue = -1.0;
    self.minXValue = -1.0;
    self.staticPaddingValue = -1.0;
    self.numberOfGapsBetweenLabels = -1;
    self.baseIndexForXAxis = -1;
    self.incrementIndexForXAxis = -1;
    self.numberOfYAxisLabels = -1;
    self.baseValueForYAxis = -1.0;
    self.incrementValueForYAxis = -1.0;
    self.dateFormatterYears =   [[NSDateFormatter alloc] init]; self.dateFormatterYears.dateFormat = @"M-YY";
    self.dateFormatterMonths =   [[NSDateFormatter alloc] init]; self.dateFormatterMonths.dateFormat = @"MMM/dd";
    self.dateFormatterDays =   [[NSDateFormatter alloc] init]; self.dateFormatterDays.dateFormat = @"dd@HH";
    self.dateFormatterHours =   [[NSDateFormatter alloc] init]; self.dateFormatterHours.dateFormat = @"HH:mm";
    self.dateFormatter =   [[NSDateFormatter alloc] init]; self.dateFormatter.dateFormat = @"M/d/yy";
    //    self.dateFormatter =  self.dateFormatterYears;
    self.variableXAxis = NO;
    _percentNulls = .2;

    // Do any additional setup after loading the view.

    self.graphObjectIncrement.value = 1000;

    [self hydrateDatasets];

    [self updateLabelsBelowGraph:self.myGraph];
}

#pragma mark Data management

float randomProbability () {
    return  (float) ((double)(arc4random())) / UINT32_MAX;
}


- (void)hydrateDatasets {
    // Reset the arrays of values (Y-Axis points) and dates (X-Axis points / labels)
    if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];

    self.totalNumber = 0;
    NSDate *date = [NSDate date];
    self.numberOfPoints = self.graphObjectIncrement.value;
    // Add objects to the array based on the stepper value
    CGFloat lastValue = 5000;
    for (int i = 0; i < self.numberOfPoints; i++) {
        if (randomProbability() < self.percentNulls) {
            [self.arrayOfValues addObject: @(BEMNullGraphValue)];
        } else {
            CGFloat value =MAX(lastValue + [self getRandomFloat]-500, 500);
            [self.arrayOfValues addObject:@(value)]; // Random values for the graph
            lastValue = value;
        }
       [self.arrayOfDates addObject:date]; // Dates for the X-Axis of the graph
        date = [self dateForGraphAfterDate:date];
    }
    [self checkMaximums];
}

-(void) checkMaximums {
    self.oldestDate = [NSDate distantFuture];
    self.newestDate = [NSDate distantPast];
    self.biggestValue = -INFINITY;
    self.smallestValue = INFINITY;
    for (int i = 0; i < self.numberOfPoints; i++) {
        CGFloat value = self.arrayOfValues[i].floatValue;
        if (value < BEMNullGraphValue) {
            self.totalNumber = self.totalNumber + value;
            self.biggestValue = MAX(self.biggestValue,value );
            self.smallestValue = MIN(self.smallestValue,value );
        }
    }
    self.oldestDate = self.arrayOfDates[0];
    self.newestDate = [self.arrayOfDates lastObject]; //needs to be last for notification

}
- (NSDate *)dateForGraphAfterDate:(NSDate *)date {
    CGFloat zeroToOne = arc4random() / (float) UINT_MAX;
    CGFloat exponentialSeconds = -log(1-zeroToOne) ; //exponential dist with 1 second mean
    NSDate *newDate = [date dateByAddingTimeInterval:exponentialSeconds* (30 * 24 * 60 * 60)];
    return newDate;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date = self.arrayOfDates[index];
    NSString *label = [self.dateFormatter stringFromDate:date];
    return label;
}

-(void) setPercentNulls:(float)percentNulls {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refresh:)  object:nil];
    _percentNulls = percentNulls;
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.25];
}

#pragma mark - Graph Actions

// Refresh the line graph using the specified properties
- (IBAction)refresh:(id)sender {
    [self hydrateDatasets];
    self.myGraph.zoomScale = 1.0;
    [self.myGraph reloadGraph];
}

- (float)getRandomFloat {
    float i1 = (float)(arc4random() % 1000) ;
    return i1;
}

- (IBAction)addOrRemovePointFromGraph:(id)sender {
    if (self.graphObjectIncrement.value > self.numberOfPoints) {
        [self addPointToGraph];
    } else if (self.graphObjectIncrement.value < self.numberOfPoints) {
        [self removePointFromGraph];
    }
    self.numberOfPoints = self.graphObjectIncrement.value;
    [self checkMaximums];
    [self.myGraph reloadGraph];
}

- (void) addPointToGraph {
    // Add point
    NSNumber * newValue ;
<<<<<<< ours
    if (randomProbability() < self.percentNulls) {
=======
    if (self.arrayOfValues.count % 6 == 0) {
>>>>>>> theirs
        newValue = @(BEMNullGraphValue);
    } else {
        newValue = @([self getRandomFloat]);
        self.biggestValue = MAX(self.biggestValue, newValue.floatValue );
        self.smallestValue = MIN(self.smallestValue, newValue.floatValue );
    }
    [self.arrayOfValues addObject:newValue];
    NSDate *lastDate = self.arrayOfDates.count > 0 ? [self.arrayOfDates lastObject]: [NSDate date];
    NSDate *newDate = [self dateForGraphAfterDate:lastDate];
    [self.arrayOfDates addObject:newDate];
}

- (void) removePointFromGraph {
    if (self.arrayOfValues.count > 0) {
        // Remove point
        [self.arrayOfValues removeObjectAtIndex:0];
        [self.arrayOfDates removeObjectAtIndex:0];
    }
}
-(NSString *) formatNumber: (NSNumber *) number {
    return [NSNumberFormatter localizedStringFromNumber:number
                                                         numberStyle:NSNumberFormatterDecimalStyle];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"showStats"]) {
        BEMGraphCalculator * calc = [BEMGraphCalculator sharedCalculator];
        StatsViewController *controller = (StatsViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        controller.standardDeviation =  [self formatNumber:[calc calculateStandardDeviationOnGraph:self.myGraph]];
        controller.average =            [self formatNumber:[calc calculatePointValueAverageOnGraph:self.myGraph]];
        controller.median =             [self formatNumber:[calc calculatePointValueMedianOnGraph: self.myGraph]];
        controller.mode =               [self formatNumber:[calc calculatePointValueModeOnGraph:   self.myGraph]];
        controller.minimum =            [self formatNumber:[calc calculateMinimumPointValueOnGraph:self.myGraph]];
        controller.maximum =            [self formatNumber:[calc calculateMaximumPointValueOnGraph:self.myGraph]];
        controller.area =               [self formatNumber:[calc calculateAreaUsingIntegrationMethod: BEMIntegrationMethodLeftReimannSum onGraph:self.myGraph xAxisScale:@(1)]];
        controller.correlation =        [self formatNumber:[calc calculateCorrelationCoefficientUsingCorrelationMethod:BEMCorrelationMethodPearson onGraph:self.myGraph xAxisScale:@(1)]];
        controller.snapshotImage =      [self.myGraph graphSnapshotImage];
    }
}


#pragma mark - SimpleLineGraph Data Source

- (NSUInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSUInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

-(NSInteger) numberOfXAxisLabelsOnLineGraph: graph {
    return self.numberofXAxisLabels;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph locationForPointAtIndex:(NSUInteger)index {

    return [[self.arrayOfDates objectAtIndex:index] timeIntervalSinceReferenceDate];
}

#pragma mark - SimpleLineGraph Delegate

-(BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(popUpTextForlineGraph:atIndex:)) {
        return self.popUpText.length > 0;
    } else if (aSelector == @selector(popUpPrefixForlineGraph:)) {
        return self.popUpPrefix.length > 0;
    } else if (aSelector == @selector(popUpSuffixForlineGraph:)) {
        return self.popUpSuffix.length > 0;
    } else if (aSelector == @selector(lineGraph:alwaysDisplayPopUpAtIndex:)) {
        return self.testAlwaysDisplayPopup;
    } else if (aSelector == @selector(maxValueForLineGraph:)) {
        return self.maxValue >= 0.0;
    } else if (aSelector == @selector(minValueForLineGraph:)) {
        return self.minValue >= 0.0;
    } else if (aSelector == @selector(maxXValueForLineGraph:)) {
        return self.maxXValue >= 0.0;
    } else if (aSelector == @selector(minXValueForLineGraph:)) {
        return self.minXValue >= 0.0;
    } else if (aSelector == @selector(lineGraph:locationForPointAtIndex:)) {
        return self.variableXAxis;
    } else if (aSelector == @selector(numberOfXAxisLabelsOnLineGraph:)) {
        return self.numberofXAxisLabels > 0;
    } else if (aSelector == @selector(noDataLabelTextForLineGraph:)) {
        return self.noDataText.length > 0;
    } else if (aSelector == @selector(staticPaddingForLineGraph:)) {
        return self.staticPaddingValue > 0;
    } else if (aSelector == @selector(popUpViewForLineGraph:)) {
        return self.provideCustomView;
    } else if (aSelector == @selector(lineGraph:modifyPopupView:forIndex:)) {
        return self.provideCustomView;
    } else if (aSelector == @selector(numberOfGapsBetweenLabelsOnLineGraph:)) {
        return self.numberOfGapsBetweenLabels >= 0;
    } else if (aSelector == @selector(baseIndexForXAxisOnLineGraph:)) {
        return self.baseIndexForXAxis >= 0;
    } else if (aSelector == @selector(incrementIndexForXAxisOnLineGraph:)) {
        return self.incrementIndexForXAxis >= 0;
    } else if (aSelector == @selector(incrementPositionsForXAxisOnLineGraph:)) {
        return self.provideIncrementPositionsForXAxis;
    } else if (aSelector == @selector(numberOfYAxisLabelsOnLineGraph:)) {
        return self.numberOfYAxisLabels >= 0;
    } else if (aSelector == @selector(yAxisPrefixOnLineGraph:)) {
        return self.yAxisPrefix.length > 0;
    } else if (aSelector == @selector(yAxisSuffixOnLineGraph:)) {
        return self.yAxisSuffix.length > 0;
    } else if (aSelector == @selector(baseValueForYAxisOnLineGraph:)) {
        return self.baseValueForYAxis >= 0;
    } else if (aSelector == @selector(incrementValueForYAxisOnLineGraph:)) {
        return self.baseValueForYAxis >= 0.0;
    } else {
        return [super respondsToSelector:aSelector];
    }
}


- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSUInteger)index {
    return [NSString stringWithFormat:@"%lu", index];
//    NSDate *date = self.arrayOfDates[index];
//    NSString *label = [self.dateFormatter stringFromDate:date];
//    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (nullable NSString *)lineGraph:(nonnull BEMSimpleLineGraphView *)graph labelOnXAxisForLocation:(CGFloat)location {
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:location];
    NSString *label = [self.dateFormatter stringFromDate:date];
    return [label stringByAppendingString:@"  " ];
}


- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return self.popUpSuffix;
}

- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return self.popUpPrefix;
}

-(NSString *) popUpTextForlineGraph:(BEMSimpleLineGraphView *)graph atIndex:(NSUInteger)index {
    if (!self.popUpText) return @"Empty format string";
    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
        return [NSString stringWithFormat: self.popUpText, index];
#pragma clang diagnostic pop
    } @catch (NSException *exception) {
        return [NSString stringWithFormat:@"Invalid format string: %@", exception ];
    }

}

- (BOOL)lineGraph:(BEMSimpleLineGraphView *)graph alwaysDisplayPopUpAtIndex:(NSUInteger)index {
    return (index % 3 != 0);
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.maxValue;
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.minValue;
}

- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.noDataLabel;
}
- (NSString *)noDataLabelTextForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.noDataText;
}

- (CGFloat)staticPaddingForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.staticPaddingValue;
}

- (UIView *)popUpViewForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.customView;
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph modifyPopupView:(UIView *)popupView forIndex:(NSUInteger)index {
    NSAssert (popupView == self.customView, @"View problem");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    if (!self.myGraph.formatStringForValues.length) return;
    CGFloat dotValue = [self lineGraph:graph valueForPointAtIndex:index] ;
    if (dotValue >= BEMNullGraphValue) return;
    self.customViewLabel.text = [NSString stringWithFormat:self.myGraph.formatStringForValues, dotValue];
#pragma pop
}

//----- X AXIS -----//

- (NSUInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.numberOfGapsBetweenLabels;
}

- (NSUInteger)baseIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.baseIndexForXAxis;
}

- (NSUInteger)incrementIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.incrementIndexForXAxis;
}

- (NSArray <NSNumber *> *)incrementPositionsForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
    NSMutableArray * positions = [NSMutableArray array];
    for (NSUInteger index = 0; index < self.arrayOfValues.count; index++ ) {
        if (arc4random() % 4 == 0) [positions addObject:@(index)];
    }
    return positions;
}

- (CGFloat)maxXValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.maxXValue;
}

- (CGFloat)minXValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.minXValue;
}


//----- Y AXIS -----//

- (NSUInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.numberOfYAxisLabels;
}

- (NSString *)yAxisPrefixOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.yAxisPrefix;
}

- (NSString *)yAxisSuffixOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.yAxisSuffix;
}

- (CGFloat)baseValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.baseValueForYAxis;
}

- (CGFloat)incrementValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.incrementValueForYAxis;
}

#pragma mark Touch handling

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSUInteger)index {
    NSNumber * value = self.arrayOfValues[index];
    if (value.floatValue < BEMNullGraphValue) {
        self.labelValues.text = [self formatNumber:value];
        self.labelDates.text = [NSString stringWithFormat:@"on %@", [self labelForDateAtIndex:index]];
    }
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
        self.labelDates.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self updateLabelsBelowGraph:graph];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
            self.labelDates.alpha = 1.0;
        } completion:nil];
    }];
}
-(BOOL) lineGraph:(BEMSimpleLineGraphView *)graph shouldScaleFrom:(CGFloat)oldScale to:(CGFloat)newScale showingFromXMinValue:(CGFloat)displayMinXValue toXMaxValue:(CGFloat)displayMaxXValue {
    //  NSLog(@"Scaling %0.2f from %f to %f", newScale, displayMinXValue, displayMaxXValue);
    NSTimeInterval displayedRange = 0;
    if (self.variableXAxis) {
        displayedRange = MAX(displayMaxXValue - displayMinXValue,0);
    } else {
        NSUInteger minIndex = ceil(displayMinXValue);
        NSUInteger maxIndex = ceil(displayMaxXValue);
        if (minIndex < self.arrayOfDates.count && maxIndex < self.arrayOfDates.count) {
            displayedRange = [self.arrayOfDates[maxIndex] timeIntervalSinceDate:self.arrayOfDates[minIndex]];
        } else {
            displayedRange = 0;
        }
    }
    if (displayedRange <= 0) {
        //problem, so use default
        self.dateFormatter = self.dateFormatterYears;
    } else if (displayedRange > 365*24*60*60) {
        self.dateFormatter = self.dateFormatterYears;
    } else if (displayedRange > 30*24*60*60) {
        self.dateFormatter = self.dateFormatterMonths;
    } else if (displayedRange > 4*24*60*60) {
        self.dateFormatter = self.dateFormatterDays;
    } else { // if (displayedRange > 24*60*60) {
        self.dateFormatter = self.dateFormatterHours;
    }
    return YES;
}

-(void) updateLabelsBelowGraph: (BEMSimpleLineGraphView *)graph {
    if (self.arrayOfValues.count > 0) {
        NSNumber * sum = [[BEMGraphCalculator sharedCalculator] calculatePointValueSumOnGraph:graph];
        self.labelValues.text =[self formatNumber:sum];
        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
    } else {
        self.labelValues.text = @"No data";
        self.labelDates.text = @"";
    }
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    [self updateLabelsBelowGraph:graph];
}

@end
