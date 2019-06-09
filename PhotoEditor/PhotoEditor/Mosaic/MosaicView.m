//
//  MosaicView.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import "MosaicView.h"
@interface MosaicView ()


@property (nonatomic, assign) CGMutablePathRef path;

@end


@implementation MosaicView

- (void)dealloc
{
	if (self.path) {
		CGPathRelease(_path);
	}
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		//添加layer（imageLayer）到self上

		
	}
	
	return self;
}

- (void)setMosaciPixValue:(NSNumber*)pixValue forImage:(UIImage *)image
{
	//底图
	_image = image;
	_pixValue = pixValue;
	UIImage *showImage = [self getMosaicImageWith:[self fixOrientation:image] level:[pixValue integerValue]];
	[self.mosaicImages addObject:showImage];

}

/**
 网上一般有两种生成马赛克图片的方法，一种是使用CIFilter生成，一种是这种，通过像素点转换。请不要使用cifilter，cifilter生成的图片会多带一层50x50透明的画布边框，且原图片的位置在画布中不一定是靠中心。
 会导致马赛克图片无法与原图准确贴合

 @param image 源图片
 @param level 像素点大小
 @return 生成的马赛克图片
 */
- (UIImage *)getMosaicImageWith:(UIImage *)image level:(NSInteger)level{
	CGImageRef imageRef = image.CGImage;
	NSUInteger imageW = CGImageGetWidth(imageRef);
	NSUInteger imageH = CGImageGetHeight(imageRef);
	//创建颜色空间
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	unsigned char *rawData = (unsigned char *)calloc(imageH*imageW*4, sizeof(unsigned char));
	CGContextRef contextRef = CGBitmapContextCreate(rawData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, imageW, imageH), imageRef);
	
	unsigned char *bitMapData = CGBitmapContextGetData(contextRef);
	NSUInteger currentIndex,preCurrentIndex;
	NSUInteger sizeLevel = level == 0 ? MIN(imageW, imageH)/40.0 : level;
	//像素点默认是4个通道
	unsigned char *pixels[4] = {0};
	for (int i = 0; i < imageH; i++) {
		for (int j = 0; j < imageW; j++) {
			currentIndex = imageW*i + j;
			NSUInteger red = rawData[currentIndex*4];
			NSUInteger green = rawData[currentIndex*4+1];
			NSUInteger blue = rawData[currentIndex*4+2];
			NSUInteger alpha = rawData[currentIndex*4+3];
			if (red+green+blue == 0 && (alpha/255.0 <= 0.5)) {
				rawData[currentIndex*4] = 255;
				rawData[currentIndex*4+1] = 255;
				rawData[currentIndex*4+2] = 255;
				rawData[currentIndex*4+3] = 0;
				continue;
			}
			/*
			 memcpy指的是c和c++使用的内存拷贝函数，memcpy函数的功能是从源src所指的内存地址的起始位置开始拷贝n个字节到目标dest所指的内存地址的起始位置中。
			 strcpy和memcpy主要有以下3方面的区别。
			 1、复制的内容不同。strcpy只能复制字符串，而memcpy可以复制任意内容，例如字符数组、整型、结构体、类等。
			 2、复制的方法不同。strcpy不需要指定长度，它遇到被复制字符的串结束符"\0"才结束，所以容易溢出。memcpy则是根据其第3个参数决定复制的长度。
			 3、用途不同。通常在复制字符串时用strcpy，而需要复制其他类型数据时则一般用memcpy
			 */
			if (i % sizeLevel == 0) {
				if (j % sizeLevel == 0) {
					memcpy(pixels, bitMapData+4*currentIndex, 4);
				}else{
					//将上一个像素点的值赋给第二个
					memcpy(bitMapData+4*currentIndex, pixels, 4);
				}
			}else{
				preCurrentIndex = (i-1)*imageW+j;
				memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
			}
		}
	}
	//获取图片数据集合
	NSUInteger size = imageW*imageH*4;
	CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitMapData, size, NULL);
	//创建马赛克图片，根据变换过的bitMapData像素来创建图片
	CGImageRef mosaicImageRef = CGImageCreate(imageW, imageH, 8, 4*8, imageW*4, colorSpace, kCGBitmapByteOrderDefault, providerRef, NULL, NO, kCGRenderingIntentDefault);//Creates a bitmap image from data supplied by a data provider.
	//创建输出马赛克图片
	CGContextRef outContextRef = CGBitmapContextCreate(bitMapData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast);
	//绘制图片
	CGContextDrawImage(outContextRef, CGRectMake(0, 0, imageW, imageH), mosaicImageRef);
	
	CGImageRef resultImageRef = CGBitmapContextCreateImage(contextRef);
	UIImage *mosaicImage = [UIImage imageWithCGImage:resultImageRef];
	//释放内存
	CGImageRelease(resultImageRef);
	CGImageRelease(mosaicImageRef);
	CGColorSpaceRelease(colorSpace);
	CGDataProviderRelease(providerRef);
	CGContextRelease(outContextRef);
	return mosaicImage;
}

