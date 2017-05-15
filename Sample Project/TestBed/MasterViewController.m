//
//  MasterViewController.m
//  TestBed2
//
//  Created by Hugh Mackworth on 5/18/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ARFontPickerViewController.h"
#import "MSColorSelectionViewController.h"
#import "NSUserDefaults+Color.h"
#import "BEMGraphCalculator.h"
#import "UITextField+Numbers.h"
#import "UIButton+Switch.m"

//some convenience extensions for setting and reading

@interface MasterViewController () <MSColorSelectionViewControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (assign) BEMLineAnimation saveAnimationSetting;
@property (strong, nonatomic) UIColor * saveColorSetting;
@property (strong, nonatomic) NSString * currentColorKey;
@property (strong, nonatomic) UIView * currentColorChip;
@end

@interface MasterViewController () <ARFontPickerViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@property (strong, nonatomic) NSDictionary <NSString *, id> *methodList;
@property (strong, nonatomic) IBOutlet UITextField *numberOfPointsField;

@property (strong, nonatomic) IBOutlet UITextField *widthLine;
@property (strong, nonatomic) IBOutlet UITextField *staticPaddingField;
@property (strong, nonatomic) IBOutlet UISwitch *bezierSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *interpolateNullValuesSwitch;
@property (strong, nonatomic) IBOutlet UISlider *percentNullSlider;

@property (strong, nonatomic) IBOutlet UISwitch *xAxisSwitch;
@property (strong, nonatomic) IBOutlet UITextField *numberOfGapsBetweenLabelsField;
@property (strong, nonatomic) IBOutlet UITextField *baseIndexForXAxisField;
@property (strong, nonatomic) IBOutlet UITextField *incrementIndexForXAxisField;
@property (strong, nonatomic) IBOutlet UISwitch *arrayOfIndicesForXAxis;
@property (strong, nonatomic) IBOutlet UISwitch *variableXAxisSwitch;
@property (strong, nonatomic) IBOutlet UITextField *numberofXAxisLabelsField;
@property (strong, nonatomic) IBOutlet UITextField *maxXValueField;
@property (strong, nonatomic) IBOutlet UITextField *minXValueField;

@property (strong, nonatomic) IBOutlet UISwitch *yAxisSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *yAxisRightSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *xAxisTopSwitch;
@property (strong, nonatomic) IBOutlet UITextField *minValueField;
@property (strong, nonatomic) IBOutlet UITextField *maxValueField;
@property (strong, nonatomic) IBOutlet UITextField *numberofYAxisField;
@property (strong, nonatomic) IBOutlet UITextField *yAxisPrefixField;
@property (strong, nonatomic) IBOutlet UITextField *yAxisSuffixField;
@property (strong, nonatomic) IBOutlet UITextField *baseValueForYAxis;
@property (strong, nonatomic) IBOutlet UITextField *incrementValueForYAxis;

@property (strong, nonatomic) IBOutlet UISwitch *enableAverageLineSwitch;
@property (strong, nonatomic) IBOutlet UITextField *averageLineTitleField;
@property (strong, nonatomic) IBOutlet UITextField *averageLineWidthField;

@property (strong, nonatomic) IBOutlet UITextField *widthReferenceLinesField;
@property (strong, nonatomic) IBOutlet UISwitch *xRefLinesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *yRefLinesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *enableReferenceAxisSwitch;
@property (strong, nonatomic) IBOutlet CustomTableViewCell *frameReferenceAxesCell;
@property (strong, nonatomic) IBOutlet UIButton *leftFrameButton;
@property (strong, nonatomic) IBOutlet UIButton *rightFrameButton;
@property (strong, nonatomic) IBOutlet UIButton *topFrameButton;
@property (strong, nonatomic) IBOutlet UIButton *bottomFrameButton;

@property (strong, nonatomic) IBOutlet UISwitch *displayDotsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *displayDotsOnlySwitch;
@property (strong, nonatomic) IBOutlet UITextField *sizePointField;
@property (strong, nonatomic) IBOutlet UISwitch *displayLabelsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *popupReportSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *testDisplayPopupCallBack;
@property (strong, nonatomic) IBOutlet UITextField *labelTextFormat;
@property (strong, nonatomic) IBOutlet UITextField *popupLabelPrefix;
@property (strong, nonatomic) IBOutlet UITextField *poupLabelSuffix;
@property (strong, nonatomic) IBOutlet UISwitch *enableCustomViewSwitch;
@property (strong, nonatomic) IBOutlet UITextField *noDataLabelTextField;
@property (strong, nonatomic) IBOutlet UISwitch *enableNoDataLabelSwitch;

@property (strong, nonatomic) IBOutlet UIButton *animationGraphStyleButton;
@property (strong, nonatomic) IBOutlet UITextField *animationEntranceTime;
@property (strong, nonatomic) IBOutlet UISwitch *dotsWhileAnimateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *userScalingSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *touchReportSwitch;
@property (strong, nonatomic) IBOutlet UITextField *widthTouchInputLineField;

@property (strong, nonatomic) IBOutlet UIButton *fontNameButton;
@property (strong, nonatomic) IBOutlet UITextField *fontSizeField;
@property (strong, nonatomic) IBOutlet UITextField *numberFormatField;

@property (strong, nonatomic) IBOutlet UIView *colorTopChip;
@property (strong, nonatomic) IBOutlet UISwitch *gradientTopSwitch;
@property (strong, nonatomic) IBOutlet UIView *colorBottomChip;
@property (strong, nonatomic) IBOutlet UISwitch *gradientBottomSwitch;
@property (strong, nonatomic) IBOutlet UIView *colorLineChip;
@property (strong, nonatomic) IBOutlet UIView *colorPointChip;
@property (strong, nonatomic) IBOutlet UIView *colorTouchInputLineChip;
@property (strong, nonatomic) IBOutlet UIView *colorXaxisLabelChip;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundXaxisChip;
@property (strong, nonatomic) IBOutlet UIView *colorYaxisLabelChip;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundYaxisChip;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundPopUpLabelChip;
@property (strong, nonatomic) IBOutlet UISwitch *gradientLineSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *gradientHorizSwitch;

