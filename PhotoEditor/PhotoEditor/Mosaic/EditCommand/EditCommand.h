//
//  EditCommand.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <Foundation/Foundation.h>
#import "EditReceiver.h"
#import "PhotoEditorProtocol.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^DynamicBlock)(EditReceiver* tm);

//特点一：实现命令协议
//特点二：传递接收者
@interface EditCommand : NSObject<PhotoEditorProtocol>

- (instancetype)init:(EditReceiver*)receiver block:(DynamicBlock)block;

+(id<PhotoEditorProtocol>)createCommand:(EditReceiver *)receiver block:(DynamicBlock)block;

@end

NS_ASSUME_NONNULL_END
