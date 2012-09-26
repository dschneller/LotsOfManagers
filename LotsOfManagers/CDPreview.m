//
//  CDPreview.m
//  CenterDevice
//
//  Created by Daniel Schneller on 01.08.12.
//
//

#import "CDPreview.h"
#import "CDPreviewImageCache.h"

@interface CDPreview ()

@property (nonatomic, readonly) NSString* storageDir;
@property (nonatomic, readonly) NSString* docId;
@property (nonatomic, readonly) NSInteger version;

@end

@implementation CDPreview

@synthesize filePath = _filePath, storageDir = _storageDir;

static NSString* const kFilenamePattern =  @"page-%d.png";
static NSString* previewDir;


-(id)initWithImage:(UIImage*)image
        resolution:(NSString*)res
              page:(NSUInteger)page
          document:(CDDocument*)doc
{
    if (!image)
    {
        @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"Cannot init preview without image using initWithImage" userInfo:nil];
    }
    
    if (self = [super init])
    {
        _resolution = res;
        _docId = doc.documentId;
        _version = doc.version;
        _page = page;
        if (page != 0) {
        [self saveToDisk:image];
        }
        [[CDPreviewImageCache sharedInstance] setImage:image forKey:self cost:(3 * 1024 * 1024)];
    }
    return self;
}

- (id) initFromFileForResolution:(NSString*)res
                            page:(NSUInteger) page
                        document:(CDDocument*)doc
{
    if (self = [super init])
    {
        _resolution = res;
        _docId = doc.documentId;
        _version = doc.version;
        _page = page;

        NSError* err = NULL;
        NSUInteger fs = [self imageFileSize];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
        {
            if (fs == 0)
            {
                [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&err];
                if (err)
                {
                    NSLog(@"Error deleting empty file %@: %@", self.filePath, err);
                }
            } else
                if (fs > 0)
                {
                    UIImage* img = [UIImage imageWithContentsOfFile:self.filePath];
                    if (img)
                    {
                        [[CDPreviewImageCache sharedInstance] setImage:img forKey:self cost:fs];
                    } else
                    {
                        @throw [NSException exceptionWithName:@"InternalInconsistencyExceptiopn"
                                                       reason:[NSString stringWithFormat:@"Image File %@ Size > 0, but could not load image", self.filePath]
                                                     userInfo:nil];
                    }
                }
        }
    }
    return self;
}

- (id) initPlaceholderWithResolution:(NSString*)res page:(NSUInteger)page document:(CDDocument*) doc
{
	if (self = [super init])
    {
        _resolution = res;
        _docId = doc.documentId;
        _version = doc.version;
        _page = page;
		_placeholder = YES;
	}
	return self;
}

+ (CDPreview*) previewForDocument:(CDDocument*)doc page:(NSUInteger)page resolution:(NSString*)resolution allowPlaceholder:(BOOL)placeholderAllowed
{
	if ([CDPreview availableForDocument:doc page:page withResolution:resolution])
	{
		return [[CDPreview alloc] initFromFileForResolution:resolution page:page document:doc];
	}
	if (placeholderAllowed)
	{
		return [[CDPreview alloc] initPlaceholderWithResolution:resolution page:page document:doc];
	}
	return nil;
}


+ (BOOL) availableForDocument:(CDDocument*)doc page:(NSUInteger)page withResolution:(NSString*)res
{
    return [CDPreview availableForDocumentId:doc.documentId
                                     version:doc.version
                                        page:page
                              withResolution:res];
}

