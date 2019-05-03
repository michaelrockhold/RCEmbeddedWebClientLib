/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "BaseLoginButton.h"

#import <dlfcn.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static UIAccessibilityTraits *traitImage = nil, *traitButton = nil;

NSMutableDictionary* s_images = nil;

@interface BaseLoginButton (PrivateMethods)

+(NSString*)keyForConnected:(BOOL)fConnected wide:(BOOL)fWide highlighted:(BOOL)fHighlighted;


@end


@implementation BaseLoginButton

@synthesize style = _style;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

+ (void)initialize
{
	if (self == [BaseLoginButton class])
	{
		// Try to load the accessibility trait values on OS 3.0
		traitImage = dlsym(RTLD_SELF, "UIAccessibilityTraitImage");
		traitButton = dlsym(RTLD_SELF, "UIAccessibilityTraitButton");
		
		s_images = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
}

+(NSString*)keyForConnected:(BOOL)fConnected wide:(BOOL)fWide highlighted:(BOOL)fHighlighted
{
	return [NSString stringWithFormat:@"%@_%@_%@",
						  fConnected ? @"CONNECTED" : @"UNCONNECTED",
						  fWide ? @"WIDE" : @"NORMAL",
						  fHighlighted ? @"LIT" : @"UNLIT"
						  ];
}

+(void)setImage:(UIImage*)image connected:(BOOL)fConnected wide:(BOOL)fWide highlighted:(BOOL)fHighlighted
{
	[s_images setObject:image forKey:[self keyForConnected:fConnected wide:fWide highlighted:fHighlighted]];
}

+(UIImage*)getImageForConnected:(BOOL)fConnected wide:(BOOL)fWide highlighted:(BOOL)fHighlighted
{
	return [s_images objectForKey:[self keyForConnected:fConnected wide:fWide highlighted:fHighlighted]];
}

-(BOOL)connected { return NO; }

-(void)updateImage
{
	_imageView.image = [self.class getImageForConnected:self.connected 
												   wide:self.style == FBLoginButtonStyleWide 
											highlighted:self.highlighted];
}

- (void)initButton
{
	_style = FBLoginButtonStyleNormal;

	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageView.contentMode = UIViewContentModeCenter;
	[self addSubview:_imageView];
	
	self.backgroundColor = [UIColor clearColor];

	[self updateImage];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

-(id)initWithFrame:(CGRect)frame
{
	if ( self = [super initWithFrame:frame] )
	{
		[self initButton];
		if (CGRectIsEmpty(frame))
		{
			[self sizeToFit];
		}
	}
	return self;
}

- (void)awakeFromNib
{
	[self initButton];
}

- (void)dealloc
{
	[_imageView release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (CGSize)sizeThatFits:(CGSize)size
{
  return _imageView.image.size;
}

- (void)layoutSubviews
{
  _imageView.frame = self.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted
{
  [super setHighlighted:highlighted];
  [self updateImage];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAccessibility informal protocol (on 3.0 only)

- (BOOL)isAccessibilityElement { return YES; }

- (UIAccessibilityTraits)accessibilityTraits
{
	return (traitImage && traitButton)
		? [super accessibilityTraits]|*traitImage|*traitButton
		: [super accessibilityTraits];
}

- (NSString *)accessibilityLabel
{
	return NSLocalizedString(self.connected ? @"Disconnect from Service" : @"Connect to Service", @"Accessibility label");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setStyle:(FBLoginButtonStyle)style
{
  _style = style;
  
  [self updateImage];
}

@end
