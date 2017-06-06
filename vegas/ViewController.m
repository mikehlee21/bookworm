//
//  ViewController.m

#import "ViewController.h"
#import "BonusViewController.h"
#import "CoinsController.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "ObjectAL.h"
#import "GameClassic20.h"
#import "ALInterstitialAd.h"
#import <RevMobAds/RevMobAds.h>

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    //
    // This method trigger AppLovin interstitial loading.
    // Note that the application flow will not be blocked: an interstital
    // will be displayed when loaded from the server.
    //
    
#ifdef ADS_INTERSTITIAL_ON_LOBBY_FREQUENCY
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger nb_shown_lobby = [prefs integerForKey:@"nShownLobby"];
    nb_shown_lobby++;
    [prefs setInteger:nb_shown_lobby forKey:@"nShownLobby"];
    [prefs synchronize];
    
    if ((nb_shown_lobby % ADS_INTERSTITIAL_ON_LOBBY_FREQUENCY) == 0) {
        [ALInterstitialAd showOver:self.view.window];
    }
#endif
}

- (IBAction)coinsView:(id)sender{
    [BaseViewController showCoinsView:sender inController:self];
}


-(void)gameengine:(NSString *)gamename :(NSString *)lines{
    // name
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%@ (%@)", gamename, lines]:@"game_name"];
    
    // lines
    [CommonUtilities encryptString:lines:@"game_lines"];
    
    // set game id (for reels, pay table etc)
    [CommonUtilities encryptString:gamename:@"game_id"];
    
    GameClassic20 *game = [[[GameClassic20 alloc] initWithNibName:@"GameClassic20" bundle:nil] autorelease];
    [self presentViewController:game animated:NO completion:nil];
}

- (IBAction)GameMega20:(id)sender{
    [self gameengine:@"mega":@"20"];
}

- (IBAction)GameMega30:(id)sender{
    [self gameengine:@"mega":@"30"];
}

- (IBAction)GameClassic20:(id)sender{
    [self gameengine:@"slot":@"20"];
}

- (IBAction)GameClassic30:(id)sender{
    [self gameengine:@"slot":@"30"];
}

- (IBAction)GameGem30:(id)sender{
    [self gameengine:@"gems":@"30"];
}

- (IBAction)GameHorse20:(id)sender{
    [self gameengine:@"horse":@"20"];
}

- (IBAction)GameHorse30:(id)sender{
    [self gameengine:@"horse":@"30"];
}

- (IBAction)GameBingo30:(id)sender{
    [self gameengine:@"bingo":@"30"];
}

- (IBAction)GameSports30:(id)sender{
    [self gameengine:@"sports":@"30"];
}

- (IBAction)GameSnacks30:(id)sender{
    [self gameengine:@"snacks":@"30"];
}

- (IBAction)GameKings30:(id)sender{
    [self gameengine:@"kings":@"30"];
}

