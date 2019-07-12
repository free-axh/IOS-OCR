//
//  OCRValidationString.m
//  scanning
//
//  Created by zwkj on 2019/7/1.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "OCRValidationString.h"

@implementation NSString (category)

/**
 * 验证中文
 */
- (BOOL)validateChinese:(NSString *)string
{
  NSString *regex = @"[\u4e00-\u9fa5]+";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
  if (![pred evaluateWithObject:string]) {
    return NO;
  }
  return YES;
}

/**
 * 验证英文
 */
- (BOOL)validateEng
{
  NSString *regex = @"[a-zA-Z]";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
  if (![pred evaluateWithObject:self]) {
    return NO;
  }
  return YES;
}

/**
 * 验证中英文
 */
- (BOOL)validateChineseEng
{
  NSString *regex = @"^[a-zA-Z\u4e00-\u9fa5]*$";// @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z\u4e00-\u9fa5]+";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
  if (![pred evaluateWithObject:self]) {
    return NO;
  }
  return YES;
}

/**
 * 验证身份证号
 */
- (BOOL)validateIdCard
{
  NSString *regex = @"^[0-9X]*$";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
  if (![pred evaluateWithObject:self]) {
    return NO;
  }
  return YES;
}

- (NSString *)subBytesOfstringToIndex:(NSInteger)index
{
  return [self substringToIndex:index];
}

@end
