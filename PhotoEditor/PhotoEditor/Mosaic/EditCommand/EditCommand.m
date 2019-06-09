//
//  EditCommand.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import "EditCommand.h"
@interface EditCommand()
//父类引用指向子类实例对象（面向对象编程）->架构设计中以后经常看到->后面讲解的内容都将面向协议
@property(nonatomic, strong) EditReceiver* receiver;
@property(nonatomic, strong) DynamicBlock block;
@end

@implementation EditCommand

- (instancetype)init:(EditReceiver*)receiver block:(DynamicBlock)block{
	self = [super init];
	if (self) {
		self.receiver = receiver;
		self.block = block;
	}
	return self;
}

-(void)execute{
	self.block(self.receiver);
}

//创建对象的时候由于有的时候初始化参数过于复杂，这个我们可以内部提供
//我的动态命令创建过程，专门有了实现，外部只需要调用即可
//类方法->这是一个小框架->命令模式->万能命令
+(id<PhotoEditorProtocol>)createCommand:(EditReceiver *)receiver block:(DynamicBlock)block{
	return [[EditCommand alloc] init:receiver block:block];
}

@end