@property (strong, nonatomic) IBOutlet UITextField *alphaTopField;
@property (strong, nonatomic) IBOutlet UITextField *alphaBottomField;
@property (strong, nonatomic) IBOutlet UITextField *alphaLineField;
@property (strong, nonatomic) IBOutlet UITextField *alphaTouchInputLineField;
@property (strong, nonatomic) IBOutlet UITextField *alphaBackgroundXaxisField;
@property (strong, nonatomic) IBOutlet UITextField *alphaBackgroundYaxisField;

@end

@implementation MasterViewController

CGGradientRef static createGradient (void) {
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    CGGradientRef result =  CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGColorSpaceRelease(colorspace);
    return result;
}

static NSDateFormatter *dateFormatter = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.title = @"Options";

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.detailViewController loadViewIfNeeded];
    self.myGraph = self.detailViewController.myGraph;

    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResign:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
    [self.detailViewController addObserver:self forKeyPath:@"newestDate" options:NSKeyValueObservingOptionNew context:nil];
    [self restoreProperties];
    [self restoreUI];
    [self.detailViewController addObserver:self forKeyPath:@"numberOfPoints" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDetailTargetDidChange:) name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
    [self showDetailTargetDidChange:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"newestDate"]) {
        [self rangePlaceHolders:self];
    } else if ([keyPath isEqualToString:@"numberOfPoints"]) {
        self.numberOfPointsField.intValue = self.detailViewController.numberOfPoints ;
    }
}

- (void)applicationWillResign:(id)sender {
    [self saveProperties];
}

