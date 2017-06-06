//
//  ViewController.m

NSMutableArray * arrayOfSection;
NSMutableArray * sectionHeaders;
NSString *error;

#import "CoinsController.h"
#import "NSString+SBJSON.h"

#import <CommonCrypto/CommonDigest.h>

@implementation CoinsController

-(void) callPurchaseId:(NSString*)iapId amount:(NSUInteger)ncoins{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier
                :iapId];
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
    viewLoading.alpha = 0.9;
    [UIView commitAnimations];
    loadingtext.text = @"Processing Purchase";
    
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%li", (unsigned long)ncoins]:@"c"];
}
- (IBAction)purchaseCoins:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    NSLog(@"%li", (long)button.tag);
    switch (button.tag) {
        case 1001:
            [self callPurchaseId:IAP1 amount:IAP_AMT_1];
            break;
        case 1002:
            [self callPurchaseId:IAP2 amount:IAP_AMT_2];
            break;
        case 1003:
            [self callPurchaseId:IAP3 amount:IAP_AMT_3];
            break;
        case 1004:
            [self callPurchaseId:IAP4 amount:IAP_AMT_4];
            break;
        case 1005:
            [self callPurchaseId:IAP5 amount:IAP_AMT_5];
            break;
        case 1006:
            [self callPurchaseId:IAP6 amount:IAP_AMT_6];
            break;
        default:
            break;
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
    nf.usesGroupingSeparator = YES;
    nf.groupingSize = 3;
    ((UILabel*)[self.view viewWithTag:2001]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_1]]];
    ((UILabel*)[self.view viewWithTag:2002]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_2]]];
    ((UILabel*)[self.view viewWithTag:2003]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_3]]];
    ((UILabel*)[self.view viewWithTag:2004]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_4]]];
    ((UILabel*)[self.view viewWithTag:2005]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_5]]];
    ((UILabel*)[self.view viewWithTag:2006]).text = [NSString stringWithFormat:@"%@ Coins", [nf stringFromNumber:[NSNumber numberWithInteger:IAP_AMT_6]]];
    [nf release];
}


