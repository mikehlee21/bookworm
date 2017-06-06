//
//  ViewController.m


#import "GameClassic20.h"
#import "CoinsController.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "BonusViewController.h"
#import "BonusChestViewController.h"
#import "BonusDoubleViewController.h"

#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>
#import "Chartboost/Chartboost.h"
#import "ALIncentivizedInterstitialAd.h"


@implementation GameClassic20

@synthesize currentScoreLabel;
// game prefs (overrides)
#define kBonus @"YES"
#define kautoSpinOverride @"NO"


-(UIImage*)createDynamicSlotImageWheel:(NSUInteger)wheel gameIdString:(NSString*)gameIdString{
    NSArray* slotItems = @[
                           @[@"J", @"7", @"Diamond", @"Star", @"A", @"J", @"Lemon", @"Star", @"Q", @"K", @"K", @"J", @"Lemon", @"Q", @"Diamond", @"Lemon", @"A", @"Star", @"7", @"J"],
                           @[@"K", @"Star", @"Q", @"Lemon", @"J", @"Diamond", @"A", @"Bonus", @"7", @"Star", @"K", @"Wild", @"7", @"Diamond", @"K", @"Q", @"J", @"Lemon", @"J", @"Star"],
                           @[@"K", @"J", @"Lemon", @"Q", @"Diamond", @"Bonus", @"A", @"Star", @"7", @"J", @"Lemon", @"7", @"K", @"A", @"Q", @"K", @"Diamond", @"Lemon", @"J", @"Wild"],
                           @[@"Lemon", @"7", @"K", @"A", @"Q", @"K", @"Diamond", @"Bonus", @"J", @"Star", @"J", @"7", @"Diamond", @"Bonus", @"A", @"J", @"Wild", @"Star", @"Q", @"K"],
                           @[@"Bonus", @"A", @"7", @"Diamond", @"K", @"Q", @"J", @"Lemon", @"Wild", @"Star", @"K", @"Star", @"Q", @"Lemon", @"J", @"Diamond", @"A", @"Bonus", @"7", @"Star"],

                           ];
    
    CGSize smallImageSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        smallImageSize = CGSizeMake(340, 340);
    }
    else
        smallImageSize = CGSizeMake(140, 140);
    CGSize bigImageSize = CGSizeMake(smallImageSize.width, smallImageSize.height*20);
    
    UIGraphicsBeginImageContext(bigImageSize);
    
    
    for (int i=0; i<20; i++) {
        NSString* item_name = [NSString stringWithFormat:@"%@item_%@@2x", gameIdString, slotItems[wheel][i]];
//        NSLog(@"%@", item_name);
        UIImage* img_item = [UIImage imageForDeviceForName:item_name];
        [img_item drawInRect:CGRectMake(0, i*smallImageSize.height, smallImageSize.width, smallImageSize.height)];
    }

    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
 }

#ifdef DONT_SHOW_APPLOVIN_ON_EACH_SCREEN
- (void)viewDidAppear:(BOOL)animated
{
    //    This empty method prevents the display of AppLovin interstitial on each re-appearance of the game screen.
    //    If you'd rather want this, comment out this method
}
#endif

- (IBAction)home:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)coinsView:(id)sender{
    [BaseViewController showCoinsView:sender inController:self];
        
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewMoreCoins.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *connectState = [prefs stringForKey:@"connectState"];
    
    //NSLog(@"connectState: %@", connectState);
    
    if([connectState isEqual:@"updatecoins"]){
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(responseString);
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:responseString forKey:@"testResponse"];
        [prefs synchronize];
    }else if([connectState isEqual:@"sync"]){
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"responseString: %@", responseString);
        
        // build 4 coin strings
        NSString *response = [CommonUtilities base64Decrypt:responseString:[CommonUtilities decryptString:@"commsKey"]];
        //NSLog(@"response: %@", response);
        
        if([response isEqual:@""]){
            //NSLog(@"decrypt error");
        }else{
            NSArray *downloadData = [response componentsSeparatedByString:@"||"];
            
            @try {
                if([[downloadData objectAtIndex:0] isEqual:@""] || [[downloadData objectAtIndex:1] isEqual:@""] || [[downloadData objectAtIndex:2] isEqual:@""] || [[downloadData objectAtIndex:3] isEqual:@""]){
                    //NSLog(@"data download bug - DONT UPDATE");
                }else{
                    [CommonUtilities encryptString:[downloadData objectAtIndex:0]:@"coins"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:1]:@"won"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:2]:@"bet"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:3]:@"exp"];
                    
                    displayCoins.text = [CommonUtilities decryptString:@"coins"];
                    
                    
                    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
                    
                    optionXP.text = [CommonUtilities decryptString:@"exp"];
                    optionLvl.text = [self returnLevel:xp];
                    
                    [self sortLevelBar];
                }
            }
            @catch (NSException * e) {
                //NSLog(@"Exception: %@", e);
            }
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)moveRow{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        int amount1 = ((moveRow1Amount/10) * 17);
        
        if(moveRow1Counter == amount1){
            
            if([finished1 isEqual:@"YES"]){
                finished1 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];
                
                finished1 = @"YES";
            }
            
        }else{
            moveRow1Counter = moveRow1Counter + 1;
            play = @"NO";
            finished1 = @"NO";
            
            ////NSLog(@"set1: %f", slot1Set1.frame.origin.y);
            ////NSLog(@"set2: %f", slot1Set2.frame.origin.y);
            
            slot1Set1.frame = CGRectMake(slot1Set1.frame.origin.x, slot1Set1.frame.origin.y + 10, slot1Set1.frame.size.width, slot1Set1.frame.size.height);
            slot1Set2.frame = CGRectMake(slot1Set2.frame.origin.x, slot1Set2.frame.origin.y + 10, slot1Set2.frame.size.width, slot1Set2.frame.size.height);
        }
        
        /*
         
         to find the first start do slot1 Y postion
         
         size - 510 to get the sum.
         
         example 100 - 510 = -410
         
         --------------
         
         the size different is +980
         
         example if
         slot1Set2 == 0
         slot1Set2 == 980
         
         -----------
         
         first = -700 different
         second = -1400 differet
         */
        
        
        //1680
        
        
        // differnet of -1400 between equal and move
        if(slot1Set2.frame.origin.y == -2720){
            slot1Set1.frame = CGRectMake(slot1Set1.frame.origin.x, -6120, slot1Set1.frame.size.width, slot1Set1.frame.size.height);
        }
        
        
        // different of -2800 between equal and move // 6800
        if(slot1Set2.frame.origin.y == 1360){
            slot1Set2.frame = CGRectMake(slot1Set2.frame.origin.x, -5440, slot1Set2.frame.size.width, slot1Set2.frame.size.height);
            // //NSLog(@"xxx");
        }
        
        
        // row2
        int amount2 = (((moveRow2Amount/10) + 20) * 17);
        
        if(moveRow2Counter == amount2){
            if([finished2 isEqual:@"YES"]){
                finished2 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished2 = @"YES";
            }
        }else{
            moveRow2Counter = moveRow2Counter + 1;
            play = @"NO";
            finished2 = @"NO";
            
            slot2Set1.frame = CGRectMake(slot2Set1.frame.origin.x, slot2Set1.frame.origin.y + 10, slot2Set1.frame.size.width, slot2Set1.frame.size.height);
            slot2Set2.frame = CGRectMake(slot2Set2.frame.origin.x, slot2Set2.frame.origin.y + 10, slot2Set2.frame.size.width, slot2Set2.frame.size.height);
        }
        
        
        if(slot2Set2.frame.origin.y == -2720){
            slot2Set1.frame = CGRectMake(slot2Set1.frame.origin.x, -6120, slot2Set1.frame.size.width, slot2Set1.frame.size.height);
        }
        
        if(slot2Set2.frame.origin.y == 1360){
            slot2Set2.frame = CGRectMake(slot2Set2.frame.origin.x, -5440, slot2Set2.frame.size.width, slot2Set2.frame.size.height);
        }
        
        // row 3
        
        int amount3 = (((moveRow3Amount/10) + 40) * 17);
        
        if(moveRow3Counter == amount3){
            if([finished3 isEqual:@"YES"]){
                finished3 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished3 = @"YES";
            }
        }else{
            moveRow3Counter = moveRow3Counter + 1;
            play = @"NO";
            finished3 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot3Set1.frame = CGRectMake(slot3Set1.frame.origin.x, slot3Set1.frame.origin.y + 10, slot3Set1.frame.size.width, slot3Set1.frame.size.height);
            slot3Set2.frame = CGRectMake(slot3Set2.frame.origin.x, slot3Set2.frame.origin.y + 10, slot3Set2.frame.size.width, slot3Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot3Set2.frame.origin.y == -2720){
            slot3Set1.frame = CGRectMake(slot3Set1.frame.origin.x, -6120, slot3Set1.frame.size.width, slot3Set1.frame.size.height);
        }
        
        if(slot3Set2.frame.origin.y == 1360){
            slot3Set2.frame = CGRectMake(slot3Set2.frame.origin.x, -5440, slot3Set2.frame.size.width, slot3Set2.frame.size.height);
        }
        
        // row 4
        
        int amount4 = (((moveRow4Amount/10) + 60) * 17);
        
        if(moveRow4Counter == amount4){
            if([finished4 isEqual:@"YES"]){
                finished4 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished4 = @"YES";
            }
        }else{
            moveRow4Counter = moveRow4Counter + 1;
            play = @"NO";
            finished4 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot4Set1.frame = CGRectMake(slot4Set1.frame.origin.x, slot4Set1.frame.origin.y + 10, slot4Set1.frame.size.width, slot4Set1.frame.size.height);
            slot4Set2.frame = CGRectMake(slot4Set2.frame.origin.x, slot4Set2.frame.origin.y + 10, slot4Set2.frame.size.width, slot4Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot4Set2.frame.origin.y == -2720){
            slot4Set1.frame = CGRectMake(slot4Set1.frame.origin.x, -6120, slot4Set1.frame.size.width, slot4Set1.frame.size.height);
        }
        
        if(slot4Set2.frame.origin.y == 1360){
            slot4Set2.frame = CGRectMake(slot4Set2.frame.origin.x, -5440, slot4Set2.frame.size.width, slot4Set2.frame.size.height);
        }
        
        // row 5
        
        int amount5 = (((moveRow5Amount/10) + 80) * 17);
        
        if(moveRow5Counter == amount5){
            if([finished5 isEqual:@"YES"]){
                finished5 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished5 = @"YES";
            }
        }else{
            moveRow5Counter = moveRow5Counter + 1;
            play = @"NO";
            finished5 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot5Set1.frame = CGRectMake(slot5Set1.frame.origin.x, slot5Set1.frame.origin.y + 10, slot5Set1.frame.size.width, slot5Set1.frame.size.height);
            slot5Set2.frame = CGRectMake(slot5Set2.frame.origin.x, slot5Set2.frame.origin.y + 10, slot5Set2.frame.size.width, slot5Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot5Set2.frame.origin.y == -2720){
            slot5Set1.frame = CGRectMake(slot5Set1.frame.origin.x, -6120, slot5Set1.frame.size.width, slot5Set1.frame.size.height);
        }
        
        if(slot5Set2.frame.origin.y == 1360){
            slot5Set2.frame = CGRectMake(slot5Set2.frame.origin.x, -5440, slot5Set2.frame.size.width, slot5Set2.frame.size.height);
        }
        
        //
        
        if([finished1 isEqual:@"YES"] && [finished2 isEqual:@"YES"] && [finished3 isEqual:@"YES"] && [finished4 isEqual:@"YES"] && [finished5 isEqual:@"YES"]){
            [row invalidate];
            play = @"YES";
            [self checkIfWon];
        }
    }else{
        int amount1 = ((moveRow1Amount/10) * 7);
        
        if(moveRow1Counter == amount1){
            
            if([finished1 isEqual:@"YES"]){
                finished1 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                
                finished1 = @"YES";
            }
            
        }else{
            moveRow1Counter = moveRow1Counter + 1;
            play = @"NO";
            finished1 = @"NO";
            
            slot1Set1.frame = CGRectMake(slot1Set1.frame.origin.x, slot1Set1.frame.origin.y + 10, slot1Set1.frame.size.width, slot1Set1.frame.size.height);
            slot1Set2.frame = CGRectMake(slot1Set2.frame.origin.x, slot1Set2.frame.origin.y + 10, slot1Set2.frame.size.width, slot1Set2.frame.size.height);
        }
        
        /*
         
         to find the first start do slot1 Y postion
         
         size - 510 to get the sum.
         
         example 100 - 510 = -410
         
         --------------
         
         the size different is +980
         
         example if
         slot1Set2 == 0
         slot1Set2 == 980
         
         -----------
         
         first = -700 different
         second = -1400 differet
         */
        
        
        //1680
        
        
        // differnet of -1400 between equal and move
        if(slot1Set2.frame.origin.y == -960){
            slot1Set1.frame = CGRectMake(slot1Set1.frame.origin.x, -2360, slot1Set1.frame.size.width, slot1Set1.frame.size.height);
        }
        
        
        // different of -2800 between equal and move
        if(slot1Set2.frame.origin.y == 720){
            slot1Set2.frame = CGRectMake(slot1Set2.frame.origin.x, -2080, slot1Set2.frame.size.width, slot1Set2.frame.size.height);
            // //NSLog(@"xxx");
        }
        
        
        // row2
        int amount2 = (((moveRow2Amount/10) + 20) * 7);
        
        if(moveRow2Counter == amount2){
            if([finished2 isEqual:@"YES"]){
                finished2 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished2 = @"YES";
            }
        }else{
            moveRow2Counter = moveRow2Counter + 1;
            play = @"NO";
            finished2 = @"NO";
            
            slot2Set1.frame = CGRectMake(slot2Set1.frame.origin.x, slot2Set1.frame.origin.y + 10, slot2Set1.frame.size.width, slot2Set1.frame.size.height);
            slot2Set2.frame = CGRectMake(slot2Set2.frame.origin.x, slot2Set2.frame.origin.y + 10, slot2Set2.frame.size.width, slot2Set2.frame.size.height);
        }
        
        
        
        if(slot2Set2.frame.origin.y == -960){
            slot2Set1.frame = CGRectMake(slot2Set1.frame.origin.x, -2360, slot2Set1.frame.size.width, slot2Set1.frame.size.height);
        }
        
        if(slot2Set2.frame.origin.y == 720){
            slot2Set2.frame = CGRectMake(slot2Set2.frame.origin.x, -2080, slot2Set2.frame.size.width, slot2Set2.frame.size.height);
        }
        
        // row 3
        
        int amount3 = (((moveRow3Amount/10) + 40) * 7);
        
        if(moveRow3Counter == amount3){
            if([finished3 isEqual:@"YES"]){
                finished3 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished3 = @"YES";
            }
        }else{
            moveRow3Counter = moveRow3Counter + 1;
            play = @"NO";
            finished3 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot3Set1.frame = CGRectMake(slot3Set1.frame.origin.x, slot3Set1.frame.origin.y + 10, slot3Set1.frame.size.width, slot3Set1.frame.size.height);
            slot3Set2.frame = CGRectMake(slot3Set2.frame.origin.x, slot3Set2.frame.origin.y + 10, slot3Set2.frame.size.width, slot3Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot3Set2.frame.origin.y == -960){
            slot3Set1.frame = CGRectMake(slot3Set1.frame.origin.x, -2360, slot3Set1.frame.size.width, slot3Set1.frame.size.height);
        }
        
        if(slot3Set2.frame.origin.y == 720){
            slot3Set2.frame = CGRectMake(slot3Set2.frame.origin.x, -2080, slot3Set2.frame.size.width, slot3Set2.frame.size.height);
        }
        
        // row 4
        
        int amount4 = (((moveRow4Amount/10) + 60) * 7);
        
        if(moveRow4Counter == amount4){
            if([finished4 isEqual:@"YES"]){
                finished4 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished4 = @"YES";
            }
        }else{
            moveRow4Counter = moveRow4Counter + 1;
            play = @"NO";
            finished4 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot4Set1.frame = CGRectMake(slot4Set1.frame.origin.x, slot4Set1.frame.origin.y + 10, slot4Set1.frame.size.width, slot4Set1.frame.size.height);
            slot4Set2.frame = CGRectMake(slot4Set2.frame.origin.x, slot4Set2.frame.origin.y + 10, slot4Set2.frame.size.width, slot4Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot4Set2.frame.origin.y == -960){
            slot4Set1.frame = CGRectMake(slot4Set1.frame.origin.x, -2360, slot4Set1.frame.size.width, slot4Set1.frame.size.height);
        }
        
        if(slot4Set2.frame.origin.y == 720){
            slot4Set2.frame = CGRectMake(slot4Set2.frame.origin.x, -2080, slot4Set2.frame.size.width, slot4Set2.frame.size.height);
        }
        
        
        // row 5
        
        int amount5 = (((moveRow5Amount/10) + 80) * 7);
        
        if(moveRow5Counter == amount5){
            if([finished5 isEqual:@"YES"]){
                finished5 = @"YES";
            }else{
                [BaseViewController playSoundEffect:kSoundFinishedSpin];

                finished5 = @"YES";
            }
        }else{
            moveRow5Counter = moveRow5Counter + 1;
            play = @"NO";
            finished5 = @"NO";
            
            //[UIView beginAnimations:@"MoveView" context:nil];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            //[UIView setAnimationDuration:0.1];
            slot5Set1.frame = CGRectMake(slot5Set1.frame.origin.x, slot5Set1.frame.origin.y + 10, slot5Set1.frame.size.width, slot5Set1.frame.size.height);
            slot5Set2.frame = CGRectMake(slot5Set2.frame.origin.x, slot5Set2.frame.origin.y + 10, slot5Set2.frame.size.width, slot5Set2.frame.size.height);
            //[UIView commitAnimations];
        }
        
        if(slot5Set2.frame.origin.y == -960){
            slot5Set1.frame = CGRectMake(slot5Set1.frame.origin.x, -2360, slot5Set1.frame.size.width, slot5Set1.frame.size.height);
        }
        
        if(slot5Set2.frame.origin.y == 720){
            slot5Set2.frame = CGRectMake(slot5Set2.frame.origin.x, -2080, slot5Set2.frame.size.width, slot5Set2.frame.size.height);
        }
        
        //
        
        if([finished1 isEqual:@"YES"] && [finished2 isEqual:@"YES"] && [finished3 isEqual:@"YES"] && [finished4 isEqual:@"YES"] && [finished5 isEqual:@"YES"]){
            [row invalidate];
            play = @"YES";
            [self checkIfWon];
        }
        
    }
}

- (void)manageWin:(int)winAmount{
    
    if(winAmount > 30){
        //NSLog(@"win greater than 30");
        // local remove 30 coins from the amount
        int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
        currentWon = currentWon + (winAmount - 30);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentWon]:@"won"];
        
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        currentCoins = currentCoins + (winAmount - 30);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
        
        displayCoins.text = [NSString stringWithFormat:@"%i", currentCoins];
        
        currentWinCoins = currentWinCoins + 30;
        coinsAdd = 0;
        
        if([addWinStatus isEqual:@"YES"]){}else{
            addWin = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(addWinCoins) userInfo:nil repeats:YES];
            addWinStatus = @"YES";
        }
    }else{
        currentWinCoins = currentWinCoins + winAmount;
        coinsAdd = 0;
        
        if([addWinStatus isEqual:@"YES"]){}else{
            addWin = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(addWinCoins) userInfo:nil repeats:YES];
            addWinStatus = @"YES";
        }
    }
    
}

