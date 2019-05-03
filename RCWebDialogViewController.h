//
//  RCWebDialogViewController.h
//  Aktuala Loko
//
//  Created by Michael Rockhold on 6/4/2010.
//  Copyright 2010 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RCWebDialogViewControllerDelegate;

@interface RCWebDialogViewController : UIViewController < UIWebViewDelegate >
{
  id<RCWebDialogViewControllerDelegate> _delegate;
  NSURL* _loadingURL;
	
  UIWebView* _webView;
  UIActivityIndicatorView* _spinner;
	
  UIDeviceOrientation _orientation;
  BOOL _showingKeyboard;
}

/**
 * The delegate.
 */
@property(nonatomic,assign) id<RCWebDialogViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

/**
 * The title that is shown in the header atop the view;
 */
@property(nonatomic,copy) NSString* title;

-(id)initWithDelegate:(id<RCWebDialogViewControllerDelegate>)delegate;

/**
 * Displays a URL in the dialog.
 */
-(void)loadPage;

-(void)loadURL:(NSString*)url
		 method:(NSString*)method
			get:(NSDictionary*)getParams
		   post:(NSDictionary*)postParams;


- (IBAction)cancel:(id)sender;

- (void)dismiss:(BOOL)animated;

/**
 * Hides the view and notifies delegates of success or cancellation.
 */
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated info:(id)info;

/**
 * Hides the view and notifies delegates of an error.
 */
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;

/**
 * Subclasses should override to process data returned from the server in a 'fbconnect' url.
 *
 * Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
 */
- (void)dialogDidSucceed:(NSURL*)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol RCWebDialogViewControllerDelegate <NSObject>

@optional

/**
 * Called when the web dialog view controller succeeds and is about to be dismissed.
 */
-(void)webDialogViewController:(RCWebDialogViewController*)wdvc didSucceed:(BOOL)succeeded info:(id)info;

/**
 * Called when it failed to load due to an error.
 */
-(void)webDialogViewController:(RCWebDialogViewController*)wdvc didFailWithError:(NSError*)error;

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser, 
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)webDialogViewController:(RCWebDialogViewController*)wdvc shouldOpenURLInExternalBrowser:(NSURL*)url;

@end
