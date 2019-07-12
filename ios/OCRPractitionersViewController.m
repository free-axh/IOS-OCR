//
//  OCRPractitionersViewController.m
//  scanning
//
//  Created by zwkj on 2019/6/26.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRPractitionersViewController.h"
#import "DTScrollStatusView.h"
#import "OCRCameraViewController.h"
#import "AppDelegate.h"
#import "OCRServices.h"
#import "OCRSingleton.h"
#import "NSString+Category.h"



#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_RATE   ([UIScreen mainScreen].bounds.size.width/375.0)
static NSString * const imageC = @"imageCell";
static NSString * const moreImageC = @"imageCell";
static const NSInteger kItemCountPerRow = 5; //每行显示5个
static const NSInteger kRowCount = 3; //每页显示行数
static float imageHeight = 80;//cell 高度
#import "CollModel.h"
#import "imageCell.h"
#import "LHHorizontalPageFlowlayout.h"
#import "DTScrollStatusHeader.h"

@interface OCRPractitionersViewController ()<DTScrollStatusDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *monitorNameLabel; // 监控对象名称
@property (nonatomic, strong) UILabel *peopleNameLabel; // 从业人员名称
@property (nonatomic, strong) UIButton *addButton; // 新增按钮
@property (nonatomic, strong) NSArray *idCardData;
@property (nonatomic, strong) NSArray *driverLicenseData;
@property (nonatomic, strong) NSArray *qualificationCertificateData;
@property (nonatomic, strong) UIButton *uploadPositive; // 上传证件正本按钮
@property (nonatomic, strong) UIButton *uploadReverse; // 上传证件正本按钮
@property (nonatomic, strong) UITableView *idCardTableView;
@property (nonatomic, strong) UITableView *driverLicenseTableView;
@property (nonatomic, strong) UITableView *qualificationCertificateTableView;
@property (nonatomic, strong) NSMutableArray *practitioners;


@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * modelArray;
@property (nonatomic, strong) UICollectionView * moreCollectionView;
@property (nonatomic, strong) UIView *layer;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation OCRPractitionersViewController

- (void)viewWillAppear:(BOOL)animated {
//  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//  }
//  [super.navigationController setNavigationBarHidden:NO animated:YES];
//  self.view.backgroundColor = [UIColor whiteColor];

  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  }
  self.navigationController.navigationBar.topItem.title = @"";
  self.navigationController.navigationBar.barTintColor = DTColor(51, 158, 255, 1);// [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
  [self.navigationController.navigationBar setTitleTextAttributes:
   @{NSFontAttributeName:[UIFont systemFontOfSize:18],
     NSForegroundColorAttributeName:[UIColor whiteColor]}];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [super.navigationController setNavigationBarHidden:NO animated:YES];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.title = @"从业人员信息";
  [self initData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self defaultData];
  [self initPage];
  [self setPageContent];
//  [self addCollectionView];
}

// 实现图文混排的方法
- (NSAttributedString *) creatAttrStringWithText:(NSString *) text image:(UIImage *) image{
  
  // NSTextAttachment可以将图片转换为富文本内容
  NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
  attachment.image = image;
  // 通过NSTextAttachment创建富文本
  // 图片的富文本
  NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attachment];
  NSMutableAttributedString *mutableImageAttr = [[NSMutableAttributedString alloc] initWithAttributedString:imageAttr];
  [mutableImageAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, imageAttr.length)];
  // 调整图片的位置，负数代表向下
  [mutableImageAttr addAttribute:NSBaselineOffsetAttributeName value:@(-2) range:NSMakeRange(0, imageAttr.length)];
  
  // 文字的富文本
  NSAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
  
  NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] init];
  
  // 将图片、文字拼接
  // 如果要求图片在文字的后面只需要交换下面两句的顺序
  [mutableAttr appendAttributedString:textAttr];
  [mutableAttr appendAttributedString:mutableImageAttr];
  return [mutableAttr copy];
}

- (void)initPage
{
  CGFloat height = self.view.bounds.size.height;
  CGFloat width = self.view.bounds.size.width;
  self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, width, 45)];
  self.headerView.backgroundColor = [UIColor whiteColor];
