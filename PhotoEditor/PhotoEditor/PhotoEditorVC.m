//
//  PhotoEditorVC.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/20.
//

#import "PhotoEditorVC.h"
#import "MosaicView.h"
#import "SnapBottomView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromAlphaAndRGB(alphaValue,rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]
#define FUll_VIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define FUll_VIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface PhotoEditorVC ()<MosaicDelegate>{
	UIView *topBGView;
	
	UIView *bottomBGView;
	UIView *separatorLine;
	UIButton *mosaicBtn;
	UIButton *undoBtn;
	UIButton *mosaic_1_btn;
	UIButton *mosaic_2_btn;
	UIView *mosaicControlView;
	
	UIButton *snapBtn;
	EditReceiver* receiver;
	EditInvoker* invoker;
	
}
@property (strong, nonatomic) SnapGridLayer *gridLayer;
@property (strong, nonatomic) SnapCornerView *leftTopView;
@property (strong, nonatomic) SnapCornerView *rightTopView;
@property (strong, nonatomic) SnapCornerView *leftBottomView;
@property (strong, nonatomic) SnapCornerView *rightBottomView;
@property (nonatomic,strong) SnapBottomView *snapBottomView;
@property (strong, nonatomic) UIPanGestureRecognizer *imagePanGesture;
@property (assign, nonatomic) CGRect clippingRect;
@property (strong, nonatomic) HXEditRatio *clippingRatio;
@property (nonatomic,strong) NSMutableArray <PathModel*>*mosaicPathArray;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic,strong) UIImage *snapOriginImage;
//保存截图后的图片
@property (strong, nonatomic) UIImage *tempEditedImage;
//@property (strong, nonatomic) UIImage *tempSnapImage;

//马赛克功能图层
@property (nonatomic,strong)MosaicView *mosaicView;
@end

@implementation PhotoEditorVC

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.view.backgroundColor = UIColorFromRGB(0x161616);
	receiver = [[EditReceiver alloc] init];
	invoker = [[EditInvoker alloc] init:receiver];
	self.snapBottomView.hidden = YES;
	[self.view addSubview:self.snapBottomView];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark =============== 主界面功能，加载数据源，UI ===============
-(void)setModel:(EditorModel *)model{
	if (_model != model) {
		_model = model;
		UIImage *currentImage;
		if(model.snappedImage){
			currentImage = model.snappedImage;
		}else{
			currentImage = model.orgImage;
		}
		self.imageWidth = currentImage.size.width;
		self.imageHeight = currentImage.size.height;
		
		CGFloat width = self.view.frame.size.width;
		CGFloat height = self.view.frame.size.height;
		CGFloat imgWidth = self.imageWidth;
		CGFloat imgHeight = self.imageHeight;
		CGFloat w = FUll_VIEW_WIDTH;
		CGFloat h = FUll_VIEW_HEIGHT;	
		if (imgWidth>=width || imgHeight>=height) {
			if (imgWidth > width) {
				imgHeight = width / imgWidth * imgHeight;
			}
			if (imgHeight > height) {
				w = height / self.imageHeight * imgWidth;
				h = height;
			}else {
				if (imgWidth > width) {
					w = width;
				}else {
					w = imgWidth;
				}
				h = imgHeight;
			}
		}else{
			imgHeight = width / imgWidth * imgHeight;//放大imgheight
			if (imgHeight > height) {//如果放大之后超出屏幕
				w = height / self.imageHeight * imgWidth;
				h = height;
			}else {
				w = width;
				h = imgHeight;
			}
		}
		
		self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-w)/2, (FUll_VIEW_HEIGHT-h)/2, w, h)];
		_imageView.clipsToBounds = YES;
		[_imageView.layer addSublayer:self.gridLayer];
		_imageView.userInteractionEnabled = YES;
		[self.view addSubview:self.imageView];
		self.imageView.image = currentImage;
		[self addTopView];
		[self addBottomView];
		
		self.imageWidth = self.imageView.image.size.width;
		self.imageHeight = self.imageView.image.size.height;
		[self.imageView addSubview:self.mosaicView];
		if (self.model.mosaicPathArray.count) {
			self.mosaicPathArray = [self.model.mosaicPathArray mutableCopy];
			for (PathModel *model in self.mosaicPathArray) {
				[self.mosaicView.layer addSublayer:model.imageLayer];
				[self.mosaicView.layer addSublayer:model.shapeLayer];
				model.imageLayer.mask = model.shapeLayer;
			}
		}
	}
}

