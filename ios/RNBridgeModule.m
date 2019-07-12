//
//  RNBridgeModule.m
//  scanning
//
//  Created by zwkj on 2019/6/11.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "RNBridgeModule.h"

#import "AppDelegate.h"
#import "OCRPeopleIdCardInfoViewController.h"

#import "OCRDrivingInfoViewController.h"
#import "OCRTransportInfoViewController.h"
#import "OCRCarPhotoViewController.h"
#import "OCRPractitionersViewController.h"
#import "OCRSingleton.h"

@implementation RNBridgeModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(backToViewController:(NSDictionary *)options){
  NSString *http = [options objectForKey:@"http"];
  NSString *token = [options objectForKey:@"token"];
  NSString *monitorId = [options objectForKey:@"monitorId"];
  NSString *monitorName = [options objectForKey:@"monitorName"];
  NSString *platform = [options objectForKey:@"platform"];
  NSString *version = [options objectForKey:@"version"];
  [OCRSingleton sharedSingleton].http = http;
  [OCRSingleton sharedSingleton].token = token;
  [OCRSingleton sharedSingleton].monitorId = monitorId;
  [OCRSingleton sharedSingleton].monitorName = monitorName;
  [OCRSingleton sharedSingleton].platform = platform;
  [OCRSingleton sharedSingleton].version = version;
  
  NSString *index = [options objectForKey:@"index"];
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([index isEqualToString:@"1"]) {
      OCRPeopleIdCardInfoViewController *one = [[OCRPeopleIdCardInfoViewController alloc] init];
      [app.nav pushViewController:one animated:YES];
    } else if ([index isEqualToString:@"2"]) {
      CGSize size = {20, 20};
      // 行驶证
      OCRDrivingInfoViewController *drivingInfo = [[OCRDrivingInfoViewController alloc] init];
      drivingInfo.tabBarItem.title = @"行驶证";
      drivingInfo.tabBarItem.image = [self scaleToSize:[UIImage imageNamed:@"warings1.png"] size:size];
      drivingInfo.tabBarItem.selectedImage = [self scaleToSize:[UIImage imageNamed:@"warings2.png"] size:size];
      [drivingInfo.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1]} forState:UIControlStateSelected];
      // 运输证
      OCRTransportInfoViewController *transportInfo = [[OCRTransportInfoViewController alloc] init];
      transportInfo.tabBarItem.title = @"运输证";
      transportInfo.tabBarItem.image = [self scaleToSize:[UIImage imageNamed:@"oversee-blur-tab.png"] size:size];
      transportInfo.tabBarItem.selectedImage = [self scaleToSize:[UIImage imageNamed:@"oversee-focus-tab.png"] size:size];
      [transportInfo.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1]} forState:UIControlStateSelected];
      // 从业人员
      OCRPractitionersViewController *practitioners = [[OCRPractitionersViewController alloc] init];
      practitioners.tabBarItem.title = @"从业人员";
      practitioners.tabBarItem.image = [self scaleToSize:[UIImage imageNamed:@"home-blur-tab.png"] size:size];
      practitioners.tabBarItem.selectedImage = [self scaleToSize:[UIImage imageNamed:@"home-focus-tab.png"] size:size];
      [practitioners.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1]} forState:UIControlStateSelected];
      // 车辆照片
      OCRCarPhotoViewController *carPhoto = [[OCRCarPhotoViewController alloc] init];
      carPhoto.tabBarItem.title = @"车辆照片";
      carPhoto.tabBarItem.image = [self scaleToSize:[UIImage imageNamed:@"application-blur-tab.png"] size:size];
      carPhoto.tabBarItem.selectedImage = [self scaleToSize:[UIImage imageNamed:@"application-focus-tab.png"] size:size];
      [carPhoto.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1]} forState:UIControlStateSelected];
      
      UITabBarController *tabs = [[UITabBarController alloc] init];
      tabs.viewControllers = @[drivingInfo, transportInfo, practitioners, carPhoto];
      [app.nav pushViewController:tabs animated:YES];
    }
  });
}

-(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newSize
{
  UIGraphicsBeginImageContext(newSize);
  [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return scaleImage;
}

@end
