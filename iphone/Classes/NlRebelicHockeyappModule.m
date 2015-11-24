/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "NlRebelicHockeyappModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

extern NSString * const TI_APPLICATION_ID;
static NSString * appCrashInfoKey;

@implementation NlRebelicHockeyappModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"5accc0b6-00bd-4304-83fe-457f73a41412";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"nl.rebelic.hockeyapp";
    
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	//NSLog(@"[INFO] %@ loaded",self);
    
    appCrashInfoKey = [NSString stringWithFormat:@"%@.%@", TI_APPLICATION_ID, @"crash_info"];
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

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}


MAKE_SYSTEM_PROP(CrashManagerStatusDisabled, BITCrashManagerStatusDisabled);
MAKE_SYSTEM_PROP(CrashManagerStatusAlwaysAsk, BITCrashManagerStatusAlwaysAsk);
MAKE_SYSTEM_PROP(CrashManagerStatusAutoSend, BITCrashManagerStatusAutoSend);


#pragma Public APIs
-(void)start:(id)args
{
    ENSURE_UI_THREAD(start, args);
    
    NSString *appId = nil;
    NSDictionary *props = nil;
    
    ENSURE_ARG_AT_INDEX(appId, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(props, args, 1, NSDictionary);
    
    BITCrashManagerStatus crashManagerStatus = [TiUtils intValue:@"crashManagerStatus" properties:props def:BITCrashManagerStatusAutoSend];
    
    if (crashManagerStatus > BITCrashManagerStatusAutoSend) {
        [self throwException:@"Invalid value for crashManagerStatus property" subreason:nil location:CODELOCATION];
    }
    
    BOOL enableStoreUpdateManager = [TiUtils boolValue:@"enableStoreUpdateManager" properties:props def:NO];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:appId delegate:self];
    [[BITHockeyManager sharedHockeyManager] setEnableStoreUpdateManager: enableStoreUpdateManager];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus: crashManagerStatus];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}

-(void)setFeedbackScreenshotType:(id)args
{
    ENSURE_SINGLE_ARG(args, NSString);
    
    NSString *type = (NSString *) args;
    
    if([type  isEqual: @"last"]) {
        [[BITHockeyManager sharedHockeyManager].feedbackManager setFeedbackObservationMode:BITFeedbackObservationModeOnScreenshot];
    }
    else if([type  isEqual: @"3finger"]) {
        [[BITHockeyManager sharedHockeyManager].feedbackManager setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
    }
}

-(void)showFeedbackListView:(id)args
{
    [[BITHockeyManager sharedHockeyManager].feedbackManager showFeedbackListView];
}

-(void)showFeedbackComposeView:(id)args
{
    [[BITHockeyManager sharedHockeyManager].feedbackManager showFeedbackComposeView];
}


-(NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager
{
    
    NSString *appLog = [[NSUserDefaults standardUserDefaults] valueForKey:appCrashInfoKey];
    if (appLog == nil) {
        return nil;
    }
    NSLog(@"appLog: %@", appLog);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:appCrashInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return appLog;
}

@end