-(void)addTopView{
	topBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, 115)];
	CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
	topGradientLayer.frame = CGRectMake(0, 0, topBGView.frame.size.width, topBGView.frame.size.height);  // 设置显示的frame
	topGradientLayer.colors = @[(id)UIColorFromAlphaAndRGB(0.41, 0x5C5C5C).CGColor,(id)UIColorFromAlphaAndRGB(0, 0x313131).CGColor];
	//	（0，0）为左上角、（1，0）为右上角、
	//  （0，1）为左下角、（1，1）为右下角，
	//默认是值是    （0.5，0）
	//			和（0.5，1）
	//	topGradientLayer.locations = @[@0.0, @0.2];
	topGradientLayer.startPoint = CGPointMake(0.5, 0.);
	topGradientLayer.endPoint = CGPointMake(0.5, 1.);
	topGradientLayer.masksToBounds = YES;
	[topBGView.layer addSublayer:topGradientLayer];
	[self.view addSubview:topBGView];
	
	UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17, 42, 32.5)];
	cancelButton.backgroundColor = [UIColor clearColor];
	[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
	cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.];
	[cancelButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[topBGView addSubview:cancelButton];
	
	UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH-65, 17, 50, 30)];
	completeBtn.backgroundColor = UIColorFromRGB(0x91C700);
	[completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[completeBtn setTitle:@"完成" forState:UIControlStateNormal];
	[completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	completeBtn.layer.masksToBounds = YES;
	completeBtn.layer.cornerRadius = 5;
	[topBGView addSubview:completeBtn];
}

-(void)addBottomView{
	bottomBGView = [[UIView alloc]initWithFrame:CGRectMake(0, FUll_VIEW_HEIGHT-215, FUll_VIEW_WIDTH, 215)];
	CAGradientLayer *bottomGradientLayer = [CAGradientLayer layer];
	bottomGradientLayer.frame = CGRectMake(0, 0, bottomBGView.frame.size.width, bottomBGView.frame.size.height);
	bottomGradientLayer.colors = @[(id)UIColorFromAlphaAndRGB(0., 0x313131).CGColor,(id)UIColorFromAlphaAndRGB(0.57, 0x5C5C5C).CGColor];
	bottomGradientLayer.startPoint = CGPointMake(0.5, 0.);
	bottomGradientLayer.endPoint = CGPointMake(0.5, 1.);
	bottomGradientLayer.masksToBounds = YES;
	[bottomBGView.layer addSublayer:bottomGradientLayer];
	[self.view addSubview:bottomBGView];
	
	separatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 215-67, FUll_VIEW_WIDTH, 0.5)];
	separatorLine.backgroundColor = UIColorFromRGB(0xC3C3C3);
	separatorLine.hidden = YES;
	[bottomBGView addSubview:separatorLine];
	
	mosaicBtn = [[UIButton alloc] initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2-44.5-27, 215-25.5-27, 27, 27)];
	mosaicBtn.backgroundColor = [UIColor clearColor];
	;
	[mosaicBtn setImage:[UIImage imageNamed:@"mosaic" ] forState:UIControlStateNormal];
	[mosaicBtn setImage:[UIImage imageNamed:@"mosaic_h" ] forState:UIControlStateSelected];
	[mosaicBtn addTarget:self action:@selector(switchMosaicModel) forControlEvents:UIControlEventTouchUpInside];
	[bottomBGView addSubview:mosaicBtn];
	
	{	//马赛克控制面板
		mosaicControlView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, FUll_VIEW_WIDTH, 27)];
		mosaicControlView.backgroundColor = [UIColor clearColor];
		CGFloat interval = (FUll_VIEW_WIDTH-27*3)/4;
		
		mosaic_1_btn = [[UIButton alloc]initWithFrame:CGRectMake(interval, 0, 27, 27)];
		mosaic_1_btn.backgroundColor = [UIColor clearColor];
		[mosaic_1_btn setImage:[UIImage imageNamed:@"mosaic_1" ] forState:UIControlStateNormal];
		[mosaic_1_btn setImage:[UIImage imageNamed:@"mosaic_1_h" ] forState:UIControlStateSelected];
		[mosaic_1_btn addTarget:self action:@selector(enterFirstMosaic) forControlEvents:UIControlEventTouchUpInside];
		mosaic_1_btn.selected = YES;
		[mosaicControlView addSubview:mosaic_1_btn];
		
		mosaic_2_btn = [[UIButton alloc]initWithFrame:CGRectMake(2*interval+27, 0, 27, 27)];
		mosaic_2_btn.backgroundColor = [UIColor clearColor];
		[mosaic_2_btn setImage:[UIImage imageNamed:@"mosaic_2" ] forState:UIControlStateNormal];
		[mosaic_2_btn setImage:[UIImage imageNamed:@"mosaic_2_h" ] forState:UIControlStateSelected];
		[mosaic_2_btn addTarget:self action:@selector(enterSecondMosaic) forControlEvents:UIControlEventTouchUpInside];
		[mosaicControlView addSubview:mosaic_2_btn];
		
		undoBtn = [[UIButton alloc]initWithFrame:CGRectMake(3*interval+27*2, 0, 27, 27)];
		undoBtn.backgroundColor = [UIColor clearColor];
		[undoBtn setImage:[UIImage imageNamed:@"undo" ] forState:UIControlStateNormal];
		[undoBtn addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
		[mosaicControlView addSubview:undoBtn];
		
		mosaicControlView.hidden = YES;
		[bottomBGView addSubview:mosaicControlView];
		
	}
	
	
	snapBtn =  [[UIButton alloc] initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2+44.5, 215-25.5-27, 27, 27)];
	snapBtn.backgroundColor = [UIColor clearColor];
	[snapBtn setImage:[UIImage imageNamed:@"snap" ] forState:UIControlStateNormal];
	[snapBtn setImage:[UIImage imageNamed:@"snap_h" ] forState:UIControlStateSelected];
	[bottomBGView addSubview:snapBtn];
	[snapBtn addTarget:self action:@selector(switchSnapModel) forControlEvents:UIControlEventTouchUpInside];
	
	
}

