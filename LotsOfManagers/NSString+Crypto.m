//
//  NSString+Crypto.m
//  CenterDevice
//
//  Created by Daniel Schneller on 23.08.12.
//
//

#import "NSString+Crypto.h"
#import <CommonCrypto/CommonDigest.h>

// Create a new NSString category to have SHA256 method on NSString

@implementation NSString (Crypto)

/**
 * Computes a SHA256 hash of the string.
 * @return A SHA256 hash in hexadecimal representation (64 chars)
 */
- (NSString*) SHA256 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19],
                   result[20], result[21], result[22], result[23], result[24],
                   result[25], result[26], result[27],
                   result[28], result[29], result[30], result[31]
                   ];
    return [s lowercaseString];
}

@end

