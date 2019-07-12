//
//  OCRCarPhotoValidateViewController.m
//  scanning
//
//  Created by zwkj on 2019/6/26.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRCarPhotoValidateViewController.h"
#import "OCRServices.h"
#import "OCRSingleton.h"
#import "ToastView.h"

@interface OCRCarPhotoValidateViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UILabel *monitorName;
@property (nonatomic, strong) NSArray *transportData;
@property (nonatomic, strong) UIButton *uploadCertificate;
@property (nonatomic, strong) UITextField *currentTextField; // 当前输入框
@property (nonatomic, strong) UITextField *carNumberTextField; // 当前输入框
@property (nonatomic, assign) NSInteger textLocation;//这里声明一个全局属性，用来记录输入位置

@end

@implementation OCRCarPhotoValidateViewController

- (void)viewWillAppear:(BOOL)animated {
//  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//  }
//  [super.navigationController setNavigationBarHidden:NO animated:YES];
//  self.view.backgroundColor = [UIColor whiteColor];
//
  
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
  
  self.title = @"确认信息";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self getData];
  [self initPage];
  [self setContent];
  // 键盘输入变化通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)name:UITextFieldTextDidChangeNotification object:nil];
  // 键盘出现的通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
  // 键盘消失的通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
}

-(void)setContent
{
  if (self.carInfoData != nil) {
    self.transportData = self.carInfoData;
  }
}

-(void)initPage
{
  CGFloat height = self.view.frame.size.height;
  CGFloat width = self.view.frame.size.width;
  UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  tableView.delegate = self;
  tableView.dataSource = self;
  tableView.tableFooterView = [[UIView alloc] init];
  [self.view addSubview:tableView];
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
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 44)];
    [textLabel setText:@"请核对扫描信息，确认无误"];
    textLabel.textColor = [UIColor grayColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
    [cell addSubview:textLabel];
  } else if (indexPath.row == 2) {
    NSDictionary *data = [self.transportData objectAtIndex:indexPath.row];
    UIImage *image = [data objectForKey:@"value"];
//    UIImage *image = [UIImage imageNamed:value];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 120)];
//    imageview.backgroundColor = [UIColor redColor];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = image;
    [cell addSubview:imageview];
  }
//  else if (indexPath.row == 3) {
//    NSDictionary *data = [self.transportData objectAtIndex:indexPath.row];
//    NSString *key = [data objectForKey:@"key"];
//    NSString *value = [data objectForKey:@"value"];
//    cell.textLabel.text = key;
//
//    self.carNumberTextField = [[UITextField alloc] initWithFrame: CGRectMake(100, 0, self.view.frame.size.width - 110, 44)];
//    self.carNumberTextField.clearsOnBeginEditing = NO;//鼠标点上时，不清空
//    self.carNumberTextField.delegate = self;
//    self.carNumberTextField.textAlignment = NSTextAlignmentRight;
//    self.carNumberTextField.returnKeyType = UIReturnKeyDone;
//    self.carNumberTextField.text = value;
//    self.carNumberTextField.tag = 3;
//    self.carNumberTextField.keyboardType = UIKeyboardTypeASCIICapable;
//    self.carNumberTextField.placeholder = @"请输入车牌号";
//    [self.carNumberTextField addTarget:self action:@selector(textfieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];//把DidEndOnExit事件响应为 textfieldDone: 方法
//    [cell.contentView addSubview: self.carNumberTextField];
//  }
  else if (indexPath.row == 3) {
    self.uploadCertificate = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 40)];
    [self.uploadCertificate setTitle:@"确认上传" forState:UIControlStateNormal];
    self.uploadCertificate.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.uploadCertificate.backgroundColor = [UIColor colorWithRed:51/255.0 green:80/255.0 blue:1 alpha:1];
    [self.uploadCertificate addTarget:self action:@selector(uploadCertificateEvent) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.uploadCertificate];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)textfieldDone
{
  
}

/**
 * textField获取焦点
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.currentTextField = textField;
  self.textLocation = [textField.text length];
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
  UITextField *textField = (UITextField *)obj.object;
  NSInteger tag = textField.tag;
  NSString *text = textField.text;
  if (tag == 3) {
    [self validateCardNumberTextField:textField string:text];
  }
}

/**
 * 车牌号
 */