//生成新图片,并放进数组,在预览和小图显示,不放进相册，也不用作本页面显示，完成选择的时候放进相册
-(void)completeBtnClick{
	if (receiver.mosaicPathArray.count>0) {
		[self.mosaicPathArray addObjectsFromArray:receiver.mosaicPathArray];
	}
	if (self.tempEditedImage) {
		self.model.snappedImage = self.tempEditedImage;
	}
	UIImage *deadledImage;
	if (invoker.commands.count>0) {
		//如果有编辑，一定生成新图片
		UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[self.imageView.layer renderInContext:context];
		deadledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		self.model.editedImage = deadledImage;
		[self.model.mosaicPathArray addObjectsFromArray:self.mosaicPathArray];
	}else{
		//如果未编辑，
		if (self.mosaicPathArray.count!=self.model.mosaicPathArray.count) {
			//有撤销
			UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
			CGContextRef context = UIGraphicsGetCurrentContext();
			[self.imageView.layer renderInContext:context];
			deadledImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			self.model.editedImage = deadledImage;
		}else{
			//未编辑也无撤销
		}
	}
	if (self.completeBlock) {
		UIImage *resultImage;
		if (deadledImage){
			resultImage = deadledImage;
		}else if (self.tempEditedImage) {
			resultImage = self.tempEditedImage;
		}
		self.completeBlock(self.model);
	}
	[self dismissViewControllerAnimated:NO completion:nil];
}
-(void)cancelBtnClick{
	[self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark =============== Snap 截图 ===============
-(void)switchSnapModel{
	[self switchSnapModel:YES complete:nil];
}
-(void)switchSnapModel:(BOOL)animated complete:(void(^)(BOOL switchIn))completeBlock{
	snapBtn.selected = !snapBtn.selected;
	if (snapBtn.selected) {
		//进入
		if (mosaicBtn.selected) [self switchMosaicModel];
		
		if (invoker.commands.count>0) {
			//如果有编辑，一定生成新图片
			UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
			CGContextRef context = UIGraphicsGetCurrentContext();
			[self.imageView.layer renderInContext:context];
			UIImage *deadledImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			self.snapOriginImage = deadledImage;
			self.imageView.image = self.snapOriginImage;
		}else{
			//如果未编辑，
			if (self.mosaicPathArray.count!=self.model.mosaicPathArray.count) {
				//有撤销
				UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
				CGContextRef context = UIGraphicsGetCurrentContext();
				[self.imageView.layer renderInContext:context];
				UIImage *deadledImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				self.snapOriginImage = deadledImage;
				self.imageView.image = deadledImage;
			}else{
				//未编辑也无撤销
				if(self.tempEditedImage){
					self.snapOriginImage = self.tempEditedImage;
				}else if(self.model.editedImage){
					self.snapOriginImage = self.model.editedImage;
				}else if(self.model.snappedImage){
					self.snapOriginImage = self.model.snappedImage;
				}else {
					self.snapOriginImage = self.model.orgImage;
				}
				self.imageView.image = self.snapOriginImage ;
			}
		}
		self.snapBottomView.hidden = NO;
		self.snapBottomView.restoreBtn.enabled = NO;
		self.snapBottomView.restoreBtn.alpha = 0.5;
		self.mosaicView.hidden = YES;
		topBGView.hidden = YES;
		bottomBGView.hidden = YES;
		self.imagePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
		[_imageView addGestureRecognizer:self.imagePanGesture];
		[self.view addSubview:self.leftTopView];
		[self.view addSubview:self.leftBottomView];
		[self.view addSubview:self.rightTopView];
		[self.view addSubview:self.rightBottomView];
		self.gridLayer.hidden = NO;
		self.leftTopView.hidden = NO;
		self.leftBottomView.hidden = NO;
		self.rightTopView.hidden = NO;
		self.rightBottomView.hidden = NO;
		[self changeSubviewFrame:animated complete:^{
			if (completeBlock) {
				completeBlock(YES);
			}
		}];
	}else{
		//		退出截图模式
		self.snapBottomView.hidden = YES;
		topBGView.hidden = NO;
		bottomBGView.hidden = NO;
		[_imageView removeGestureRecognizer:self.imagePanGesture];
		
		[self restoreSubviewFrame:animated complete:^{
			if (completeBlock) {
				completeBlock(NO);
			}
		}];
	}
}
- (void)setClippingRect:(CGRect)clippingRect {
	_clippingRect = clippingRect;
	
	self.leftTopView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:_imageView];
	self.leftBottomView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
	self.rightTopView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:_imageView];
	self.rightBottomView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
	
	self.gridLayer.clippingRect = clippingRect;
	[self.gridLayer setNeedsDisplay];
}

