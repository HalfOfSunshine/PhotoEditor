//
//  PathModel.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/22.
//

#import <Foundation/Foundation.h>
#import "MosaicPath.h"
NS_ASSUME_NONNULL_BEGIN

@interface PathModel : NSObject
@property (nonatomic,strong) CALayer *imageLayer;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@end

NS_ASSUME_NONNULL_END