//  [_headerView bringSubviewToFront:];
  [self.view addSubview:self.headerView];
  // 顶部监控对象名称
  self.monitorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, (width - 30) / 3, 45)];
  self.monitorNameLabel.textAlignment = NSTextAlignmentLeft;
  [self.headerView addSubview:self.monitorNameLabel];
//  self.monitorNameLabel.backgroundColor = [UIColor redColor];
  // 从业人员
  self.peopleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - 30) / 3 + 15, 0, (width - 30) / 3, 45)];
  self.peopleNameLabel.textAlignment = NSTextAlignmentCenter;
  [self.headerView addSubview:self.peopleNameLabel];
  self.peopleNameLabel.userInteractionEnabled = YES;
  UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
  
  [self.peopleNameLabel addGestureRecognizer:labelTapGestureRecognizer];
//  UIImage *image = [UIImage imageNamed:@"spinner.png"];
//  self.peopleNameLabel.attributedText = [self creatAttrStringWithText:@"--" image:image];
//  self.peopleNameLabel.backgroundColor = [UIColor blackColor];
  // 新增按钮
  UIImageView *addBtnIcon = [[UIImageView alloc] initWithFrame:CGRectMake(width - 45, 0, 30, 45)];
  UIImage *icon = [UIImage imageNamed:@"renyuanxinzeng.png"];
  addBtnIcon.image = icon;
  addBtnIcon.contentMode = UIViewContentModeScaleAspectFit;
  [self.headerView addSubview:addBtnIcon];
  
  self.addButton = [[UIButton alloc] initWithFrame:CGRectMake((width - 30) / 3 * 2 + 15, 0, (width - 30) / 3, 45)];
  self.addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
  [self.headerView addSubview:self.addButton];
  [self.addButton addTarget:self action:@selector(addBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
//  [self.addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//  self.addButton.titleLabel.textColor = [UIColor blackColor];
//  self.addButton.backgroundColor = [UIColor grayColor];
  
  // 选项卡
  UIView *tabContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, width, height - 160)];
  [self.view addSubview:tabContentView];
  
  DTScrollStatusView *scrollTapView = [[DTScrollStatusView alloc]initWithTitleArr:@[@"身份证", @"驾驶证", @"从业资格证"]
                                                                             type:ScrollTapTypeWithNavigation];
  scrollTapView.scrollStatusDelegate = self;
  [tabContentView addSubview:scrollTapView];
}

/**
 * 从业人员下拉列表点击事件
 */
-(void)labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
//  UILabel *label=(UILabel*)recognizer.view;
  if (self.practitioners.count > 0) {
    [self viewAnimation:self.collectionView willHidden:!self.collectionView.hidden];
  }
}

/**
 * 显示从业人员列表
 */
-(void)addCollectionView
{
//  NSArray *appArray = [[self getDict] objectForKey:@"dictInfo"];
  for (int i = 0; i < self.practitioners.count; i++) {
    NSDictionary * appDic = self.practitioners[i];
    CollModel * model = [[CollModel alloc]init];
    model.title = [appDic objectForKey:@"title"];
    model.url = [appDic objectForKey:@"url"];
    model.vid = [appDic objectForKey:@"id"];
    [self.modelArray addObject:model];
  }
  if (self.collectionView == nil) {
    [self createCollectionView];
  }
}

-(void)setPageContent
{
  self.monitorNameLabel.text = [OCRSingleton sharedSingleton].monitorName;
  self.peopleNameLabel.text = @"--";
//  [self.addButton setTitle:@"新增" forState:UIControlStateNormal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *text = @"UITableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:text];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:text];
  }
  if (tableView.tag == 0) {
    cell = [self idCardContent:cell indexPathRow:indexPath.row];
  }
  else if(tableView.tag == 1)
  {
    cell = [self driverLicenseContent:cell indexPathRow:indexPath.row];
  }
  else if (tableView.tag == 2) {
    cell = [self qualificationCertificateContent:cell indexPathRow: indexPath.row];
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

/**
 * 身份证正面
 */
-(UITableViewCell *)idCardContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.idCardData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
    // UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 5) {
    self.uploadPositive = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadPositive setTitle:@"拍照上传" forState:UIControlStateNormal];
    self.uploadPositive.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadPositive.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadPositive addTarget:self action:@selector(uploadIdCardEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadPositive];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.idCardData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

