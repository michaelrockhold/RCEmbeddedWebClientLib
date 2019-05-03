//
//  RCWebDialogViewController.h
//  Aktuala Loko
//
//  Created by Michael Rockhold on 6/4/2010.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import "RCWebDialogViewController.h"

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static CGFloat kPadding = 10;
static CGFloat kBorderWidth = 10;


@implementation RCWebDialogViewController

@synthesize delegate = _delegate, webView = _webView, spinner = _spinner;

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// private

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
	if (orientation == _orientation) {
		return NO;
	} else {
		return orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight
		|| orientation == UIDeviceOrientationPortrait
		|| orientation == UIDeviceOrientationPortraitUpsideDown;
	}
}

- (CGAffineTransform)transformForOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}


- (void)updateWebOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.setAttribute('orientation', 90);"];
	} else {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.removeAttribute('orientation');"];
	}
}


- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params
{
	if (params)
	{
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator)
		{
			NSString* value = [params objectForKey:key];
			NSString* val = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* pair = [NSString stringWithFormat:@"%@=%@", key, val];
			[pairs addObject:pair];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	}
	else
	{
		return [NSURL URLWithString:baseURL];
	}
}

- (NSMutableData*)generatePostBody:(NSDictionary*)params
{
	if (!params)
	{
		return nil;
	}
	
	NSMutableData* body = [NSMutableData data];
	NSString* endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (id key in [params keyEnumerator])
	{
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[params valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];        
	}
	
	return body;
}

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
}


- (void)dismiss:(BOOL)animated
{	
	[_loadingURL release];
	_loadingURL = nil;
}

	///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithDelegate:(id<RCWebDialogViewControllerDelegate>)delegate
{
	if ( self = [super init] )
	{
		_delegate = delegate;
		_loadingURL = nil;
		_orientation = UIDeviceOrientationUnknown;
		_showingKeyboard = NO;        
	}
	return self;
}

-(void)loadView
{
	UIWebView* webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	webview.autoresizingMask = (
								UIViewAutoresizingFlexibleLeftMargin |
								UIViewAutoresizingFlexibleWidth | 
								UIViewAutoresizingFlexibleRightMargin |
								UIViewAutoresizingFlexibleTopMargin |
								UIViewAutoresizingFlexibleHeight |
								UIViewAutoresizingFlexibleBottomMargin
								);
	self.view = webview;
	self.webView = webview;
	self.webView.delegate = self;
	[webview release];
	
	UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	spinner.hidesWhenStopped = YES;
	spinner.center = self.view.center;
	[self.view addSubview:spinner];
	self.spinner = spinner;
	[spinner release];
}

- (void)dealloc
{
	self.webView.delegate = nil;
	self.webView = nil;
	self.spinner = nil;
	[_loadingURL release];
	[super dealloc];
}


	///////////////////////////////////////////////////////////////////////////////////////////////////
	// UIWebViewDelegate

- (BOOL)              webView:(UIWebView*)webView 
   shouldStartLoadWithRequest:(NSURLRequest*)request
			   navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL* url = request.URL;
	if ( [url.scheme isEqualToString:@"fbconnect"] )
	{
		if ( [url.resourceSpecifier isEqualToString:@"cancel"] )
		{
			[self cancel:self];
		}
		else
		{
			[self dialogDidSucceed:url];
		}
		return NO;
	}
	else if ( [_loadingURL isEqual:url] )
	{
		return YES;
	}
	else if ( navigationType == UIWebViewNavigationTypeLinkClicked )
	{
		if ( [_delegate respondsToSelector:@selector(webDialogViewController:shouldOpenURLInExternalBrowser:)] )
		{
			if ( ![_delegate webDialogViewController:self shouldOpenURLInExternalBrowser:url] )
			{
				return NO;
			}
		}
		
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else
	{
		return YES;
	}
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_spinner stopAnimating];
	_spinner.hidden = YES;
	
	self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self updateWebOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
		// 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
	if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))
	{
		[self dismissWithError:error animated:YES];
	}
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"- (void)webViewDidStartLoad:(UIWebView *)%@", webView);
}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object
{
	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (!_showingKeyboard && [self shouldRotateToOrientation:orientation])
	{
		[self updateWebOrientation];
		
		CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
			//[self sizeToFitOrientation:YES];
		[UIView commitAnimations];
	}
}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation))
	{
		_webView.frame = CGRectInset(_webView.frame,
									 -(kPadding + kBorderWidth),
									 -(kPadding + kBorderWidth));
	}
	
	_showingKeyboard = YES;
}

- (void)keyboardWillHide:(NSNotification*)notification
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ( UIInterfaceOrientationIsLandscape(orientation) )
	{
		_webView.frame = CGRectInset(_webView.frame,
									 kPadding + kBorderWidth,
									 kPadding + kBorderWidth);
	}
	
	_showingKeyboard = NO;
}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// public

- (NSString*)title
{
	return @"";
}

- (void)setTitle:(NSString*)title
{
}

-(void)loadPage
{
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];

	[_spinner sizeToFit];

	[self addObservers];
	
	[self loadPage];
}

- (void)viewDidUnload
{
	[self removeObservers];
	[super viewDidUnload];
}

- (IBAction)cancel:(id)sender
{
	[self dismissWithSuccess:NO animated:YES info:nil];
}

- (void)dismissWithSuccess:(BOOL)success 
				  animated:(BOOL)animated
					  info:(id)info
{
	if ( [_delegate respondsToSelector:@selector(webDialogViewController:didSucceed:info:)] )
	{
		[_delegate webDialogViewController:self didSucceed:success info:info];
	}
	[self dismiss:animated];
}

- (void)dismissWithError:(NSError*)error 
				animated:(BOOL)animated
{
	if ( [_delegate respondsToSelector:@selector(dialog:didFailWithError:)] )
	{
		[_delegate webDialogViewController:self didFailWithError:error];
	}
	[self dismiss:animated];
}

- (void)loadURL:(NSString*)url 
		 method:(NSString*)method 
			get:(NSDictionary*)getParams
		   post:(NSDictionary*)postParams
{
	[_loadingURL release];
	_loadingURL = [[self generateURL:url params:getParams] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
	
	if (method)
	{
		[request setHTTPMethod:method];
		
		if ([[method uppercaseString] isEqualToString:@"POST"])
		{
			NSString* contentType = [NSString
									 stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
			[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
			
			NSData* body = [self generatePostBody:postParams];
			if (body)
			{
				[request setHTTPBody:body];
			}
		}
	}
	[_spinner startAnimating];
	[_webView loadRequest:request];
}

- (void)dialogDidSucceed:(NSURL*)url
{
	[self dismissWithSuccess:YES animated:YES info:url];
}

@end
