//
//  NSUserDefaults+NSUserDefaults_Color.m
//  SimpleLineChart
//
//  Created by Hugh Mackworth on 4/4/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

#import "NSUserDefaults+Color.h"

@implementation NSUserDefaults (Color)



- (UIColor *)colorForKey:(NSString *)colorKey {
    UIColor * color = nil;
    NSData * colorData = [self dataForKey:colorKey];
    if (colorData) {
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    return color;
}

- (void)setColor:(UIColor *)color forKey:(NSString *)colorKey {
    NSData * colorData = nil;
    if (color) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    }
    [self setObject:colorData forKey:colorKey];
}


@end
