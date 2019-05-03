//
//  NSData+ResponseDecoding.h
//  Here-I-Am
//
//  Created by Michael Rockhold on 6/10/10.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ResponseDecoding)

- (NSString*)UTF8String;

- (NSDictionary*)decodeResponse;

@end

@interface NSDataResponseDecodingDummy : NSObject
{
	
}

@end