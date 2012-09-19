//
//  CDDocumentViewModel.h
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDocumentViewModel : NSObject

@property (nonatomic, copy) NSString* documentFileName;
@property (nonatomic, strong) UIImage* smallThumbImage;

@end
