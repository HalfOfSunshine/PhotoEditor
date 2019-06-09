//
//  SnapCornerView.m
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/24.
//

#import "SnapCornerView.h"

@implementation SnapCornerView
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect rct = self.bounds;
	rct.origin.x = rct.size.width/2-rct.size.width/6;
	rct.origin.y = rct.size.height/2-rct.size.height/6;
	rct.size.width /= 3;
	rct.size.height /= 3;
	
	CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
	CGContextFillEllipseInRect(context, rct);
}

@end
