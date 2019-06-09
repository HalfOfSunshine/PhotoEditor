//
//  MosaicPath.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PathPoint:NSObject

@property(nonatomic)float xPoint;

@property(nonatomic)float yPoint;

@end


@interface MosaicPath : NSObject

@property(nonatomic)CGPoint startPoint;
@property(nonatomic,strong)NSMutableArray *pathPointArray;
@property(nonatomic)CGPoint endPoint;

-(void)resetStatus;

@end
NS_ASSUME_NONNULL_END