- (void)restoreProperties {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

#define RestoreProperty(property, type) \
if ([defaults objectForKey:@#property] != nil) { \
self.myGraph.property = [defaults   type ##ForKey:@#property]; \
}\

    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"

    RestoreProperty (animationGraphEntranceTime, float);
    RestoreProperty (animationGraphStyle, integer);

    RestoreProperty (colorXaxisLabel, color);
    RestoreProperty (colorYaxisLabel, color);
    RestoreProperty (colorTop, color);
    RestoreProperty (colorLine, color);
    RestoreProperty (colorBottom, color);
    RestoreProperty (colorPoint, color);
    RestoreProperty (colorTouchInputLine, color);
    RestoreProperty (colorBackgroundPopUplabel, color);
    RestoreProperty (colorBackgroundYaxis, color);
    RestoreProperty (colorBackgroundXaxis, color);
    RestoreProperty (averageLine.color, color);

    RestoreProperty (alphaTop, float);
    RestoreProperty (alphaLine, float);
    RestoreProperty (alphaTouchInputLine, float);
    RestoreProperty (alphaBackgroundXaxis, float);
    RestoreProperty (alphaBackgroundYaxis, float);

    RestoreProperty (widthLine, float);
    RestoreProperty (widthReferenceLines, float);
    RestoreProperty (sizePoint, float);
    RestoreProperty (widthTouchInputLine, float);
    RestoreProperty (zoomScale, float);
    RestoreProperty (minXDisplayedValue, float);

    RestoreProperty (enableUserScaling, bool);
    RestoreProperty (enableTouchReport, bool);
    RestoreProperty (enablePopUpReport, bool);
    RestoreProperty (enableBezierCurve, bool);
    RestoreProperty (enableXAxisLabel, bool);
    RestoreProperty (enableYAxisLabel, bool);
    RestoreProperty (autoScaleYAxis, bool);
    RestoreProperty (positionYAxisRight, bool);
    RestoreProperty (positionXAxisTop, bool);
    RestoreProperty (alwaysDisplayDots, bool);
    RestoreProperty (alwaysDisplayPopUpLabels, bool);
    RestoreProperty (enableReferenceAxisFrame, bool);
    RestoreProperty (enableLeftReferenceAxisFrameLine, bool);
    RestoreProperty (enableBottomReferenceAxisFrameLine, bool);
    RestoreProperty (enableTopReferenceAxisFrameLine, bool);
    RestoreProperty (enableRightReferenceAxisFrameLine, bool);
    RestoreProperty (interpolateNullValues, bool);
    RestoreProperty (displayDotsOnly, bool);
    RestoreProperty (displayDotsWhileAnimating, bool);

    RestoreProperty (touchReportFingersRequired, integer);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullable-to-nonnull-conversion"
    RestoreProperty (formatStringForValues, object);

    //RestoreProperty (averageLine, object);
#pragma clang diagnostic pop

   NSString * labelFontName = [defaults objectForKey:@"labelFontName"] ;
    if (labelFontName) {
        CGFloat labelFontSize =  [defaults floatForKey:@"labelFontSize"] ;
        [self updateFont:labelFontName atSize:labelFontSize];
    }
#define RestoreDetail(property, type) \
if ([defaults type ##ForKey:@#property]) { \
self.detailViewController.property = [defaults   type ##ForKey:@#property]; \
}

    RestoreDetail (numberOfPoints, integer );
    RestoreDetail (percentNulls, float );
    RestoreDetail (popUpText, object);
    RestoreDetail (popUpPrefix, object);
    RestoreDetail (popUpSuffix, object);
    RestoreDetail (testAlwaysDisplayPopup, bool );
    RestoreDetail (maxValue, float );
    RestoreDetail (minValue, float );
    RestoreDetail (maxXValue, float );
    RestoreDetail (minXValue, float );
    RestoreDetail (variableXAxis, bool );
    RestoreDetail (numberofXAxisLabels, integer );
    RestoreDetail (noDataLabel, bool );
    RestoreDetail (noDataText, object);
    RestoreDetail (staticPaddingValue, float );
    RestoreDetail (provideCustomView, bool );
    RestoreDetail (numberOfGapsBetweenLabels, integer );
    RestoreDetail (baseIndexForXAxis, integer );
    RestoreDetail (incrementIndexForXAxis, integer );
    RestoreDetail (provideIncrementPositionsForXAxis, bool );
    RestoreDetail (numberOfYAxisLabels, integer );
    RestoreDetail (yAxisPrefix, object);
    RestoreDetail (yAxisSuffix, object);
    RestoreDetail (baseValueForYAxis, float );
    RestoreDetail (incrementValueForYAxis, float );}


- (void)saveProperties{

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
#define EncodeProperty(property, type) [defaults set ## type: self.myGraph.property forKey:@#property]

    EncodeProperty (animationGraphEntranceTime, Float);
    EncodeProperty (animationGraphStyle, Integer);

    EncodeProperty (colorXaxisLabel, Color);
    EncodeProperty (colorYaxisLabel, Color);
    EncodeProperty (colorTop, Color);
    EncodeProperty (colorLine, Color);
    EncodeProperty (colorBottom, Color);
    EncodeProperty (colorPoint, Color);
    EncodeProperty (colorTouchInputLine, Color);
    EncodeProperty (colorBackgroundPopUplabel, Color);
    EncodeProperty (colorBackgroundYaxis, Color);
    EncodeProperty (colorBackgroundXaxis, Color);
    EncodeProperty (averageLine.color, Color);

    EncodeProperty (alphaTop, Float);
    EncodeProperty (alphaLine, Float);
    EncodeProperty (alphaTouchInputLine, Float);
    EncodeProperty (alphaBackgroundXaxis, Float);
    EncodeProperty (alphaBackgroundYaxis, Float);

    EncodeProperty (widthLine, Float);
    EncodeProperty (widthReferenceLines, Float);
    EncodeProperty (sizePoint, Float);
    EncodeProperty (widthTouchInputLine, Float);
    EncodeProperty (zoomScale, Float);
    EncodeProperty (minXDisplayedValue, Float);

    EncodeProperty (enableUserScaling, Bool);
    EncodeProperty (enableTouchReport, Bool);
    EncodeProperty (enablePopUpReport, Bool);
    EncodeProperty (enableBezierCurve, Bool);
    EncodeProperty (enableXAxisLabel, Bool);
    EncodeProperty (enableYAxisLabel, Bool);
    EncodeProperty (positionYAxisRight, Bool);
    EncodeProperty (positionXAxisTop, Bool);
    EncodeProperty (autoScaleYAxis, Bool);
    EncodeProperty (alwaysDisplayDots, Bool);
    EncodeProperty (alwaysDisplayPopUpLabels, Bool);
    EncodeProperty (enableReferenceAxisFrame, Bool);
    EncodeProperty (enableLeftReferenceAxisFrameLine, Bool);
    EncodeProperty (enableBottomReferenceAxisFrameLine, Bool);
    EncodeProperty (enableTopReferenceAxisFrameLine, Bool);
    EncodeProperty (enableRightReferenceAxisFrameLine, Bool);
    EncodeProperty (interpolateNullValues, Bool);
    EncodeProperty (displayDotsOnly, Bool);
    EncodeProperty (displayDotsWhileAnimating, Bool);
    EncodeProperty (touchReportFingersRequired, Integer);

    EncodeProperty (formatStringForValues, Object);
    //   EncodeProperty (averageLine, Object);

    [defaults setObject:self.myGraph.labelFont.fontName forKey:@"labelFontName"] ;
    [defaults setFloat:self.myGraph.labelFont.pointSize forKey:@"labelFontSize"] ;

#define EncodeDetail(property, type) [defaults set ## type: self.detailViewController.property forKey:@#property]
    EncodeDetail (numberOfPoints, Integer );
    EncodeDetail (percentNulls, Float );

    EncodeDetail (popUpText, Object);
    EncodeDetail (popUpPrefix, Object);
    EncodeDetail (popUpSuffix, Object);
    EncodeDetail (testAlwaysDisplayPopup, Bool );
    EncodeDetail (maxValue, Float );
    EncodeDetail (minValue, Float );
    EncodeDetail (maxXValue, Float );
    EncodeDetail (minXValue, Float );
    EncodeDetail (variableXAxis, Bool );
    EncodeDetail (numberofXAxisLabels, Integer );
    EncodeDetail (noDataLabel, Bool );
    EncodeDetail (noDataText, Object);
    EncodeDetail (staticPaddingValue, Float );
    EncodeDetail (provideCustomView, Bool );
    EncodeDetail (numberOfGapsBetweenLabels, Integer );
    EncodeDetail (baseIndexForXAxis, Integer );
    EncodeDetail (incrementIndexForXAxis, Integer );
    EncodeDetail (provideIncrementPositionsForXAxis, Bool );
    EncodeDetail (numberOfYAxisLabels, Integer );
    EncodeDetail (yAxisPrefix, Object);
    EncodeDetail (yAxisSuffix, Object);
    EncodeDetail (baseValueForYAxis, Float );
    EncodeDetail (incrementValueForYAxis, Float );
}


- (void)restoreUI {
    self.numberOfPointsField.intValue = self.detailViewController.numberOfPoints;
    self.widthLine.floatValue = self.myGraph.widthLine;
    self.staticPaddingField.floatValue = self.detailViewController.staticPaddingValue;
    self.bezierSwitch.on = self.myGraph.enableBezierCurve;
    self.interpolateNullValuesSwitch.on = self.myGraph.interpolateNullValues;
    self.percentNullSlider.value = self.detailViewController.percentNulls;

    self.xAxisSwitch.on = self.myGraph.enableXAxisLabel;
    self.xAxisTopSwitch.on = self.myGraph.positionXAxisTop;
    self.numberOfGapsBetweenLabelsField.intValue = self.detailViewController.numberOfGapsBetweenLabels;
    self.baseIndexForXAxisField.floatValue = self.detailViewController.baseIndexForXAxis;
    self.incrementIndexForXAxisField.intValue = self.detailViewController.incrementIndexForXAxis;
    self.arrayOfIndicesForXAxis.on = self.detailViewController.provideIncrementPositionsForXAxis;
    self.variableXAxisSwitch.on = self.detailViewController.variableXAxis;
    self.numberofXAxisLabelsField.intValue = self.detailViewController.numberofXAxisLabels;
    self.maxXValueField.floatValue = self.detailViewController.maxXValue;
    self.minXValueField.floatValue = self.detailViewController.minXValue;

    self.yAxisSwitch.on = self.myGraph.enableYAxisLabel;
    self.yAxisRightSwitch.on = self.myGraph.positionYAxisRight;
    self.minValueField.floatValue = self.detailViewController.minValue;
    self.maxValueField.floatValue = self.detailViewController.maxValue;
    self.numberofYAxisField.intValue = self.detailViewController.numberOfYAxisLabels;
    self.yAxisPrefixField.text = self.detailViewController.yAxisPrefix;
    self.yAxisSuffixField.text = self.detailViewController.yAxisSuffix;
    self.baseValueForYAxis.floatValue = self.detailViewController.baseValueForYAxis;
    self.incrementValueForYAxis.floatValue = self.detailViewController.incrementValueForYAxis;

    self.enableAverageLineSwitch.on = self.myGraph.averageLine.enableAverageLine;
    self.averageLineTitleField.text = self.myGraph.averageLine.title;
    self.averageLineWidthField.floatValue = self.myGraph.averageLine.width;

    self.widthReferenceLinesField.floatValue = self.myGraph.widthReferenceLines;
    self.xRefLinesSwitch.on = self.myGraph.enableReferenceXAxisLines;
    self.yRefLinesSwitch.on = self.myGraph.enableReferenceYAxisLines;
    self.enableReferenceAxisSwitch.on = self.myGraph.enableReferenceAxisFrame;
    [self updateReferenceAxisFrame:self.myGraph.enableReferenceAxisFrame];
    self.leftFrameButton.on = self.myGraph.enableLeftReferenceAxisFrameLine;
    self.rightFrameButton.on = self.myGraph.enableRightReferenceAxisFrameLine;
    self.topFrameButton.on = self.myGraph.enableTopReferenceAxisFrameLine;
    self.bottomFrameButton.on = self.myGraph.enableBottomReferenceAxisFrameLine;

    self.displayDotsSwitch.on = self.myGraph.alwaysDisplayDots;
    self.displayDotsOnlySwitch.on = self.myGraph.displayDotsOnly;
    self.sizePointField.floatValue = self.myGraph.sizePoint;
    self.popupReportSwitch.on = self.myGraph.enablePopUpReport;
    self.displayLabelsSwitch.on = self.myGraph.alwaysDisplayPopUpLabels;
    self.testDisplayPopupCallBack.on = self.detailViewController.testAlwaysDisplayPopup;
    self.labelTextFormat.text = self.detailViewController.popUpText;
    self.poupLabelSuffix.text = self.detailViewController.popUpSuffix;
    self.popupLabelPrefix.text = self.detailViewController.popUpPrefix;
    self.enableCustomViewSwitch.on  = self.detailViewController.provideCustomView;
    self.enableNoDataLabelSwitch.on = self.detailViewController.noDataLabel;
    self.noDataLabelTextField.text = self.detailViewController.noDataText;

    [self updateAnimationGraphStyle];
    self.animationEntranceTime.floatValue = self.myGraph.animationGraphEntranceTime;
    self.dotsWhileAnimateSwitch.on = self.myGraph.displayDotsWhileAnimating;
    self.touchReportSwitch.on = self.myGraph.enableTouchReport;
    self.userScalingSwitch.on = self.myGraph.enableUserScaling;
    self.widthTouchInputLineField.floatValue = self.myGraph.widthTouchInputLine;

    self.fontSizeField.floatValue = self.myGraph.labelFont.pointSize;
    self.numberFormatField.text = self.myGraph.formatStringForValues;


    self.colorTopChip.backgroundColor = self.myGraph.colorTop;
    self.colorBottomChip.backgroundColor = self.myGraph.colorBottom;
    self.gradientTopSwitch.on = self.myGraph.gradientTop != nil;
    self.gradientBottomSwitch.on = self.myGraph.gradientBottom != nil;
    self.gradientHorizSwitch.on = self.myGraph.gradientLineDirection == BEMLineGradientDirectionHorizontal;
    self.gradientLineSwitch.on = self.myGraph.gradientLine != nil;

    self.colorLineChip.backgroundColor = self.myGraph.colorLine;
    self.colorPointChip.backgroundColor = self.myGraph.colorPoint;
    self.colorXaxisLabelChip.backgroundColor = self.myGraph.colorXaxisLabel;
    self.colorBackgroundXaxisChip.backgroundColor = self.myGraph.colorBackgroundXaxis ?: self.myGraph.colorBottom;
    self.colorTouchInputLineChip.backgroundColor = self.myGraph.colorTouchInputLine;
    self.colorYaxisLabelChip.backgroundColor = self.myGraph.colorYaxisLabel;
    self.colorBackgroundYaxisChip.backgroundColor = self.myGraph.colorBackgroundYaxis ?: self.myGraph.colorTop;
    self.colorBackgroundPopUpLabelChip.backgroundColor = self.myGraph.colorBackgroundPopUplabel;

    self.alphaTopField.floatValue= self.myGraph.alphaTop;
    self.alphaBottomField.floatValue = self.myGraph.alphaBottom;
    self.alphaLineField.floatValue = self.myGraph.alphaLine;
    self.alphaTouchInputLineField.floatValue = self.myGraph.alphaTouchInputLine;
    self.alphaBackgroundXaxisField.floatValue = self.myGraph.alphaBackgroundXaxis;
    self.alphaBackgroundYaxisField.floatValue = self.myGraph.alphaBackgroundYaxis;


}
- (void)rangePlaceHolders:(id)sender {
    //give user a hint on what range is ok for min/max
    self.maxValueField.placeholder = [NSString stringWithFormat:@"%0.2f",self.detailViewController.biggestValue ];
    self.minValueField.placeholder = [NSString stringWithFormat:@"%0.2f",self.detailViewController.smallestValue ];
    if (self.variableXAxisSwitch.isOn) {
        self.minXValueField.placeholder = [dateFormatter stringFromDate: self.detailViewController.oldestDate ];
        self.maxXValueField.placeholder = [dateFormatter stringFromDate: self.detailViewController.newestDate ];
    } else {
        self.minXValueField.placeholder =  @"0";
        self.maxXValueField.placeholder = [NSString stringWithFormat:@"%ld",(long)self.detailViewController.numberOfPoints ];
    }

}
/* properties/methods not implemented:
     touchReportFingersRequired,
     autoScaleYAxis
    Dashpatterns for averageLine, XAxis, Yaxis
    Gradient choices
 */

- (IBAction)numberOfPointsDidChange:(UITextField *)sender {
    NSInteger value = sender.intValue;
    if (value >= 0 ) {
        self.detailViewController.numberOfPoints = value;
    }
}

#pragma mark Main Line
- (IBAction)widthLineDidChange:(UITextField *)sender {
    float value = sender.floatValue;
    if (value > 0.0f) {
        self.myGraph.widthLine = value;
    }
    [self.myGraph reloadGraph];
}

- (IBAction)staticPaddingDidChange:(UITextField *)sender {
   self.detailViewController.staticPaddingValue = sender.floatValue;
    [self.myGraph reloadGraph];
}

- (IBAction)enableBezier:(UISwitch *)sender {
    self.myGraph.enableBezierCurve = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)interpolateNullValues:(UISwitch *)sender {
    self.myGraph.interpolateNullValues = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)percentNullSliderChanged:(UISlider *)sender {
    self.detailViewController.percentNulls = sender.value;
    [self.myGraph reloadGraph];
}

#pragma mark Axes and Reference Lines

- (IBAction)enableXAxisLabel:(UISwitch *)sender {
    self.myGraph.enableXAxisLabel = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)numberOfGapsBetweenLabelDidChange:(UITextField *)sender {
    self.detailViewController.numberOfGapsBetweenLabels = sender.intValue;
    [self.myGraph reloadGraph];
}

- (IBAction)baseIndexForXAxisDidChange:(UITextField *)sender {
    self.detailViewController.baseIndexForXAxis = sender.intValue;
    [self.myGraph reloadGraph];
}

- (IBAction)incrementIndexForXAxisDidChange:(UITextField *)sender {
    self.detailViewController.incrementIndexForXAxis = sender.intValue;
    [self.myGraph reloadGraph];
}

- (IBAction)enableArrayOfIndicesForXAxis:(UISwitch *)sender {
    self.detailViewController.provideIncrementPositionsForXAxis = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)variableXAxis:(UISwitch *)sender {
    self.detailViewController.variableXAxis = sender.on;
    self.maxXValueField.text = @"";
    self.minXValueField.text = @"";
    self.detailViewController.maxXValue = -1;
    self.detailViewController.minXValue = -1;

    [self rangePlaceHolders:self];
    [self.myGraph reloadGraph];
}

- (IBAction)numberofXAxisDidChange:(UITextField *)sender {
    self.detailViewController.numberofXAxisLabels = sender.intValue;
    [self.myGraph reloadGraph];
}

- (IBAction)minXValueDidChange:(UITextField *)sender {
    if (self.variableXAxisSwitch.on) {
        //expect date format
        NSTimeInterval interval = [self timeIntervalFromString:sender.text];
        if (interval > 0) {
            self.detailViewController.minXValue = interval;
        } else {
            self.detailViewController.minXValue = -1;
        }
    } else {
        self.detailViewController.minXValue = sender.floatValue;
    }
    [self.myGraph reloadGraph];
}

- (NSTimeInterval)timeIntervalFromString:(NSString *)string {
     NSDate *date = [dateFormatter dateFromString:string ];
    return (date) ? [date timeIntervalSinceReferenceDate] : 0;
 }

- (IBAction)maxXValueDidChange:(UITextField *)sender {
    if (self.variableXAxisSwitch.isOn) {
        //expect date format
        NSTimeInterval interval = [self timeIntervalFromString:sender.text];
        if (interval > 0) {
            self.detailViewController.maxXValue = interval;
        } else {
            self.detailViewController.maxValue = -1;
        }
    } else {
        self.detailViewController.maxXValue = sender.floatValue;
    }
    [self.myGraph reloadGraph];
}

#pragma mark Axes and Reference Lines

- (IBAction)enableYAxisLabel:(UISwitch *)sender {
    self.myGraph.enableYAxisLabel = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)positionYAxisRight:(UISwitch *)sender {
    self.myGraph.positionYAxisRight = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)positionXAxisTop:(UISwitch *)sender {
    self.myGraph.positionXAxisTop = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)minValueDidChange:(UITextField *)sender {
    self.detailViewController.minValue = sender.floatValue;
    [self.myGraph reloadGraph];

}

- (IBAction)maxValueDidChange:(UITextField *)sender {
    self.detailViewController.maxValue = sender.floatValue;
    [self.myGraph reloadGraph];
}

- (IBAction)numberofYAxisDidChange:(UITextField *)sender {
    self.detailViewController.numberOfYAxisLabels = sender.intValue;
    [self.myGraph reloadGraph];
}

- (IBAction)yAxisPrefixDidChange:(UITextField *)sender {
    self.detailViewController.yAxisPrefix = sender.text;
    [self.myGraph reloadGraph];
}

- (IBAction)yAxisSuffixDidChange:(UITextField *)sender {
    self.detailViewController.yAxisSuffix = sender.text;
    [self.myGraph reloadGraph];
}
- (IBAction)baseValueForYAxisDidChange:(UITextField *)sender {
    self.detailViewController.baseValueForYAxis = sender.floatValue;
    [self.myGraph reloadGraph];

}
- (IBAction)incrementValueForYAxisDidChange:(UITextField *)sender {
    self.detailViewController.incrementValueForYAxis = sender.floatValue;
    [self.myGraph reloadGraph];
}

#pragma mark Average Line
- (IBAction)enableAverageLine:(UISwitch *)sender {
    self.myGraph.averageLine.enableAverageLine = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)averageLineTitleDidChange:(UITextField *)sender {
    self.myGraph.averageLine.title = sender.text;
    [self.myGraph reloadGraph];
}

- (IBAction)averageLineWidthDidChange:(UITextField *)sender {
    if (sender.text.floatValue <= 0) {
        sender.text = @"1.0";
    }
    self.myGraph.averageLine.width = sender.text.doubleValue;
    [self.myGraph reloadGraph];
}

#pragma mark Reference Lines

- (IBAction)widthReferenceLines:(UITextField *)sender {
    if (sender.text.floatValue <= 0) {
        sender.text = @"1.0";
    }
    self.myGraph.widthReferenceLines = (CGFloat) sender.text.doubleValue;
    [self.myGraph reloadGraph];
}

- (IBAction)enableReferenceXAxisLines:(UISwitch *)sender {
    self.myGraph.enableReferenceXAxisLines = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)enableReferenceYAxisLines:(UISwitch *)sender {
    self.myGraph.enableReferenceYAxisLines = sender.on;
    [self.myGraph reloadGraph];
}

- (void)updateReferenceAxisFrame:(BOOL)newState {
    self.myGraph.enableReferenceAxisFrame = newState;
    self.frameReferenceAxesCell.alpha = newState ? 1.0 : 0.5 ;
    self.frameReferenceAxesCell.userInteractionEnabled = newState;
}

- (IBAction)enableReferenceAxisFrame:(UISwitch *)sender {
    [self updateReferenceAxisFrame:sender.on];
    [self.myGraph reloadGraph];
}

- (IBAction)enableLeftReferenceAxisFrameLine:(UIButton *)button {
    BOOL newState = button.on;
    self.myGraph.enableLeftReferenceAxisFrameLine = newState;
    button.on = newState;
    [self.myGraph reloadGraph];
}

- (IBAction)enableRightReferenceAxisFrameLine:(UIButton *)button {
    BOOL newState = button.on;
    self.myGraph.enableRightReferenceAxisFrameLine = newState;
    button.on = newState;
    [self.myGraph reloadGraph];
}

- (IBAction)enableTopReferenceAxisFrameLine:(UIButton *)button {
    BOOL newState = button.on;
    self.myGraph.enableTopReferenceAxisFrameLine = newState;
    button.on = newState;
    [self.myGraph reloadGraph];
}

- (IBAction)enableBottomReferenceAxisFrameLine:(UIButton *)button {
    BOOL newState = button.on;
    self.myGraph.enableBottomReferenceAxisFrameLine = newState;
    button.on = newState;
    [self.myGraph reloadGraph];
}

#pragma mark Dots & Labels section

- (IBAction)alwaysDisplayDots:(UISwitch *)sender {
    self.myGraph.alwaysDisplayDots = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)displayDotsOnly:(UISwitch *)sender {
    self.myGraph.displayDotsOnly = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)sizePointDidChange:(UITextField *)sender {
    if (sender.text.floatValue <= 0) {
        sender.text = @"1.0";
    }
    self.myGraph.sizePoint = (CGFloat) sender.text.floatValue;
    [self.myGraph reloadGraph];
}

- (IBAction)enablePopUpReport:(UISwitch *)sender {
    self.myGraph.enablePopUpReport = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)alwaysDisplayPopUpLabels:(UISwitch *)sender {
    self.myGraph.alwaysDisplayPopUpLabels = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)enableTestDisplayPopups:(UISwitch *)sender {
    self.detailViewController.testAlwaysDisplayPopup = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)labelTextDidChange:(UITextField *)sender {
    self.detailViewController.popUpText = [self checkUsersFormatString:sender];
    [self.myGraph reloadGraph];
}

- (IBAction)labelPrefixDidChange:(UITextField *)sender {
    self.detailViewController.popUpPrefix = sender.text;
    [self.myGraph reloadGraph];
}

- (IBAction)labelSuffixDidChange:(UITextField *)sender {
    self.detailViewController.popUpSuffix = sender.text;
    [self.myGraph reloadGraph];
}

- (IBAction)enableCustomView:(UISwitch *)sender {
    self.detailViewController.provideCustomView = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)enableNoDataLabel:(UISwitch *)sender {
    self.detailViewController.noDataLabel = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)noDataLabelTextDidChange:(UITextField *)sender {
    self.detailViewController.noDataText = sender.text;
    [self.myGraph reloadGraph];
}

#pragma mark Animation section
//
//typedef NS_ENUM(NSInteger, BEMLineAnimation) {
//    /// The draw animation draws the lines from left to right and bottom to top.
//    BEMLineAnimationDraw,
//    /// The fade animation fades in the lines from 0% opaque to 100% opaque (based on the \p lineAlpha property).
//    BEMLineAnimationFade,
//    /// The expand animation expands the lines from a small point to their full width (based on the \p lineWidth property).
//    BEMLineAnimationExpand,
//    /// No animation is used to display the graph
//    BEMLineAnimationNone
//};
//
- (void)updateAnimationGraphStyle {
    NSString * newTitle = @"";
    switch (self.myGraph.animationGraphStyle) {
        case BEMLineAnimationDraw:
            newTitle = @"Draw";
            break;
        case BEMLineAnimationFade:
            newTitle = @"Fade";
            break;
        case BEMLineAnimationExpand:
            newTitle = @"Expand";
            break;
        case BEMLineAnimationNone:
            newTitle = @"None";
            break;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
        default:
            newTitle = @"N/A";
                break;
#pragma clang diagnostic pop
    }
    [self.animationGraphStyleButton setTitle:newTitle forState:UIControlStateNormal];
}

- (IBAction)animationGraphStyle:(UIButton *)sender {
    if (self.myGraph.animationGraphStyle == BEMLineAnimationNone) {
        self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
        self.myGraph.animationGraphEntranceTime = self.animationEntranceTime.floatValue;
    } else {
        self.myGraph.animationGraphStyle ++;
    }
    [self updateAnimationGraphStyle];
    [self.myGraph reloadGraph];
}

- (IBAction)animationGraphEntranceTimeDidChange:(UITextField *)sender {
    self.myGraph.animationGraphEntranceTime = (CGFloat) sender.floatValue;
    [self.myGraph reloadGraph];
}

- (IBAction)displayDotsWhileAnimating:(UISwitch *)sender {
    self.myGraph.displayDotsWhileAnimating = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)enableUserScaling:(UISwitch *)sender {
    self.myGraph.enableUserScaling = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)enableTouchReport:(UISwitch *)sender {
    self.myGraph.enableTouchReport = sender.on;
    [self.myGraph reloadGraph];
}

- (IBAction)widthTouchInputLineDidChange:(UITextField *)sender {
    if (sender.text.floatValue <= 0) {
        sender.text = @"1.0";
    }
    self.myGraph.widthTouchInputLine = (CGFloat) sender.text.floatValue;
    [self.myGraph reloadGraph];
}


#pragma mark TextFormatting

- (IBAction)fontFamily:(UIButton *)sender {
    // done in IB: [self performSegueWithIdentifier:@"FontPicker" sender:self];
}

- (void)updateFont:(NSString *)fontName atSize:(CGFloat)fontSize {
    if (!fontName) fontName = self.fontNameButton.titleLabel.text;
    if (fontSize <= 0) fontSize = (CGFloat)self.fontSizeField.text.floatValue;
    if (fontSize < 1.0) fontSize = 14.0;
    UIFont * newFont = nil;
    if ([@"System" isEqualToString:fontName]) {
        newFont = [UIFont systemFontOfSize:fontSize];
    } else {
        newFont = [UIFont fontWithName:fontName size:fontSize];
    }
    if (newFont) {
        self.myGraph.labelFont = newFont;
        self.fontNameButton.titleLabel.font = newFont;
        [self.fontNameButton setTitle:fontName forState:UIControlStateNormal];
    }
}

- (void)fontPickerViewController:(ARFontPickerViewController *)fontPicker didSelectFont:(NSString *)fontName {
    [fontPicker dismissViewControllerAnimated:YES completion:nil];
    self.fontNameButton.enabled = NO;
    [self.fontNameButton setTitle:fontName forState:UIControlStateNormal];
    self.fontNameButton.enabled = YES;
    [self updateFont: fontName atSize:0.0];
    [self.myGraph reloadGraph];
}

- (IBAction)fontSizeFieldChanged:(UITextField *)sender {
    [self updateFont: nil atSize: self.fontSizeField.text.floatValue];
    [self.myGraph reloadGraph];
}

- (IBAction)numberFormatChanged:(UITextField *)sender {
    self.myGraph.formatStringForValues = [self checkUsersFormatString:sender];
    [self.myGraph reloadGraph];
}
- (NSString *)checkUsersFormatString:(UITextField *)sender {
    //there are many ways to crash this (more than one format), but this is most obvious
    NSString * newFormat = sender.text ?: @"";
    if ([newFormat containsString:@"%@"]) {
        //prevent crash
        NSLog(@"%%@ not allowed in numeric format strings");
        newFormat = [newFormat stringByReplacingOccurrencesOfString:@"%@" withString:@"%%@"];
        sender.text = newFormat;
    }
    return newFormat;
}

- (IBAction)alphaTopFieldChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaTop = newAlpha;
        [self.myGraph reloadGraph];
    }
}

- (IBAction)alphaBottomFieldChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaBottom = newAlpha;
        [self.myGraph reloadGraph];
    }
}

