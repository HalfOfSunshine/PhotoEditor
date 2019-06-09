//
//  EditorModel.h
//  PhotoEditor
//
//  Created by kkmm on 2019/6/9.
//  Copyright © 2019 kkmm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnapModel.h"
#import "Mosaic/PathModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EditorModel : NSObject
@property (nonatomic,strong) UIImage *editedImage;
@property (strong, nonatomic) UIImage *snappedImage;
@property (nonatomic,strong) NSMutableArray <PathModel*>*mosaicPathArray;
@property (nonatomic,strong) SnapModel *snapModel;
@property (nonatomic,assign) BOOL previewSelected;
@property (nonatomic,assign)  CGSize assetGridThumbnailSize;
@property (strong, nonatomic) UIImage *orgImage;

@end

NS_ASSUME_NONNULL_END