- (void)requestProUpgradeProductData
{
	NSLog(@"called  productsRequest");
    
    [UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
	viewLoading.alpha = 0.9;
	[UIView commitAnimations];
    
    loadingtext.text = @"Connecting to Store";
    
    if([cost1000.text isEqual:@"0.00"]){
        
        NSSet *productIdentifiers = [NSSet setWithObjects:IAP1, IAP2, IAP3, IAP4, IAP5, IAP6, nil];
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
        
        
    }else{
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
        viewLoading.alpha = 0.0;
        [UIView commitAnimations];
    }
	
    
	
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSString *sym = @"";
    NSArray *items = response.products;
    
    for(SKProduct *itemproduct in items)
    {
        
        NSLog(@"Product title: %@    - %@" , itemproduct.localizedTitle, itemproduct.priceAsString);
        NSLog(@"Product id: %@" , itemproduct.productIdentifier);
        
        if([itemproduct.productIdentifier isEqual:IAP1]){
            cost1000.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }else if([itemproduct.productIdentifier isEqual:IAP2]){
            cost3200.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }else if([itemproduct.productIdentifier isEqual:IAP3]){
            cost8000.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }else if([itemproduct.productIdentifier isEqual:IAP4]){
            cost20000.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }else if([itemproduct.productIdentifier isEqual:IAP5]){
            cost80000.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }else if([itemproduct.productIdentifier isEqual:IAP6]){
            cost200000.text = [sym stringByAppendingString:[NSString stringWithFormat:@"%@", itemproduct.priceAsString]];
        }
        
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        
        error = @"YES";
    }
    
    if([error isEqual:@"YES"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments Error Occured" message:@"Could not read payment information from Apple In-App Servers. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
        [self dismissViewControllerAnimated:YES completion:nil];
        error = @"NO";
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    //[productsRequest release];
    
    [UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
	viewLoading.alpha = 0.0;
	[UIView commitAnimations];
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
    if (wasSuccessful)
    {
#ifdef kURL_VERIFY_PURCHASE_RECEIPT
        NSString *jsonObjectString = [CommonUtilities encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
        ////NSLog(jsonObjectString);
        
        
        [CommonUtilities encryptString:[CommonUtilities md5:jsonObjectString]:@"b"];
        
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
		viewLoading.alpha = 0.9;
		[UIView commitAnimations];
		//loadingtext.text = @"Purchase Completing";

        loadingtext.text = @"Completing Transaction";
        
        NSString *httpBodyString=[[NSString alloc] initWithFormat:@"receipt=%@&userid=%@",jsonObjectString, [CommonUtilities decryptString:@"username"]];
        
        NSString *urlString=kURL_VERIFY_PURCHASE_RECEIPT;
        
        NSURL *url=[[NSURL alloc] initWithString:urlString];
        [urlString release];
        
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
        [url release];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [httpBodyString length]];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[httpBodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
        [httpBodyString release];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        responseData=[[NSMutableData data] retain];
#else
        int addCoins = [[CommonUtilities decryptString:@"c"] intValue];
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        int newCoins = addCoins + currentCoins;
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", newCoins]:@"coins"];
        
        // due to sync issues we add + 1 to xp so sync to server completes
        NSLog(@"transaction complete");
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
        viewLoading.alpha = 0.0;
        [UIView commitAnimations];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase complete" message:@"The coins you've purchased have been added to your inventory" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
#endif
    }
    else
    {
		////NSLog(@"notpurchased");
        // send out a notification for the failed transaction
        // NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction failed" message:[transaction.error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];

		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
		viewLoading.alpha = 0.0;
		[UIView commitAnimations];
		
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}
//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
		
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
		viewLoading.alpha = 0.0;
		[UIView commitAnimations];
        ////NSLog(@"error transaction");
		
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
		viewLoading.alpha = 0.0;
		[UIView commitAnimations];
        ////NSLog(@"cancelled transaction");
		
    }
}
//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}


#pragma mark -


- (IBAction)closeCoins:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
   [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    webView.opaque = NO; 
    webView.backgroundColor = [UIColor clearColor];
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    jackpotView.opaque = NO; 
    jackpotView.backgroundColor = [UIColor clearColor];
    
    //[self didLoad];
    
    viewLoading.alpha = 0.0;
    viewNoInternet.alpha = 0.0;
    
    // reachability
    [self tryConnect:nil];
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"can make payments");
		[self requestProUpgradeProductData];
	}else{
		NSLog(@"cannot make payments");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments Disabled" message:@"In-App Purchases are disabled on this device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
        [self dismissViewControllerAnimated:YES completion:nil];
        
	}
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    result = CGSizeMake(result.width * scale, result.height * scale);

    if(result.height == 960){
        bar.frame = CGRectMake(0,0,(result.height / 2),32);
    }else if(result.height == 1136){
        bar.frame = CGRectMake(0,0,(result.height / 2),32);
    }else if(result.height == 1024){
        bar.frame = CGRectMake(0,0,result.height,44);
//        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:26.0]];
    }else if (result.height == 2048){
        bar.frame = CGRectMake(0,0,result.height/2,44);
//        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:26.0]];
    }
    else{
        bar.frame = CGRectMake(0,0,(result.height),32);
    }

    int fontSize = 16;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:18.0]];
    }else{
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        fontSize = 12;
    }
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    UIImage *buttonBack32 = [[UIImage imageNamed:@"NavigationBackButton"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 5)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack32 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica-Bold" size:fontSize],
      UITextAttributeFont,
      nil]
                                                forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
}


-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"coins has gone");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sortCoins" object:self];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:20.0]];
    }else{
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
    }
}


//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}

//- (BOOL) shouldAutorotate {
//    return YES;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        return YES;
    }else{
        return NO;
    }
}


- (void)dealloc {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[super dealloc];
}

/*#pragma mark for server side validation (no customer support)
// these connection-related methods are only here to help in case you ever decide to implement
// server-side validation of purchase receipts

// - in this case, you'll also need to define your own kURL_VERIFY_PURCHASE_RECEIPT and figure out the existing validation protocol (I can't provide you with support on this one, it's code written by someone else)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
		NSDictionary *dictionary = [httpResponse allHeaderFields];
		////NSLog([dictionary description]);
	}
	
}
*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[responseData appendData:data];
    
    NSString *a = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    ////NSLog(@"Data: %@", a);
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You are not connected to the internet or data. Please connect and try again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //////NSLog(responseString);
    
    NSString *gKey = [CommonUtilities decryptString:@"b"];
    NSString *result = [CommonUtilities base64Decrypt:responseString:gKey];
    
    NSLog(@"%@",result);
    
    int r = [result intValue];
    
    ////NSLog(@"r int: %i", r);
    
    if(r == 1){
        int addCoins = [[CommonUtilities decryptString:@"c"] intValue];
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        int newCoins = addCoins + currentCoins;
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", newCoins]:@"coins"];
        
        // due to sync issues we add + 1 to xp so sync to server completes
        NSLog(@"transaction complete");
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Receipt Failed" message:@"Please make the purchase again using a vaild iTunes account" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
    viewLoading.alpha = 0.0;
    [UIView commitAnimations];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)fadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    // [infoLbl setAlpha:1];
    [UIView commitAnimations];
    
}
@end
