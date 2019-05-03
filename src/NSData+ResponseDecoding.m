//
//  NSData+ResponseDecoding.m
//  Here-I-Am
//
//  Created by Michael Rockhold on 6/10/10.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import "NSData+ResponseDecoding.h"
#import "NSString+ResponseDecoding.h"

@implementation NSData (ResponseDecoding)

- (NSString*)UTF8String
{
	return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] autorelease];
}

- (NSDictionary*)decodeResponse
{
	return [[self UTF8String] decodeResponse];
}

@end

@implementation NSDataResponseDecodingDummy

@end