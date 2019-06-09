//
//  ViewController.m
//  PhotoEditor
//
//  Created by kkmm on 2019/6/9.
//  Copyright © 2019 kkmm. All rights reserved.
//

#import "ViewController.h"
#import "PhotoEditor/PhotoEditorVC.h"
#import "PhotoEditor/EditorModel.h"
@interface ViewController ()<UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)pickImage:(id)sender {
	UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
	
	if([UIImagePickerController isSourceTypeAvailable:type]){
		//        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		//            type = UIImagePickerControllerSourceTypeCamera;
		//        }
		
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.allowsEditing = NO;
		picker.delegate   = self;
		picker.sourceType = type;
		
		[self presentViewController:picker animated:YES completion:nil];
	}
}

#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//	因为实战中很可能编辑完成再进入编辑，需要支持之前的撤销操作，所以这里传个model，而不是image
	EditorModel *editModel = [[EditorModel alloc]init];
	editModel.orgImage = image;
	PhotoEditorVC *VC = [[PhotoEditorVC alloc]init];
	VC.model = editModel;
	__weak typeof(self) weakSelf = self;
	VC.completeBlock = ^(EditorModel * _Nonnull resultModel) {
//			[self addPicture];
		UIImageView *imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
		imageView.contentMode = UIViewContentModeCenter;
		if(resultModel.editedImage){
			imageView.image = resultModel.editedImage ;
		}else if(resultModel.snappedImage){
			imageView.image = resultModel.snappedImage ;
		}if (resultModel.orgImage){
			imageView.image = resultModel.orgImage ;
		}
		[weakSelf.view addSubview:imageView];
	};
	[picker dismissViewControllerAnimated:NO completion:^{
		[self presentViewController:VC animated:NO completion:nil];
	}];
	
}
@end
