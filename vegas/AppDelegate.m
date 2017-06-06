//
//  AppDelegate.m

#import "AppDelegate.h"
#import "ViewController.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;


UIBackgroundTaskIdentifier bgTask;

- (void)dealloc
{
    [Chartboost release];
    [_window release];
    [_viewController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	
    NSString *gamewin = [notification.userInfo valueForKey:@"daily"];
	application.applicationIconBadgeNumber = 0;
    
    if([gamewin isEqual:@"1"]){
        [CommonUtilities encryptString:@"YES":@"zd"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DailyBonus" object:self];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
   [ALSdk initializeSdk];
    
    [Chartboost startWithAppId:CHARTBOOST_APP_KEY appSignature:CHARTBOOST_APP_SECRET delegate:self];
    [Chartboost cacheRewardedVideo:CBLocationMainMenu];
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];


    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

  /*  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            //NSLog(@"Launched from push notification: %@", dictionary);
            // do something with your dictionary
        }
    }*/
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
    }
    
    NSString *gamewin = [localNotification.userInfo valueForKey:@"daily"];
	application.applicationIconBadgeNumber = 0;
    
    if([gamewin isEqual:@"1"]){
        [CommonUtilities encryptString:@"YES":@"zd"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DailyBonus" object:self];
    }
    return YES;
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification;
{
    switch([[UIApplication sharedApplication] statusBarOrientation]){
        case UIInterfaceOrientationLandscapeLeft:
            self.window.bounds = CGRectMake(0, 0, self.initialWindowBounds.width-20, self.initialWindowBounds.height);
            self.window.frame =  CGRectMake(20, 0, self.initialWindowBounds.width-20, self.initialWindowBounds.height);
            NSLog(@"%@", NSStringFromCGRect(self.window.bounds));
        default :break;
        case UIInterfaceOrientationLandscapeRight:
            self.window.bounds = CGRectMake(20, 0, self.initialWindowBounds.width-20, self.initialWindowBounds.height);
            self.window.frame =  CGRectMake(0, 0, self.initialWindowBounds.width-20, self.initialWindowBounds.height);
            NSLog(@"%@", NSStringFromCGRect(self.window.bounds));
            break;
    }
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //  Push notification received while the app is running
    //NSLog(@"Received notification: %@", userInfo);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"%@",token);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:token forKey:@"pushtoken"];
    [prefs synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    UIApplication* app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self.viewController manageServer:@"end"];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(closeBackground)
                                   userInfo:nil
                                    repeats:NO];
}
-(void)closeBackground{
    UIApplication* app = [UIApplication sharedApplication];
    
    if( bgTask != UIBackgroundTaskInvalid ) {
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        NSLog(@"closed background");
    }else{
        NSLog(@"called but not closed");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
#ifdef ADS_RESUME_FREQUENCY
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger resume_nb = [prefs integerForKey:@"nResumes"];
    resume_nb++;
    [prefs setInteger:resume_nb forKey:@"nResumes"];
    [prefs synchronize];

    if ((resume_nb % ADS_RESUME_FREQUENCY) == 0) {
        [Chartboost showInterstitial:CBLocationHomeScreen];
    }
    /* 
     for revmob interstitials instead of Chartboost, instead of the line that says
             [[Chartboost sharedChartboost] showInterstitial];
        write a line that says
            [[RevMobAds session] showFullscreen];
     */
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.viewController manageServer:@"start"];
    [self setupLocalNotif];
}


-(void)setupLocalNotif{
    
    NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
    int todayNow = [intervalString intValue];
    double sDate = todayNow + 86001;
    
    NSLog(@"%i", todayNow);
    NSLog(@"%f", [[CommonUtilities decryptString:@"p"] doubleValue]);
    
    // if newsDate is higher than save dated = notif
    
    if(todayNow > [[CommonUtilities decryptString:@"p"] doubleValue]){
        NSLog(@"notif");
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        //localNotif.fireDate = [NSDate dateWithTimeIntervalSince1970:sDate];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:86000];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        localNotif.alertBody = @"Big Daily Bonus Now! Play Vegas Slots Bookworm!";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"1" forKey:@"daily"];
        localNotif.userInfo = infoDict;
        
        if([[CommonUtilities decryptString:@"notif"] isEqual:@"YES"]){
            // Schedule the notification
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            [localNotif release];
        }else{
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%f", sDate]:@"p"];
        
        if([[CommonUtilities decryptString:@"firstNotifBoot"] isEqual:@"YES"]){
            //prizeShuffleCounter = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DailyBonus" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseForBonus" object:self];
        }else{
            [CommonUtilities encryptString:@"YES":@"firstNotifBoot"];
            NSLog(@"first booot up");
        }
    }else{
        NSLog(@"already dispatched today");
    }
    
    NSLog(@"a: %i", todayNow);
    NSLog(@"a: %f", [[CommonUtilities decryptString:@"p"] doubleValue]);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward{
 
    int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
    currentCoins = currentCoins + 100;
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
   
}
-(void) rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    /* AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
     awarded and the name of the currency.  However, ideally, you should verify this with your server before granting it. */
    int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
    currentCoins = currentCoins + 100;
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
}

@end
