//
//  NSUserDefaults+NSUserDefaults_Color.h
//  SimpleLineChart
//
//  Created by Hugh Mackworth on 4/4/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface NSUserDefaults (Color)

- (UIColor *) colorForKey:(NSString *) colorKey;
- (void) setColor:(UIColor *) color forKey:(NSString *) colorKey;

@end
