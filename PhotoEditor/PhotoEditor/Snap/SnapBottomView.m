//
//  SnapBottomView.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/26.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromAlphaAndRGB(alphaValue,rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]
#define FUll_VIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define FUll_VIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#import "SnapBottomView.h"
@implementation SnapBottomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGFloat interval = 42;
	CGFloat btnWidth = (self.frame.size.width-interval*2)/3;
	
	_rorateBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, self.frame.size.height/2)];
	[_rorateBtn setImage:[UIImage imageNamed:@"snap_rorate" ] forState:UIControlStateNormal];
	[_rorateBtn addTarget:self action:@selector(rorateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_rorateBtn];
	
	UIView *separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, 0.5)];
	separateLine.backgroundColor = UIColorFromRGB(0x454545);
	[self addSubview:separateLine];
	
	_closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2, btnWidth, self.frame.size.height/2)];
	[_closeBtn setImage:[UIImage imageNamed:@"snap_close" ] forState:UIControlStateNormal];
	[_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_closeBtn];
	
	_restoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth+interval, self.frame.size.height/2, btnWidth, self.frame.size.height/2)];
	[_restoreBtn setTitle:@"还原" forState:UIControlStateNormal];
	_restoreBtn.titleLabel.font = [UIFont systemFontOfSize:15.];
	[_restoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_restoreBtn addTarget:self action:@selector(restoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	_restoreBtn.enabled = NO;
	_restoreBtn.alpha = 0.5;
	[self addSubview:_restoreBtn];
	
	_completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(2*btnWidth+2*interval, self.frame.size.height/2, btnWidth, self.frame.size.height/2)];
	[_completeBtn setImage:[UIImage imageNamed:@"snap_complete" ] forState:UIControlStateNormal];
	[_completeBtn addTarget:self action:@selector(completeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_completeBtn];
	
}
-(void)rorateBtnClick:(UIButton *)sender{
	if ([self.delegate respondsToSelector:@selector(snapBottomView:didClickRorateBtn:)]) {
		[self.delegate snapBottomView:self didClickRorateBtn:sender];
	}
}
-(void)closeBtnClick:(UIButton*)sender{
	if ([self.delegate respondsToSelector:@selector(snapBottomView:didClickCloseBtn:)]) {
		[self.delegate snapBottomView:self didClickCloseBtn:sender];
	}
}

-(void)restoreBtnClick:(UIButton*)sender{
	if ([self.delegate respondsToSelector:@selector(snapBottomView:didClickCloseBtn:)]) {
		[self.delegate snapBottomView:self didClickRestoreBtn:sender];
	}
}


-(void)completeBtnClick:(UIButton*)sender{
	if ([self.delegate respondsToSelector:@selector(snapBottomView:didClickCloseBtn:)]) {
		[self.delegate snapBottomView:self didClickCompleteBtn:sender];
	}
}

@end
