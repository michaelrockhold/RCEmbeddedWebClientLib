//
//  NSString+ResponseDecoding.m
//  Here-I-Am
//
//  Created by Michael Rockhold on 6/10/10.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import "NSString+ResponseDecoding.h"


@implementation NSString (ResponseDecoding)

- (NSDictionary*)decodeResponse
{	
		// split the response at the '&'s
	NSArray* pairs = [self componentsSeparatedByString:@"&"];
	
	NSMutableDictionary* responseDic = [NSMutableDictionary dictionaryWithCapacity:3];
		// split each substring at the '='s
	for (NSString* p in pairs)
	{
		NSArray* a = [p componentsSeparatedByString:@"="];
		NSString* v = a.count > 1 ? [a objectAtIndex:1] : @"";
		[responseDic setObject:v forKey:[a objectAtIndex:0]];
	}
	return responseDic;
}

@end

@implementation NSStringResponseDecodingDummy
@end