- (void)checkIfWon{
    NSArray *winLine1 = [NSArray arrayWithObjects: @"Star", @"A", @"Lemon", @"Diamond", @"Q", @"Lemon", @"J", @"K", @"K", @"Q", @"Star", @"Lemon", @"J", @"A", @"Star", @"Diamond", @"7", @"J", @"J", @"7", nil];
    
    NSArray *winLine2 = [NSArray arrayWithObjects: @"Lemon", @"J", @"Q", @"K", @"Diamond", @"7", @"Wild", @"K", @"Star", @"7", @"Bonus", @"A", @"Diamond", @"J", @"Lemon", @"Q", @"Star", @"K", @"Star", @"J", nil];
    
    NSArray *winLine3 = [NSArray arrayWithObjects: @"Lemon", @"Diamond", @"K", @"Q", @"A", @"K", @"7", @"Lemon", @"J", @"7", @"Star", @"A", @"Bonus", @"Diamond", @"Q", @"Lemon", @"J", @"K", @"Wild", @"J", nil];
    
    NSArray *winLine4 = [NSArray arrayWithObjects: @"Star", @"Wild", @"J", @"A", @"Bonus", @"Diamond", @"7", @"J", @"Star", @"J", @"Bonus", @"Diamond", @"K", @"Q", @"A", @"K", @"7", @"Lemon", @"K", @"Q", nil];
    
    NSArray *winLine5 = [NSArray arrayWithObjects: @"Bonus", @"A", @"Diamond", @"J", @"Lemon", @"Q", @"Star", @"K", @"Star", @"Wild", @"Lemon", @"J", @"Q", @"K", @"Diamond", @"7", @"A", @"Bonus", @"Star", @"7", nil];
    
    
    int localPos1 = row1Postion - 1;
    NSString *row1CurrentWin = [winLine1 objectAtIndex:localPos1];
    //line1.text = row1CurrentWin;
    
    int localPos2 = row2Postion - 1;
    NSString *row2CurrentWin = [winLine2 objectAtIndex:localPos2];
    //line2.text = row2CurrentWin;
    
    int localPos3 = row3Postion - 1;
    NSString *row3CurrentWin = [winLine3 objectAtIndex:localPos3];
    //line3.text = row3CurrentWin;
    
    int localPos4 = row4Postion - 1;
    NSString *row4CurrentWin = [winLine4 objectAtIndex:localPos4];
    //line4.text = row4CurrentWin;
    
    int localPos5 = row5Postion - 1;
    NSString *row5CurrentWin = [winLine5 objectAtIndex:localPos5];
    //line5.text = row5CurrentWin;
    
    int localPos1Before = row1Postion;
    int localPos2Before = row2Postion;
    int localPos3Before = row3Postion;
    int localPos4Before = row4Postion;
    int localPos5Before = row5Postion;
    
    if(localPos1Before == 20){
        localPos1Before = 0;
    }
    if(localPos2Before == 20){
        localPos2Before = 0;
    }
    if(localPos3Before == 20){
        localPos3Before = 0;
    }
    if(localPos4Before == 20){
        localPos4Before = 0;
    }
    if(localPos5Before == 20){
        localPos5Before = 0;
    }
    
    NSString *row1CurrentWinBefore = [winLine1 objectAtIndex:localPos1Before];
    NSString *row2CurrentWinBefore = [winLine2 objectAtIndex:localPos2Before];
    NSString *row3CurrentWinBefore = [winLine3 objectAtIndex:localPos3Before];
    NSString *row4CurrentWinBefore = [winLine4 objectAtIndex:localPos4Before];
    NSString *row5CurrentWinBefore = [winLine5 objectAtIndex:localPos5Before];
    
    int localPos1After = row1Postion - 2;
    int localPos2After = row2Postion - 2;
    int localPos3After = row3Postion - 2;
    int localPos4After = row4Postion - 2;
    int localPos5After = row5Postion - 2;
    
    if(localPos1After == -1){
        localPos1After = 19;
    }
    if(localPos2After == -1){
        localPos2After = 19;
    }
    if(localPos3After == -1){
        localPos3After = 19;
    }
    if(localPos4After == -1){
        localPos4After = 19;
    }
    if(localPos5After == -1){
        localPos5After = 19;
    }
    
    NSString *row1CurrentWinAfter = [winLine1 objectAtIndex:localPos1After];
    NSString *row2CurrentWinAfter = [winLine2 objectAtIndex:localPos2After];
    NSString *row3CurrentWinAfter = [winLine3 objectAtIndex:localPos3After];
    NSString *row4CurrentWinAfter = [winLine4 objectAtIndex:localPos4After];
    NSString *row5CurrentWinAfter = [winLine5 objectAtIndex:localPos5After];

    //NSLog(@"-1      %@      | %@       | %@       | %@       | %@", row1CurrentWinBefore, row2CurrentWinBefore, row3CurrentWinBefore, row4CurrentWinBefore, row5CurrentWinBefore);
    //NSLog(@"win     %@      | %@       | %@       | %@       | %@", row1CurrentWin, row2CurrentWin, row3CurrentWin, row4CurrentWin, row5CurrentWin);
    //NSLog(@"+1      %@      | %@       | %@       | %@       | %@", row1CurrentWinAfter, row2CurrentWinAfter, row3CurrentWinAfter, row4CurrentWinAfter, row5CurrentWinAfter);
    
    /* 
    
     [row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"]  ||[row1CurrentWinBefore isEqual:@"Lemon"] || [row1CurrentWinBefore isEqual:@"7"]
     
    --- WIN TABLE
    */
    
    // pay tables
    
    NSArray *payout = [NSArray arrayWithObjects: @"J", @"Q", @"K", @"A", @"Star", @"Diamond", @"Lemon", @"7", @"Bonus", nil];
    NSArray *payout_2 = [NSArray arrayWithObjects: @"2", @"4", @"0", @"0", @"10", @"0", @"0", @"0", @"0", nil];
    NSArray *payout_3 = [NSArray arrayWithObjects: @"4", @"8", @"5", @"10", @"30", @"100", @"20", @"25", @"0", nil];
    NSArray *payout_4 = [NSArray arrayWithObjects: @"8", @"16", @"10", @"20", @"60", @"200", @"40", @"50", @"0", nil];
    NSArray *payout_5 = [NSArray arrayWithObjects: @"16", @"32", @"20", @"40", @"120", @"400", @"80", @"100", @"0", nil];
    
    //NSLog(@"Playing Lines: %i", linesToSpin);
    
    // manage bonus
#pragma mark init bonus
//#warning !!!!!!!        bonusCount should be 0; it's changed here only to help with debugging
//    int bonusCount = 3;
    int bonusCount = 0;
    
//#warning !!!!!!!        uncomment the above line
    totalWinAmount = 0;
    
    if([row1CurrentWinBefore isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row2CurrentWinBefore isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row3CurrentWinBefore isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row4CurrentWinBefore isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row5CurrentWinBefore isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row1CurrentWin isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row2CurrentWin isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row3CurrentWin isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row4CurrentWin isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row5CurrentWin isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row1CurrentWinAfter isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row2CurrentWinAfter isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row3CurrentWinAfter isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row4CurrentWinAfter isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    if([row5CurrentWinAfter isEqual:@"Bonus"]){
        bonusCount = bonusCount + 1;
    }
    
    // line 1 check if won
    if(linesToSpin >= 1){
        //NSLog(@"playing 1 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"1,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"1,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"1,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"1,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 2 check if won
    if(linesToSpin >= 2){
        //NSLog(@"playing 2 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"2,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"2,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"2,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"2,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 3 check if won
    if(linesToSpin >= 3){
        //NSLog(@"playing 3 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"3,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"3,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"3,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"3,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 4 check if won
    if(linesToSpin >= 4){
        //NSLog(@"playing 4 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"4,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"4,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"4,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"4,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 5 check if won
    if(linesToSpin >= 5){
        //NSLog(@"playing 5 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"5,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"5,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                 if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"5,3"];;
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"5,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 6 check if won
    if(linesToSpin >= 6){
        //NSLog(@"playing 6 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"6,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"6,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"6,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"] ){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"6,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 7 check if won
    if(linesToSpin >= 7){
        //NSLog(@"playing 7 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"7,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"7,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"7,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"] ){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"7,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 8 check if won
    if(linesToSpin >= 8){
        //NSLog(@"playing 8 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"8,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"8,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"8,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"8,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 9 check if won
    if(linesToSpin >= 9){
        //NSLog(@"playing 9 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"9,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"9,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"9,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"9,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 10 check if won
    if(linesToSpin >= 10){
        //NSLog(@"playing 10 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"10,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"10,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"10,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"] ){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"10,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 11 check if won
    if(linesToSpin >= 11){
        //NSLog(@"playing 11 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"11,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"11,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"11,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"] ){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"11,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 12 check if won
    if(linesToSpin >= 12){
        //NSLog(@"playing 12 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"12,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"12,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"12,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"12,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 13 check if won
    if(linesToSpin >= 13){
        //NSLog(@"playing 13 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"13,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"13,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"13,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"13,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 14 check if won
    if(linesToSpin >= 14){
        //NSLog(@"playing 14 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"14,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"14,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"14,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"]  || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"14,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 15 check if won
    if(linesToSpin >= 15){
        //NSLog(@"playing 15 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"15,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"15,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"15,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"]  || [row1CurrentWinAfter isEqual:@"Star"] ){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"15,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 16 check if won
    if(linesToSpin >= 16){
        //NSLog(@"playing 16 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"16,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"16,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"16,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"] ){
                        
                        if([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"16,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 17 check if won
    if(linesToSpin >= 17){
        //NSLog(@"playing 17 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"17,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWin] || [row4CurrentWin isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"17,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"17,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if([row1CurrentWin isEqual:row2CurrentWin] || [row2CurrentWin isEqual:@"Wild"]){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"17,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 18 check if won
    if(linesToSpin >= 18){
        //NSLog(@"playing 18 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"18,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"18,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"18,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"18,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 19 check if won
    if(linesToSpin >= 19){
        //NSLog(@"playing 19 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"19,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"19,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"19,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"19,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 20 check if won
    if(linesToSpin >= 20){
        //NSLog(@"playing 20 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"20,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];

        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"20,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];

            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"20,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];

                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"20,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];

                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }

    // line 21 check if won
    if(linesToSpin >= 21){
        //NSLog(@"playing 21 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"21,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"21,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"21,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"21,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 22 check if won
    if(linesToSpin >= 22){
        //NSLog(@"playing 22 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"22,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"22,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"22,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"22,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 23 check if won
    if(linesToSpin >= 23){
        //NSLog(@"playing 23 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"23,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"23,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"23,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"23,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 24 check if won
    if(linesToSpin >= 24){
        //NSLog(@"playing 24 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"24,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"24,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"24,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"]  || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"24,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 25 check if won
    if(linesToSpin >= 25){
        //NSLog(@"playing 25 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"25,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"25,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"25,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"25,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 26 check if won
    if(linesToSpin >= 26){
        //NSLog(@"playing 26 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"26,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"26,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"26,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"26,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 27 check if won
    if(linesToSpin >= 27){
        //NSLog(@"playing 27 line");
        
        // Object 5 Win
        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row5CurrentWin] || [row5CurrentWin isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"27,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"27,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWin isEqual:row3CurrentWin] || [row3CurrentWin isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"27,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWin isEqual:@"J"] || [row1CurrentWin isEqual:@"Q"] || [row1CurrentWin isEqual:@"Star"]){
                        
                        if(([row1CurrentWin isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWin];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"27,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 28 check if won
    if(linesToSpin >= 28){
        //NSLog(@"playing 28 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"28,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinAfter] || [row4CurrentWinAfter isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"28,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinAfter] || [row3CurrentWinAfter isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"28,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinAfter] || [row2CurrentWinAfter isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinAfter];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"28,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 28 check if won
    if(linesToSpin >= 29){
        //NSLog(@"playing 29 line");
        
        // Object 5 Win
        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row5CurrentWinAfter] || [row5CurrentWinAfter isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"29,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"29,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinBefore isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"29,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinBefore isEqual:@"J"] || [row1CurrentWinBefore isEqual:@"Q"] || [row1CurrentWinBefore isEqual:@"Star"]){
                        
                        if(([row1CurrentWinBefore isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"29,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }
    
    // line 30 check if won
    if(linesToSpin >= 30){
        //NSLog(@"playing 30 line");
        
        // Object 5 Win
        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row5CurrentWinBefore] || [row5CurrentWinBefore isEqual:@"Wild"])){
            
            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
            NSString *winAmount = [payout_5 objectAtIndex:grabCoins];
            [showWinData addObject:@"30,5"];
            totalWinAmount = totalWinAmount + [winAmount intValue];
            
        }else{
            //Object 4 Win
            if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row4CurrentWinBefore] || [row4CurrentWinBefore isEqual:@"Wild"])){
                
                NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                NSString *winAmount = [payout_4 objectAtIndex:grabCoins];
                [showWinData addObject:@"30,4"];
                totalWinAmount = totalWinAmount + [winAmount intValue];
                
            }else{
                //Object 3 Win
                if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"]) && ([row1CurrentWinAfter isEqual:row3CurrentWinBefore] || [row3CurrentWinBefore isEqual:@"Wild"])){
                    
                    NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                    NSString *winAmount = [payout_3 objectAtIndex:grabCoins];
                    [showWinData addObject:@"30,3"];
                    totalWinAmount = totalWinAmount + [winAmount intValue];
                    
                }else{
                    //Object 2 Win
                    
                    if([row1CurrentWinAfter isEqual:@"J"] || [row1CurrentWinAfter isEqual:@"Q"] || [row1CurrentWinAfter isEqual:@"Star"]){
                        
                        if(([row1CurrentWinAfter isEqual:row2CurrentWinBefore] || [row2CurrentWinBefore isEqual:@"Wild"])){
                            
                            NSUInteger grabCoins = [payout indexOfObject:row1CurrentWinBefore];
                            NSString *winAmount = [payout_2 objectAtIndex:grabCoins];
                            [showWinData addObject:@"30,2"];
                            totalWinAmount = totalWinAmount + [winAmount intValue];
                            
                        }else{
                            //NSLog(@"-- no win");
                        }
                    }
                }
            }
        }
    }


    //NSLog(@"xxxxxxxxxxxxx ------------------ total won: %i", totalWinAmount);
    
    
    if(totalWinAmount == 0){
        optionWon.text = @"0";
    }else{
        totalWinAmount = totalWinAmount * betAmount;
        optionWon.text = [NSString stringWithFormat:@"%i", totalWinAmount];
        lblAlert1.text = [NSString stringWithFormat:@"Last Win %i Coins", totalWinAmount];
    }
    
    int XP = [[CommonUtilities decryptString:@"exp"] intValue];
    XP = ((totalWinAmount / betAmount) / 6) + 5 + XP;
    
    //score submit
 //   AppDelegate* del = (AppDelegate*)[UIApplication sharedApplication].delegate;
   // [del.viewController submitScore:XP];

    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", XP]:@"exp"];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    
    //optionLvl.text = ;
    
    if(([optionLvl.text intValue] + 1) == [[self returnLevel:XP] intValue]){
        //NSLog(@"level up ----------------- ");
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        viewLevelUp.alpha = 1.0;
        [UIView commitAnimations];
        
        int cLevel = [[self returnLevel:XP] intValue];
        
        int giveCoins = [[self returnLevel:XP] intValue] * 10;
        
        if(giveCoins > 50){
            giveCoins = 50;
        }
        
        totalWinAmount = totalWinAmount + giveCoins;
        
        ViewController *view = [[[ViewController alloc] init] autorelease];
        NSString *unlockedItem = [view isLevelUnlocked:cLevel];
        
        if([unlockedItem isEqual:@"NO"]){
            lblLevelUpLevel.text = [NSString stringWithFormat:@"Congratulations! Reached Level %i", ([[self returnLevel:XP] intValue])];
            lblLevelUp1.text = [NSString stringWithFormat:@"You have been awarded %i coins", giveCoins];
            lblLevelUp2.text = @"";
            
        }else{
            lblLevelUpLevel.text = [NSString stringWithFormat:@"Congratulations! Reached Level %i", ([[self returnLevel:XP] intValue])];
            lblLevelUp1.text = unlockedItem;
            lblLevelUp2.text = @"Go to Back Home to Play!";
        }
    }else{
        
    }
    
    if(totalWinAmount == 0){
        
    }else{
        [self manageWin:totalWinAmount];
    }
    
    btnHome.enabled = YES;
    btnBet.enabled = YES;
    btnLines.enabled = YES;
    btnBetMax.enabled = YES;
    btnWon.enabled = YES;
    btnBuyCoins.enabled = YES;
    
    line1.enabled = YES;
    line2.enabled = YES;
    line3.enabled = YES;
    line4.enabled = YES;
    line5.enabled = YES;
    line6.enabled = YES;
    line7.enabled = YES;
    line8.enabled = YES;
    line9.enabled = YES;
    line10.enabled = YES;
    line11.enabled = YES;
    line12.enabled = YES;
    line13.enabled = YES;
    line14.enabled = YES;
    line15.enabled = YES;
    line16.enabled = YES;
    line17.enabled = YES;
    line18.enabled = YES;
    line19.enabled = YES;
    line20.enabled = YES;
    
    line30_1.enabled = YES;
    line30_2.enabled = YES;
    line30_3.enabled = YES;
    line30_4.enabled = YES;
    line30_5.enabled = YES;
    line30_6.enabled = YES;
    line30_7.enabled = YES;
    line30_8.enabled = YES;
    line30_9.enabled = YES;
    line30_10.enabled = YES;
    line30_11.enabled = YES;
    line30_12.enabled = YES;
    line30_13.enabled = YES;
    line30_14.enabled = YES;
    line30_15.enabled = YES;
    line30_16.enabled = YES;
    line30_17.enabled = YES;
    line30_18.enabled = YES;
    line30_19.enabled = YES;
    line30_20.enabled = YES;
    line30_21.enabled = YES;
    line30_22.enabled = YES;
    line30_23.enabled = YES;
    line30_24.enabled = YES;
    line30_25.enabled = YES;
    line30_26.enabled = YES;
    line30_27.enabled = YES;
    line30_28.enabled = YES;
    line30_29.enabled = YES;
    line30_30.enabled = YES;
    
    optionLvl.text = [self returnLevel:XP];
    
    [self sortLevelBar];
    
    // manage win prefs
    if([showWinData count] > 0){
        won = @"YES";
    }else{
        won = @"NO";
    }
    
    if([won isEqual:@"YES"]){
        
        wonCounter = 0;

        dropCoinsTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleDropCoins) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeBigWin) userInfo:nil repeats:NO];
        
        handleDropCoinsStatus = @"YES";
        [BaseViewController playSoundEffect:kSoundWon];
        
        showWinItems = [showWinData count];
        //NSLog(@"------------------------------- actualy able to call");
        [self addShowWinLines];
        
        showWinLines = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(addShowWinLines) userInfo:nil repeats:YES];
        
        showWinStatus = @"YES";
        //nudgeStatus = @"NO";
    }

    if([displayCoins.text isEqual:@"0"]){
        //nudgeStatus = @"NO";
        //holdStatus = @"NO";
    }
    
    //NSLog(@"--------- BONUS READ OUT --------- ");
    //NSLog(@"Bonus: %i", bonusCount);
    //NSLog(@"--------- BONUS READ OUT --------- ");
#pragma mark show Bonus if needed
    if([kBonus isEqual:@"YES"]){
        if(bonusCount >= 3){
            //autoSpinAmountCounter = 0;
            
            if([autoSpinStatus isEqual:@"YES"]){
                [autoSpinTimer invalidate];
                autoSpinStatus = @"NO";
                autoSpinAmountCounter = 0;
                
                defaultMessages = @"YES";
                
                lblAlert1.text = LABEL_TAPPLAY;
                lblAlert2.text = LABEL_TAPPLAY;
                lblAlert3.text = LABEL_TAPPLAY;
                
                lblAutoSpin.text = @"Auto Spin";
                lblSpin.text = @"Spin!";
            }
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            viewBonusWin.alpha = 1.0;
            [viewBonusWin setTransform:CGAffineTransformIdentity];
            [UIView commitAnimations];
            [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(removeBigWin) userInfo:nil repeats:NO];
            
            //NSLog(@"bonus game enabbled ");
            
            if([won isEqual:@"YES"]){
                //NSLog(@"BONUS GAME & WIN");
                bonusDoubleStatus = @"YES";
                [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", totalWinAmount]:@"lastWin"];
            }
            
            [NSTimer scheduledTimerWithTimeInterval:1.4 target:self selector:@selector(pushBonus) userInfo:nil repeats:NO];
        }else{
            if(totalWinAmount > (49 * betAmount)){
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.4];
                viewBigWin.alpha = 1.0;
                [viewBigWin setTransform:CGAffineTransformIdentity];
                [UIView commitAnimations];
                [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(removeBigWin) userInfo:nil repeats:NO];
            }else{
                
            }
        }
    }
    
}

- (void)pushBonus{
    /*
    BonusViewController *sampleView = [[[BonusViewController alloc] init] autorelease];
    [self presentModalViewController:sampleView animated:NO];*/
    
    if([bonusDoubleStatus isEqual:@"YES"]){
        int random = arc4random() % 3;
        
        if(random == 0){
            BonusDoubleViewController *sampleView = [[[BonusDoubleViewController alloc] initWithNibName:@"BonusDoubleViewController" bundle:nil] autorelease];
            [self presentViewController:sampleView animated:NO completion:nil];
        }else if(random == 2){
            BonusChestViewController *sampleView = [[[BonusChestViewController alloc] initWithNibName:@"BonusChestViewController" bundle:nil] autorelease];
            [self presentViewController:sampleView animated:NO completion:nil];
        }else{
            BonusViewController *sampleView = [[[BonusViewController alloc] initWithNibName:@"BonusViewController" bundle:nil] autorelease];
            [self presentViewController:sampleView animated:NO completion:nil];
        }
        
        bonusDoubleStatus = @"NO";
    }else{
        int random = arc4random() % 2;
        
        if(random == 0){
            BonusChestViewController *sampleView = [[[BonusChestViewController alloc] initWithNibName:@"BonusChestViewController" bundle:nil] autorelease];
            [self presentViewController:sampleView animated:NO completion:nil];
        }else{
            BonusViewController *sampleView = [[[BonusViewController alloc] initWithNibName:@"BonusViewController" bundle:nil] autorelease];
            [self presentViewController:sampleView animated:NO completion:nil];
        }
    }    
}

-(void)removeBigWin{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [viewBigWin setTransform:CGAffineTransformIdentity];
    viewBigWin.alpha = 0;
    [viewBigWin setTransform:CGAffineTransformMakeScale(0.1,0.1)];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [viewBonusWin setTransform:CGAffineTransformIdentity];
    viewBonusWin.alpha = 0;
    [viewBonusWin setTransform:CGAffineTransformMakeScale(0.1,0.1)];
    [UIView commitAnimations];
    
    if([handleDropCoinsStatus isEqual:@"YES"]){
        [dropCoinsTimer invalidate];
        handleDropCoinsStatus = @"NO";
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        moveCoin1.alpha = 0;
        moveCoin2.alpha = 0;
        moveCoin3.alpha = 0;
        moveCoin4.alpha = 0;
        moveCoin5.alpha = 0;
        moveCoin6.alpha = 0;
        moveCoin7.alpha = 0;
        moveCoin8.alpha = 0;
        moveCoin9.alpha = 0;
        [UIView commitAnimations];
    }
}

-(void) resetWinBoxImages{
    winBox1.image = [UIImage imageNamed:@"null"];
    winBox2.image = [UIImage imageNamed:@"null"];
    winBox3.image = [UIImage imageNamed:@"null"];
    winBox4.image = [UIImage imageNamed:@"null"];
    winBox5.image = [UIImage imageNamed:@"null"];
    winBox6.image = [UIImage imageNamed:@"null"];
    winBox7.image = [UIImage imageNamed:@"null"];
    winBox8.image = [UIImage imageNamed:@"null"];
    winBox9.image = [UIImage imageNamed:@"null"];
    winBox10.image = [UIImage imageNamed:@"null"];
    winBox11.image = [UIImage imageNamed:@"null"];
    winBox12.image = [UIImage imageNamed:@"null"];
    winBox13.image = [UIImage imageNamed:@"null"];
    winBox14.image = [UIImage imageNamed:@"null"];
    winBox15.image = [UIImage imageNamed:@"null"];
}

- (void)addShowWinLines{
    NSString *lineImg = [UIImage nameForImageForDeviceForName:([[CommonUtilities decryptString:@"game_lines"] isEqual:@"30"]) ? @"30_line" : @"line"];
    NSString *boxImg  = [UIImage nameForImageForDeviceForName:@"box"];
    [self resetWinBoxImages];
    
    NSArray *winItem = [[showWinData objectAtIndex:(showWinItemsCounter-1)] componentsSeparatedByString:@","];;
    
    int line = [[winItem objectAtIndex:0] intValue];
    int winCount = [[winItem objectAtIndex:1] intValue];
    
    ////NSLog(@"line:       %i", line);
    ////NSLog(@"winCount:   %i", winCount);
    
    showWin.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i@2x",lineImg,line]];
    
    if(showWinItems == showWinItemsCounter){
        showWinItemsCounter = 1;
    }else{
        showWinItemsCounter = showWinItemsCounter + 1;
    }
    
    
    if(line == 1){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 2){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 3){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 4){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 5){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 6){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 7){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 8){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 9){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 10){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 11){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 12){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 13){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 14){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 15){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 16){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 17){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox9.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 18){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 19){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 20){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 21){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 22){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 23){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 24){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 25){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 26){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 27){
        if(winCount == 5){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox10.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox8.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 28){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox14.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox13.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox12.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 29){
        if(winCount == 5){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox15.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }else if(line == 30){
        if(winCount == 5){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 4){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 3){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }else if(winCount == 2){
            winBox11.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
            winBox2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%i@2x",boxImg,line]];
        }
    }
}

-(int)spinMoveToRow1:(NSString *)object{
    NSArray *winLine1 = [NSArray arrayWithObjects: @"Star", @"A", @"Lemon", @"Diamond", @"Q", @"Lemon", @"J", @"K", @"K", @"Q", @"Star", @"Lemon", @"J", @"A", @"Star", @"Diamond", @"7", @"J", @"J", @"7", nil];
    
    NSMutableArray *tmpObject = [[NSMutableArray alloc] init];
    int counter = 0;
    
    for (NSString *string in winLine1) {
        if([string isEqual:object]){
            [tmpObject addObject:[NSString stringWithFormat:@"%i", counter]];
        }
        counter = counter + 1;
    }

    int random = arc4random() % [tmpObject count];
    NSString *randomValue = [tmpObject objectAtIndex:random];
    
    return [randomValue intValue];
}

-(int)spinMoveToRow2:(NSString *)object{
    NSArray *winLine2 = [NSArray arrayWithObjects: @"Lemon", @"J", @"Q", @"K", @"Diamond", @"7", @"Wild", @"K", @"Star", @"7", @"Bonus", @"A", @"Diamond", @"J", @"Lemon", @"Q", @"Star", @"K", @"Star", @"J", nil];
    
    NSMutableArray *tmpObject = [[NSMutableArray alloc] init];
    int counter = 0;
    
    for (NSString *string in winLine2) {
        if([string isEqual:object]){
            [tmpObject addObject:[NSString stringWithFormat:@"%i", counter]];
        }
        counter = counter + 1;
    }
    
    int random = arc4random() % [tmpObject count];
    NSString *randomValue = [tmpObject objectAtIndex:random];
    
    return [randomValue intValue];
}

-(int)spinMoveToRow3:(NSString *)object{
    NSArray *winLine3 = [NSArray arrayWithObjects: @"Lemon", @"Diamond", @"K", @"Q", @"A", @"K", @"7", @"Lemon", @"J", @"7", @"Star", @"A", @"Bonus", @"Diamond", @"Q", @"Lemon", @"J", @"K", @"Wild", @"J", nil];
    
    NSMutableArray *tmpObject = [[NSMutableArray alloc] init];
    int counter = 0;
    
    for (NSString *string in winLine3) {
        if([string isEqual:object]){
            [tmpObject addObject:[NSString stringWithFormat:@"%i", counter]];
        }
        counter = counter + 1;
    }
    
    int random = arc4random() % [tmpObject count];
    NSString *randomValue = [tmpObject objectAtIndex:random];
    
    return [randomValue intValue];
}

-(int)spinMoveToRow4:(NSString *)object{
    NSArray *winLine4 = [NSArray arrayWithObjects: @"Star", @"Wild", @"J", @"A", @"Bonus", @"Diamond", @"7", @"J", @"Star", @"J", @"Bonus", @"Diamond", @"K", @"Q", @"A", @"K", @"7", @"Lemon", @"K", @"Q", nil];

    NSMutableArray *tmpObject = [[NSMutableArray alloc] init];
    int counter = 0;
    
    for (NSString *string in winLine4) {
        if([string isEqual:object]){
            [tmpObject addObject:[NSString stringWithFormat:@"%i", counter]];
        }
        counter = counter + 1;
    }
    
    int random = arc4random() % [tmpObject count];
    NSString *randomValue = [tmpObject objectAtIndex:random];
    
    return [randomValue intValue];
}

-(int)spinMoveToRow5:(NSString *)object{
    NSArray *winLine5 = [NSArray arrayWithObjects: @"Bonus", @"A", @"Diamond", @"J", @"Lemon", @"Q", @"Star", @"K", @"Star", @"Wild", @"Lemon", @"J", @"Q", @"K", @"Diamond", @"7", @"A", @"Bonus", @"Star", @"7", nil];
    
    NSMutableArray *tmpObject = [[NSMutableArray alloc] init];
    int counter = 0;
    
    for (NSString *string in winLine5) {
        if([string isEqual:object]){
            [tmpObject addObject:[NSString stringWithFormat:@"%i", counter]];
        }
        counter = counter + 1;
    }
    
    int random = arc4random() % [tmpObject count];
    NSString *randomValue = [tmpObject objectAtIndex:random];
    
    return [randomValue intValue];
}

- (void)setSpinTo:(NSString *)row1 :(NSString *)row2 :(NSString *)row3 :(NSString *)row4 :(NSString *)row5{
    
    if([row1 isEqual:@"diff"] || [row2 isEqual:@"diff"] || [row3 isEqual:@"diff"] || [row4 isEqual:@"diff"] || [row5 isEqual:@"diff"]){
        //NSLog(@"diff called");
        
        // less wilds
        NSMutableArray *tmpRow2 = [[NSMutableArray alloc] initWithObjects:@"A", @"K", @"Q", @"7", @"Bonus", @"Diamond", @"Lemon", @"Star", nil];
        NSMutableArray *tmpRow3 = [[NSMutableArray alloc] initWithObjects:@"A", @"K", @"Q", @"7", @"Bonus", @"Diamond", @"Lemon", @"Star", nil];
        
        int randomRow1 = arc4random() % 8;
        
        if(randomRow1 == 0){
            row1 = @"A";
        }else if(randomRow1 == 1){
            row1 = @"K";
        }else if(randomRow1 == 2){
            row1 = @"Q";
        }else if(randomRow1 == 3){
            row1 = @"7";
        }else if(randomRow1 == 5){
            row1 = @"Diamond";
        }else if(randomRow1 == 6){
            row1 = @"Lemon";
        }else if(randomRow1 == 7){
            row1 = @"Star";
        }else{
            row1 = @"J";
        }
        
        [tmpRow2 removeObject:row1];
        [tmpRow3 removeObject:row1];
        
        int randomRow2 = arc4random() % [tmpRow2 count];
        row2 = [tmpRow2 objectAtIndex:randomRow2];
        
        [tmpRow3 removeObject:row2];
        
        int randomRow3 = arc4random() % [tmpRow3 count];
        row3 = [tmpRow3 objectAtIndex:randomRow3];
        
        // row 4 and row 5 are random
        int randomRow4 = arc4random() % 10;
        
        if(randomRow4 == 0){
            row4 = @"A";
        }else if(randomRow4 == 1){
            row4 = @"K";
        }else if(randomRow4 == 2){
            row4 = @"Q";
        }else if(randomRow4 == 3){
            row4 = @"7";
        }else if(randomRow4 == 4){
            row4 = @"Bonus";
        }else if(randomRow4 == 5){
            row4 = @"Diamond";
        }else if(randomRow4 == 6){
            row4 = @"Lemon";
        }else if(randomRow4 == 7){
            row4 = @"Star";
        }else if(randomRow4 == 8){
            row4 = @"Wild";
        }else{
            row4 = @"J";
        }
        
        int randomRow5 = arc4random() % 10;
        
        if(randomRow5 == 0){
            row5 = @"A";
        }else if(randomRow5 == 1){
            row5 = @"K";
        }else if(randomRow5 == 2){
            row5 = @"Q";
        }else if(randomRow5 == 3){
            row5 = @"7";
        }else if(randomRow5 == 4){
            row5 = @"Bonus";
        }else if(randomRow5 == 5){
            row5 = @"Diamond";
        }else if(randomRow5 == 6){
            row5 = @"Lemon";
        }else if(randomRow5 == 7){
            row5 = @"Star";
        }else if(randomRow5 == 8){
            row5 = @"Wild";
        }else{
            row5 = @"J";
        }
    }else{
        if([row1 isEqual:@"random"]){
            
            int randomRow1 = arc4random() % 8;
            
            if(randomRow1 == 0){
                row1 = @"A";
            }else if(randomRow1 == 1){
                row1 = @"K";
            }else if(randomRow1 == 2){
                row1 = @"Q";
            }else if(randomRow1 == 3){
                row1 = @"7";
            }else if(randomRow1 == 5){
                row1 = @"Diamond";
            }else if(randomRow1 == 6){
                row1 = @"Lemon";
            }else if(randomRow1 == 7){
                row1 = @"Star";
            }else{
                row1 = @"J";
            }
        }
        
        if([row2 isEqual:@"random"]){
            int randomRow2 = arc4random() % 10;
            
            if(randomRow2 == 0){
                row2 = @"A";
            }else if(randomRow2 == 1){
                row2 = @"K";
            }else if(randomRow2 == 2){
                row2 = @"Q";
            }else if(randomRow2 == 3){
                row2 = @"7";
            }else if(randomRow2 == 4){
                row2 = @"Bonus";
            }else if(randomRow2 == 5){
                row2 = @"Diamond";
            }else if(randomRow2 == 6){
                row2 = @"Lemon";
            }else if(randomRow2 == 7){
                row2 = @"Star";
            }else if(randomRow2 == 8){
                row2 = @"Wild";
            }else{
                row2 = @"J";
            }
        }
        
        if([row3 isEqual:@"random"]){
            int randomRow3 = arc4random() % 10;
            
            if(randomRow3 == 0){
                row3 = @"A";
            }else if(randomRow3 == 1){
                row3 = @"K";
            }else if(randomRow3 == 2){
                row3 = @"Q";
            }else if(randomRow3 == 3){
                row3 = @"7";
            }else if(randomRow3 == 4){
                row3 = @"Bonus";
            }else if(randomRow3 == 5){
                row3 = @"Diamond";
            }else if(randomRow3 == 6){
                row3 = @"Lemon";
            }else if(randomRow3 == 7){
                row3 = @"Star";
            }else if(randomRow3 == 8){
                row3 = @"Wild";
            }else{
                row3 = @"J";
            }
        }
        
        if([row4 isEqual:@"random"]){
            int randomRow4 = arc4random() % 10;
            
            if(randomRow4 == 0){
                row4 = @"A";
            }else if(randomRow4 == 1){
                row4 = @"K";
            }else if(randomRow4 == 2){
                row4 = @"Q";
            }else if(randomRow4 == 3){
                row4 = @"7";
            }else if(randomRow4 == 4){
                row4 = @"Bonus";
            }else if(randomRow4 == 5){
                row4 = @"Diamond";
            }else if(randomRow4 == 6){
                row4 = @"Lemon";
            }else if(randomRow4 == 7){
                row4 = @"Star";
            }else if(randomRow4 == 8){
                row4 = @"Wild";
            }else{
                row4 = @"J";
            }
        }
        
        if([row5 isEqual:@"random"]){
            int randomRow5 = arc4random() % 10;
            
            if(randomRow5 == 0){
                row5 = @"A";
            }else if(randomRow5 == 1){
                row5 = @"K";
            }else if(randomRow5 == 2){
                row5 = @"Q";
            }else if(randomRow5 == 3){
                row5 = @"7";
            }else if(randomRow5 == 4){
                row5 = @"Bonus";
            }else if(randomRow5 == 5){
                row5 = @"Diamond";
            }else if(randomRow5 == 6){
                row5 = @"Lemon";
            }else if(randomRow5 == 7){
                row5 = @"Star";
            }else if(randomRow5 == 8){
                row5 = @"Wild";
            }else{
                row5 = @"J";
            }
        }
    }
    
    // row1
    moveRow1Counter = 0;
    moveRow1Amount = 0;
    int outstandingRow1ToZero = 20 - row1Postion;
    int moveToRow1 = 0;
    
    moveToRow1 = [self spinMoveToRow1:row1];
    moveRow1Amount = (outstandingRow1ToZero + moveToRow1 + 1) * 10;
    
    // row2
    moveRow2Counter = 0;
    moveRow2Amount = 0;
    int outstandingRow2ToZero = 20 - row2Postion;
    int moveToRow2 = 0;
    moveToRow2 = [self spinMoveToRow2:row2];
    moveRow2Amount = (outstandingRow2ToZero + moveToRow2 + 1) * 10;
    
    // row3
    moveRow3Counter = 0;
    moveRow3Amount = 0;
    int outstandingRow3ToZero = 20 - row3Postion;
    int moveToRow3 = 0;
    moveToRow3 = [self spinMoveToRow3:row3];
    moveRow3Amount = (outstandingRow3ToZero + moveToRow3 + 1) * 10;
    
    // row4
    moveRow4Counter = 0;
    moveRow4Amount = 0;
    int outstandingRow4ToZero = 20 - row4Postion;
    int moveToRow4 = 0;
    moveToRow4 = [self spinMoveToRow4:row4];
    moveRow4Amount = (outstandingRow4ToZero + moveToRow4 + 1) * 10;
    
    // row5
    moveRow5Counter = 0;
    moveRow5Amount = 0;
    int outstandingRow5ToZero = 20 - row5Postion;
    int moveToRow5 = 0;
    moveToRow5 = [self spinMoveToRow5:row5];
    moveRow5Amount = (outstandingRow5ToZero + moveToRow5 + 1) * 10;
}

- (IBAction)playAgain:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewGameOver.alpha = 0.0;
    viewBack.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)spin{
    [self hideLevel:@""];
    [self hidePayTable:@""];
    
    if([autoSpinStatusMenu isEqual:@"YES"]){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            // finish at 280;
            viewAutoSpinMenu.frame = CGRectMake(2,550,175,240);
        }else{
            viewAutoSpinMenu.frame = CGRectMake(5,250,81,110);
        }
        
        [UIView commitAnimations];
        autoSpinStatusMenu = @"NO";
        lblAutoSpin.text = @"Auto Spin";
    }
    
    if([play isEqual:@"NO"]){
        //NSLog(@"cannot play");
    }else{
        // cost to play (10 credits)
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        int countBet = linesToSpin * betAmount;
        
        if (currentCoins < 0){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            viewMoreCoins.alpha = 1.0;
            [UIView commitAnimations];
            autoSpinAmountCounter = 0;
        }else if((currentCoins - countBet) < 0){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            viewMoreCoins.alpha = 1.0;
            [UIView commitAnimations];
            autoSpinAmountCounter = 0;
        }else{
            btnHome.enabled = NO;
            btnBet.enabled = NO;
            btnLines.enabled = NO;
            btnBetMax.enabled = NO;
            btnWon.enabled = NO;
            btnBuyCoins.enabled = NO;
            
            line1.enabled = NO;
            line2.enabled = NO;
            line3.enabled = NO;
            line4.enabled = NO;
            line5.enabled = NO;
            line6.enabled = NO;
            line7.enabled = NO;
            line8.enabled = NO;
            line9.enabled = NO;
            line10.enabled = NO;
            line11.enabled = NO;
            line12.enabled = NO;
            line13.enabled = NO;
            line14.enabled = NO;
            line15.enabled = NO;
            line16.enabled = NO;
            line17.enabled = NO;
            line18.enabled = NO;
            line19.enabled = NO;
            line20.enabled = NO;
            
            line30_1.enabled = NO;
            line30_2.enabled = NO;
            line30_3.enabled = NO;
            line30_4.enabled = NO;
            line30_5.enabled = NO;
            line30_6.enabled = NO;
            line30_7.enabled = NO;
            line30_8.enabled = NO;
            line30_9.enabled = NO;
            line30_10.enabled = NO;
            line30_11.enabled = NO;
            line30_12.enabled = NO;
            line30_13.enabled = NO;
            line30_14.enabled = NO;
            line30_15.enabled = NO;
            line30_16.enabled = NO;
            line30_17.enabled = NO;
            line30_18.enabled = NO;
            line30_19.enabled = NO;
            line30_20.enabled = NO;
            line30_21.enabled = NO;
            line30_22.enabled = NO;
            line30_23.enabled = NO;
            line30_24.enabled = NO;
            line30_25.enabled = NO;
            line30_26.enabled = NO;
            line30_27.enabled = NO;
            line30_28.enabled = NO;
            line30_29.enabled = NO;
            line30_30.enabled = NO;
            
            currentCoins = currentCoins - countBet;
            [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
            displayCoins.text = [NSString stringWithFormat:@"%i", currentCoins];
            
            // current bets
            int currentBet = [[CommonUtilities decryptString:@"bet"] intValue];
            currentBet = currentBet + countBet;
            [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentBet]:@"bet"];
            
            // current spins
            int currentSpins = [[CommonUtilities decryptString:@"spins"] intValue];
            currentSpins = currentSpins + 1;
            [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentSpins]:@"spins"];
            // show ad if necessary:
            #ifdef ADS_SPIN_FREQUENCY
            if ((currentSpins % ADS_SPIN_FREQUENCY) == 0) {
                [Chartboost showInterstitial:CBLocationHomeScreen];
            }
            /*
             for revmob interstitials instead of Chartboost, instead of the line that says
             [[Chartboost sharedChartboost] showInterstitial];
             write a line that says
             [[RevMobAds session] showFullscreen];
             */
            #endif

            
            // current won
            int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
            
            //NSLog(@"currentBet: %i", currentBet);
            //NSLog(@"currentWon: %i", currentWon);
            
            displayBet.text = [NSString stringWithFormat:@"%i", currentBet];
            displayWon.text = [NSString stringWithFormat:@"%i", currentWon];
            
            //currentBet = currentBet * 0.6;
            
            [self resetWinBoxImages];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            [viewBigWin setTransform:CGAffineTransformIdentity];
            viewBigWin.alpha = 0;
            [viewBigWin setTransform:CGAffineTransformMakeScale(0.1,0.1)];
            [UIView commitAnimations];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            [viewBonusWin setTransform:CGAffineTransformIdentity];
            viewBonusWin.alpha = 0;
            [viewBonusWin setTransform:CGAffineTransformMakeScale(0.1,0.1)];
            [UIView commitAnimations];
            
            nudge1Button.enabled = NO;
            nudge2Button.enabled = NO;
            nudge3Button.enabled = NO;
            nudge4Button.enabled = NO;
            nudge5Button.enabled = NO;
            nudge1Button.alpha = 0.3;
            nudge2Button.alpha = 0.3;
            nudge3Button.alpha = 0.3;
            nudge4Button.alpha = 0.3;
            nudge5Button.alpha = 0.3;
            nudgeCounter = 0;
            optionWon.text = @"0";
            showWinItemsCounter = 1;
            displayNudge.text = @"";
            [showWinData removeAllObjects];
            [nudgeSound stop];
            [finishedSpinSound stop];
            [wonSound stop];
            
            UIImage *winImage = [UIImage imageNamed:@"line_null"];
            showWin.image = winImage;
            
            holdStatus = @"NO";
            nudgeStatus = @"NO";
            
            if([showWinStatus isEqual:@"YES"]){
                [showWinLines invalidate];
                showWinStatus = @"NO";
            }
            
            if([handleDropCoinsStatus isEqual:@"YES"]){
                [dropCoinsTimer invalidate];
                handleDropCoinsStatus = @"NO";
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                moveCoin1.alpha = 0;
                moveCoin2.alpha = 0;
                moveCoin3.alpha = 0;
                moveCoin4.alpha = 0;
                moveCoin5.alpha = 0;
                moveCoin6.alpha = 0;
                moveCoin7.alpha = 0;
                moveCoin8.alpha = 0;
                moveCoin9.alpha = 0;
                [UIView commitAnimations];
            }
            
            int random = arc4random() % 10;
            
            
            if (currentWon > (currentBet * 0.9)) {
                if(random == 3){
                    //NSLog(@"------------------------------- ------------------------------- ------------------------------- random");
                    [self setSpinTo:@"random":@"random":@"random":@"random":@"random"];
                }else{
                    //NSLog(@"------------------------------- ------------------------------- ------------------------------- return your monieessss");
                    [self setSpinTo:@"diff":@"diff":@"diff":@"diff":@"diff"];
                }
            }else{
                //NSLog(@"------------------------------- ------------------------------- ------------------------------- go to pay");
                [self setSpinTo:@"random":@"random":@"random":@"random":@"random"];
            }
            
            //[self setSpinTo:@"Diamond":@"Wild":@"Bonus":@"Bonus":@"Bonus"];
            
            nudgeStatus = @"NO";
            holdStatus = @"NO";
            
            // move row 1
            int placesmoved1 = (moveRow1Amount / 10);
            row1Postion = (placesmoved1 + row1Postion);
            
            if(row1Postion > 20){
                row1Postion = row1Postion - 20;
            }
            
            // move row 2 
            int placesmoved2 = (moveRow2Amount / 10);
            row2Postion = (placesmoved2 + row2Postion);
            
            if(row2Postion > 20){
                row2Postion = row2Postion - 20;
            }
            
            // move row 3
            int placesmoved3 = (moveRow3Amount / 10);
            row3Postion = (placesmoved3 + row3Postion);
            
            if(row3Postion > 20){
                row3Postion = row3Postion - 20;
            }
            
            // move row 4
            int placesmoved4 = (moveRow4Amount / 10);
            row4Postion = (placesmoved4 + row4Postion);
            
            if(row4Postion > 20){
                row4Postion = row4Postion - 20;
            }
            
            // move row 5
            int placesmoved5 = (moveRow5Amount / 10);
            row5Postion = (placesmoved5 + row5Postion);
            
            if(row5Postion > 20){
                row5Postion = row5Postion - 20;
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                row = [NSTimer scheduledTimerWithTimeInterval:0.004 target:self selector:@selector(moveRow) userInfo:nil repeats:YES];
            }else{
                row = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(moveRow) userInfo:nil repeats:YES];
            }
        }
    }
}

- (IBAction)spin:(id)sender{
    
    if([lblSpin.text isEqual:@"Stop"]){
        autoSpinAmountCounter = 0;
        lblAutoSpin.text = @"Auto Spin";
        lblSpin.text = @"Spin!";
    }else{
        if([spinSafe isEqual:@"YES"]){
            spinSafe = @"NO";
        }else{
            [self spin];
        }
    }
}

-(IBAction)autoSpinByAmount:(id)sender{
    
    if([autoSpinStatus isEqual:@"YES"]){
        [autoSpinTimer invalidate];
        autoSpinStatus = @"NO";
        autoSpinAmountCounter = 0;
        
    }else{
        if([kautoSpinOverride isEqual:@"YES"]){
            autoSpinAmountCounter = 50000;
            
            [self autoSpin];
            autoSpinTimer = [NSTimer scheduledTimerWithTimeInterval:DELAY_FOR_AUTO_SPIN target:self selector:@selector(autoSpin) userInfo:nil repeats:YES];
            autoSpinStatus = @"YES";
            
            lblAutoSpin.text = @"Stop";
            lblSpin.text = @"Stop";
        }else{
            UIButton *button = (UIButton *)sender;
            autoSpinAmountCounter = button.tag;
            
            [self autoSpin];
            autoSpinTimer = [NSTimer scheduledTimerWithTimeInterval:DELAY_FOR_AUTO_SPIN target:self selector:@selector(autoSpin) userInfo:nil repeats:YES];
            autoSpinStatus = @"YES";
            
            lblAutoSpin.text = @"Stop";
            lblSpin.text = @"Stop";
        }
    }
}

- (IBAction)autoSpin:(id)sender{
    if([lblAutoSpin.text isEqual:@"Stop"]){
        autoSpinAmountCounter = 0;
        lblAutoSpin.text = @"Auto Spin";
        lblSpin.text = @"Spin!";
    }else{
        if([autoSpinStatusMenu isEqual:@"YES"]){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                // finish at 280;
                viewAutoSpinMenu.frame = CGRectMake(2,550,175,240);
            }else{
                viewAutoSpinMenu.frame = CGRectMake(5,250,81,110);
            }
            [UIView commitAnimations];
            autoSpinStatusMenu = @"NO";
            lblAutoSpin.text = @"Auto Spin";
        }else{
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                // finish at 280;
                viewAutoSpinMenu.frame = CGRectMake(2,280,175,240);
            }else{
                viewAutoSpinMenu.frame = CGRectMake(5,146,81,110);
            }
            [UIView commitAnimations];
            autoSpinStatusMenu = @"YES";
            lblAutoSpin.text = @"Close";
        }
    }
}

-(void)autoSpin{
    if(autoSpinAmountCounter == 0){
        [autoSpinTimer invalidate];
        autoSpinStatus = @"NO";
        autoSpinAmountCounter = 0;
        
        defaultMessages = @"YES";
        
        lblAlert1.text = LABEL_TAPPLAY;;
        lblAlert2.text = LABEL_TAPPLAY;;
        lblAlert3.text = LABEL_TAPPLAY;;
        
        lblAutoSpin.text = @"Auto Spin";
        lblSpin.text = @"Spin!";
    }else{
        lblAutoSpin.text = @"Stop";
        lblSpin.text = @"Stop";
        
        [self spin];
        autoSpinAmountCounter = autoSpinAmountCounter - 1;
        
        defaultMessages = @"NO";
        
        if(autoSpinAmountCounter == 1){
            lblAlert1.text = [NSString stringWithFormat:@"%i Spin Remaining", autoSpinAmountCounter];
            lblAlert2.text = [NSString stringWithFormat:@"%i Spin Remaining", autoSpinAmountCounter];
            lblAlert3.text = [NSString stringWithFormat:@"%i Spin Remaining", autoSpinAmountCounter];
        }else if(autoSpinAmountCounter == 0){
            lblAlert1.text = LABEL_TAPPLAY;;
            lblAlert2.text = LABEL_TAPPLAY;;
            lblAlert3.text = LABEL_TAPPLAY;;
            defaultMessages = @"YES";
        }else if(autoSpinAmountCounter < 0){
            lblAlert1.text = LABEL_TAPPLAY;;
            lblAlert2.text = LABEL_TAPPLAY;;
            lblAlert3.text = LABEL_TAPPLAY;;
            defaultMessages = @"YES";
            autoSpinAmountCounter = 0;
        }else{
            lblAlert1.text = [NSString stringWithFormat:@"%i Spins Remaining", autoSpinAmountCounter];
            lblAlert2.text = [NSString stringWithFormat:@"%i Spins Remaining", autoSpinAmountCounter];
            lblAlert3.text = [NSString stringWithFormat:@"%i Spins Remaining", autoSpinAmountCounter];
        }
    }
}

-(void)addWinCoins{
    
    ////NSLog([CommonUtilities decryptString:@"coins"]);
    
    if(coinsAdd == currentWinCoins){
        [addWin invalidate];
        [BaseViewController playSoundEffect:kSoundCoinDrop];
        
        currentWinCoins = 0;
        addWinStatus = @"NO";
        
    }else{
        int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
        

        currentWon = currentWon + 1;
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentWon]:@"won"];
    //    NSLog(@"coinAdda: %i", currentWon);
        
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
    //    NSLog(@"coinAdda: %i", currentCoins);
        currentCoins = currentCoins + 1;
    //    NSLog(@"coinAdda: %i", currentCoins);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
        
        displayCoins.text = [NSString stringWithFormat:@"%i", currentCoins];
        
        coinsAdd = coinsAdd + 1;
    NSLog(@"coinAdd: %i", coinsAdd);
    }
}



-(IBAction)play:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewWelcome.alpha = 0.0;
    viewBack.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)cleanUpOnClose{
    if([autoSpinStatus isEqual:@"YES"]){
        [autoSpinTimer invalidate];
        autoSpinStatus = @"NO";
    }else{
        
    }
    
    if([showWinStatus isEqual:@"YES"]){
        [showWinLines invalidate];
        showWinStatus = @"NO";
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self cleanUpOnClose];
}

- (void)viewWillAppear:(BOOL)animated{
    
    prizeShuffleCounter = 0;
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    [self presetSoundButtons];
}

-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(void)sortLines:(int)lines{
    linesToSpin = lines;
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i",linesToSpin]:@"optionLines"];
    
    line1.alpha = 0.4;
    line2.alpha = 0.4;
    line3.alpha = 0.4;
    line4.alpha = 0.4;
    line5.alpha = 0.4;
    line6.alpha = 0.4;
    line7.alpha = 0.4;
    line8.alpha = 0.4;
    line9.alpha = 0.4;
    line10.alpha = 0.4;
    line11.alpha = 0.4;
    line12.alpha = 0.4;
    line13.alpha = 0.4;
    line14.alpha = 0.4;
    line15.alpha = 0.4;
    line16.alpha = 0.4;
    line17.alpha = 0.4;
    line18.alpha = 0.4;
    line19.alpha = 0.4;
    line20.alpha = 0.4;
    
    line30_1.alpha = 0.4;
    line30_2.alpha = 0.4;
    line30_3.alpha = 0.4;
    line30_4.alpha = 0.4;
    line30_5.alpha = 0.4;
    line30_6.alpha = 0.4;
    line30_7.alpha = 0.4;
    line30_8.alpha = 0.4;
    line30_9.alpha = 0.4;
    line30_10.alpha = 0.4;
    line30_11.alpha = 0.4;
    line30_12.alpha = 0.4;
    line30_13.alpha = 0.4;
    line30_14.alpha = 0.4;
    line30_15.alpha = 0.4;
    line30_16.alpha = 0.4;
    line30_17.alpha = 0.4;
    line30_18.alpha = 0.4;
    line30_19.alpha = 0.4;
    line30_20.alpha = 0.4;
    line30_21.alpha = 0.4;
    line30_22.alpha = 0.4;
    line30_23.alpha = 0.4;
    line30_24.alpha = 0.4;
    line30_25.alpha = 0.4;
    line30_26.alpha = 0.4;
    line30_27.alpha = 0.4;
    line30_28.alpha = 0.4;
    line30_29.alpha = 0.4;
    line30_30.alpha = 0.4;
    
    if(linesToSpin >= 1){line1.alpha = 1.0;}
    if(linesToSpin >= 2){line2.alpha = 1.0;}
    if(linesToSpin >= 3){line3.alpha = 1.0;}
    if(linesToSpin >= 4){line4.alpha = 1.0;}
    if(linesToSpin >= 5){line5.alpha = 1.0;}
    if(linesToSpin >= 6){line6.alpha = 1.0;}
    if(linesToSpin >= 7){line7.alpha = 1.0;}
    if(linesToSpin >= 8){line8.alpha = 1.0;}
    if(linesToSpin >= 9){line9.alpha = 1.0;}
    if(linesToSpin >= 10){line10.alpha = 1.0;}
    if(linesToSpin >= 11){line11.alpha = 1.0;}
    if(linesToSpin >= 12){line12.alpha = 1.0;}
    if(linesToSpin >= 13){line13.alpha = 1.0;}
    if(linesToSpin >= 14){line14.alpha = 1.0;}
    if(linesToSpin >= 15){line15.alpha = 1.0;}
    if(linesToSpin >= 16){line16.alpha = 1.0;}
    if(linesToSpin >= 17){line17.alpha = 1.0;}
    if(linesToSpin >= 18){line18.alpha = 1.0;}
    if(linesToSpin >= 19){line19.alpha = 1.0;}
    if(linesToSpin >= 20){line20.alpha = 1.0;}
    
    if(linesToSpin >= 1){line30_1.alpha = 1.0;}
    if(linesToSpin >= 2){line30_2.alpha = 1.0;}
    if(linesToSpin >= 3){line30_3.alpha = 1.0;}
    if(linesToSpin >= 4){line30_4.alpha = 1.0;}
    if(linesToSpin >= 5){line30_5.alpha = 1.0;}
    if(linesToSpin >= 6){line30_6.alpha = 1.0;}
    if(linesToSpin >= 7){line30_7.alpha = 1.0;}
    if(linesToSpin >= 8){line30_8.alpha = 1.0;}
    if(linesToSpin >= 9){line30_9.alpha = 1.0;}
    if(linesToSpin >= 10){line30_10.alpha = 1.0;}
    if(linesToSpin >= 11){line30_11.alpha = 1.0;}
    if(linesToSpin >= 12){line30_12.alpha = 1.0;}
    if(linesToSpin >= 13){line30_13.alpha = 1.0;}
    if(linesToSpin >= 14){line30_14.alpha = 1.0;}
    if(linesToSpin >= 15){line30_15.alpha = 1.0;}
    if(linesToSpin >= 16){line30_16.alpha = 1.0;}
    if(linesToSpin >= 17){line30_17.alpha = 1.0;}
    if(linesToSpin >= 18){line30_18.alpha = 1.0;}
    if(linesToSpin >= 19){line30_19.alpha = 1.0;}
    if(linesToSpin >= 20){line30_20.alpha = 1.0;}
    if(linesToSpin >= 21){line30_21.alpha = 1.0;}
    if(linesToSpin >= 22){line30_22.alpha = 1.0;}
    if(linesToSpin >= 23){line30_23.alpha = 1.0;}
    if(linesToSpin >= 24){line30_24.alpha = 1.0;}
    if(linesToSpin >= 25){line30_25.alpha = 1.0;}
    if(linesToSpin >= 26){line30_26.alpha = 1.0;}
    if(linesToSpin >= 27){line30_27.alpha = 1.0;}
    if(linesToSpin >= 28){line30_28.alpha = 1.0;}
    if(linesToSpin >= 29){line30_29.alpha = 1.0;}
    if(linesToSpin >= 30){line30_30.alpha = 1.0;}
    
    optionLines.text = [NSString stringWithFormat:@"%i",linesToSpin];
    
    [self calBet];
}

-(IBAction)changeLines:(id)sender{
    if([showWinStatus isEqual:@"YES"]){
        [showWinLines invalidate];
        showWinStatus = @"NO";
    }
    
    [self resetWinBoxImages];
    
    UIButton *button = (UIButton *)sender;
    [self sortLines:button.tag];
    
    int nextLine = button.tag;
    
    if([[CommonUtilities decryptString:@"game_lines"] isEqual:@"30"]){
        UIImage *winImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"30_bundle_%i@2x", nextLine]];
        showWin.image = winImage;
    }else{
        UIImage *winImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"bundle_%i@2x", nextLine]];
        showWin.image = winImage;
    }
}

-(IBAction)maxBet:(id)sender{
    //int currentBet = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    ////NSLog([[CommonUtilities decryptString:@"game_lines"] intValue]);
    
    [self sortLines:[[CommonUtilities decryptString:@"game_lines"] intValue]];
    [self spin:@""];
}

-(IBAction)changeAllLines:(id)sender{
    
    [self resetWinBoxImages];
    
    if([showWinStatus isEqual:@"YES"]){
        [showWinLines invalidate];
        showWinStatus = @"NO";
    }
    
    int currentLine = [[CommonUtilities decryptString:@"optionLines"] intValue];
    
    int nextLine = 0;

    if(currentLine == [[CommonUtilities decryptString:@"game_lines"] intValue]){
        nextLine = 1;
    }else{
        nextLine = 1 + currentLine;
    }
    
    [self sortLines:nextLine];
    
    if([[CommonUtilities decryptString:@"game_lines"] isEqual:@"30"]){
        UIImage *winImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"30_bundle_%i@2x", nextLine]];
        showWin.image = winImage;
    }else{
        UIImage *winImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"bundle_%i@2x", nextLine]];
        showWin.image = winImage;
    }
    
}

-(void)calBet{
    int currentLine = [[CommonUtilities decryptString:@"optionLines"] intValue];
    int currentBet = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    optionMaxBet.text = [NSString stringWithFormat:@"%i", currentBet * currentLine];
}


-(IBAction)changeBet:(id)sender{
    int currentBet = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    int nextBet = 0;
    
    if(currentBet == 1){
        nextBet = 2;
    }else if(currentBet == 2){
        nextBet = 5;
    }else if(currentBet == 5){
        nextBet = 10;
    }else if(currentBet == 10){
        nextBet = 25;
    }else if(currentBet == 25){
        nextBet = 50;
    }else if(currentBet == 50){
        nextBet = 1;
    }

    optionBet.text = [NSString stringWithFormat:@"%i", nextBet];
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", nextBet]:@"optionBet"];
    
    betAmount = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    [self calBet];
}

- (IBAction)spinWheel:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewPrize.alpha = 0.0;
    [UIView commitAnimations];
}



// integrate ad networks
- (IBAction)showFreeCoins1:(id)sender{
    if([ALIncentivizedInterstitialAd isReadyForDisplay]){
        // If you want to use a reward delegate, set it here.  For this example, we will use nil.
        [ALIncentivizedInterstitialAd showAndNotify:nil];
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        //    NSLog(@"coinAdda1: %i", currentCoins);
        currentCoins = currentCoins + 100;
        //    NSLog(@"coinAdda2: %i", currentCoins);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
        

    }
    else{
        // No rewarded video is ready.  Perform failover logic, etc.
    }
}
// ALAdDisplayDelegate methods
- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view{}
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view{}
- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    // The user has closed the ad.  We must preload the next rewarded video.
    [ALIncentivizedInterstitialAd preloadAndNotify:nil];
}

-(void) rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    /* AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
     awarded and the name of the currency.  However, ideally, you should verify this with your server before granting it. */
   // NSString* currencyName = [response objectForKey: @"currency"];
   // NSString* amountGiven = [response objectForKey: @"amount"];
    int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
    //    NSLog(@"coinAdda1: %i", currentCoins);
    currentCoins = currentCoins + 100;
    //    NSLog(@"coinAdda2: %i", currentCoins);
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
    
    
}

- (IBAction)showFreeCoins2:(id)sender{
      //  if (_rewardedVideo) [_rewardedVideo showAd];
    [self showLoadedRewardedVideo];
    NSLog(@"[RevMob Sample App] Rewarded Video loaded.");
    int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
    //    NSLog(@"coinAdda1: %i", currentCoins);
    currentCoins = currentCoins + 100;
    //    NSLog(@"coinAdda2: %i", currentCoins);
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
    
    

}
- (void)loadRewardedVideo {
    //Initialize "video" as a fullscreen object
    _rewardedVideo = [[RevMobAds session] fullscreen];
    _rewardedVideo.delegate = self;
    [_rewardedVideo loadAd];
}
- (void)showLoadedRewardedVideo{
    if (_rewardedVideo) [_rewardedVideo showAd];
}


//RevMob delegates fired by RevMob Video objects:
-(void) revmobRewardedVideoDidLoad:(NSString *)placementId {
    [self showLoadedRewardedVideo];
    NSLog(@"[RevMob Sample App] Rewarded Video loaded.");
}
-(void) revmobRewardedVideoDidFailWithError:(NSError *)error onPlacement:(NSString *)placementId {
    NSLog(@"[RevMob Sample App] Rewarded Video failed with error: %@.", error);
}
-(void) revmobRewardedVideoNotCompletelyLoaded:(NSString *)placementId {
    NSLog(@"[RevMob Sample App] Rewarded Video not completely loaded.");
}
-(void) revmobRewardedVideoDidStart:(NSString *)placementId {
    NSLog(@"[RevMob Sample App] Rewarded Video started.");
}
-(void) revmobRewardedVideoComplete:(NSString *)placementId {
    //Give reward
    NSLog(@"[RevMob Sample App] Rewarded Video completed.");
}



- (IBAction)showFreeCoins3:(id)sender{
    
   // int startrew = [[CommonUtilities decryptString:@"startrew"] intValue];
   // NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
   // NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
  //  int todayNowRew = [intervalString intValue];
  //  double sDateRew = todayNowRew + 86001;
//  NSLog(@"today: %f", today);
//  NSLog(@"pRew: %f", [[CommonUtilities decryptString:@"pRew"] doubleValue]);
// if newsDate is higher than save dated = notif
    
  //  if(todayNowRew > [[CommonUtilities decryptString:@"pRew"] doubleValue]){
    //    startrew =0;
  //  }
  //  if (startrew <15 ){
        [Chartboost showRewardedVideo:CBLocationHomeScreen];
   //     startrew=startrew+1;
   //     [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", startrew]:@"startrew"];
   // }else{
   //     {
   //         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have reached your daily limit"
   //                                                         message:@"Try again later!"
   //                                                        delegate:nil
   //                                               cancelButtonTitle:@"OK"
   //                                               otherButtonTitles:nil];
   //         [alert show];
   //     }
        
   // }
    
    
  //  [CommonUtilities encryptString:[NSString stringWithFormat:@"%f", sDateRew]:@"pRew"];

}

- (IBAction)showPayTable:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewPayTable.alpha = 1.0;
    [UIView commitAnimations];
}

- (IBAction)hidePayTable:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewPayTable.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)hideLevel:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewLevelUp.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)hideCoinPopup:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewMoreCoins.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)viewDidLoad{
    //NSLog(@"Game: %@", [CommonUtilities decryptString:@"game_name"]);
    [super viewDidLoad];
    
    [RevMobAds startSessionWithAppID:REVMOB_APP_ID
                  withSuccessHandler:^{
                      //Custom method defined below - LOAD
                      [self loadRewardedVideo];
                  } andFailHandler:^(NSError *error) {
                      //For now we don't need this
                  }];
    // Your initialization code
    
    
    

    
    [self sortLevelBar];
    
    // Set the display delegate so we can receive the "wasHiddenIn" callback for preloading the next ad.
    [ALIncentivizedInterstitialAd shared].adDisplayDelegate = self;
    // If you want to use a load delegate, set it here.  For this example, we will use nil.
    [ALIncentivizedInterstitialAd preloadAndNotify:nil];
    
    
    
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // finish at 280;
        viewAutoSpinMenu.frame = CGRectMake(2,550,175,240);
    }else{
        viewAutoSpinMenu.frame = CGRectMake(5,250,81,110);
    }
    
    
    showWinData = [[NSMutableArray alloc] init];
    
    viewMoreCoins.alpha = 0.0;
    viewPrize.alpha = 0;
    viewAlert.alpha = 0;
    viewBack.alpha = 0;
    viewGameOver.alpha = 0;
    viewWelcome.alpha = 0;
    viewPayTable.alpha = 0;
    viewLevelUp.alpha = 0;
    viewBigWin.alpha = 0;
    viewBonusWin.alpha = 0;
    highscores.enabled = NO;
    
    iphone5Logo.alpha = 0;
    iphone5Text.alpha = 0;
    prizeShuffleCounter = 0;
    showWinItemsCounter = 1;
    
    UIImage *winImage = [UIImage imageNamed:@"line_null"];
    showWin.image = winImage;
    
    [self resetWinBoxImages];
    
    NSString* gameIdString = [CommonUtilities decryptString:@"game_id"];
    
    slot1Set1.image = [self createDynamicSlotImageWheel:0 gameIdString:gameIdString];
    slot1Set2.image = [slot1Set1.image copy];
    slot2Set1.image = [self createDynamicSlotImageWheel:1 gameIdString:gameIdString];
    slot2Set2.image = [slot2Set1.image copy];
    slot3Set1.image = [self createDynamicSlotImageWheel:2 gameIdString:gameIdString];
    slot3Set2.image = [slot3Set1.image copy];
    slot4Set1.image = [self createDynamicSlotImageWheel:3 gameIdString:gameIdString];
    slot4Set2.image = [slot4Set1.image copy];
    slot5Set1.image = [self createDynamicSlotImageWheel:4 gameIdString:gameIdString];
    slot5Set2.image = [slot5Set1.image copy];
    
    
    imgA.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_A@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgK.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_K@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgQ.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Q@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgJ.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_J@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgLemon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Lemon@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgDiamond.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Diamond@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgStar.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Star@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    img7.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_7@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgWild.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Wild@2x.png", [CommonUtilities decryptString:@"game_id"]]];
    imgBonus.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@item_Bonus@2x.png", [CommonUtilities decryptString:@"game_id"]]];

    
    if([[CommonUtilities decryptString:@"game_lines"] isEqual:@"30"]){
        lines_20_left.alpha = 0;
        lines_20_right.alpha = 0;
        lines_30_left.alpha = 1;
        lines_30_right.alpha = 1;
    }else{
        lines_20_left.alpha = 1;
        lines_20_right.alpha = 1;
        lines_30_left.alpha = 0;
        lines_30_right.alpha = 0;
    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    result = CGSizeMake(result.width * scale, result.height * scale);
    
    if(result.height == 960){
        //NSLog(@"iphone 4, 4s retina resolution");
    }
    if(result.height == 1136){
        //NSLog(@"iphone 5 resolution");
    }
    
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    displayWon.text = [CommonUtilities decryptString:@"won"];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    
    // request a read
    optionLines.text = [CommonUtilities decryptString:@"optionLines"];
    
    //NSLog(@"%i", [[CommonUtilities decryptString:@"optionLines"] intValue]);
    
    
    if([[CommonUtilities decryptString:@"game_lines"] intValue] < [[CommonUtilities decryptString:@"optionLines"] intValue]){
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", [[CommonUtilities decryptString:@"game_lines"] intValue]]:@"optionLines"];
        optionLines.text = [NSString stringWithFormat:@"%i", [[CommonUtilities decryptString:@"game_lines"] intValue]];
    }else if([[CommonUtilities decryptString:@"game_lines"] intValue] == 30 && [[CommonUtilities decryptString:@"optionLines"] intValue] == 20){
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", [[CommonUtilities decryptString:@"game_lines"] intValue]]:@"optionLines"];
        optionLines.text = [NSString stringWithFormat:@"%i", [[CommonUtilities decryptString:@"game_lines"] intValue]];
    }
    
    optionBet.text = [CommonUtilities decryptString:@"optionBet"];
    optionWon.text = @"0";
    
    linesToSpin = [[CommonUtilities decryptString:@"optionLines"] intValue];
    betAmount = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    [self sortLines:linesToSpin];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    viewWelcome.alpha = 1.0;
    viewBack.alpha = 0.6;
    [UIView commitAnimations];
    
    row1Postion = 20;
    row2Postion = 20;
    row3Postion = 20;
    row4Postion = 20;
    row5Postion = 20;
    
    //// auto-play runner
    
    // no nudges or holds or golden, just spins
    
    // prepare data
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //NSLog(@"can build to ipad");
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:20.0]];
        
        [lblLevelUpLevel setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10]];
        [lblLevelUp1 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10]];
        [lblLevelUp2 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10]];
        
    }else{
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        
        [displayCoins setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [optionXP setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [optionLvl setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [displayCoins setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        
        
        [optionBet setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [optionWon setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [optionMaxBet setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [optionLines setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblBet setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblWon setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblMaxBet setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblLines setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblPayTable1 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblPayTable2 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
        [lblSpin setFont:[UIFont fontWithName:@"Myriad Web Pro" size:12.0]];
    }
    
    lblAlert1.text = LABEL_WELCOME;
    lblAlert2.text = LABEL_TAPPLAY;
    
    lblAlert1.alpha = 1;
    lblAlert2.alpha = 0;
    lblAlert3.alpha = 0;
    
    currentWinCoins = 0;
    
    defaultMessages = @"YES";
    
    lblCounter = 0;
    alertControl = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeLbl) userInfo:nil repeats:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CloseForBonus:) name:@"CloseForBonus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortCoins:) name:@"sortCoins" object:nil];
    
    handleDropCoinsStatus = @"NO";
    [bgDropCoinsTimer invalidate];
}

-(void)CloseForBonus:(NSNotification*)notifcation{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)CloseForBonus2:(NSNotification*)notifcation{
    [self dismissViewControllerAnimated:NO completion:nil];
}

//



-(void)handleDropCoins{
    
    int maxY = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        maxY = 750;
    }else{
        maxY = 320;
    }
    
    if(moveCoin1.frame.origin.y > maxY){
        // time to reset
        moveCoin1By = 1 + (10 * [self giveRandom:4]);
        moveCoin1.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin1.frame = CGRectMake(moveCoin1.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin1.frame.size.width, moveCoin1.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin1.image = coinImg;
    }
    
    moveCoin1.frame = CGRectMake(moveCoin1.frame.origin.x, moveCoin1.frame.origin.y + moveCoin1By, moveCoin1.frame.size.width, moveCoin1.frame.size.height);
    
    if(moveCoin2.frame.origin.y > maxY){
        // time to reset
        moveCoin2By = 1 + (10 * [self giveRandom:4]);
        moveCoin2.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin2.frame = CGRectMake(moveCoin2.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin2.frame.size.width, moveCoin2.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin2.image = coinImg;
    }
    
    moveCoin2.frame = CGRectMake(moveCoin2.frame.origin.x, moveCoin2.frame.origin.y + moveCoin2By, moveCoin2.frame.size.width, moveCoin2.frame.size.height);
    
    if(moveCoin3.frame.origin.y > maxY){
        // time to reset
        moveCoin3By = 1 + (10 * [self giveRandom:4]);
        moveCoin3.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin3.frame = CGRectMake(moveCoin3.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin3.frame.size.width, moveCoin3.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin3.image = coinImg;
    }
    
    moveCoin3.frame = CGRectMake(moveCoin3.frame.origin.x, moveCoin3.frame.origin.y + moveCoin3By, moveCoin3.frame.size.width, moveCoin3.frame.size.height);
    
    if(moveCoin4.frame.origin.y > maxY){
        // time to reset
        moveCoin4By = 1 + (10 * [self giveRandom:4]);
        moveCoin4.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin4.frame = CGRectMake(moveCoin4.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin4.frame.size.width, moveCoin4.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin4.image = coinImg;
    }
    
    moveCoin4.frame = CGRectMake(moveCoin4.frame.origin.x, moveCoin4.frame.origin.y + moveCoin4By, moveCoin4.frame.size.width, moveCoin4.frame.size.height);
    
    if(moveCoin5.frame.origin.y > maxY){
        // time to reset
        moveCoin5By = 1 + (10 * [self giveRandom:4]);
        moveCoin5.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin5.frame = CGRectMake(moveCoin5.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin5.frame.size.width, moveCoin5.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin5.image = coinImg;
    }
    
    moveCoin5.frame = CGRectMake(moveCoin5.frame.origin.x, moveCoin5.frame.origin.y + moveCoin5By, moveCoin5.frame.size.width, moveCoin5.frame.size.height);
    
    if(moveCoin6.frame.origin.y > maxY){
        // time to reset
        moveCoin6By = 1 + (10 * [self giveRandom:4]);
        moveCoin6.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin6.frame = CGRectMake(moveCoin6.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin6.frame.size.width, moveCoin6.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin6.image = coinImg;
    }
    
    moveCoin6.frame = CGRectMake(moveCoin6.frame.origin.x, moveCoin6.frame.origin.y + moveCoin6By, moveCoin6.frame.size.width, moveCoin6.frame.size.height);
    
    if(moveCoin7.frame.origin.y > maxY){
        // time to reset
        moveCoin7By = 1 + (10 * [self giveRandom:4]);
        moveCoin7.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin7.frame = CGRectMake(moveCoin7.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin7.frame.size.width, moveCoin7.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin7.image = coinImg;
    }
    
    moveCoin7.frame = CGRectMake(moveCoin7.frame.origin.x, moveCoin7.frame.origin.y + moveCoin7By, moveCoin7.frame.size.width, moveCoin7.frame.size.height);
    
    if(moveCoin8.frame.origin.y > maxY){
        // time to reset
        moveCoin8By = 1 + (10 * [self giveRandom:4]);
        moveCoin8.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin8.frame = CGRectMake(moveCoin8.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin8.frame.size.width, moveCoin8.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin8.image = coinImg;
    }
    
    moveCoin8.frame = CGRectMake(moveCoin8.frame.origin.x, moveCoin8.frame.origin.y + moveCoin8By, moveCoin8.frame.size.width, moveCoin8.frame.size.height);
    
    if(moveCoin9.frame.origin.y > maxY){
        // time to reset
        moveCoin9By = 1 + (10 * [self giveRandom:4]);
        moveCoin9.alpha = [[NSString stringWithFormat:@"0.%i", [self giveRandom:10]] floatValue];
        moveCoin9.frame = CGRectMake(moveCoin9.frame.origin.x, -(5 * [self giveRandom:15]), moveCoin9.frame.size.width, moveCoin9.frame.size.height);
        UIImage *coinImg = [UIImage imageNamed:[self randomCoinImg]];
        moveCoin9.image = coinImg;
    }
    
    moveCoin9.frame = CGRectMake(moveCoin9.frame.origin.x, moveCoin9.frame.origin.y + moveCoin9By, moveCoin9.frame.size.width, moveCoin9.frame.size.height);
}

- (void)sortCoins:(NSNotification *) notification
{
    //NSLog(@"UPDATE ALL THE OUTPUTS ______ GAME CLASSIC");
    
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    displayWon.text = [CommonUtilities decryptString:@"won"];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
}

-(void)changeLbl{
    
    if(lblCounter == 0){
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
        lblAlert1.alpha = 1;
        lblAlert2.alpha = 0;
        lblAlert3.alpha = 0;
        [UIView commitAnimations];
        
        lblCounter = 1;
    }else if(lblCounter == 1){
        NSMutableArray *defaultMsg = [[NSMutableArray alloc] initWithObjects:LABEL_TAPPLAY, @"3 'Bonus' for Bonus Game", @"Wild plays anything!", @"Bet More, Win More!", @"Play more lines and win more!", nil];
        
        int random = arc4random() % ([defaultMsg count]);
        
        if([defaultMessages isEqual:@"YES"]){
            lblAlert2.text = [defaultMsg objectAtIndex:random];
        }
        
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
        lblAlert1.alpha = 0;
        lblAlert2.alpha = 1;
        lblAlert3.alpha = 0;
        [UIView commitAnimations];
        
        lblCounter = 2;
    }else if(lblCounter == 2){
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
        lblAlert1.alpha = 0;
        lblAlert2.alpha = 0;
        lblAlert3.alpha = 1;
        [UIView commitAnimations];
        
        lblCounter = 0;
    }
    
}
-(void)fadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    // [infoLbl setAlpha:1];
    [UIView commitAnimations];
}
- (void)dealloc{
    [alertControl invalidate];
     [super dealloc];
}
@end
