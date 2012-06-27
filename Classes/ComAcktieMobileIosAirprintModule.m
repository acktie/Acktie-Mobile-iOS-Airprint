/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComAcktieMobileIosAirprintModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiUIViewProxy.h" 

@implementation ComAcktieMobileIosAirprintModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"e30249f1-8ddc-4230-afa9-2357c105c92a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.acktie.mobile.ios.airprint";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                               object: nil];
     */
}

- (void) orientationDidChange: (NSNotification *) note
{
    /*
    UIInterfaceOrientation orientation = [[[note userInfo] objectForKey: UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    NSLog(@"Rotated!");
     */
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

-(void)print: (id)args
{
    NSLog(@"print");
    ENSURE_UI_THREAD(print, args);
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString *file = nil;
    NSData *document = nil;
    BOOL displayPageRange = true;
    TiViewProxy* proxy = nil;
    NSString* jobName = nil;
    
    if([args objectForKey:@"file"] != nil)
    {
        NSString* fileString = [TiUtils stringValue:[args objectForKey:@"file"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        
        file = [[paths lastObject] stringByAppendingPathComponent:fileString];
        
        document = [NSData dataWithContentsOfFile:file];
    }
    else if([args objectForKey:@"url"] != nil)
    {
        file = [TiUtils stringValue:[args objectForKey:@"url"]];
        NSURL *url = [NSURL URLWithString:file];
        
        document = [NSData dataWithContentsOfURL:url];
    }
    NSLog([NSString stringWithFormat:@"file: %@", file]);
    
    if([args objectForKey:@"displayPageRange"] != nil)
    {
        displayPageRange = [TiUtils boolValue:[args objectForKey:@"displayPageRange"]];
    }
    NSLog([NSString stringWithFormat:@"displayPageRange: %d", displayPageRange]);
    
    if([args objectForKey:@"jobName"] != nil)
    {
        jobName = [TiUtils stringValue:[args objectForKey:@"jobName"]];;
    }
    else
    {
        jobName = [file lastPathComponent];
    }
    NSLog([NSString stringWithFormat:@"jobName: %@", jobName]);
    
    if([args objectForKey:@"view"] != nil)
    {
        proxy = (TiViewProxy*)[args objectForKey:@"view"];
    }
    NSLog([NSString stringWithFormat:@"proxy: %@", proxy]);
     
    if ([args objectForKey:@"sentToPrinter"] != nil)
    {
        NSLog(@"Received sentToPrinter callback");
        
        sentToPrinter = [args objectForKey:@"sentToPrinter"];
        ENSURE_TYPE_OR_NIL(sentToPrinter,KrollCallback);
        [sentToPrinter retain];
    }
    
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    
    if(printController && [UIPrintInteractionController canPrintData:document]) {
        
        printController.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = jobName;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        printController.printInfo = printInfo;
        printController.showsPageRange = displayPageRange;
        printController.printingItem = document;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) 
        {
            id listener = [[sentToPrinter retain] autorelease];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:NUMBOOL(completed) forKey:@"completed"];
            NSLog(@"completionHandler, completed? : %d", completed);
            if (!completed && error) 
            {
                // Populate Callback data
                [dictionary setObject:NUMINT(error.code) forKey:@"code"];
                [dictionary setObject:error.domain forKey:@"message"];

                NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
            }

            NSLog(@"Calling Callback");
            [self _fireEventToListener:@"sentToPrinter" withObject:dictionary listener:listener thisObject:nil];
        };
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            [printController presentFromRect:proxy.view.frame inView:proxy.parent.view animated:YES completionHandler:completionHandler];
        } 
        else 
        {
            [printController presentAnimated:YES completionHandler:completionHandler];
        }
    }
}

-(id)canPrint
{
    return NUMBOOL([UIPrintInteractionController isPrintingAvailable]);
}
@end