- (void)panCircleView:(UIPanGestureRecognizer*)sender {
	CGPoint point = [sender locationInView:self.imageView];
	CGPoint dp = [sender translationInView:self.imageView];
	
	CGRect rct = self.clippingRect;
	
	const CGFloat W = self.imageView.frame.size.width;
	const CGFloat H = self.imageView.frame.size.height;
	CGFloat minX = 0;
	CGFloat minY = 0;
	CGFloat maxX = W;
	CGFloat maxY = H;
	
	CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
	//	CGFloat ratio = 0 ;
	switch (sender.view.tag) {
		case 0: // upper left
		{
//			maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
//			maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
			maxX = MAX((rct.origin.x + rct.size.width)  - 64, 64);
			maxY = MAX((rct.origin.y + rct.size.height) - 64, 64);
			if (ratio!=0) {
				CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
				CGFloat x0 = -y0 / ratio;
				minX = MAX(x0, 0);
				minY = MAX(y0, 0);
				
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				
				if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
				else{ point.y = point.x * ratio + y0; }
			} else {
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				if (rct.origin.x+rct.size.width-point.x<64) {
					point.x = rct.origin.x+rct.size.width-64;
				}
				if (rct.origin.y+rct.size.height-point.y<64) {
					point.y = rct.origin.y+rct.size.height-64;
				}
			}
			
			rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
			rct.size.height = rct.size.height - (point.y - rct.origin.y);
			rct.origin.x = point.x;
			rct.origin.y = point.y;
			break;
		}
		case 1: // lower left
		{
//			maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
//			minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
			maxX = MAX((rct.origin.x + rct.size.width)  - 64, 64);
			minY = MAX(rct.origin.y + 64, 64);

			if (ratio!=0) {
				CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
				CGFloat xh = (H - y0) / ratio;
				minX = MAX(xh, 0);
				maxY = MIN(y0, H);
				
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				
				if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
				else{ point.y = point.x * ratio + y0; }
			} else {
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				if (rct.origin.x+rct.size.width-point.x<64) {
					point.x = rct.origin.x+rct.size.width-64;
				}
				if (rct.origin.y+point.y<64) {
					point.y = rct.origin.y+64;
				}
			}
			
			rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
			rct.size.height = point.y - rct.origin.y;
			rct.origin.x = point.x;
			break;
		}
		case 2: // upper right
		{
			minX = MAX(rct.origin.x + 64, 64);
			maxY = MAX((rct.origin.y + rct.size.height) - 64, 64);
			
			if (ratio!=0) {
				CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
				CGFloat yw = ratio * W + y0;
				CGFloat x0 = -y0 / ratio;
				maxX = MIN(x0, W);
				minY = MAX(yw, 0);
				
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				
				if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
				else{ point.y = point.x * ratio + y0; }
			} else {
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				if (rct.origin.x+point.x<64) {
					point.x = rct.origin.x+64;
				}
				if (rct.origin.y+rct.size.height-point.y<64) {
					point.y = rct.origin.y+rct.size.height-64;
				}
			}
			
			rct.size.width  = point.x - rct.origin.x;
			rct.size.height = rct.size.height - (point.y - rct.origin.y);
			rct.origin.y = point.y;
			break;
		}
		case 3: // lower right
		{
			minX = MAX(rct.origin.x + 64, 64);
			minY = MAX(rct.origin.y + 64, 64);
			
			if (ratio!=0) {
				CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
				CGFloat yw = ratio * W + y0;
				CGFloat xh = (H - y0) / ratio;
				maxX = MIN(xh, W);
				maxY = MIN(yw, H);
				
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				
				if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
				else{ point.y = point.x * ratio + y0; }
			} else {
				point.x = MAX(minX, MIN(point.x, maxX));
				point.y = MAX(minY, MIN(point.y, maxY));
				if (rct.origin.x+point.x<64) {
					point.x = rct.origin.x+64;
				}
				if (rct.origin.y+point.y<64) {
					point.y = rct.origin.y+64;
				}
			}
			
			rct.size.width  = point.x - rct.origin.x;
			rct.size.height = point.y - rct.origin.y;
			break;
		}
		default:
			break;
	}
	self.clippingRect = rct;
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
		[self startTimer];
	}else {
		[self stopTimer];
	}
}
- (void)panGridView:(UIPanGestureRecognizer*)sender {
	static BOOL dragging = NO;
	static CGRect initialRect;
	
	if (sender.state==UIGestureRecognizerStateBegan) {
		CGPoint point = [sender locationInView:self.imageView];
		dragging = CGRectContainsPoint(self.clippingRect, point);
		initialRect = self.clippingRect;
	} else if(dragging) {
		CGPoint point = [sender translationInView:self.imageView];
		CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.imageView.frame.size.width-initialRect.size.width);
		CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.imageView.frame.size.height-initialRect.size.height);
		
		CGRect rct = self.clippingRect;
		rct.origin.x = left;
		rct.origin.y = top;
		self.clippingRect = rct;
	}
	
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
		[self startTimer];
	}else {
		[self stopTimer];
	}
}

