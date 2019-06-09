//
//  PhotoEditorVC.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/20.
//

#import <UIKit/UIKit.h>
#import "EditorModel.h"
#import "EditReceiver.h"
#import "EditInvoker.h"
#import "SnapGridLayer.h"
#import "SnapCornerView.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^CompletedBlock)(EditorModel *resultModel);
@interface PhotoEditorVC : UIViewController
@property (nonatomic,strong) EditorModel *model;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) CompletedBlock completeBlock;
@end


@interface SnapRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;
- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;
@end

@interface HXEditRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;
- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;
@end
NS_ASSUME_NONNULL_END
