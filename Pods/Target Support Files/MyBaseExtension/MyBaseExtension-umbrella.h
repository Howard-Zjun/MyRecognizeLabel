#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MyBaseExtension.h"
#import "UIImage+Extension.h"

FOUNDATION_EXPORT double MyBaseExtensionVersionNumber;
FOUNDATION_EXPORT const unsigned char MyBaseExtensionVersionString[];

