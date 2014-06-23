//
//  KLGridLayoutControllerViewController.m
//  KLCollectionLayoutsDemo
//
//  Created by Kevin Lundberg on 6/14/14.
//  Copyright (c) 2014 Lundbergsoft. All rights reserved.
//

#import "KLGridLayoutViewController.h"
#import <KRLCollectionViewGridLayout/KRLCollectionViewGridLayout.h>

@interface KLGridLayoutViewController () <UIActionSheetDelegate>

@end

@implementation KLGridLayoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (KRLCollectionViewGridLayout *)layout
{
    return (id)self.collectionView.collectionViewLayout;
}

- (IBAction)changeColumnsTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Choose how many columns"
                                 delegate:self
                        cancelButtonTitle:nil
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"1",@"2",@"3",@"4",@"5", nil]
     showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.layout.numberOfItemsPerLine = [[actionSheet buttonTitleAtIndex:buttonIndex] integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.layout.numberOfItemsPerLine = 3;
    self.layout.aspectRatio = 1.5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
}

@end
