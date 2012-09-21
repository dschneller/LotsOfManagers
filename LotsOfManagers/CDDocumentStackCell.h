//
//  CDMyCell.h
//  AQGridViewTests
//
//  Created by Daniel Schneller on 09.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "AQGridViewCell.h"
#import "CustomBadge.h"

@interface CDDocumentStackCell : UIView
{
    IBOutlet UIImageView *_frameImgView;
    IBOutlet UIImageView *_imgView;
    IBOutlet UILabel *_nameLabel;
    IBOutlet UIImageView *_badge;
    
    @private
    NSString* _elementCount;
}

@property (nonatomic, assign, getter=isPlaceholder) BOOL placeholder;
@property (nonatomic, copy) NSString* elementName;
@property (nonatomic, copy) NSString* elementCount;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* frameImage;

@end
