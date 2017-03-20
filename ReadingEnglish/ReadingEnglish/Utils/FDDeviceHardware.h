/**
 * Copyright (C) 2016 Fudemame, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UIDeviceFamily) {
  UIDeviceFamilyiPhone,
  UIDeviceFamilyiPod,
  UIDeviceFamilyiPad,
  UIDeviceFamilyAppleTV,
  UIDeviceFamilyUnknown,
};

@interface FDDeviceHardware : NSObject

/**
 Returns a machine-readable model name in the format of "iPhone4,1"
 */
+ (NSString *)modelIdentifier;

/**
 Returns a human-readable model name in the format of "iPhone 4S". Fallback of
 the the `modelIdentifier` value.
 */
+ (NSString *)modelName;

/**
 Returns the device family as a `UIDeviceFamily`
 */
+ (UIDeviceFamily)deviceFamily;

+ (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier;
@end
