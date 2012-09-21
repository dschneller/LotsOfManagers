//
//  CDMyCell.m
//  AQGridViewTests
//
//  Created by Daniel Schneller on 09.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentStackCell.h"
#import "CustomBadge.h"


@implementation CDDocumentStackCell

NSString* const kPlaceholderString = @"...";
NSString* const kPlaceholderIconImageName = @"stapel-1-dots";

@synthesize placeholder = _placeholder;

- (void) setPlaceholder:(BOOL)placeholder
{
    _placeholder = placeholder;
    if (placeholder)
    { 
        self.elementName = kPlaceholderString;
        self.elementCount = kPlaceholderString;
        self.image = nil;
        self.frameImage = [UIImage imageNamed:kPlaceholderIconImageName];
    }
}

- (NSString *) elementName
{
    return _nameLabel.text;
}

- (void) setElementName:(NSString *)elementName
{
    _nameLabel.text = elementName;
    [self setNeedsLayout];
}


- (NSString *) elementCount
{
    return _elementCount;
}


- (void) setElementCount:(NSString *)elementCount
{
    _elementCount = elementCount;
    if ([elementCount isEqualToString:@"1"] ||
        [elementCount isEqualToString:@"0"] || 
        [elementCount isEqualToString:kPlaceholderString] ||
        elementCount.length == 0) // only if new badge value provided
    {
        _badge.hidden = YES;
    } else {
        _badge.image = [CustomBadge customBadgeImageWithString:elementCount];
        _badge.hidden = NO;
    }
}


- (UIImage *)image
{
    return _imgView.image;
}

- (void)setImage:(UIImage *)image
{
    _imgView.image = image;
    if (!image)
    {
        self.frameImage = [UIImage imageNamed:kPlaceholderIconImageName];
    }
}

- (UIImage*) frameImage
{
    return _frameImgView.image;
}

- (void)setFrameImage:(UIImage *)frameImage
{
    _frameImgView.image = frameImage;
}

@end
