//
//  EditReceiver.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import "EditReceiver.h"

@implementation EditReceiver

-(NSMutableArray <PathModel *>*)mosaicPathArray{
	if (!_mosaicPathArray) {
		_mosaicPathArray = [NSMutableArray array];
	}
	return _mosaicPathArray;
}

- (void)increase:(PathModel *)pathModel{
	[self.mosaicPathArray addObject:pathModel];
}

- (void)reduce:(PathModel *)pathModel{
	if (self.mosaicPathArray.count>0) {
		[self.mosaicPathArray.lastObject.shapeLayer removeFromSuperlayer];
		[self.mosaicPathArray.lastObject.imageLayer removeFromSuperlayer];
		[self.mosaicPathArray removeLastObject];
	}
}

@end
