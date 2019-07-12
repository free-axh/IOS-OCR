//
//  OCRDrivingInfoViewController.m
//  scanning
//
//  Created by zwkj on 2019/6/25.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRDrivingInfoViewController.h"
#import "DTScrollStatusView.h"
#import "OCRCameraViewController.h"
#import "AppDelegate.h"
#import "OCRServices.h"
#import "OCRSingleton.h"

@interface OCRDrivingInfoViewController ()<DTScrollStatusDelegate>

@property (nonatomic, strong) UILabel *monitorNameLabel;
@property (nonatomic, strong) NSArray *vehicleLicensePositiveData;
@property (nonatomic, strong) NSArray *vehicleLicenseReverseData;
@property (nonatomic, strong) NSArray *nonFreightCarData;
@property (nonatomic, strong) UIButton *uploadPositive; // 上传证件正本按钮
@property (nonatomic, strong) UIButton *uploadReverse; // 上传证件正本按钮

@property (nonatomic, strong) UITableView *frontTableView;
@property (nonatomic, strong) UITableView *duplicateTableView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tabContentView;


@end

@implementation OCRDrivingInfoViewController

- (void)viewWillAppear:(BOOL)animated {
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  }
  self.navigationController.navigationBar.topItem.title = @"";
  self.view.backgroundColor = [UIColor whiteColor];
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
  [self.navigationController.navigationBar setTitleTextAttributes:
   @{NSFontAttributeName:[UIFont systemFontOfSize:18],
     NSForegroundColorAttributeName:[UIColor whiteColor]}];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [super.navigationController setNavigationBarHidden:NO animated:YES];
  self.title = @"行驶证信息";
  [self initData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self defaultData];
  [self initPage];
  [self setPageContent];
}

- (void)initPage
{
  CGFloat height = self.view.bounds.size.height;
  CGFloat width = self.view.bounds.size.width;
  
  // 顶部监控对象名称
  self.monitorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 75, width - 30, 30)];
  self.monitorNameLabel.textAlignment = NSTextAlignmentCenter;
  self.monitorNameLabel.textColor = [UIColor blackColor];
  [self.view addSubview:self.monitorNameLabel];
  
  // 选项卡
  self.tabContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, width, height - 160)];
  [self.view addSubview:self.tabContentView];

  DTScrollStatusView *scrollTapView = [[DTScrollStatusView alloc] initWithTitleArr:@[@"行驶证正本", @"行驶证副本"]
                                                          type:ScrollTapTypeWithNavigation];
  scrollTapView.scrollStatusDelegate = self;
  [self.tabContentView addSubview:scrollTapView];
  self.tabContentView.hidden = YES;
  
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];
  self.tableView.tag = 3;
  [self.view addSubview:self.tableView];
  self.tableView.hidden = YES;
}

-(void)setPageContent
{
  self.monitorNameLabel.text = [OCRSingleton sharedSingleton].monitorName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *text = @"UITableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:text];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:text];
  }
  if (tableView.tag == 0) {
    cell = [self positiveContent:cell indexPathRow:indexPath.row];
  }
  else if(tableView.tag == 1)
  {
    cell = [self reverseContent:cell indexPathRow:indexPath.row];
  } else if (tableView.tag == 3) {
    NSLog(@"dddd");
    cell = [self nonFreightCarContent:cell indexPathRow:indexPath.row];
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

/**
 * 非货运车行驶证正面
 */
-(UITableViewCell *)nonFreightCarContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.nonFreightCarData objectAtIndex:index];
    NSString *value = [data objectForKey:@"value"];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [nameLabel setText:value];
    [cell addSubview:nameLabel];
  } else if (index == 1) {
    NSDictionary *data = [self.nonFreightCarData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
    //    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 8) {
    self.uploadPositive = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadPositive setTitle:@"上传证件正本" forState:UIControlStateNormal];
    self.uploadPositive.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadPositive.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadPositive addTarget:self action:@selector(uploadPositiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadPositive];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.nonFreightCarData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

/**
 * 行驶证正面
 */
-(UITableViewCell *)positiveContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.vehicleLicensePositiveData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 7) {
    self.uploadPositive = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadPositive setTitle:@"上传证件正本" forState:UIControlStateNormal];
    self.uploadPositive.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadPositive.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadPositive addTarget:self action:@selector(uploadPositiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadPositive];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.vehicleLicensePositiveData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

/**
 * 驾驶证正面上传
 */
- (void)uploadPositiveEvent
{
  NSDictionary *data = nil;
  if ([[OCRSingleton sharedSingleton].carType isEqualToString:@"1"]) {
    data = self.vehicleLicensePositiveData[7];
  } else {
    data = self.nonFreightCarData[8];
  }
  NSString *photoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = photoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 2;
  [app.nav pushViewController:cv animated:YES];
}

