//
//  BaseViewController.m

#import "BaseViewController.h"
#import "CoinsController.h"
#import "ObjectAL.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize webView, tableData;
@synthesize currentScore;
@synthesize currentLeaderBoard;
@synthesize currentScoreLabel;

+(void)playSoundEffect:(NSString*)soundEfectId{
    if([[CommonUtilities decryptString:@"sound"] isEqual:@"OFF"]){
        
    }else{
        [[OALSimpleAudio sharedInstance] playEffect:soundEfectId];
    }

}

+ (void)showCoinsView:(id)sender inController:(UIViewController*)controller{
    CoinsController *sampleView = [[[CoinsController alloc] initWithNibName:@"CoinsController" bundle:nil] autorelease];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        sampleView.modalPresentationStyle = UIModalPresentationFormSheet;
        [controller presentViewController:sampleView animated:YES completion:nil];
        
//        sampleView.view.superview.frame = CGRectMake(0, 20, 1024, 768);//it's important to do this after
        
        //sampleView.view.superview.center = self.view.window.center;
    }else{
        [controller presentViewController:sampleView animated:YES completion:nil];
    }
}


- (IBAction)closeCoins:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
	[responseData setLength:0];
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
#ifdef DEBUG
		NSDictionary *dictionary = [httpResponse allHeaderFields];
		NSLog(@"%@", [dictionary description]);
#endif
	}
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
#ifdef DEBUG
    NSString *a = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Data: %@", a);
#endif
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(IBAction)tryConnect:(id)sender{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReachable startNotifier];
}


-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            ////NSLog(@"The internet is down.");
            //self.internetActive = NO;
            
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
            //viewLoading.alpha = 0.0;
            viewNoInternet.alpha = 0.9;
            [UIView commitAnimations];
            
            break;
        }
        case ReachableViaWiFi:
        {
            ////NSLog(@"The internet is working via WIFI.");
            //self.internetActive = YES;
            
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
            //viewLoading.alpha = 0.0;
            viewNoInternet.alpha = 0.0;
            [UIView commitAnimations];
            
            break;
        }
        case ReachableViaWWAN:
        {
            ////NSLog(@"The internet is working via WWAN.");
            //self.internetActive = YES;
            
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
            //viewLoading.alpha = 0.0;
            viewNoInternet.alpha = 0.0;
            [UIView commitAnimations];
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            
            ////NSLog(@"A gateway to the host server is down.");
            // self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            ////NSLog(@"A gateway to the host server is working via WIFI.");
            // self.hostActive = YES;
            
            
            break;
        }
        case ReachableViaWWAN:
        {
            ////NSLog(@"A gateway to the host server is working via WWAN.");
            // self.hostActive = YES;
            
            break;
        }
    }
    
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}

- (BOOL) shouldAutorotate {
    return YES;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        return YES;
    }else{
        return NO;
    }
}


- (void)presetSoundButtons{
    if([[CommonUtilities decryptString:@"sound"] isEqual:@"OFF"]){
        [soundswitch setImage:[UIImage imageForDeviceForName:@"sound_off.png"] forState:UIControlStateNormal];
    }else{
        [soundswitch setImage:[UIImage imageForDeviceForName:@"sound_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)sound:(id)sender{
    
    if([[CommonUtilities decryptString:@"sound"] isEqual:@"OFF"]){
        [CommonUtilities encryptString:@"ON":@"sound"];
        [soundswitch setImage:[UIImage imageForDeviceForName:@"sound_on.png"] forState:UIControlStateNormal];
    }else{
        [CommonUtilities encryptString:@"OFF":@"sound"];
        [soundswitch setImage:[UIImage imageForDeviceForName:@"sound_off.png"] forState:UIControlStateNormal];
    }
}

-(void)fadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [UIView commitAnimations];
}



@end