/**
 * 身份证正面上传
 */
- (void)uploadIdCardEvent
{
  [OCRSingleton sharedSingleton].isAddPractitioners = NO;
  NSDictionary *data = self.idCardData[5];
  NSString *oldPhotoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = oldPhotoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 11;
  [app.nav pushViewController:cv animated:YES];
}

/**
 * 驾驶证正面
 */
-(UITableViewCell *)driverLicenseContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.driverLicenseData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 5) {
    self.uploadReverse = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadReverse setTitle:@"拍照上传" forState:UIControlStateNormal];
    self.uploadReverse.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadReverse.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadReverse addTarget:self action:@selector(uploadDriverLicenseEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadReverse];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.driverLicenseData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

/**
 * 驾驶证上传
 */
- (void)uploadDriverLicenseEvent
{
  NSDictionary *data = self.driverLicenseData[5];
  NSString *oldPhotoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = oldPhotoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 6;
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

-(UITableViewCell *)qualificationCertificateContent:(UITableViewCell *)cell indexPathRow:(NSInteger)index
{
  if (index == 0) {
    NSDictionary *data = [self.qualificationCertificateData objectAtIndex:index];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  } else if (index == 2) {
    self.uploadReverse = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadReverse setTitle:@"拍照上传" forState:UIControlStateNormal];
    self.uploadReverse.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadReverse.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadReverse addTarget:self action:@selector(uploadQualificationCertificateEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadReverse];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  } else {
    NSDictionary *data = [self.qualificationCertificateData objectAtIndex:index];
    NSString *key = [data objectForKey:@"key"];
    NSString *value = [data objectForKey:@"value"];
    cell.detailTextLabel.text = value;
    cell.textLabel.text = key;
  }
  return cell;
}

- (void)uploadQualificationCertificateEvent
{
  NSDictionary *data = self.qualificationCertificateData[2];
  NSString *oldPhotoUrl = [data objectForKey:@"value"];
  [OCRSingleton sharedSingleton].oldPhotoUrl = oldPhotoUrl;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 5;
  [app.nav pushViewController:cv animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView.tag == 0) {
    self.idCardTableView = tableView;
    return 6;
  }
  else if (tableView.tag == 1) {
    self.driverLicenseTableView = tableView;
    return 6;
  } else {
    self.qualificationCertificateTableView = tableView;
    return 3;
  }
}

/**
 * 行驶证正面数据填充
 */
-(void)setContentValue
{
  
}

- (void)defaultData
{
  UIImage *image = [UIImage imageNamed:@"idCard.png"];
  // 身份证正面数据
  self.idCardData = @[
                      @{@"key": @"图片", @"value": image},
                      @{@"key": @"姓名", @"value": @"--"},
                      @{@"key": @"性别", @"value": @"--"},
                      @{@"key": @"身份证号", @"value": @"--"},
                      @{@"key": @"电话号码", @"value": @"--"}
                    ];
  // 驾驶证数据
  self.driverLicenseData = @[
                             @{@"key": @"图片", @"value": image},
                             @{@"key": @"驾驶证号", @"value": @"--"},
                             @{@"key": @"准驾车型", @"value": @"--"},
                             @{@"key": @"有效期起", @"value": @"--"},
                             @{@"key": @"有效期至", @"value": @"--"}
                           ];
  // 从业资格证书数据
  self.qualificationCertificateData = @[
                                        @{@"key": @"图片", @"value": image},
                                        @{@"key": @"从业资格证", @"value": @"--"}
                                      ];
}

-(void)initData
{
  NSDictionary *params = @{
                           @"id": [OCRSingleton sharedSingleton].monitorId,
                           };
  [[OCRServices shardService] requestPractitionersList:params
                                        successHandler:^(id result) {
                                          [self practitionersListHandler:result];
                                        }
                                           failHandler:^(NSError *err) {
                                             
                                           }];
}

/**
 * 从业人员列表获取成功处理
 */
