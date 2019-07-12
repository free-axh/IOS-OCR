//
//  OCRPeopleIdCardInfoViewController.m
//  scanning
//
//  Created by zwkj on 2019/6/20.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRPeopleIdCardInfoViewController.h"
#import "OCRCameraViewController.h"
#import "AppDelegate.h"
#import "OCRServices.h"
#import "OCRSingleton.h"

@interface OCRPeopleIdCardInfoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *monitorNameLabel;
@property (nonatomic, strong) UIImageView *idCardImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genderLabel;
@property (nonatomic, strong) UILabel *cardLabel;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *peopleCardInfoData;

@end

@implementation OCRPeopleIdCardInfoViewController

- (void)viewWillAppear:(BOOL)animated {
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  }
  self.navigationController.navigationBar.topItem.title = @"";
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
  [self.navigationController.navigationBar setTitleTextAttributes:
   @{NSFontAttributeName:[UIFont systemFontOfSize:18],
     NSForegroundColorAttributeName:[UIColor whiteColor]}];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [super.navigationController setNavigationBarHidden:NO animated:YES];
  self.title = @"身份证信息";
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
  static NSString *text = @"UITableViewPeopleCard";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:text];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:text];
  }
  if (indexPath.row == 0) {
    NSDictionary *data = [self.peopleCardInfoData objectAtIndex:indexPath.row];
    NSString *value = [data objectForKey:@"value"];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [nameLabel setText:value];
    [cell addSubview:nameLabel];
  } else if (indexPath.row == 1) {
    NSDictionary *data = [self.peopleCardInfoData objectAtIndex:indexPath.row];
    UIImage *image = [data objectForKey:@"value"];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (indexPath.row == 5) {
    self.uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadButton setTitle:@"上传证件" forState:UIControlStateNormal];
    self.uploadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadButton.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadButton addTarget:self action:@selector(uploadIdCard) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadButton];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.peopleCardInfoData objectAtIndex:indexPath.row];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 6;
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

-(void)getData
{
  NSDictionary *params = @{
                          @"monitorId": [OCRSingleton sharedSingleton].monitorId,
                        };
  [[OCRServices shardService] requestIdCardInfo: params
                          successHandler:^(id result) {
                            NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
                            BOOL success = [[result objectForKey:@"success"] boolValue];
                            if (statusCode == 200 && success == YES) {
                              NSDictionary *data = [result objectForKey:@"obj"];
                              if (data.count > 0) {
                                NSString *gender = [self getGender:[data objectForKey:@"gender"]];
                                NSString *identityCardPhoto = [data objectForKey:@"identityCardPhoto"];
                                [OCRSingleton sharedSingleton].oldPhotoUrl = identityCardPhoto;
                                NSString *identity = [data objectForKey:@"identity"];
                                NSString *name = [data objectForKey:@"name"];
                                
                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:identityCardPhoto]]];
                                if (image == nil) {
                                  image = [UIImage imageNamed:@"idCard.png"];
                                }
                                
                                self.peopleCardInfoData = @[
                                                            @{@"key": @"monitorName", @"value":[OCRSingleton sharedSingleton].monitorName},
                                                            @{@"key": @"image", @"value": image},
                                                            @{@"key": @"姓名", @"value": name},
                                                            @{@"key": @"性别", @"value": gender},
                                                            @{@"key": @"身份证号", @"value": identity}
                                                            ];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.tableView reloadData];
                                });
                              }
                            }
                          }
                             failHandler:^(NSError *error) {
                               NSLog(@"ssss");
                             }];
  
}

-(void)defaultData
{
  UIImage *image = [UIImage imageNamed:@"idCard.png"];
  self.peopleCardInfoData = @[
                              @{@"key": @"monitorName", @"value": [OCRSingleton sharedSingleton].monitorName},
                              @{@"key": @"image", @"value": image},
                              @{@"key": @"姓名", @"value": @"--"},
                              @{@"key": @"性别", @"value": @"--"},
                              @{@"key": @"身份证号", @"value": @"--"}
                            ];
}

/**
 * 上传证件
 */
- (void)uploadIdCard
{
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 1;
  [app.nav pushViewController:cv animated:YES];
}

/**
 * 性别
 */
- (NSString *)getGender:(NSString *)type
{
  if ([type isEqualToString:@"1"]) {
    return @"男";
  } else {
    return @"女";
  }
}

@end
