//
//  CDCertificateFingerPrintVerifier.h
//  CenterDevice
//
//  Created by Daniel Schneller on 23.08.12.
//
//

#import <Foundation/Foundation.h>

@interface CDCertificateFingerPrintVerifier : NSObject <NSURLConnectionDelegate>

+ (NSURLCredential*) createCredentialsIfServerCertificateDetailsAreValidChallenge:(NSURLAuthenticationChallenge*)challenge;
+ (NSURLCredential*) createCredentialsIfServerCertificateDetailsAreValidTrust:(SecTrustRef)trustRef;

@end
