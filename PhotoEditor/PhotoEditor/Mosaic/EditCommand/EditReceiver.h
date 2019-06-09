//
//  EditReceiver.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <Foundation/Foundation.h>
#import "PathModel.h"
#import "MosaicPath.h"
NS_ASSUME_NONNULL_BEGIN

@interface EditReceiver : NSObject{
	NSInteger _count;
}
//被服务的对象
@property (nonatomic,strong) NSMutableArray <PathModel *>*mosaicPathArray;
//增加
- (void)increase:(PathModel*)pathModel;
//减少
- (void)reduce:(PathModel*)value;

@end

NS_ASSUME_NONNULL_END
