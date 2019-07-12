//
//  OCRTransportInfoViewController.m
//  scanning
//
//  Created by zwkj on 2019/6/26.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRTransportInfoViewController.h"
#import "OCRCameraViewController.h"
#import "AppDelegate.h"
#import "OCRServices.h"
#import "OCRSingleton.h"

@interface OCRTransportInfoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *monitorName;
@property (nonatomic, strong) NSArray *transportData;
@property (nonatomic, strong) UIButton *uploadCertificate;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation OCRTransportInfoViewController

- (void)viewWillAppear:(BOOL)animated {
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  }
  [super.navigationController setNavigationBarHidden:NO animated:YES];
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"运输证信息";
  [self getData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self defaultData];
  [self initPage];
}

-(void)initPage
{
  CGFloat height = self.view.frame.size.height;
  CGFloat width = self.view.frame.size.width;
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];
  [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *text = @"UITableViewTransportCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:text];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:text];
  }
  if (indexPath.row == 0) {
    NSDictionary *data = [self.transportData objectAtIndex:indexPath.row];
    NSString *value = [data objectForKey:@"value"];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [nameLabel setText:value];
    [cell addSubview:nameLabel];
  } else if (indexPath.row == 1) {
    NSDictionary *data = [self.transportData objectAtIndex:indexPath.row];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (indexPath.row == 2) {
    NSDictionary *data = [self.transportData objectAtIndex:indexPath.row];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  } else if (indexPath.row == 3) {
    self.uploadCertificate = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadCertificate setTitle:@"上传证件" forState:UIControlStateNormal];
    self.uploadCertificate.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadCertificate.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadCertificate addTarget:self action:@selector(uploadCertificateEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadCertificate];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
    
  }
  return cell;
}

-(void)uploadCertificateEvent
{
  NSDictionary *data = self.transportData[3];
  NSString *oldPhotoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = oldPhotoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 4;
  [app.nav pushViewController:cv animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 1) {
    return 150;
  }
  return 44;
}

-(void)defaultData
{
  UIImage *image = [UIImage imageNamed:@"idCard.png"];
  self.transportData = @[
                         @{@"key": @"monitorName", @"value": @""},
                         @{@"key": @"image", @"value": image},
                         @{@"key": @"运输证号", @"value": @"--"}
                      ];
}

-(void)getData
{
  NSDictionary *params = @{
                           @"monitorId": [OCRSingleton sharedSingleton].monitorId,
                           };
  [[OCRServices shardService] requestTransportNumberInfo:params
                                          successHandler:^(id result) {
                                            NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
                                            BOOL success = [[result objectForKey:@"success"] boolValue];
                                            if (statusCode == 200 && success == YES) {
                                              NSDictionary *data = [result objectForKey:@"obj"];
                                              NSString *transportNumberPhoto = [data objectForKey:@"transportNumberPhoto"];
                                              UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:transportNumberPhoto]]];
                                              if (image == nil) {
                                                image = [UIImage imageNamed:@"idCard.png"];
                                              }
                                              NSString *transportNumber = [data objectForKey:@"transportNumber"];
                                              self.transportData = @[
                                                                     @{@"key": @"monitorName", @"value": [OCRSingleton sharedSingleton].monitorName},
                                                                     @{@"key": @"image", @"value": image},
                                                                     @{@"key": @"运输证号", @"value": transportNumber},
                                                                     @{@"key": @"oldPhotoUrl", @"value": transportNumberPhoto}
                                                                     ];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.tableView reloadData];
                                              });
                                            }
                                          }
                                             failHandler:^(NSError *err) {
                                               
                                             }];
}

@end