- (void)changeClipImageView {
	if (CGSizeEqualToSize(self.clippingRect.size, self.imageView.frame.size)) {
		[self stopTimer];
		return;
	}
	UIImage *image = [self clipImage];
	self.imageView.image = image;
	CGFloat imgW = self.rightTopView.center.x - self.leftTopView.center.x;
	CGFloat imgH = self.leftBottomView.center.y - self.leftTopView.center.y;
	self.imageView.frame = CGRectMake(self.leftTopView.center.x, self.leftTopView.center.y, imgW, imgH);
	self.gridLayer.frame = self.imageView.bounds;
	self.imageWidth = image.size.width;
	self.imageHeight = image.size.height;
	[self changeSubviewFrame:YES complete:^{
		[self stopTimer];
	}];
	
}
- (void)changeSubviewFrame:(BOOL)animated complete:(void(^)(void))compeletBlock{
	CGFloat width = self.view.frame.size.width - 40;
	CGFloat imageY = 30;
	
	CGFloat height = self.view.frame.size.height - 100 - imageY - 50;
	CGFloat imgWidth = self.imageWidth;
	CGFloat imgHeight = self.imageHeight;
	CGFloat w;
	CGFloat h;
	if (imgWidth>=width || imgHeight>=height) {
		if (imgWidth > width) {
			imgHeight = width / imgWidth * imgHeight;
		}
		if (imgHeight > height) {
			w = height / self.imageHeight * imgWidth;
			h = height;
		}else {
			if (imgWidth > width) {
				w = width;
			}else {
				w = imgWidth;
			}
			h = imgHeight;
		}
	}else{
		imgHeight = width / imgWidth * imgHeight;//放大imgheight
		if (imgHeight > height) {//如果放大之后超出屏幕
			w = height / self.imageHeight * imgWidth;
			h = height;
		}else {
			w = width;
			h = imgHeight;
		}
	}
	
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			self.imageView.frame = CGRectMake(0, imageY, w, h);
			self.imageView.center = CGPointMake(self.view.frame.size.width / 2, imageY + height / 2);
			self.gridLayer.frame = self.imageView.bounds;
		}completion:^(BOOL finished) {
			if (compeletBlock) compeletBlock();
		}];
	}else {
		self.imageView.frame = CGRectMake(0, imageY, w, h);
		self.imageView.center = CGPointMake(self.view.frame.size.width / 2, imageY + height / 2);
		self.gridLayer.frame = self.imageView.bounds;
		if (compeletBlock) compeletBlock();
	}
	[self clippingRatioDidChange:animated];
}
- (void)restoreSubviewFrame:(BOOL)animated complete:(void(^)(void))compeletBlock{
	self.imageWidth = self.imageView.image.size.width;
	self.imageHeight = self.imageView.image.size.height;
	
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	CGFloat imgWidth = self.imageWidth;
	CGFloat imgHeight = self.imageHeight;
	CGFloat w;
	CGFloat h;
	if (imgWidth>=width || imgHeight>=height) {
		if (imgWidth > width) {
			imgHeight = width / imgWidth * imgHeight;
		}
		if (imgHeight > height) {
			w = height / self.imageHeight * imgWidth;
			h = height;
		}else {
			if (imgWidth > width) {
				w = width;
			}else {
				w = imgWidth;
			}
			h = imgHeight;
		}
	}else{
		imgHeight = width / imgWidth * imgHeight;//放大imgheight
		if (imgHeight > height) {//如果放大之后超出屏幕
			w = height / self.imageHeight * imgWidth;
			h = height;
		}else {
			w = width;
			h = imgHeight;
		}
	}
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			self.imageView.frame = CGRectMake((FUll_VIEW_WIDTH-w)/2, (FUll_VIEW_HEIGHT-h)/2, w, h);
			//			self.imageView.center = CGPointMake(self.view.frameWidth / 2, imageY + height / 2);
			self.gridLayer.hidden = YES;
			self.leftTopView.hidden = YES;
			self.leftBottomView.hidden = YES;
			self.rightTopView.hidden = YES;
			self.rightBottomView.hidden = YES;
			self.gridLayer.frame = self.imageView.bounds;
		}completion:^(BOOL finished) {
			self.mosaicView.hidden = NO;
			if (compeletBlock) {
				compeletBlock();
			}
		}];
	}else {
		self.imageView.frame = CGRectMake((FUll_VIEW_WIDTH-w)/2, (FUll_VIEW_HEIGHT-h)/2, w, h);
		//			self.imageView.center = CGPointMake(self.view.frameWidth / 2, imageY + height / 2);
		self.gridLayer.hidden = YES;
		self.leftTopView.hidden = YES;
		self.leftBottomView.hidden = YES;
		self.rightTopView.hidden = YES;
		self.rightBottomView.hidden = YES;
		self.mosaicView.hidden = NO;
		if (compeletBlock) {
			compeletBlock();
		}
	}
}
- (void)clippingRatioDidChange:(BOOL)animated {
	CGRect rect = self.imageView.bounds;
	if (self.clippingRatio) {
		CGFloat H = rect.size.width * self.clippingRatio.ratio;
		if (H<=rect.size.height) {
			rect.size.height = H;
		} else {
			rect.size.width *= rect.size.height / H;
		}
		rect.origin.x = (self.imageView.bounds.size.width - rect.size.width) / 2;
		rect.origin.y = (self.imageView.bounds.size.height - rect.size.height) / 2;
	}
	[self setClippingRect:rect animated:animated];
}
- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated {
	if (animated) {
		[UIView animateWithDuration:0.2 animations:^{
			self.leftTopView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self.imageView];
			self.leftBottomView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self.imageView];
			self.rightTopView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self.imageView];
			self.rightBottomView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self.imageView];
		} completion:^(BOOL finished) {
			[self changeClipImageView];
		}];
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
		animation.duration = 0.2;
		animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
		animation.toValue = [NSValue valueWithCGRect:clippingRect];
		[self.gridLayer addAnimation:animation forKey:nil];
		
		self.gridLayer.clippingRect = clippingRect;
		self.clippingRect = clippingRect;
		[self.gridLayer setNeedsDisplay];
	} else {
		self.clippingRect = clippingRect;
	}
}
- (UIImage *)clipImage {
	CGFloat zoomScale = self.imageView.bounds.size.width / self.imageView.image.size.width;
	CGFloat widthScale = self.imageView.image.size.width / self.imageView.frame.size.width;
	CGFloat heightScale = self.imageView.image.size.height / self.imageView.frame.size.height;
	
	CGRect rct = self.clippingRect;
	rct.size.width  *= widthScale;
	rct.size.height *= heightScale;
	rct.origin.x    /= zoomScale;
	rct.origin.y    /= zoomScale;
	
	CGPoint origin = CGPointMake(-rct.origin.x, -rct.origin.y);
	UIImage *img = nil;
	
	UIGraphicsBeginImageContextWithOptions(rct.size, NO, self.imageView.image.scale);
	[self.imageView.image drawAtPoint:origin];
	img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}
