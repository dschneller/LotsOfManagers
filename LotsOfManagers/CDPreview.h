//
//  CDPreview.h
//  CenterDevice
//
//  Created by Daniel Schneller on 01.08.12.
//
//

#import <Foundation/Foundation.h>
#import "CDDocument.h"

@interface CDPreview : NSObject

@property (nonatomic, readonly) NSString* filePath;
@property (nonatomic, readonly) NSString* resolution;
@property (nonatomic, readonly) NSUInteger page;
@property (nonatomic, readonly) UIImage*  image;
@property (nonatomic, readonly, getter = isPlaceholder) BOOL placeholder;


-(id)initWithImage:(UIImage*)image
        resolution:(NSString*)res
              page:(NSUInteger)page
          document:(CDDocument*)doc;


- (id) initFromFileForResolution:(NSString*)res
                            page:(NSUInteger) page
                        document:(CDDocument*)doc;

- (id) initPlaceholderWithResolution:(NSString*)res page:(NSUInteger)page document:(CDDocument*)doc;

+ (CDPreview*) previewForDocument:(CDDocument*)doc
							 page:(NSUInteger)page
					   resolution:(NSString*)resolution
				 allowPlaceholder:(BOOL)placeholderAllowed;

+ (BOOL) availableForDocument:(CDDocument*)doc
                         page:(NSUInteger)page
               withResolution:(NSString*)res;

+ (BOOL) savePNGData:(NSData*)data
           forDocument:(NSString*)docId
               version:(NSInteger)version
                  page:(NSUInteger)page
        withResolution:(NSString*)res;

@end
