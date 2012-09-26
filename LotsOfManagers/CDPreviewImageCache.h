//
//  CDPreviewsCache.h
//  CenterDevice
//
//  Created by Daniel Schneller on 08.08.12.
//
//

#import <Foundation/Foundation.h>
#define PREVIEW_CACHE_TOTAL_COST_LIMIT (25 * 1024 * 1024)

@class CDPreview;

@interface CDPreviewImageCache : NSObject <NSCacheDelegate>

+ (id)sharedInstance;
- (void) setImage:(UIImage*)img forKey:(CDPreview*)key cost:(NSUInteger)cost;
- (UIImage*) imageForKey:(CDPreview*)key;
- (void) clearCache;

@end