- (void)setClippingRatio:(HXEditRatio *)clippingRatio {
	if(clippingRatio != self.clippingRatio){
		_clippingRatio = clippingRatio;
		[self clippingRatioDidChange:YES];
	}
}

- (void)startTimer {
	self.snapBottomView.userInteractionEnabled = NO;
	if (!self.timer) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeClipImageView) userInfo:nil repeats:NO];
	}
}

- (void)stopTimer {
	self.snapBottomView.userInteractionEnabled = YES;
	if (!self.model.orgImage || self.imageView.image == self.snapOriginImage) {
		self.snapBottomView.restoreBtn.enabled = NO;
		self.snapBottomView.restoreBtn.alpha = 0.5;
	}else{
		self.snapBottomView.restoreBtn.enabled = YES;
		self.snapBottomView.restoreBtn.alpha = 1.;
	}
	if (self.timer) {
		[self.timer invalidate];
		self.timer = nil;
	}
}
#pragma mark =============== SnapBottomViewDelegate ===============
//旋转
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickRorateBtn:(UIButton*)btn{
	self.clippingRatio = nil;
	
	self.imageView.image = [self rotationImage:self.imageView.image orientation:UIImageOrientationLeft];
	self.imageWidth = self.imageView.image.size.width;
	self.imageHeight = self.imageView.image.size.height;
	[self changeSubviewFrame:YES complete:^{
		[self stopTimer];
	}];
}

//关闭
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickCloseBtn:(UIButton*)btn{
	[self stopTimer];
	self.clippingRatio = nil;
	self.imageView.image = self.snapOriginImage;
	self.imageWidth = self.imageView.image.size.width;
	self.imageHeight = self.imageView.image.size.height;
	[self changeSubviewFrame:NO complete:nil];
	
	[self switchSnapModel:YES complete:^(BOOL switchIn) {
		UIImage *currentImage;
		if(self.tempEditedImage){
			currentImage = self.tempEditedImage;
		}else if(self.model.snappedImage){
			currentImage = self.model.snappedImage;
		}else{
			currentImage = self.model.orgImage;
		}
		self.imageView.image = currentImage;

	}];
}