/**
 * 行驶证反面
 */
-(UITableViewCell *)reverseContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.vehicleLicenseReverseData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 6) {
    self.uploadReverse = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadReverse setTitle:@"上传证件副本" forState:UIControlStateNormal];
    self.uploadReverse.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadReverse.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadReverse addTarget:self action:@selector(uploadReverseEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadReverse];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.vehicleLicenseReverseData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

/**
 * 驾驶证反面上传
 */
- (void)uploadReverseEvent
{
  NSDictionary *data = self.vehicleLicenseReverseData[6];
  NSString *photoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = photoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 3;
  [app.nav pushViewController:cv animated:YES];
}


- (void)refreshViewWithTag:(NSInteger)tag
                  isHeader:(BOOL)isHeader {
  if(isHeader)
  {
    NSLog(@"当前%ld个tableview 的头部正在刷新",tag);
  }
  else
  {
    NSLog(@"当前%ld个tableview 的尾部正在刷新",tag);
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView.tag == 0) {
    self.frontTableView = tableView;
    return 8;
  }
  else if (tableView.tag == 1)
  {
    self.duplicateTableView = tableView;
    return 7;
  } else {
    self.tableView = tableView;
    return 9;
  }
}

- (void)defaultData
{
  UIImage *image = [UIImage imageNamed:@"idCard.png"];
  // 行驶证正面数据
  self.vehicleLicensePositiveData = @[
                                      @{@"key": @"图片", @"value": image},
                                      @{@"key": @"车架号", @"value": @"--"},
                                      @{@"key": @"发动机号", @"value": @"--"},
                                      @{@"key": @"使用性质", @"value": @"--"},
                                      @{@"key": @"品牌型号", @"value": @"--"},
                                      @{@"key": @"注册日期", @"value": @"--"},
                                      @{@"key": @"发证日期", @"value": @"--"}
                                    ];

  // 行驶证反面数据
  self.vehicleLicenseReverseData = @[
                                     @{@"key": @"图片", @"value": image},
                                     @{@"key": @"检验有效期至", @"value": @"--"},
                                     @{@"key": @"总质量(kg)", @"value": @"--"},
                                     @{@"key": @"外廓尺寸-长(mm)", @"value": @"--"},
                                     @{@"key": @"外廓尺寸-高(mm)", @"value": @"--"},
                                     @{@"key": @"外廓尺寸-宽(mm)", @"value": @"--"}
                                   ];
  
  // 非货运车数据
  self.nonFreightCarData = @[
                             @{@"key": @"monitorName", @"value": @"张三德"},
                             @{@"key": @"图片", @"value": image},
                             @{@"key": @"车架号", @"value": @"--"},
                             @{@"key": @"发动机号", @"value": @"--"},
                             @{@"key": @"使用性质", @"value": @"--"},
                             @{@"key": @"品牌型号", @"value": @"--"},
                             @{@"key": @"注册日期", @"value": @"--"},
                             @{@"key": @"发证日期", @"value": @"--"}
                           ];
}

