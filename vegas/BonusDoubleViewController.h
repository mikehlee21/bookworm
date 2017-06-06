//
//  ViewController.h

#import "BonusViewController.h"

@interface BonusDoubleViewController : BonusViewController <NSURLConnectionDelegate>{
    IBOutlet UIButton *prizeChest1, *prizeChest2, *prizeChest3, *prizeChest4, *prizeChest5, *prizeChest6, *prizeChest7, *prizeChest8, *prizeChest9, *prizeChest10;
    
    int card1, card2, card3;
    BOOL userPicked;
}
-(IBAction)prizeChest:(id)sender;
@end
