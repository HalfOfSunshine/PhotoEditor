//
//  EditInvoker.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import "EditInvoker.h"
#import "EditCommand.h"

@interface EditInvoker ()


@property (nonatomic, strong) EditReceiver *receiver;

@end

@implementation EditInvoker

- (instancetype)init:(EditReceiver*)receiver{
	self = [super init];
	if (self) {
		self.commands = [[NSMutableArray alloc] init];
		self.receiver = receiver;
	}
	return self;
}

//增加
- (void)increasePathModel:(PathModel *)pathModel{
	[self addCommand:@"reduce:" PathModel:pathModel];
	[self.receiver increase:pathModel];
}

//减少
- (void)reducePathModel:(PathModel *)pathModel{
	[self addCommand:@"increase:" PathModel:(PathModel *)pathModel];
	[self.receiver reduce:pathModel];
}

-(void)addCommand:(NSString*)methodName PathModel:(PathModel *)pathModel{
	//根据方法名称，动态加载执行对象的方法(runtime基础知识)
	//自己复习一下关于runtime基础知识
	//获取到方法对象
	//添加动态命令
	[self.commands addObject:[EditCommand createCommand:self.receiver block:^(EditReceiver *receiver) {
		SEL method = NSSelectorFromString(methodName);
		//执行回调
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[receiver performSelector:method withObject:pathModel];
#pragma clang diagnostic pop
	}]];
}

- (void)undo{
	if (self.commands.count > 0) {
		//撤销->DynamicCommand
		EditCommand* command = [self.commands lastObject];
		[command execute];
		//移除
		[self.commands removeObject:command];
	}
}

- (void)undoAll{
	for (EditCommand* command in self.commands) {
		[command execute];
	}
	[self.commands removeAllObjects];
}
@end