/**
 纠正图片朝向

 @param UIImage 原图片
 @return 纠正后的图片
 */
#pragma mark - Rotate Image
- (UIImage *)fixOrientation:(UIImage *)aImage {
	
	// No-op if the orientation is already correct
	if (aImage.imageOrientation == UIImageOrientationUp)
		return aImage;
	
	// We need to calculate the proper transformation to make the image upright.
	// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (aImage.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		default:
			break;
	}
	
	switch (aImage.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		default:
			break;
	}
	
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
											 CGImageGetBitsPerComponent(aImage.CGImage), 0,
											 CGImageGetColorSpace(aImage.CGImage),
											 CGImageGetBitmapInfo(aImage.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (aImage.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
			break;
			
		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
			break;
	}
	
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

-(NSMutableArray <UIImage *>*)mosaicImages{
	if (!_mosaicImages) {
		_mosaicImages = [NSMutableArray array];
	}
	return _mosaicImages;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	


	 CALayer *imageLayer = [CALayer layer];
	imageLayer.frame = self.bounds;
	[self.layer addSublayer:imageLayer];
	imageLayer.contents = (id)self.self.mosaicImages[_mosaicIndex].CGImage;
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.frame = self.bounds;
	shapeLayer.lineCap = kCALineCapRound;
	shapeLayer.lineJoin = kCALineJoinRound;
	//手指移动时 画笔的宽度
	shapeLayer.lineWidth = 20.f;
	shapeLayer.strokeColor = [UIColor blueColor].CGColor;
	shapeLayer.fillColor = nil;
	
	[self.layer addSublayer:shapeLayer];
	imageLayer.mask = shapeLayer;
	if ([self.delegate respondsToSelector:@selector(mosaicView:drawBeginOnLayer:shape:)]) {
		[self.delegate mosaicView:self drawBeginOnLayer:imageLayer shape:shapeLayer];
		}
	CGMutablePathRef pathRef = CGPathCreateMutable();
	self.path = CGPathCreateMutableCopy(pathRef);
	CGPathRelease(pathRef);

//	[self.model.mosaicPathArray addObject:pathModel];
	
	CGPathMoveToPoint(self.path, NULL, point.x, point.y);
	CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
	shapeLayer.path = path;
	CGPathRelease(path);
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
	CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	if (!currentContext) {
		UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
	}
	CGContextAddPath(currentContext, path);
	[[UIColor blueColor] setStroke];
	CGContextDrawPath(currentContext, kCGPathStroke);
	if ([self.delegate respondsToSelector:@selector(mosaicView:drawMoveOnPath:)]) {
		[self.delegate mosaicView:self drawMoveOnPath:path];
	}
	CGPathRelease(path);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathMoveToPoint(self.path, NULL, point.x, point.y);

	if ([self.delegate respondsToSelector:@selector(mosaicView:drawEnd:)]) {
		[self.delegate mosaicView:self drawEnd:point];
	}
}
@end