//还原
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickRestoreBtn:(UIButton*)btn{
	btn.enabled = NO;
	if (CGSizeEqualToSize(self.clippingRect.size, self.model.orgImage.size)) {
		[self stopTimer];
		return;
	}
	if (!self.model.orgImage || self.imageView.image == self.snapOriginImage) {
		[self stopTimer];
		return;
	}
	self.snapBottomView.restoreBtn.enabled = NO;
	self.snapBottomView.restoreBtn.alpha = 0.5;
	self.clippingRatio = nil;
	self.imageView.image = self.snapOriginImage;
	self.imageWidth = self.imageView.image.size.width;
	self.imageHeight = self.imageView.image.size.height;
	[self changeSubviewFrame:YES complete:^{
		[self stopTimer];
	}];
}
//完成
-(void)snapBottomView:(SnapBottomView*)snapBottomView didClickCompleteBtn:(UIButton*)btn{
	[self stopTimer];
	if (!self.model.orgImage || self.imageView.image == self.snapOriginImage) {
		//原图放回去

		[self switchSnapModel:YES complete:^(BOOL switchIn) {
			if(self.tempEditedImage){
				self.imageView.image = self.tempEditedImage;
			}else if(self.model.snappedImage){
				self.imageView.image = self.model.snappedImage;
			}else{
				self.imageView.image = self.model.orgImage;
			}
		}];
	}else{
		self.tempEditedImage = self.imageView.image;
		[invoker undoAll];
		for (PathModel *model in self.mosaicPathArray) {
			[model.shapeLayer removeFromSuperlayer];
			[model.imageLayer removeFromSuperlayer];
		}
		
		[self.model.mosaicPathArray removeAllObjects];
		[self.mosaicPathArray removeAllObjects];
		__weak typeof(self) weakSelf = self;
		[self switchSnapModel:YES complete:^(BOOL switchIn) {
//			strongify(self);
			if (!switchIn) {
				weakSelf.mosaicView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
				[weakSelf.mosaicView.mosaicImages removeAllObjects];
				[weakSelf.mosaicView setMosaciPixValue:@(50) forImage:self.imageView.image];
				[weakSelf.mosaicView setMosaciPixValue:@(20) forImage:self.imageView.image];
			}
		}];

	}
}