-(void)practitionersListHandler:(id)result
{
  NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
  BOOL success = [[result objectForKey:@"success"] boolValue];
  if (statusCode == 200 && success == YES) {
    NSArray *data = [result objectForKey:@"obj"];
    if (data.count > 0) {
      if (self.layer != nil) {
        self.layer.hidden = YES;
      }
      NSString *firstId = nil;
      NSString *firstName = nil;
      self.practitioners = [[NSMutableArray alloc] init];
      for (int i = 0; i < data.count; i++) {
        NSDictionary *info = data[i];
        NSString *name = [info objectForKey:@"name"];
        NSString *vid = [info objectForKey:@"id"];
        NSDictionary *dic = @{
                              @"title": name,
                              @"id": vid,
                              @"url": @"renyuan-copy.png",
                              };
//        [self.practitioners setObject:id forKey:name];
        [self.practitioners addObject:dic];
        if (i == 0) {
          firstId = vid;
          firstName = name;
        }
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [OCRSingleton sharedSingleton].peopleName = firstName;
        if (data.count > 1) {
          [self addCollectionView];
          UIImage *image = [UIImage imageNamed:@"xiala-2.png"];
          self.peopleNameLabel.attributedText = [self creatAttrStringWithText:firstName image:image];
        } else {
          self.peopleNameLabel.text = firstName;
        }
      });
      [self searchPractitionersInfo:firstId];
      
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (self.layer == nil) {
          CGFloat height = self.view.bounds.size.height;
          CGFloat width = self.view.bounds.size.width;
          self.layer = [[UIView alloc] initWithFrame:CGRectMake(0, 100, width, height - 100)];
          [self.view addSubview:self.layer];
          self.layer.backgroundColor = [UIColor whiteColor];
          
          UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, width, 100)];
          UIImage *image = [UIImage imageNamed:@"renyuan.png"];
          imageView.image = image;
          imageView.contentMode = UIViewContentModeScaleAspectFit;
          [self.layer addSubview:imageView];
          
          UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, width, 30)];
          [self.layer addSubview:title];
          title.textAlignment = NSTextAlignmentCenter;
          [title setText:@"该监控对象尚未关联从业人员"];
        } else {
          self.layer.hidden = NO;
        }
      });
    }
  }
}

/**
 * 查询从业人员信息
 */
-(void)searchPractitionersInfo:(NSString *)practitionersId
{
  [OCRSingleton sharedSingleton].practitionersId = practitionersId;
  NSDictionary *params = @{
                           @"id": practitionersId,
                           };
  [[OCRServices shardService] requestPractitionersInfo:params
                                        successHandler:^(id result) {
                                          [self practitionersInfoHandler:result];
                                        }
                                           failHandler:^(NSError *err) {
                                             
                                           }];
}

/**
 * 处理查询从业人员成功后的信息
 */
