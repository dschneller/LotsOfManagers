//
//  CDPreviewsCache.m
//  CenterDevice
//
//  Created by Daniel Schneller on 08.08.12.
//
//

#import "CDPreviewImageCache.h"
#import "CDPreview.h"

@implementation CDPreviewImageCache
{
    NSCache* _previewCache;
}
+(id)sharedInstance
{
    static CDPreviewImageCache* __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CDPreviewImageCache alloc] init];
    });
    return __sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        _previewCache = [[NSCache alloc] init];
        [_previewCache setTotalCostLimit:PREVIEW_CACHE_TOTAL_COST_LIMIT];
        _previewCache.delegate = self;
    }
    return self;
}

- (void) setImage:(UIImage*)img forKey:(CDPreview*)key cost:(NSUInteger)cost
{
    if (img)
    {
        //        NSLog(@"Adding %@ for Key %@ at cost %d", img, key, cost);
        [_previewCache setObject:img forKey:key cost:cost];
    }
}

- (UIImage*) imageForKey:(CDPreview*)key
{
    if (key.page == 0)
    {
        return [UIImage imageNamed:@"symbol-noData"];
    }
    
    UIImage* img = [_previewCache objectForKey:key];
    if (!img) {
//    NSLog(@"Returning %@ for key %@", img, key);
    }
    return img;
}

-(void)cache:(NSCache *)cache willEvictObject:(id)obj
{
//    NSLog(@"CDPreviewImageCache evicting object %@", obj);
}

- (void) clearCache
{
//    NSLog(@"Clearing preview image cache");
    [_previewCache removeAllObjects];
}

@end
