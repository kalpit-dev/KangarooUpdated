//
//  UILabel+Boldify.h
//  Kangaroo.Superheroes
//
//  Created by Bipul Dev on 10/12/15.
//  Copyright © 2015 MastermindConsulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)
- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
- (void) boldMultipleSubstring: (NSArray *) arraysubstring;

@end
