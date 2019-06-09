//
//  MosaicPath.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import "MosaicPath.h"

@interface MosaicPath()<NSCopying,NSMutableCopying>

@end

@implementation MosaicPath

- (instancetype)init
{
	self = [super init];
	if (self) {
		_startPoint = CGPointZero;
		_endPoint = CGPointZero;
		_pathPointArray = [[NSMutableArray alloc]init];
	}
	return self;
}

-(NSMutableArray *)pathPointArray{
	if (!_pathPointArray) {
		_pathPointArray = [[NSMutableArray alloc]init];
	}
	return _pathPointArray;
}


-(void)resetStatus{
	_startPoint = CGPointZero;
	_endPoint = CGPointZero;
	[_pathPointArray removeAllObjects];
}



- (id)copyWithZone:(NSZone *)zone
{
	MosaicPath *obj = [[[self class] allocWithZone:zone] init];
	obj.pathPointArray = [self.pathPointArray copyWithZone:zone];
	obj.startPoint = self.startPoint;
	obj.endPoint = self.endPoint;
	
	return obj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	MosaicPath *obj = [[[self class] allocWithZone:zone] init];
	obj.pathPointArray = [self.pathPointArray copyWithZone:zone];
	obj.startPoint = self.startPoint;
	obj.endPoint = self.endPoint;
	return obj;
}

@end


@implementation PathPoint

- (instancetype)init
{
	self = [super init];
	if (self) {
		_xPoint = _yPoint = 0;
	}
	return self;
}
@end