- (IBAction)alphaLineFieldChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaLine = newAlpha;
        [self.myGraph reloadGraph];
    }
}

- (IBAction)alphaTouchInputFieldChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaTouchInputLine = newAlpha;
        [self.myGraph reloadGraph];
    }
}

- (IBAction)alphaBackgroundXaxisChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaBackgroundXaxis = newAlpha;
        [self.myGraph reloadGraph];
    }
}

- (IBAction)alphaBackgroundYaxisChanged:(UITextField *)sender {
    float newAlpha = sender.floatValue;
    if (newAlpha >= 0 && newAlpha <= 1.0) {
        self.myGraph.alphaBackgroundYaxis = newAlpha;
        [self.myGraph reloadGraph];
    }
}

#pragma Color section
- (void)didChangeColor:(UIColor *)color {
    if (![color isEqual:self.currentColorChip.backgroundColor]) {
        self.currentColorChip.backgroundColor = color;
        [self.myGraph setValue: color forKey: self.currentColorKey];
        [self.myGraph reloadGraph];
    }

}
- (void)colorViewController:(MSColorSelectionViewController *)colorViewCntroller didChangeColor:(UIColor *)color {
    [self didChangeColor:color];
}

- (void)saveColor:(id)sender {
    self.myGraph.animationGraphStyle = self.saveAnimationSetting;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restoreColor:(id)sender {
    if (self.saveColorSetting) {
        [self didChangeColor:self.saveColorSetting];
    } else {
        [self.myGraph setValue: nil forKey: self.currentColorKey];

        if ([self.currentColorKey isEqualToString:@"colorBackgroundYaxis"]) {
            self.currentColorChip.backgroundColor = self.myGraph.colorTop;
        } else if ([self.currentColorKey isEqualToString:@"colorBackgroundXaxis"]) {
            self.currentColorChip.backgroundColor = self.myGraph.colorBottom;
        }

    }
    self.myGraph.animationGraphStyle = self.saveAnimationSetting;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self restoreColor:nil];
}

