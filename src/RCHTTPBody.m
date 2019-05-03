//
//  RCHTTPBody.m
//  Here-I-Am
//
//  Created by Michael Rockhold on 6/13/10.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import "RCHTTPBody.h"

@interface RCHTTPBody ()

-(BOOL)sealCheck;

@end

@implementation RCHTTPBody

-(id)initWithBoundary:(NSString*)boundary
{
	if ( self = [super init] )
	{
		_sealed = NO;
		_boundaryString = [boundary retain];
		_bodyString = [[NSMutableString alloc] initWithCapacity:1024];
	}
	return self;
}

-(void)dealloc
{
	[_boundaryString release];
	[_bodyString release];
	[super dealloc];
}

-(BOOL)sealCheck
{
	if ( _sealed )
	{
		NSLog(@"Warning: appending ignored for already-sealed RCHTTPBody");
		return NO;
	}
	return YES;
}

-(void)appendString:(NSString*)value name:(NSString*)name
{
	if ( [self sealCheck] )
	{
		[_bodyString appendFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n",
		 _boundaryString, name];
		[_bodyString appendString:value];
	}
}

-(void)appendData:(NSData*)value name:(NSString*)name type:(NSString*)type filename:(NSString*)filename
{
	if ( [self sealCheck] )
	{
		[_bodyString appendFormat:@"\r\n--%@\r\n", _boundaryString];
		[_bodyString appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
		[_bodyString appendFormat:@"Content-Type: %@\r\n\r\n", type];
		NSString* dataStr = [[NSString alloc] initWithData:value encoding:NSISOLatin1StringEncoding];
		[_bodyString appendString:dataStr];
		[dataStr release];
	}
}

-(void)seal
{
	[_bodyString appendFormat:@"\r\n--%@--\r\n", _boundaryString];
	_sealed = YES;
}

-(NSString*)boundary
{
	return _boundaryString;
}

-(NSData*)data
{
	if ( !_sealed )
	{
		[self seal];
	}
	return [_bodyString dataUsingEncoding:NSISOLatin1StringEncoding];
}

@end
