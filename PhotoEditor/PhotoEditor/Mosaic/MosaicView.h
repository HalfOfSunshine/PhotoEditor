//
//  MosaicView.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "MosaicPath.h"
#import "EditorModel.h"
NS_ASSUME_NONNULL_BEGIN

@class MosaicView;
@protocol MosaicDelegate <NSObject>
-(void)mosaicView:(MosaicView*)mosaicView drawBeginOnLayer:(CALayer *)imageLayer shape:(CAShapeLayer *)shapeLeyer;
-(void)mosaicView:(MosaicView*)mosaicView drawMoveOnPath:(CGMutablePathRef )path;
-(void)mosaicView:(MosaicView*)mosaicView drawEnd:(CGPoint )point;
@end

@interface MosaicView : UIView

/**
 为mosaicImages数组添加一张新的马赛克图片

 @param pixValue 马赛克像素点大小
 @param image 源图片
 */
- (void)setMosaciPixValue:(NSNumber*)pixValue forImage:(UIImage *)image;
-(void)redraw:(NSArray*)mosaicPathArray;
//原图片
@property (nonatomic, strong) UIImage *image;
//马赛克图片.
@property (nonatomic,weak) UIImageView *originView;
@property (nonatomic,strong) EditorModel *model;

/**
 马赛克图片数组
 */
@property (nonatomic,strong) NSMutableArray <UIImage *>*mosaicImages;
@property (nonatomic,assign) NSInteger mosaicIndex;
@property (nonatomic,strong) NSNumber *pixValue;
@property (nonatomic,weak) id<MosaicDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