- (void)initData
{
  NSDictionary *params = @{
                           @"monitorId": [OCRSingleton sharedSingleton].monitorId,
                         };
  [[OCRServices shardService] requestVehicleDriveLicenseInfo:params
                                              successHandler:^(id result) {
                                                NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
                                                BOOL success = [[result objectForKey:@"success"] boolValue];
                                                if (statusCode == 200 && success == YES) {
                                                  NSDictionary *data = [result objectForKey:@"obj"];
                                                  if (data.count > 0) {
                                                    NSString *standard = [data objectForKey:@"standard"];
                                                    NSString *drivingLicenseFrontPhoto = [data objectForKey:@"drivingLicenseFrontPhoto"];
                                                    UIImage *frontImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:drivingLicenseFrontPhoto]]];
                                                    if (frontImage == nil) {
                                                      frontImage = [UIImage imageNamed:@"idCard.png"];
                                                    }
                                                    NSString *chassisNumber = [data objectForKey:@"chassisNumber"];
                                                    NSString *engineNumber = [data objectForKey:@"engineNumber"];
                                                    NSString *usingNature = [data objectForKey:@"usingNature"];
                                                    NSString *brandModel = [data objectForKey:@"brandModel"];
                                                    NSString *registrationDate = [data objectForKey:@"registrationDate"];
                                                    if (![registrationDate isEqual:[NSNull null]]) {
                                                      NSArray *registrationDateArr = [registrationDate componentsSeparatedByString:@" "];
                                                      registrationDate = registrationDateArr[0];
                                                    } else {
                                                      registrationDate = @"--";
                                                    }
                                                    NSString *licenseIssuanceDate = [data objectForKey:@"licenseIssuanceDate"];
                                                    if (![licenseIssuanceDate isEqual:[NSNull null]]) {
                                                      NSArray *licenseIssuanceDateArr = [licenseIssuanceDate componentsSeparatedByString:@" "];
                                                      licenseIssuanceDate = licenseIssuanceDateArr[0];
                                                    } else {
                                                      licenseIssuanceDate = @"--";
                                                    }
                                                    if ([standard isEqualToString:@"1"]) {
                                                      self.vehicleLicensePositiveData = @[
                                                                                          @{@"key": @"图片", @"value": frontImage},
                                                                                          @{@"key": @"车架号", @"value": chassisNumber},
                                                                                          @{@"key": @"发动机号", @"value": engineNumber},
                                                                                          @{@"key": @"使用性质", @"value": usingNature},
                                                                                          @{@"key": @"品牌型号", @"value": brandModel},
                                                                                          @{@"key": @"注册日期", @"value": registrationDate},
                                                                                          @{@"key": @"发证日期", @"value": licenseIssuanceDate},
                                                                                          @{@"key": @"oldPhotoUrl", @"value": drivingLicenseFrontPhoto},
                                                                                          ];
                                                    } else {
                                                      self.nonFreightCarData = @[
                                                                                 @{@"key": @"monitorName", @"value": [OCRSingleton sharedSingleton].monitorName},
                                                                                          @{@"key": @"图片", @"value": frontImage},
                                                                                          @{@"key": @"车架号", @"value": chassisNumber},
                                                                                          @{@"key": @"发动机号", @"value": engineNumber},
                                                                                          @{@"key": @"使用性质", @"value": usingNature},
                                                                                          @{@"key": @"品牌型号", @"value": brandModel},
                                                                                          @{@"key": @"注册日期", @"value": registrationDate},
                                                                                          @{@"key": @"发证日期", @"value": licenseIssuanceDate},
                                                                                          @{@"key": @"oldPhotoUrl", @"value": drivingLicenseFrontPhoto},
                                                                                          ];
                                                    }
                                                    
                                                    
                                                    if ([standard isEqualToString:@"1"]) {
                                                      NSString *drivingLicenseDuplicatePhoto = [data objectForKey:@"drivingLicenseDuplicatePhoto"];
                                                      UIImage *duplicateImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:drivingLicenseDuplicatePhoto]]];
                                                      if (duplicateImage == nil) {
                                                        duplicateImage = [UIImage imageNamed:@"idCard.png"];
                                                      }
                                                      NSString *validEndDate = [data objectForKey:@"validEndDate"];
                                                      if (![validEndDate isEqual:[NSNull null]]) {
                                                        NSArray *validEndDateArr = [validEndDate componentsSeparatedByString: @" "];
                                                        validEndDate = validEndDateArr[0];
                                                      } else {
                                                        validEndDate = @"--";
                                                      }
                                                      NSString *totalQuality = [data objectForKey:@"totalQuality"];
                                                      NSString *profileSizeLong = [[data objectForKey:@"profileSizeLong"] stringValue];
                                                      NSString *profileSizeHigh = [[data objectForKey:@"profileSizeHigh"] stringValue];
                                                      NSString *profileSizeWide = [[data objectForKey:@"profileSizeWide"] stringValue];
                                                      self.vehicleLicenseReverseData = @[
                                                                                         @{@"key": @"图片", @"value": duplicateImage},
                                                                                         @{@"key": @"检验有效期至", @"value": validEndDate},
                                                                                         @{@"key": @"总质量(kg)", @"value": totalQuality},
                                                                                         @{@"key": @"外廓尺寸-长(mm)", @"value": profileSizeLong},
                                                                                         @{@"key": @"外廓尺寸-高(mm)", @"value": profileSizeHigh},
                                                                                         @{@"key": @"外廓尺寸-宽(mm)", @"value": profileSizeWide},
                                                                                         @{@"key": @"oldPhotoUrl", @"value": drivingLicenseDuplicatePhoto},
                                                                                         ];
                                                    }
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      [OCRSingleton sharedSingleton].carType = standard;
                                                      if ([standard isEqualToString:@"1"]) {
                                                        self.tableView.hidden = YES;
                                                        self.tabContentView.hidden = NO;
                                                        [self.frontTableView reloadData];
                                                        [self.duplicateTableView reloadData];

                                                      } else {
                                                        self.tabContentView.hidden = YES;
                                                        self.tableView.hidden = NO;
                                                        [self.tableView reloadData];
                                                      }
                                                    });
                                                  }
                                                }
                                              }
                                                 failHandler:^(NSError *err) {
                                                   NSLog(@"ssss");
                                                 }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView.tag == 3) {
    if (indexPath.row == 1) {
      return 150;
    }
  } else {
    if (indexPath.row == 0) {
      return 150;
    }
  }
  return 44;
}

@end