- (UIImage *)rotationImage:(UIImage *)orgImage orientation:(UIImageOrientation)orient {
	CGRect bnds = CGRectZero;
	UIImage* copy = nil;
	CGContextRef ctxt = nil;
	CGImageRef imag = orgImage.CGImage;
	CGRect rect = CGRectZero;
	CGAffineTransform tran = CGAffineTransformIdentity;
	
	rect.size.width = CGImageGetWidth(imag);
	rect.size.height = CGImageGetHeight(imag);
	
	bnds = rect;
	
	switch (orient)
	{
		case UIImageOrientationUp:
			return orgImage;
			
		case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
		case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
		default:
			return orgImage;
	}
	
	UIGraphicsBeginImageContext(bnds.size);
	ctxt = UIGraphicsGetCurrentContext();
	
	switch (orient)
	{
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
		default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
	}
	
	CGContextConcatCTM(ctxt, tran);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
	
	copy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return copy;
}
/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect) {
	CGFloat swap = rect.size.width;
	
	rect.size.width = rect.size.height;
	rect.size.height = swap;
	
	return rect;
}
#pragma mark =============== Snap 懒加载 ===============
-(NSMutableArray<PathModel *> *)mosaicPathArray{
	if (!_mosaicPathArray) {
		_mosaicPathArray = [NSMutableArray array];
	}
	return _mosaicPathArray;
}
-(SnapBottomView *)snapBottomView{
	if (!_snapBottomView) {
		_snapBottomView = [[SnapBottomView alloc]initWithFrame:CGRectMake(0, FUll_VIEW_HEIGHT-67*2, FUll_VIEW_WIDTH, 67*2)];
		_snapBottomView.delegate = (id)self;
		[_snapBottomView setNeedsDisplay];
	}
	return _snapBottomView;
}
- (SnapGridLayer *)gridLayer {
	if (!_gridLayer) {
		_gridLayer = [[SnapGridLayer alloc] init];
		_gridLayer.bgColor   = [[UIColor blackColor] colorWithAlphaComponent:.5];
		_gridLayer.gridColor = [UIColor whiteColor];
	}
	return _gridLayer;
}
- (SnapCornerView *)leftTopView {
	if (!_leftTopView) {
		_leftTopView = [self editCornerViewWithTag:0];
	}
	return _leftTopView;
}
- (SnapCornerView *)leftBottomView {
	if (!_leftBottomView) {
		_leftBottomView = [self editCornerViewWithTag:1];
	}
	return _leftBottomView;
}
- (SnapCornerView *)rightTopView {
	if (!_rightTopView) {
		_rightTopView = [self editCornerViewWithTag:2];
	}
	return _rightTopView;
}
- (SnapCornerView *)rightBottomView {
	if (!_rightBottomView) {
		_rightBottomView = [self editCornerViewWithTag:3];
	}
	return _rightBottomView;
}
- (SnapCornerView *)editCornerViewWithTag:(NSInteger)tag {
	SnapCornerView *view = [[SnapCornerView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	view.backgroundColor = [UIColor clearColor];
	view.bgColor = [UIColor whiteColor];
	view.tag = tag;
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
	[view addGestureRecognizer:panGesture];
	[panGesture requireGestureRecognizerToFail:self.imagePanGesture];
	return view;
}
#pragma mark =============== 马赛克 Mossaic ===============
-(void)switchMosaicModel{
	mosaicBtn.selected = !mosaicBtn.selected;
	separatorLine.hidden = !separatorLine.hidden;
	if (mosaicBtn.selected) {
		//进入
		if (snapBtn.selected)[self switchSnapModel:YES complete:nil];
		mosaicControlView.hidden = NO;
		if (mosaic_1_btn.selected) {
			[self enterFirstMosaic];
		}else{
			[self enterSecondMosaic];
		}
		if (invoker.commands.count||self.mosaicPathArray.count) {
			undoBtn.enabled = YES;
		}else{
			undoBtn.enabled = NO;
		}
	}else{
		//退出
		mosaicControlView.hidden = YES;
		self.mosaicView.userInteractionEnabled = NO;
	}
}

-(void)enterFirstMosaic{
	mosaic_1_btn.selected = YES;
	self.mosaicView.userInteractionEnabled = YES;
	self.mosaicView.mosaicIndex = 0;
	mosaic_2_btn.selected = NO;
}

-(void)enterSecondMosaic{
	mosaic_1_btn.selected = NO;
	self.mosaicView.userInteractionEnabled = YES;
	self.mosaicView.mosaicIndex = 1;
	mosaic_2_btn.selected = YES;
}


-(void)undo{
	if (invoker.commands.count) {
		[invoker undo];
	}else{
		if (self.mosaicPathArray.count) {
			[self.mosaicPathArray.lastObject.shapeLayer removeFromSuperlayer];
			[self.mosaicPathArray.lastObject.imageLayer removeFromSuperlayer];
			[self.mosaicPathArray removeLastObject];
		}
	}
	if (invoker.commands.count||self.mosaicPathArray.count) {
		undoBtn.enabled = YES;
	}else{
		undoBtn.enabled = NO;
	}
}


#pragma mark =============== MosaicDelegate ===============
-(void)mosaicView:(MosaicView*)mosaicView drawBeginOnLayer:(nonnull CALayer *)imageLayer shape:(nonnull CAShapeLayer *)shapeLeyer{
//		MosaicPath *mosaicPath = [[MosaicPath alloc]init];
//		mosaicPath.startPoint = CGPointMake(point.x, point.y);
	
	PathModel *pathModel = [[PathModel alloc]init];
	pathModel.shapeLayer = shapeLeyer;
	pathModel.imageLayer = imageLayer;
	[invoker increasePathModel:pathModel];
	undoBtn.enabled = YES;
	topBGView.hidden = YES;
	bottomBGView.hidden = YES;
}

-(void)mosaicView:(MosaicView*)mosaicView drawMoveOnPath:(nonnull CGMutablePathRef)path{
	receiver.mosaicPathArray.lastObject.shapeLayer.path = path;
}

-(void)mosaicView:(MosaicView*)mosaicView drawEnd:(CGPoint )point{
	topBGView.hidden = NO;
	bottomBGView.hidden = NO;
}

#pragma mark =============== Mosaic 懒加载 ===============
-(MosaicView *)mosaicView{
	if (!_mosaicView) {
		_mosaicView = [[MosaicView alloc]initWithFrame:self.imageView.bounds];
		_mosaicView.delegate = (id)self;
		_mosaicView.model = self.model;
		[_mosaicView setMosaciPixValue:@(50) forImage:self.imageView.image];
		[_mosaicView setMosaciPixValue:@(20) forImage:self.imageView.image];
		_mosaicView.userInteractionEnabled = NO;
	}
	return _mosaicView;
}

@end


@implementation SnapRatio {
	CGFloat _longSide;
	CGFloat _shortSide;
}
- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2 {
	self = [super init];
	if(self){
		_longSide  = MAX(fabs(value1), fabs(value2));
		_shortSide = MIN(fabs(value1), fabs(value2));
	}
	return self;
}
- (NSString*)description {
	NSString *format = (self.titleFormat) ? self.titleFormat : @"%g : %g";
	
	if(self.isLandscape){
		return [NSString stringWithFormat:format, _longSide, _shortSide];
	}
	return [NSString stringWithFormat:format, _shortSide, _longSide];
}
- (CGFloat)ratio {
	if(_longSide==0 || _shortSide==0){
		return 0;
	}
	if(self.isLandscape){
		return _shortSide / (CGFloat)_longSide;
	}
	return _longSide / (CGFloat)_shortSide;
}

@end
@implementation HXEditRatio {
	CGFloat _longSide;
	CGFloat _shortSide;
}
- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2 {
	self = [super init];
	if(self){
		_longSide  = MAX(fabs(value1), fabs(value2));
		_shortSide = MIN(fabs(value1), fabs(value2));
	}
	return self;
}
- (NSString*)description {
	NSString *format = (self.titleFormat) ? self.titleFormat : @"%g : %g";
	
	if(self.isLandscape){
		return [NSString stringWithFormat:format, _longSide, _shortSide];
	}
	return [NSString stringWithFormat:format, _shortSide, _longSide];
}
- (CGFloat)ratio {
	if(_longSide==0 || _shortSide==0){
		return 0;
	}
	if(self.isLandscape){
		return _shortSide / (CGFloat)_longSide;
	}
	return _longSide / (CGFloat)_shortSide;
}

@end
