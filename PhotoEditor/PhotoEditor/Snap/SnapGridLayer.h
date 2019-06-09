//
//  SnapGridLayer.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/24.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SnapGridLayer :  CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@end

NS_ASSUME_NONNULL_END
