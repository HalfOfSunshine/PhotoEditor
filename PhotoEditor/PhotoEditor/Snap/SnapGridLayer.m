//
//  SnapGridLayer.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/24.
//

#import "SnapGridLayer.h"

@implementation SnapGridLayer

+ (BOOL)needsDisplayForKey:(NSString*)key {
	if ([key isEqualToString:@"clippingRect"]) {
		return YES;
	}
	return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer {
	self = [super initWithLayer:layer];
	if(self && [layer isKindOfClass:[SnapGridLayer class]]){
		self.bgColor   = ((SnapGridLayer *)layer).bgColor;
		self.gridColor = ((SnapGridLayer *)layer).gridColor;
		self.clippingRect = ((SnapGridLayer *)layer).clippingRect;
	}
	return self;
}

- (void)drawInContext:(CGContextRef)context {
	CGRect rct = self.bounds;
	CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
	CGContextFillRect(context, rct);
	
	CGContextClearRect(context, _clippingRect);
	
	CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(1, 2), 0.8f, [[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor);
	CGContextSetLineWidth(context, 1);
	
	rct = self.clippingRect;
	
	CGContextBeginPath(context);
	CGFloat dW = 0;
	for(int i = 0; i < 4; ++i){
		CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
		CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
		dW += _clippingRect.size.width/3;
	}
	
	dW = 0;
	for(int i = 0; i < 4; ++i){
		CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
		CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
		dW += rct.size.height/3;
	}
	CGContextStrokePath(context);
}
@end
