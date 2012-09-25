//
//  CDCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+PerformBlockAfterDelay.h"
#import <RestKit/Restkit.h>
#import "CDTask.h"
#import "CDCommandResult.h"

#define WS_STATUS_CODE_OK 200
#define WS_STATUS_DOCUMENT_UPLOADED_CODE_OK 201
#define WS_STATUS_CODE_ERROR 400
#define WS_STATUS_CODE_UNATHORIZED 401
#define WS_STATUS_CODE_NOT_FOUND 404
#define WS_STATUS_CODE_INTERNAL_ERROR 500

#define WS_HTTP_METHOD_PUT @"PUT"
#define WS_HTTP_METHOD_POST @"POST"
#define WS_HTTP_METHOD_DELETE @"DELETE"

#define WS_CONTENT_TYPE @"Content-Type"
#define WS_FORM_URL_ENCODE @"application/x-www-form-urlencoded"
#define WS_CHARSET_UTF_8 @"charset=utf-8"

#define WS_ACCEPT @"Accept"
#define WS_ALL_MEDIA_TYPE @"*/*"
#define WS_APP_JSON @"application/json"
#define WS_APP_PDF @"application/pdf"
#define WS_IMAGE_PNG @"image/png"
#define WS_IMAGE_JPG @"image/jpeg"
#define WS_APP_MULTIPART @"multipart/form-data"
#define TEXT_MT @"text/plain"

#define ERROR_RESPONSE_CODE @"code"
#define ERROR_RESPONSE_DATA @"data"
#define ERROR_RESPONSE_MESSAGE @"message"


@interface CDCommand : NSObject <RKObjectLoaderDelegate>

@property(nonatomic, weak) id<CDCommandResult> delegate;

@property(nonatomic, assign, getter = isFinished) BOOL finished;

@property(nonatomic, strong) CDTask *originatingTask;

-(void)execute;
-(void)didFinishWithResult:(id)result;
-(void)cancel;

+(RKObjectManager *)sharedObjectManagerInstance;

@end

static NSString* kWSPathDocuments = @"/documents";

/////////////////////////////////////////////////////////////////

// mapping stuff

static NSString* kWSDocuments = @"documents";
static NSString* kDocuments = @"documents";

////////////////////////////////////////////////////////////////

// CDDocumentsCountCommand

static NSString* kWSDocumentsCount = @"hits";
static NSString* kDocumentsCount = @"hits";

////////////////////////////////////////////////////////////////





