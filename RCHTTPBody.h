//
//  RCHTTPBody.h
//  Here-I-Am
//
//  Created by Michael Rockhold on 6/13/10.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHTTPBody : NSObject
{
	NSString* _boundaryString;
	NSMutableString* _bodyString;
	BOOL _sealed;
}

@property (nonatomic, retain, readonly) NSString* boundary;

-(id)initWithBoundary:(NSString*)boundary;

-(void)appendString:(NSString*)value name:(NSString*)name;
-(void)appendData:(NSData*)value name:(NSString*)name type:(NSString*)type filename:(NSString*)filename;

-(NSData*)data;

@end
