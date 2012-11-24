//
//  MenuViewController.m
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import "MenuViewController.h"
#import "MazaikaViewController.h"

@interface MenuViewController ()
@property (weak, nonatomic) UIButton *makePicButton;
@property (weak, nonatomic) UIButton *selectPicButton;
@property (weak, nonatomic) UITextField *searchTerm;
@property (weak, nonatomic) UITextField *smallImageCount;
@property (weak, nonatomic) UITextField *numPixels;
@end

@implementation MenuViewController

- (void)loadView
{
    [super loadView];
    
    UITextField *searchTerm = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, self.view.bounds.size.width - 20.0f, 30.0f)];
    searchTerm.placeholder = @"Search term";
    searchTerm.delegate = self;
    [self.view addSubview:searchTerm];
    self.searchTerm = searchTerm;
    
    UITextField *smallImageCount = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 45.0f, self.view.bounds.size.width - 20.0f, 30.0f)];
    smallImageCount.placeholder = @"Small image count";
    smallImageCount.delegate = self;
    [self.view addSubview:smallImageCount];
    self.smallImageCount = smallImageCount;

    UITextField *numPixels = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 80.0f, self.view.bounds.size.width - 20.0f, 30.0f)];
    numPixels.placeholder = @"Columns and rows count";
    numPixels.delegate = self;
    [self.view addSubview:numPixels];
    self.numPixels = numPixels;
    
    UIButton *makePicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [makePicButton setTitle:@"Make photo" forState:UIControlStateNormal];
    [makePicButton addTarget:self action:@selector(makeMazaikaButtonHendler:) forControlEvents:UIControlEventTouchUpInside];
    makePicButton.frame = CGRectMake((self.view.bounds.size.width - 150.0f) / 2.0f, 115.0f, 150.0f, 30.0f);
    [self.view addSubview:makePicButton];
    self.makePicButton = makePicButton;
    
    UIButton *selectPicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [selectPicButton setTitle:@"Select photo" forState:UIControlStateNormal];
    [selectPicButton addTarget:self action:@selector(makeMazaikaButtonHendler:) forControlEvents:UIControlEventTouchUpInside];
    selectPicButton.frame = CGRectMake((self.view.bounds.size.width - 150.0f) / 2.0f, 150.0f, 150.0f, 30.0f);
    [self.view addSubview:selectPicButton];
    self.selectPicButton = selectPicButton;
}

- (void)viewDidLoad
{
    self.title = @"select parametrs";
}

- (void)makeMazaikaButtonHendler:(UIButton*)button
{
    if (self.numPixels.text.integerValue < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Column and rows count should be greater then 1"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (self.smallImageCount.text.integerValue < 7) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Small image count should be greater then 6"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
        
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (button == self.makePicButton) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if (button == self.selectPicButton) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - image picker view controller delegate

-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image
                 editingInfo:(NSDictionary*)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    MazaikaViewController *viewController = [[MazaikaViewController alloc] initWithSearchTerm:self.searchTerm.text
                                                                                        image:image
                                                                                    numPixels:[self.numPixels.text integerValue]
                                                                             smallImagesCount:[self.smallImageCount.text integerValue]];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*) picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