- (void)validateCardNumberTextField:(UITextField *)textField string:(NSString *)text
{
  UITextRange *selectedRange = [textField markedTextRange];
  UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
  if (!position) {
    // 中文和英文一起检测  中文是两个字符
    if ([text length] > 24) {
      textField.text = [text substringToIndex:self.textLocation];
    }
    self.textLocation = [textField.text length];
  }
}

- (void)keyboardWillShow:(NSNotification *)notification {
  // 获取键盘高度
  CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
  
  // 计算出键盘顶端到输入框底端的距离
  CGRect tFActualFrame = [self.currentTextField convertRect:self.currentTextField.frame toView:self.view];  // textField在self.view中的实际frame
  
  CGFloat offset;
  
  offset = tFActualFrame.origin.y + tFActualFrame.size.height - (self.view.frame.size.height - kbHeight - 30);  // Keyboard_Interval为自定义的textField与键盘保持的距离
  
  // 键盘动画时间
  double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  
  // 将视图上移计算好的偏移
  if (offset > 0) {
    [UIView animateWithDuration:duration animations:^{
      self.view.frame = CGRectMake(0, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }];
  }
}

// 键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notification {
  // 键盘动画时间
  double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  
  // 视图恢复原位置
  [UIView animateWithDuration:duration animations:^{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  }];
}

-(void)uploadCertificateEvent
{
  UIImage *image = [[self.carInfoData objectAtIndex:2] objectForKey:@"value"];
  NSDictionary *imageData = @{
                              @"decodeImage": image,
                              };
  [[OCRServices shardService] uploadImage:imageData
                           successHandler:^(id result) {
                             NSLog(@"sss");
                             NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
                             BOOL success = [[result objectForKey:@"success"] boolValue];
                             if (statusCode == 200 && success == YES) {
                               NSDictionary *data = [result objectForKey:@"obj"];
                               NSString *newImageUrl = [data objectForKey:@"webUrl"];
                               [self uploadCarPhoto:newImageUrl];
                             }
                           }
                              failHandler:^(NSError *err) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [[ToastView shareInstance] makeToast:@"上传失败" duration:2.0];
                                });
                              }];
}

-(void)uploadCarPhoto:(NSString *)newImageUrl
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary *params = @{
                             @"monitorId": [OCRSingleton sharedSingleton].monitorId,
                             @"vehiclePhoto": newImageUrl,
                             @"oldVehiclePhoto": [OCRSingleton sharedSingleton].oldPhotoUrl,
                             };
    [[OCRServices shardService] uploadCarPhoto:params
                                successHandler:^(id result) {
                                  NSInteger statusCode = [[result objectForKey:@"statusCode"] integerValue];
                                  BOOL success = [[result objectForKey:@"success"] boolValue];
                                  if (statusCode == 200 && success == YES) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      [[ToastView shareInstance] makeToast:@"上传成功" duration:2.0];
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        NSArray *controllers = self.navigationController.viewControllers;
                                        [self.navigationController popToViewController:[controllers objectAtIndex:controllers.count - 3] animated:YES];
                                      });
                                      
                                    });
                                  } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      [[ToastView shareInstance] makeToast:@"上传失败" duration:2.0];
                                    });
                                  }
                                }
                                   failHandler:^(NSError *err) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       [[ToastView shareInstance] makeToast:@"上传失败" duration:2.0];
                                     });
                                   }];
  });
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
  if (indexPath.row == 2) {
    return 150;
  }
  return 44;
}

-(void)getData
{
  UIImage *image = [UIImage imageNamed:@"idCard.png"];
  self.transportData = @[
                         @{@"key": @"monitorName", @"value": @"渝A886RC"},
                         @{@"key": @"prompt", @"value": @"请核对扫描信息，确认无误"},
                         @{@"key": @"image", @"value": image},
//                         @{@"key": @"车牌号", @"value": @""}
                       ];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 收起键盘
  [self.view endEditing:YES];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  // 键盘消失的通知
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
