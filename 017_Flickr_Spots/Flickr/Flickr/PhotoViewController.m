//
//  PhotoViewController.m
//  Flickr
//
//  Created by Duane Cawthron on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"

@interface PhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation PhotoViewController

@synthesize photo = _photo;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;

- (void)loadImage
{
    if (self.imageView) {
        if (self.photo) {
            NSURL *imageURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            dispatch_queue_t imageDownloadQ = dispatch_queue_create("PhotoViewController image downloader", NULL);
            dispatch_async(imageDownloadQ, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                    self.scrollView.contentSize = self.imageView.image.size;
                    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                    // zoom to show the whole image
                    [self.scrollView zoomToRect:self.imageView.frame animated:YES];
                });
            });
            dispatch_release(imageDownloadQ);
        } else {
            self.imageView.image = nil;
        }
    }
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (![_photo isEqual:photo]) {
        _photo = photo;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self loadImage];           
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
        }
        [[RecentPhotos recentPhotos] addPhoto:photo];
    }
}

#pragma mark - View lifecycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.photo) [self loadImage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{

    UITabBarController *tabBarController = [self.splitViewController.viewControllers objectAtIndex:0];
    UINavigationController *navigationController = (UINavigationController *) [tabBarController selectedViewController];
    UITableViewController *tableViewController = [[navigationController viewControllers] objectAtIndex:0];
    if ([tableViewController.navigationItem title]) barButtonItem.title = [tableViewController.navigationItem title];
    else barButtonItem.title = @"Menu";

    // tell the detail view to put this button up
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void) splitViewController:(UISplitViewController *)svc
      willShowViewController:(UIViewController *)aViewController
   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // tell the detail view to take the button away
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

@end
