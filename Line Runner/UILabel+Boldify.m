//
//  UILabel+Boldify.m
//  Kangaroo.Superheroes
//
//  Created by Bipul Dev on 10/12/15.
//  Copyright © 2015 MastermindConsulting. All rights reserved.
//

#import "UILabel+Boldify.h"

@implementation UILabel (Boldify)
- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}

- (void) boldSubstring: (NSString*) substring {
    
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

- (void) boldMultipleSubstring: (NSArray *) arraysubstring;

{
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease];
    for (NSString *str in arraysubstring)
    {
        NSRange range = [self.text rangeOfString:str];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    }
    
    
    self.attributedText = attributedText;
}



@end