- (IBAction)GameZoo30:(id)sender{
    [self gameengine:@"zoo":@"30"];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *connectState = [prefs stringForKey:@"connectState"];
    
    if([connectState isEqual:@"updatecoins"]){
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        [prefs setObject:responseString forKey:@"testResponse"];
        [prefs synchronize];
    }else if([connectState isEqual:@"sync"]){
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        // build 4 coin strings
        NSString *response = [CommonUtilities base64Decrypt:responseString:[CommonUtilities decryptString:@"commsKey"]];

        NSArray *downloadData = [response componentsSeparatedByString:@"||"];
        NSLog(@"%@", response);
        
        if([response isEqual:@""] || [downloadData count] < 8){
        }else{
           @try {
                if([[downloadData objectAtIndex:0] isEqual:@""] || [[downloadData objectAtIndex:1] isEqual:@""] || [[downloadData objectAtIndex:2] isEqual:@""] || [[downloadData objectAtIndex:3] isEqual:@""] || [[downloadData objectAtIndex:4] isEqual:@""]){
                }else{
                    [CommonUtilities encryptString:[downloadData objectAtIndex:0]:@"coins"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:1]:@"won"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:2]:@"bet"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:3]:@"exp"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:4]:@"username"];
                    [CommonUtilities encryptString:[downloadData objectAtIndex:5]:@"public"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sortCoins" object:self];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCoins" object:self];
                    
                    
                    
                    if([[downloadData objectAtIndex:6] isEqual:@"0"] || [[downloadData objectAtIndex:6] isEqual:@""]){
                        // no promote
                        //NSLog(@"no promo to promote");
                    }else{
                        [CommonUtilities encryptString:[downloadData objectAtIndex:6]:@"adrelease"];
                        [CommonUtilities encryptString:[downloadData objectAtIndex:7]:@"adtitle"];
                        [CommonUtilities encryptString:[downloadData objectAtIndex:8]:@"adbody"];
                        [CommonUtilities encryptString:[downloadData objectAtIndex:9]:@"download_url"];
                    }
                }
            }
            @catch (NSException * e) {
                //NSLog(@"Exception: %@", e);
            }
        }
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    
    prizeShuffleCounter = 0;
    
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    lblDisplayLevel.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    lblDisplayLevelNOT.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    
    // check all levles
    game1.userInteractionEnabled = NO;
    game2.userInteractionEnabled = NO;
    game3.userInteractionEnabled = NO;
    game4.userInteractionEnabled = NO;
    game5.userInteractionEnabled = NO;
    game6.userInteractionEnabled = NO;
    game7.userInteractionEnabled = NO;
    game8.userInteractionEnabled = NO;
    game9.userInteractionEnabled = NO;
    game10.userInteractionEnabled = NO;
    game11.userInteractionEnabled = NO;
    game12.userInteractionEnabled = NO;
    
    int level = [[self returnLevel:xp] intValue];
        
    
    if(level >= 1){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game1@2x.png"]];
        [game1 setImage:buttonImage forState:UIControlStateNormal];
        game1.userInteractionEnabled = YES;
    }
    if(level >= 1){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game2@2x.png"]];
        [game2 setImage:buttonImage forState:UIControlStateNormal];
        game2.userInteractionEnabled = YES;
    }

    if(level >= 3){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game3@2x.png"]];
        [game3 setImage:buttonImage forState:UIControlStateNormal];
        game3.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game3_locked@2x.png"]];
        [game3 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 5){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game4@2x.png"]];
        [game4 setImage:buttonImage forState:UIControlStateNormal];
        game4.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game4_locked@2x.png"]];
        [game4 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 7){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game5@2x.png"]];
        [game5 setImage:buttonImage forState:UIControlStateNormal];
        game5.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game5_locked@2x.png"]];
        [game5 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 9){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game6@2x.png"]];
        [game6 setImage:buttonImage forState:UIControlStateNormal];
        game6.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game6_locked@2x.png"]];
        [game6 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 11){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game7@2x.png"]];
        [game7 setImage:buttonImage forState:UIControlStateNormal];
        game7.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game7_locked@2x.png"]];
        [game7 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 15){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game8@2x.png"]];
        [game8 setImage:buttonImage forState:UIControlStateNormal];
        game8.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game8_locked@2x.png"]];
        [game8 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 20){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game9@2x.png"]];
        [game9 setImage:buttonImage forState:UIControlStateNormal];
        game9.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game9_locked@2x.png"]];
        [game9 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 24){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game10@2x.png"]];
        [game10 setImage:buttonImage forState:UIControlStateNormal];
        game10.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game10_locked@2x.png"]];
        [game10 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 28){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game11@2x.png"]];
        [game11 setImage:buttonImage forState:UIControlStateNormal];
        game11.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game11_locked@2x.png"]];
        [game11 setImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(level >= 32){
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game12@2x.png"]];
        [game12 setImage:buttonImage forState:UIControlStateNormal];
        game12.userInteractionEnabled = YES;
    }else{
        UIImage *buttonImage = [UIImage imageForDeviceForName:[NSString stringWithFormat:@"game12_locked@2x.png"]];
        [game12 setImage:buttonImage forState:UIControlStateNormal];
    }
    
  //  [CommonUtilities encryptString:@"DONE":[NSString stringWithFormat:@"alertpromo%@", @""]];
  //  [CommonUtilities encryptString:@"DONE":[NSString stringWithFormat:@"alertpromo%@", @"0"]];
    
//#if SHOW_DOWNLOAD_POPUP
//    if([[CommonUtilities decryptString:[NSString stringWithFormat:@"alertpromo%@", [CommonUtilities decryptString:@"adrelease"]]] isEqual:@"DONE"]){
        //NSLog(@"already done promo");
//    }else{
        // save the promo data to file
        
        //NSLog(@"show promo data");
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.5];
//        viewDownload.alpha = 1.0;
//        [UIView commitAnimations];
        
 //       [CommonUtilities encryptString:@"DONE":[NSString stringWithFormat:@"alertpromo%@", [CommonUtilities decryptString:@"adrelease"]]];
//        downloadTitle.text = [CommonUtilities decryptString:@"adtitle"];
//        downloadBody.text = [CommonUtilities decryptString:@"adbody"];
//    }
//#endif
}

- (NSString*)isLevelUnlocked:(int)level{
    /*
    
     Game 1     = Classic (20)
     Game 2     = Horse Time (20)
     Game 3     = Mega Bullions (20)
     Game 4     = Classic (30)
     Game 5     = Horse Time (30)
     Game 6     = Gems (30)
     Game 7     = Mega Bullions (30)
     Game 9     = Bingo (30)
     
    */
    
    if(level == 3){
        return @"Unlocked Mega Bullions (20 Lines)";
    }else if(level == 5){
        return @"Unlocked Classic Slots (30 Lines)";
    }else if(level == 7){
        return @"Unlocked Horse Time! (30 Lines)";
    }else if(level == 9){
        return @"Unlocked Gem Slots (30 Lines)";
    }else if(level == 11){
        return @"Unlocked Mega Bullions (30 Lines)";
    }else if(level == 15){
        return @"Unlocked Bingo Slots (30 Lines)";
    }else if(level == 20){
        return @"Unlocked Crazy Zoo! (30 Lines)";
    }else if(level == 24){
        return @"Unlocked Kings & Pirates (30 Lines)";
    }else if(level == 28){
        return @"Unlocked Cool Sports (30 Lines)";
    }else if(level == 30){
        return @"Unlocked Snacks (30 Lines)";
    }else{
        return @"NO";
    }
}

-(void)DailyBonus:(NSNotification*)notifcation{
    prizeShuffleCounter = 0;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pushLoadPrize) userInfo:nil repeats:NO];
}

-(void)pushLoadPrize{
    BonusViewController *sampleView = [[[BonusViewController alloc] initWithNibName:@"BonusViewController" bundle:nil] autorelease];
    [self presentViewController:sampleView animated:NO completion:nil];
}



-(NSString*)returnLevel:(int)exp{
    float e = (25 + sqrt(625 + 100 * exp)) / 50;
    int lvl = floor(e);
    return [NSString stringWithFormat:@"%i", lvl];
    
    /* 
     to get exp from level do the following
     
     (25 * level * level) - (25 * level)
     */
}

-(void)sortLevelBar{
    int exp = [[CommonUtilities decryptString:@"exp"] intValue];
    float e = (25 + sqrt(625 + 100 * exp)) / 50;
    NSArray *x = [[NSString stringWithFormat:@"%.2f", e] componentsSeparatedByString:@"."];
    // percent remaining
    NSString *percent = [x objectAtIndex:1];
    
    int p = [percent intValue];
    
    NSString *itm = @"";
    
    if(p < 10){
        itm = @"1";
    }else if(p < 20){
        itm = @"2";
    }else if(p < 30){
        itm = @"3";
    }else if(p < 40){
        itm = @"4";
    }else if(p < 50){
        itm = @"5";
    }else if(p < 60){
        itm = @"6";
    }else if(p < 70){
        itm = @"7";
    }else if(p < 80){
        itm = @"8";
    }else if(p < 90){
        itm = @"9";
    }else if(p < 100){
        itm = @"full";
    }
    
    [UIView beginAnimations:@"Fade In" context:nil];
    [UIView setAnimationDuration:5.0];
    UIImage *image = [UIImage imageForDeviceForName: [NSString stringWithFormat:@"level_%@.png", itm]];
    [showLevel setImage:image];
    [UIView commitAnimations];
    
    
    // xp to next level
    
    NSString *lvl = [NSString stringWithFormat:@"%.2f", e];
    
    int lvlcurrent = floor([lvl floatValue]);
    int nextlvl = lvlcurrent + 1;
    int nextxp = (25 * nextlvl * nextlvl) - (25 * nextlvl);
    int remainxp = nextxp - exp;
    
    lblAlert3.text = [NSString stringWithFormat:@"%i XP for Next Level", remainxp];
}

-(int)giveRandom:(int)by{
    int randis = (arc4random() % by) + 1;
    return randis;
}

-(NSString *)randomCoinImg{
    int randomNo = [self giveRandom:3];
    
    if(randomNo == 1){
        return @"ipad_move_coin_left.png";
    }else if(randomNo == 2){
        return @"ipad_move_coin_right.png";
    }else{
        return @"ipad_move_coin.png";
    }
}

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

- (void)manageSlide{
    //NSLog(@"page: %i", moveSlides);
    if(moveSlides == 0){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        btnMoveLeft.alpha = 0;
        btnMoveRight.alpha = 1;
        [UIView commitAnimations];
    }else if(moveSlides == 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        btnMoveLeft.alpha = 1;
        btnMoveRight.alpha = 0;
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        btnMoveLeft.alpha = 1;
        btnMoveRight.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    //NSLog(@"%f", games.contentOffset.x);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        moveSlides = floor(games.contentOffset.x / 930);
    }else{
        moveSlides = floor(games.contentOffset.x / 420);
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    [self manageSlide];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sender{
    [self manageSlide];
}

-(IBAction)moveRight:(id)sender{
    moveSlides = moveSlides + 1;
    
    CGRect frame;
	frame.origin.x = games.frame.size.width * moveSlides;
	frame.origin.y = 0;
	frame.size = games.frame.size;
	[games scrollRectToVisible:frame animated:YES];
}

-(IBAction)moveLeft:(id)sender{
    moveSlides = moveSlides - 1;
    
    CGRect frame;
	frame.origin.x = games.frame.size.width * moveSlides;
	frame.origin.y = 0;
	frame.size = games.frame.size;
	[games scrollRectToVisible:frame animated:YES];
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentLeaderBoard = kGameCenterLeaderboardID;
        
        if ([GameCenterManager isGameCenterAvailable]) {
            isGameCenterAvailable = YES;
            self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
            [self.gameCenterManager setDelegate:self];
            [self.gameCenterManager authenticateLocalUser];
            
        } else {
            isGameCenterAvailable = NO;
            // The current device does not support Game Center.
            
        }
    }
    return self;
}*/


- (void)viewDidLoad{
    [OALSimpleAudio sharedInstance].allowIpod = YES;
    
    // Mute all audio if the silent switch is turned on.
    //[OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    
    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    [[OALSimpleAudio sharedInstance] preloadEffect:kSoundWon];
    [[OALSimpleAudio sharedInstance] preloadEffect:kSoundNudge];
    [[OALSimpleAudio sharedInstance] preloadEffect:kSoundCoinDrop];
    [[OALSimpleAudio sharedInstance] preloadEffect:kSoundChestOpen];
    [[OALSimpleAudio sharedInstance] preloadEffect:kSoundFinishedSpin];

    [self sortLevelBar];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        CGSize srect =  CGSizeMake(2790, 599);
        games.contentSize = srect;
    }else{
        CGSize srect =  CGSizeMake(1260, 234);
        games.contentSize = srect;
    }
    
    showWinData = [[NSMutableArray alloc] init];
    
    moveSlides = 0;
    
    viewSettings.alpha = 0;
    
    prizeShuffleCounter = 0;
    showWinItemsCounter = 1;
    
    viewDownload.alpha = 0;
    
    UIImage *winImage = [UIImage imageNamed:@"line_null.png"];
    showWin.image = winImage;
    
    [super viewDidLoad];
    
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    result = CGSizeMake(result.width * scale, result.height * scale);
    
    if(result.height == 960){
        //NSLog(@"iphone 4, 4s retina resolution");
    }else if(result.height == 1136){
        //NSLog(@"iphone 5 resolution");
    }
    
    NSString *id1 = [CommonUtilities decryptString:@"id1"];
    if(id1 == nil){
        [CommonUtilities encryptString:INITIAL_STARTUP_BET:@"bet"];
        [CommonUtilities encryptString:@"0":@"won"];
        [CommonUtilities encryptString:INITIAL_STARTUP_COINS:@"coins"];
        displayCoins.text = INITIAL_STARTUP_COINS;
        
        [CommonUtilities encryptString:@"ON":@"sound"];
        
        [CommonUtilities encryptString:INITIAL_LINES_COUNT:@"optionLines"];
        [CommonUtilities encryptString:@"1":@"optionBet"];
        
        [CommonUtilities encryptString:@"0":@"exp"];
        
        [CommonUtilities encryptString:@"YES":@"notif"];
        [CommonUtilities encryptString:@"YES":@"public"];
        
        [CommonUtilities encryptString:@"Guest":@"username"];
    
        NSString *genkey = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        //NSLog(genkey);
        
        [CommonUtilities encryptString:[CommonUtilities md5:genkey]:@"id1"];
    }else{
        displayCoins.text = [CommonUtilities decryptString:@"coins"];
    }
    
    // prepare the settings popup
    if([[CommonUtilities decryptString:@"notif"] isEqual:@"YES"]){
        [switchNotif setOn:YES];
    }else{
        [switchNotif setOn:NO];
    }
    
    if([[CommonUtilities decryptString:@"public"] isEqual:@"YES"]){
        [switchPublic setOn:YES];
    }else{
        [switchPublic setOn:NO];
    }
    
    if([[CommonUtilities decryptString:@"sound"] isEqual:@"ON"]){
        [switchSound setOn:YES];
    }else{
        [switchSound setOn:NO];
    }
    
    //[CommonUtilities encryptString:@"NO":@"zd"];
    [self presetSoundButtons];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    lblDisplayLevel.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    lblDisplayLevelNOT.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    
    // request a read
    
    linesToSpin = [[CommonUtilities decryptString:@"optionLines"] intValue];
    betAmount = [[CommonUtilities decryptString:@"optionBet"] intValue];
    
    // sort
    
    
    row1Postion = 20;
    row2Postion = 20;
    row3Postion = 20;
    row4Postion = 20;
    row5Postion = 20;
    UIFont* ft20 = [UIFont fontWithName:@"Myriad Web Pro" size:20.0];
    UIFont* ft10 = [UIFont fontWithName:@"Myriad Web Pro" size:10.0];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //NSLog(@"can build to ipad");
        [[UILabel appearance] setFont:ft20];
        [btnDownloadCancel.titleLabel setFont:ft20];
        [btnDownloadNow.titleLabel setFont:ft20];
    }else{
        [[UILabel appearance] setFont:ft10];
        
        [displayCoins setFont:ft10];
        [optionXP setFont:ft10];
        [optionLvl setFont:ft10];
        [displayCoins setFont:ft10];
        [btnDownloadCancel.titleLabel setFont:ft10];
        [btnDownloadNow.titleLabel setFont:ft10];
    }
    
//    [downloadBody setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
//    [downloadCancel setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
//    [downloadNow setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
//    [downloadTitle setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
    
    lblAlert1.text = LABEL_WELCOME;
    lblAlert2.text = LABEL_TAPPLAY;
    
    lblAlert1.alpha = 1;
    lblAlert2.alpha = 0;
    lblAlert3.alpha = 0;
    
    defaultMessages = @"YES";
    
    [self manageSlide];
    
    lblCounter = 0;
    //NSTimer *alertControl = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeLbl) userInfo:nil repeats:YES];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoins:) name:@"updateCoins" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DailyBonus:) name:@"DailyBonus" object:nil];
    
    bgDropCoinsTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleDropCoins) userInfo:nil repeats:YES];
}

-(void)manageServer:(NSString *)where{
#ifndef kSERVER_SIDE_URL
    return;
#else    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"sync" forKey:@"connectState"];
    [prefs synchronize];
    
    NSString *genkey = [NSString stringWithFormat:@"commsKey_%f", [[NSDate date] timeIntervalSince1970]];
    //NSLog(genkey);
    
    [CommonUtilities encryptString:[CommonUtilities md5:genkey]:@"commsKey"];
    
    NSString *deviceName = [CommonUtilities base64Encrypt:[[UIDevice currentDevice] name]:[CommonUtilities md5:genkey]];
    NSString *userkey = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"id1"]:[CommonUtilities md5:genkey]];
    NSString *won = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"won"]:[CommonUtilities md5:genkey]];
    NSString *bet = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"bet"]:[CommonUtilities md5:genkey]];
    NSString *xp = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"exp"]:[CommonUtilities md5:genkey]];
    NSString *spins = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"spins"]:[CommonUtilities md5:genkey]];
    NSString *sendcoins = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"coins"]:[CommonUtilities md5:genkey]];
    NSString *fbid = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"efbid"]:[CommonUtilities md5:genkey]];
    NSString *fbemail = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"efbemail"]:[CommonUtilities md5:genkey]];
    NSString *fbname = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"efbname"]:[CommonUtilities md5:genkey]];
    NSString *public = [CommonUtilities base64Encrypt:[CommonUtilities decryptString:@"public"]:[CommonUtilities md5:genkey]];
    NSString *device_type = [CommonUtilities base64Encrypt:[[[[UIDeviceHardware alloc] init] autorelease] platformString]:[CommonUtilities md5:genkey]];
    
    NSString *version = @"10";
    
    NSString *httpBodyString=[[NSString alloc] initWithFormat:@"version=%@&device=%@&userkey=%@&won=%@&bet=%@&coins=%@&comm=%@&xp=%@&fbid=%@&fbemail=%@&spins=%@&fbname=%@&device_type=%@&public=%@", version, deviceName, userkey, won, bet, sendcoins, [CommonUtilities md5:genkey], xp, fbid, fbemail, spins, fbname,device_type, public];
    
    NSString *urlString=[[NSString alloc] initWithFormat:kSERVER_SIDE_URL];
    
    NSURL *url=[[NSURL alloc] initWithString:urlString];
    [urlString release];
    
    NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
    [url release];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [httpBodyString length]];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[httpBodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
    NSLog(@"%@", urlRequest);
    [httpBodyString release];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    responseData=[[NSMutableData data] retain];    
    #endif
}