-(void)practitionersInfoHandler:(id)result
{
  NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
  BOOL success = [[result objectForKey:@"success"] boolValue];
  if (statusCode == 200 && success == YES) {
    NSDictionary *data = [result objectForKey:@"obj"];
    
    NSString *identityCardPhoto = [data objectForKey:@"identityCardPhoto"];
    UIImage *idCardImage = [identityCardPhoto isEqual:[NSNull null]] ? nil : [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:identityCardPhoto]]];
    if (idCardImage == nil) {
      idCardImage = [UIImage imageNamed:@"idCard.png"];
    }
    NSString *name = [data objectForKey:@"name"];
    NSString *gender = [[data objectForKey:@"gender"] renturnGender];
    NSString *identity = [data objectForKey:@"identity"];
    NSString *phone = [data objectForKey:@"phone"];
    // 岗位类型
    NSString *positionType = [data objectForKey:@"positionType"];
    if ([positionType isEqualToString:@"ed057aa7-64b8-4ec1-9b14-dbc62b4286d4"]) {
      [OCRSingleton sharedSingleton].isICType = YES;
    } else {
      [OCRSingleton sharedSingleton].isICType = NO;
    }
    
    self.idCardData = @[
                        @{@"key": @"图片", @"value": idCardImage},
                        @{@"key": @"姓名", @"value": name},
                        @{@"key": @"性别", @"value": gender},
                        @{@"key": @"身份证号", @"value": identity},
                        @{@"key": @"电话号码", @"value": phone},
                        @{@"key": @"oldPhotoUrl", @"value": [identityCardPhoto isEqual:[NSNull null]] ? @"" : identityCardPhoto}
                      ];
    
    
    
    NSString *driverLicensePhoto = [data objectForKey:@"driverLicensePhoto"];
    UIImage *driverLicenseImage = [driverLicensePhoto isEqual:[NSNull null]] ? nil : [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:driverLicensePhoto]]];
    if (driverLicenseImage == nil) {
      driverLicenseImage = [UIImage imageNamed:@"idCard.png"];
    }
    NSString *drivingLicenseNo = [data objectForKey:@"drivingLicenseNo"];
    NSString *drivingType = [data objectForKey:@"drivingType"];
    NSString *drivingStartDate = [data objectForKey:@"drivingStartDate"];
    NSArray *drivingStartDateArr = [drivingStartDate componentsSeparatedByString:@" "];
    drivingStartDate = drivingStartDateArr[0];
    
    NSString *drivingEndDate = [data objectForKey:@"drivingEndDate"];
    NSArray *drivingEndDateArr = [drivingEndDate componentsSeparatedByString:@" "];
    drivingEndDate = drivingEndDateArr[0];
    
    self.driverLicenseData = @[
                               @{@"key": @"图片", @"value": driverLicenseImage},
                               @{@"key": @"驾驶证号", @"value": drivingLicenseNo},
                               @{@"key": @"准驾车型", @"value": drivingType},
                               @{@"key": @"有效期起", @"value": drivingStartDate},
                               @{@"key": @"有效期至", @"value": drivingEndDate},
                               @{@"key": @"oldPhotoUrl", @"value": [driverLicensePhoto isEqual:[NSNull null]] ? @"" : driverLicensePhoto}
                             ];
    
    NSString *qualificationCertificatePhoto = [data objectForKey:@"qualificationCertificatePhoto"];
    UIImage *qualificationCertificateImage = [qualificationCertificatePhoto isEqual:[NSNull null]] ? nil : [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:qualificationCertificatePhoto]]];
    if (qualificationCertificateImage == nil) {
      qualificationCertificateImage = [UIImage imageNamed:@"idCard.png"];
    }
    NSString *cardNumber = [data objectForKey:@"cardNumber"];
    self.qualificationCertificateData = @[
                                          @{@"key": @"图片", @"value": qualificationCertificateImage},
                                          @{@"key": @"从业资格证", @"value": cardNumber},
                                          @{@"key": @"oldPhotoUrl", @"value": [qualificationCertificatePhoto isEqual:[NSNull null]] ? @"" : qualificationCertificatePhoto}
                                        ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.idCardTableView reloadData];
      [self.driverLicenseTableView reloadData];
      [self.qualificationCertificateTableView reloadData];
      if ([OCRSingleton sharedSingleton].isICType) {
        [OCRSingleton sharedSingleton].idCardData = self.idCardData;
        [OCRSingleton sharedSingleton].driverLicenseData = self.driverLicenseData;
        [OCRSingleton sharedSingleton].qualificationCertificateData = self.qualificationCertificateData;
      }
    });
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    return 150;
  }
  return 44;
}


//- (NSDictionary *)getDict {
//  NSString * string  = @"{\"dictInfo\":[{\"title\":\"你好啊\",\"url\":\"1.jpeg\"},{\"title\":\"你好啊\",\"url\":\"2.jpeg\"},{\"title\":\"你好啊\",\"url\":\"3.jpeg\"},{\"title\":\"你好啊\",\"url\":\"4.jpeg\"},{\"title\":\"你好啊\",\"url\":\"5.jpeg\"},{\"title\":\"你好啊\",\"url\":\"6.jpeg\"},{\"title\":\"是很好\",\"url\":\"7.jpeg\"},{\"title\":\"你好啊\",\"url\":\"1.jpeg\"},{\"title\":\"你好啊\",\"url\":\"2.jpeg\"},{\"title\":\"你好啊\",\"url\":\"3.jpeg\"},{\"title\":\"你好啊\",\"url\":\"4.jpeg\"},{\"title\":\"你好啊\",\"url\":\"5.jpeg\"},{\"title\":\"你好啊\",\"url\":\"6.jpeg\"},{\"title\":\"是很好\",\"url\":\"7.jpeg\"},{\"title\":\"你好啊\",\"url\":\"1.jpeg\"},{\"title\":\"你好啊\",\"url\":\"2.jpeg\"},{\"title\":\"你好啊\",\"url\":\"3.jpeg\"},{\"title\":\"你好啊\",\"url\":\"4.jpeg\"},{\"title\":\"你好啊\",\"url\":\"5.jpeg\"},{\"title\":\"你好啊\",\"url\":\"6.jpeg\"},{\"title\":\"是很好\",\"url\":\"7.jpeg\"}]}";
//  NSDictionary *infoDic = [self dictionaryWithJsonString:string];
//  return infoDic;
//}