- (IBAction)enableGradientTop:(UISwitch *)sender {
    if (sender.on) {
        CGGradientRef gradient = createGradient();
        self.myGraph.gradientTop = gradient;
        CGGradientRelease(gradient);
    } else {
        self.myGraph.gradientTop = nil;
    }

    [self.myGraph reloadGraph];
}

- (IBAction)enableGradientBottom:(UISwitch *)sender {
    if (sender.on) {
        CGGradientRef gradient = createGradient();
        self.myGraph.gradientBottom = gradient;
        CGGradientRelease(gradient);
    } else {
        self.myGraph.gradientBottom = nil;
    }

    [self.myGraph reloadGraph];
}

- (IBAction)enableGradientLine:(UISwitch *)sender {
    if (sender.on) {
        CGGradientRef gradient = createGradient();
        self.myGraph.gradientLine = gradient;
        CGGradientRelease(gradient);
    } else {
        self.myGraph.gradientLine = nil;
    }

    [self.myGraph reloadGraph];
}

- (IBAction)enableGradientHoriz:(UISwitch *)sender {
    self.myGraph.gradientLineDirection = sender.on ? BEMLineGradientDirectionVertical : BEMLineGradientDirectionHorizontal;
    [self.myGraph reloadGraph];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        UINavigationController* navigationController = (UINavigationController*)[segue destinationViewController];
        navigationController.viewControllers = @[self.detailViewController];
        self.detailViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        self.detailViewController.navigationItem.leftItemsSupplementBackButton = YES;
    } else if ([[segue identifier] isEqualToString:@"FontPicker"]) {
        ARFontPickerViewController * controller = (ARFontPickerViewController*) [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier hasPrefix:@"color"]) {

        //set up color selector
        UINavigationController *destNav = segue.destinationViewController;
        destNav.popoverPresentationController.delegate = self;
//        CGRect cellFrame = [self.view convertRect:((UIView *)sender).bounds fromView:sender];
        destNav.popoverPresentationController.sourceView = ((UIView *)sender) ;
        destNav.popoverPresentationController.sourceRect = ((UIView *)sender).bounds ;
        destNav.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        destNav.preferredContentSize = [[destNav visibleViewController].view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        MSColorSelectionViewController *colorSelectionController = (MSColorSelectionViewController *)destNav.visibleViewController;
        colorSelectionController.delegate = self;

        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", ) style:UIBarButtonItemStyleDone target:self action:@selector(saveColor:)];
        colorSelectionController.navigationItem.rightBarButtonItem = doneBtn;
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", ) style:UIBarButtonItemStyleDone target:self action:@selector(restoreColor:)];
        colorSelectionController.navigationItem.leftBarButtonItem = cancelBtn;


        //remember stuff from sender tableviewCell
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSArray <UIView *> * subViews = [[(UITableViewCell *) sender contentView] subviews];
            for (UIView * subView in subViews) {
                if (subView.tag == 12343) {
                    self.currentColorChip = subView;
                    break;
                }
            }
        }
        self.currentColorKey = segue.identifier;

        NSAssert(self.currentColorKey != nil && self.currentColorChip != nil, @"View Structural problem");

        UIColor * oldColor = (UIColor *) [self.myGraph valueForKey:self.currentColorKey];
        if (!oldColor) {
            //value is not currently set; handle special cases that default to others
            if ([self.currentColorKey isEqualToString:@"colorBackgroundYaxis"]) {
                oldColor = self.myGraph.colorTop;
                self.myGraph.colorBackgroundYaxis = oldColor;
            } else if ([self.currentColorKey isEqualToString:@"colorBackgroundXaxis"]) {
                oldColor = self.myGraph.colorBottom;
                self.myGraph.colorBackgroundXaxis = oldColor;
            } else {
                oldColor = [UIColor blueColor]; //shouldn't happen
                [self didChangeColor:oldColor];
            }
            self.currentColorChip.backgroundColor = oldColor;
        }
        self.saveColorSetting = oldColor;
        self.saveAnimationSetting = self.myGraph.animationGraphStyle;
        self.myGraph.animationGraphStyle = BEMLineAnimationNone;

        colorSelectionController.color = oldColor;
    }


}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //static sections
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //static cells
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static cells
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.splitViewController.isCollapsed) {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    }
}

#pragma mark TextDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Detail did change
- (void)showDetailTargetDidChange:(id)sender {
    if (self.splitViewController.isCollapsed) {
        if (!self.navigationItem.rightBarButtonItem) {
            UIBarButtonItem *graphBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Graph" style:UIBarButtonItemStylePlain target:self action:@selector(showDetail:)];
            self.navigationItem.rightBarButtonItem = graphBarButton;
        }
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void) showDetail:(id) sender {
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.detailViewController removeObserver:self forKeyPath:@"newestDate" ];
    [self.detailViewController removeObserver:self forKeyPath:@"numberOfPoints" ];

}
@end

