//
//  Copyright (c) 2014 Arkadiusz Holko, 2015 Ayan Yenbekbay.
//
//  Original source: https://github.com/Sumi-Interactive/SIAlertView/blob/master/SIAlertView/UIWindow%2BSIUtils.h
//

#import "UIWindow+SEAHelpers.h"

#import "AYMacros.h"

@implementation UIWindow (SEAHelpers)

#pragma mark Public

- (UIImage *)snapshot {
  // source (under MIT license): https://github.com/shinydevelopment/SDScreenshotCapture/blob/master/SDScreenshotCapture/SDScreenshotCapture.m#L35

  // UIWindow doesn't have to be rotated on iOS 8+.
  BOOL ignoreOrientation = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");

  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

  CGSize imageSize = CGSizeZero;

  if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation) {
    imageSize = [UIScreen mainScreen].bounds.size;
  } else {
    imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
  }

  UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, self.center.x, self.center.y);
  CGContextConcatCTM(context, self.transform);
  CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);

  // correct for the screen orientation
  if (!ignoreOrientation) {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
      CGContextRotateCTM(context, (CGFloat)M_PI_2);
      CGContextTranslateCTM(context, 0, -imageSize.width);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
      CGContextRotateCTM(context, (CGFloat) - M_PI_2);
      CGContextTranslateCTM(context, -imageSize.height, 0);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
      CGContextRotateCTM(context, (CGFloat)M_PI);
      CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
    }
  }

  if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
  } else {
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
  }

  CGContextRestoreGState(context);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

#pragma mark Private

- (UIViewController *)currentViewController {
  UIViewController *viewController = self.rootViewController;

  while (viewController.presentedViewController) {
    viewController = viewController.presentedViewController;
  }
  return viewController;
}

@end