//-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
//  if (jsonString == nil) {
//    return nil;
//  }
//  NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//  NSError *err;
//  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers  error:&err];
//  if(err)
//  {
//    NSLog(@"json解析失败：%@",err);
//    return nil;
//  }
//  return dic;
//}

- (NSMutableArray *)modelArray {
  if (!_modelArray) {
    _modelArray = [NSMutableArray array];
  }
  return _modelArray;
}

- (void)createCollectionView{
  UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  layout.minimumLineSpacing = 0;
  layout.minimumInteritemSpacing = 0;
  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, imageHeight * SCREEN_RATE / 2) collectionViewLayout:layout];
  _collectionView.tag = 11;
  _collectionView.backgroundColor = [UIColor whiteColor]; // [UIColor colorWithRed:186 / 255.0 green:186 / 255.0 blue:186 / 255.0 alpha:0.9];
  _collectionView.dataSource = self;
  _collectionView.delegate = self;
  _collectionView.bounces = NO;
  _collectionView.alwaysBounceHorizontal = YES;
  _collectionView.alwaysBounceVertical = NO;
  _collectionView.showsHorizontalScrollIndicator = NO;
  _collectionView.showsVerticalScrollIndicator = NO;
  [self.view addSubview:_collectionView];
  [_collectionView registerClass:[imageCell class] forCellWithReuseIdentifier:imageC];
  _collectionView.hidden = YES;
  [self.view bringSubviewToFront:self.headerView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CollModel * model = self.modelArray[indexPath.row];
  imageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageC forIndexPath:indexPath];
  cell.itemModel = model;
  return cell;
}

// 返回每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat CWidth =  imageHeight * SCREEN_RATE;
  CGFloat CHeight = imageHeight * SCREEN_RATE;
  return CGSizeMake(CWidth, CHeight);
}

#pragma mark - UICollectionViewDelegate点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  CollModel * model = self.modelArray[indexPath.row];
  NSLog(@"self.appModelArray----%@",model.title);
  UIImage *image = [UIImage imageNamed:@"xiala-2.png"];
  self.peopleNameLabel.attributedText = [self creatAttrStringWithText:model.title image:image];
  [self searchPractitionersInfo:model.vid];
  [self viewAnimation:self.collectionView willHidden:YES];
  [OCRSingleton sharedSingleton].peopleName = model.title;
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

/**
 * 选择器显示与隐藏动画
 */
- (void)viewAnimation:(UIView*)view willHidden:(BOOL)hidden {
//  CGFloat height = self.view.frame.size.height;
  CGFloat width = self.view.frame.size.width;
  [UIView animateWithDuration:0.2
                   animations:^{
    if (hidden) {
      view.frame = CGRectMake(0, 0, width, imageHeight * SCREEN_RATE / 2);
    } else {
      [view setHidden:hidden];
      view.frame = CGRectMake(0, 105, width, imageHeight * SCREEN_RATE / 2);
    }
  } completion:^(BOOL finished) {
    [view setHidden:hidden];
  }];
}

-(void)addBtnEvent:(UIButton *)btn
{
  [OCRSingleton sharedSingleton].isAddPractitioners = YES;
  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  OCRCameraViewController *cv = [[OCRCameraViewController alloc] init];
  cv.type = 11;
  [app.nav pushViewController:cv animated:YES];
}

@end