+ (BOOL) availableForDocumentId:(NSString*)docId version:(NSInteger)ver page:(NSUInteger)page withResolution:(NSString*)res
{
    NSString* dir = [CDPreview buildStorageDirForDocId:docId
                                               version:ver
                                            resolution:res];
    NSString* filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:kFilenamePattern, page]];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL) savePNGData:(NSData*)data
           forDocument:(NSString*)docId
               version:(NSInteger)version
                  page:(NSUInteger)page
        withResolution:(NSString*)res
{
    if (!data)
    {
        NSLog(@"WARNING: Got nil data to store as PNG preview. DocId %@, v%d, page %d, res %@",
              docId, version, page, res);
        return NO;
    }
    if (data.length == 0) {
        NSLog(@"WARNING: Got zero length data to store as PNG preview. DocId %@, v%d, page %d, res %@",
              docId, version, page, res);
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* storageDir = [CDPreview buildStorageDirForDocId:docId
                               version:version
                            resolution:res];
    if (![fileManager fileExistsAtPath:storageDir]){
        NSError *error;
        if (![fileManager createDirectoryAtPath:storageDir
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Unable to create file directory: %@", error);
        }
    }
    NSString* filePath = [storageDir stringByAppendingPathComponent:[NSString stringWithFormat:kFilenamePattern, page]];
    if (![fileManager createFileAtPath:filePath
                                  contents:data
                                attributes:nil])
    {
            NSLog(@"Unable to save document preview");
            return NO;
    }
    return YES;

}



+ (NSString*) buildStorageBaseDirForDocId:(NSString*)docId version:(NSUInteger)ver
{
    NSString* tmpDir = [previewDir copy];

    if (!tmpDir)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        tmpDir = [paths objectAtIndex:0];
        tmpDir = [tmpDir stringByAppendingPathComponent:@"previews"];
        previewDir = [tmpDir copy];
    }
    tmpDir = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", docId, ver]];
    return tmpDir;
}

+ (NSString*) buildStorageDirForDocId:(NSString*)docId version:(NSUInteger)ver resolution:(NSString*)res
{
    NSString* tmpDir =[CDPreview buildStorageBaseDirForDocId:docId version:ver];
    return [tmpDir stringByAppendingPathComponent:res];
}

- (NSString*) storageDir {
    if (!_storageDir)
    {
        _storageDir =  [CDPreview buildStorageDirForDocId:self.docId
                                                  version:self.version
                                               resolution:self.resolution];
    }
    return _storageDir;
}

- (NSString*) filePath
{
    if (!_filePath)
    {
        NSString* tmpPath = self.storageDir;
        tmpPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:kFilenamePattern,
                                                           self.page]];
        _filePath = tmpPath;
    }
    return _filePath;
}

- (void)createTargetDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.storageDir]){
        NSError *error;
        if (![fileManager createDirectoryAtPath:self.storageDir
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Unable to create file directory: %@", error);
        }
    }
}

- (BOOL) saveToDisk:(UIImage*)img
{
    if ([CDPreview availableForDocumentId:self.docId
                                  version:self.version
                                     page:self.page
                           withResolution:self.resolution])
    {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self createTargetDirectory];
    if (img){
        if (![fileManager createFileAtPath:self.filePath
                                  contents:UIImagePNGRepresentation(img)
                                attributes:nil]) {
            NSLog(@"Unable to save document preview");
            return NO;
        }
    } else
    {
         NSLog(@"No document preview to save");
         return NO;
    }
    return YES;

}


- (NSUInteger) imageFileSize
{
    NSError* err = NULL;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
    {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:&err];
        if (!err)
        {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            return [fileSizeNumber unsignedIntegerValue];
        } else
        {
            NSLog(@"Cannot determine preview image file %@'s size: %@", self.filePath, err);
        }
    }
    return -1;
}

- (UIImage*) image
{

	if (_placeholder)
	{
#warning DECIDE ON PREVIEW IMAGE AND ALSO PROVIDE DIFFERENT RESOLUTION PREVIEWS
		return [UIImage imageNamed:@"stapel-1-dots"];
	}
	
    UIImage* img = [[CDPreviewImageCache sharedInstance] imageForKey:self];
    if (!img)
    {
        img = [UIImage imageWithContentsOfFile:self.filePath];
        if (img) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                               [[CDPreviewImageCache sharedInstance] setImage:img forKey:self cost:[self imageFileSize]];
                           });
        }
    }
    return img;
}



@end