- (void)updateCoins:(NSNotification *) notification
{
    
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    
    lblDisplayName.text = [CommonUtilities decryptString:@"username"];
    lblDisplayLevel.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    
    lblDisplayNameNOT.text = [CommonUtilities decryptString:@"username"];
    lblDisplayLevelNOT.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    
    [self viewWillAppear:YES];
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
  //  [gameCenterManager release];
    [super dealloc];
}


#pragma mark Settings popup:

-(IBAction)showSettings:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    viewSettings.alpha = 1.0;
    [UIView commitAnimations];
    
    if([[CommonUtilities decryptString:@"notif"] isEqual:@"YES"]){
        [switchNotif setOn:YES];
    }else{
        [switchNotif setOn:NO];
    }
    
    if([[CommonUtilities decryptString:@"public"] isEqual:@"YES"]){
        [switchPublic setOn:YES];
    }else{
        [switchPublic setOn:NO];
    }
    
    if([[CommonUtilities decryptString:@"sound"] isEqual:@"ON"]){
        [switchSound setOn:YES];
    }else{
        [switchSound setOn:NO];
    }
}

-(IBAction)hideSettings:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    viewSettings.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)changePublic:(id)sender {
    //UISwitch *mySwitch = (UISwitch *)sender;
    if ([switchPublic isOn]) {
        //NSLog(@"its on! - pub");
        [CommonUtilities encryptString:@"YES":@"public"];
    } else {
        //NSLog(@"its off! - pub");
        [CommonUtilities encryptString:@"NO":@"public"];
    }
}

- (IBAction)changeNotif:(id)sender {
    //UISwitch *mySwitch = (UISwitch *)sender;
    if ([switchNotif isOn]) {
        //NSLog(@"its on! - notif");
        [CommonUtilities encryptString:@"YES":@"notif"];
    } else {
        //NSLog(@"its off! - notif");
        [CommonUtilities encryptString:@"NO":@"notif"];
    }
}

- (IBAction)changeSound:(id)sender {
    //UISwitch *mySwitch = (UISwitch *)sender;
    if ([switchSound isOn]) {
        //NSLog(@"its on! - sound");
        [CommonUtilities encryptString:@"ON":@"sound"];
    } else {
        //NSLog(@"its off! - sound");
        [CommonUtilities encryptString:@"OFF":@"sound"];
    }
    [self presetSoundButtons];
}

@end
