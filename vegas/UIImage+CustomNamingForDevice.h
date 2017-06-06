//
//  UIImage+CustomNamingForDevice.h
//  PartySlots
//


#import <UIKit/UIKit.h>

@interface UIImage (CustomNamingForDevice)

// this method will be used as a shortcut to ease the custom naming convention used across this game
// that is, images targeted for ipad have the ipad_ prefix
// images for iphone don't have such prefix

// standard naming conventions(covered by UIImage imageNamed) state that images for ipad have the ~ipad suffix
// however this game is different and changing it to use the standard would be too complex a task with no clear benefits
+ (UIImage*) imageForDeviceForName:(NSString*)imageName;
+ (NSString*) nameForImageForDeviceForName:(NSString*)imageName;
@end
