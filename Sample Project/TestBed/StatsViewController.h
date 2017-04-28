//
//  StatsViewController.h
//  SimpleLineChart
//
//  Created by iRare Media on 1/6/14.
//  Copyright (c) 2014 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//
@import UIKit;

@interface StatsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *standardDeviationLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UILabel *medianLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumLabel;
@property (weak, nonatomic) IBOutlet UILabel *maximumLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *correlationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;

@property (strong, nonatomic) NSString *standardDeviation;
@property (strong, nonatomic) NSString *average;
@property (strong, nonatomic) NSString *median;
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *minimum;
@property (strong, nonatomic) NSString *maximum;
@property (strong, nonatomic) NSString *area;
@property (strong, nonatomic) NSString *correlation;
@property (strong, nonatomic) UIImage *snapshotImage;

@end
