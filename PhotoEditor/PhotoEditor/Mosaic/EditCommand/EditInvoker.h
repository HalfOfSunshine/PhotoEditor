//
//  EditInvoker.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <Foundation/Foundation.h>
#import "PhotoEditorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditInvoker : NSObject
- (instancetype)init:(EditReceiver*)receiver;
//增加
- (void)increasePathModel:(PathModel *)pathModel;

//减少
- (void)reducePathModel:(PathModel *)pathModel;

//为最后一个数组添加一个移动点位
-(void)increasePathPointForLastObjc:(PathPoint *)pathPoint;

//为最后一个数组减少一个移动点位,暂时用不到
//-(void)reducePathPointForLastObjc:(PathPoint *)pathPoint;


/**
 撤回
 */
- (void)undo;

/**
 撤销
 */
- (void)undoAll;

@property (nonatomic, strong) NSMutableArray *commands;
@end

NS_ASSUME_NONNULL_END
