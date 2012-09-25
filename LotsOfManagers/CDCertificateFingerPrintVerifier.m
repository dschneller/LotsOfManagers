//
//  CDCertificateFingerPrintVerifier.m
//  CenterDevice
//
//  Created by Daniel Schneller on 23.08.12.
//
//

#import "CDCertificateFingerPrintVerifier.h"
#import <CommonCrypto/CommonDigest.h>

#define CD_CERT_FINGERPRINT @"E0 2C 7D DF 2D 75 1B 12 42 E9 ED FB 50 74 83 BF 24 10 7F F0"

#warning TODO: Prepare for multiple certs


@implementation CDCertificateFingerPrintVerifier


+ (NSURLCredential*) createCredentialsIfServerCertificateDetailsAreValidTrust:(SecTrustRef)trustRef
{
    SecTrustResultType result;
    
    if (SecTrustEvaluate(trustRef, &result) == noErr)
    {
        if (kSecTrustResultUnspecified == result || kSecTrustResultProceed == result)
        {
            // only in these 2 cases the certificate could be definitely verified.
            // now we still need to double check the certificate fingerprints to
            // make sure we are talking to the correct server, and not merely have
            // an encrypted channel.
            // otherwise someone could attempt a man-in-the-middle attack using
            // a certificate that was correctly signed by any of the many root-CAs
            // the system trusts by default.
            
            BOOL verified;
            CFIndex count = SecTrustGetCertificateCount(trustRef);
            for (CFIndex i = 0; i < count; i++)
            {
                SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, i);
                CFDataRef certData = SecCertificateCopyData(certRef);
                
                NSData *myData = (NSData *)CFBridgingRelease(certData);
                NSString* fingerprint = [CDCertificateFingerPrintVerifier sha1:myData];
                verified = [fingerprint compare:CD_CERT_FINGERPRINT options:NSCaseInsensitiveSearch] == NSOrderedSame;
                //                NSLog(@"Certificate fingerprint: %@ [%@]", fingerprint, verified ? @"Verified" : @"NOT VERIFIED");
                //
                //                CFStringRef certSummary = SecCertificateCopySubjectSummary(certRef);
                //                NSLog(@"<%p %@: %s line:%d> Certificate summary:%@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (NSString*) CFBridgingRelease(certSummary));

                //                NSLog(@"<%p %@: %s line:%d> Certificate data:%@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (NSString*) certData);
                //     CFRelease(certData);
                
                if (verified)
                {
                    NSURLCredential* urlCredential = [NSURLCredential credentialForTrust:trustRef];
                    return urlCredential;
                }
            }
        }
    }
    NSLog(@"FATAL: Could not verify certificate fingerprint.");
    return nil;
    
}


+ (NSURLCredential*) createCredentialsIfServerCertificateDetailsAreValidChallenge:(NSURLAuthenticationChallenge*)challenge
{
    SecTrustRef trustRef =  challenge.protectionSpace.serverTrust;
    return [CDCertificateFingerPrintVerifier createCredentialsIfServerCertificateDetailsAreValidTrust:trustRef];
}

+ (NSString*)sha1:(NSData*)certData {
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(certData.bytes, certData.length, sha1Buffer);
    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 3];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i)
    {
        [fingerprint appendFormat:@"%02x ",sha1Buffer[i]];
    }
    return [fingerprint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
