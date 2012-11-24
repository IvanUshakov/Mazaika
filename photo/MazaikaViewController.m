//
//  MazaikaViewController.m
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import "MazaikaViewController.h"
#import "MazaikaModel.h"
#import "NetworkModel.h"
#import "UIImage+mazaika.h"

@interface MazaikaViewController ()
@property (weak, nonatomic) UIView *contaner;

@property (strong, nonatomic) MazaikaModel *mazaikaModel;
@property (strong, nonatomic) NSMutableDictionary *smallImages;
@property (strong, nonatomic) NSArray *colors;
@property (assign, nonatomic) NSInteger numPixels;
@property (assign, nonatomic) NSInteger loadingImages;
@end

@implementation MazaikaViewController

- (id)initWithSearchTerm:(NSString*)searchTerm
                   image:(UIImage*)image
               numPixels:(NSInteger)numPixels
        smallImagesCount:(NSInteger)smallImagesCount;
{
    self = [super init];
    if (self) {
        self.smallImages = [[NSMutableDictionary alloc] init];
        self.numPixels = numPixels;
        self.mazaikaModel = [[MazaikaModel alloc] init];
        [self loadSmallImageWithSearchTerm:searchTerm count:smallImagesCount];
        self.colors = [self.mazaikaModel colorsFromImage:image withPixelCount:numPixels];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.minimumZoomScale = 320.0f / (self.numPixels * 128);
    scrollView.maximumZoomScale = 1.0f;
    scrollView.contentSize = CGSizeMake(self.numPixels * 128, self.numPixels * 128);
    scrollView.delegate = self;
    self.view = scrollView;
    
    UIView *contaner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.numPixels * 128, self.numPixels * 128)];
    [scrollView addSubview:contaner];
    self.contaner = contaner;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [NetworkModel stopAllConnections];
}

#pragma mark - scroll view delegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contaner;
}

#pragma mark - private

- (void)loadSmallImageWithSearchTerm:(NSString*)searchTerm count:(NSInteger)count
{
    NSInteger perColorCount = count / 5;
    NSArray *colors = [self.mazaikaModel stringsForMazaikaPossableColor];
    self.loadingImages = colors.count * perColorCount;
    for (NSString *color in colors) {
        [NetworkModel startSearchingWithSearchTerm:searchTerm
                                             color:color
                                             count:perColorCount
                                           success:^(NSArray *imagesUrls) {
                                               for (NSDictionary *dict in imagesUrls) {
                                                   [NetworkModel startLoadImageWithURL:[NSURL URLWithString:dict[@"url"]]
                                                                               success:^(UIImage *image) {
                                                                                   CGFloat minSize = MIN(image.size.width, image.size.height);
                                                                                   CGRect crop = CGRectMake((image.size.width - minSize) / 2.0, (image.size.height - minSize) / 2.0, minSize, minSize);
                                                                                   [self addImage:[image crop:crop] toColor:color];
                                                                                   self.loadingImages--;
                                                                                   if (self.loadingImages == 0) {
                                                                                       [self addSmallImagesViews];
                                                                                   }
                                                                               } failure:^(NSError *error) {
                                                                                   self.loadingImages--;
                                                                                   if (self.loadingImages == 0) {
                                                                                       [self addSmallImagesViews];
                                                                                   }
                                                                               }];
                                                }
                                           } failure:NULL];
    }
}

- (void)addImage:(UIImage*)image toColor:(NSString*)color
{
    if (![self.smallImages valueForKey:color]) {
        [self.smallImages setValue:[[NSMutableArray alloc] init] forKey:color];
    }
    [[self.smallImages valueForKey:color] addObject:image];
}

- (void)addSmallImagesViews
{
    for (NSInteger i = 0; i < self.numPixels; i++) {
        for (NSInteger j = 0; j < self.numPixels; j++) {
            NSArray *imagesForColor = [self.smallImages valueForKey:self.colors[i * self.numPixels + j]];
            NSInteger random = rand() % imagesForColor.count;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:imagesForColor[random]];
            imageView.frame = CGRectMake(j * 128, i * 128, 128, 128);
            [self.contaner addSubview:imageView];
        }
    }
    ((UIScrollView*)(self.view)).zoomScale = ((UIScrollView*)(self.view)).minimumZoomScale;
}

@end
