//
//  SnapBottomView.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SnapBottomView;
@protocol SnapBottomViewDelegate <NSObject>
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickRorateBtn:(UIButton*)btn;
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickCloseBtn:(UIButton*)btn;
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickRestoreBtn:(UIButton*)btn;
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickCompleteBtn:(UIButton*)btn;

@end
@interface SnapBottomView : UIView
@property (nonatomic,weak) id<SnapBottomViewDelegate> delegate;
@property (nonatomic,strong) UIButton *rorateBtn;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIButton *restoreBtn;
@property (nonatomic,strong) UIButton *completeBtn;

@end

NS_ASSUME_NONNULL_END
