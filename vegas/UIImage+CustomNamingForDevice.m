//
//  UIImage+CustomNamingForDevice.m


#import "UIImage+CustomNamingForDevice.h"

@implementation UIImage (CustomNamingForDevice)
+ (NSString*) nameForImageForDeviceForName:(NSString*)imageName{
    NSString* imageNameNew = imageName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        imageNameNew = [NSString stringWithFormat:@"ipad_%@", imageName];
    }
    else {
        imageNameNew = imageName;
    }
    return imageNameNew;
}

+ (UIImage*) imageForDeviceForName:(NSString*)imageName{
    UIImage * resultImg;
    NSString* imageNameNew = [self nameForImageForDeviceForName:imageName];
    resultImg = [UIImage imageNamed:imageNameNew];
    if (!resultImg){
        resultImg = [UIImage imageNamed:imageName];
    }
    
    return resultImg;
}
@end
