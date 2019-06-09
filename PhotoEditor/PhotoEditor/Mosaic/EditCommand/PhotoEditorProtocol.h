//
//  PhotoEditorProtocol.h
//  NL_CameraComponent
//
//  Created by kkmm on 2019/5/21.
//

#import <Foundation/Foundation.h>
#import "EditReceiver.h"
NS_ASSUME_NONNULL_BEGIN

@protocol PhotoEditorProtocol <NSObject>
@required

- (void)execute;

@end

NS_ASSUME_NONNULL_END
