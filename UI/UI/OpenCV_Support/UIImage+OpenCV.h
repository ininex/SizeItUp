//
//  UIImage+OpenCV.h
//  OpenCVClient
//
//  Created by Washe on 01/12/2012.
//  Copyright 2012 Washe / Foundry. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/nonfree/features2d.hpp>
#import <opencv2/core/core.hpp>
#import <opencv2/nonfree/nonfree.hpp>
#import <opencv2/calib3d/calib3d.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/highgui/ios.h>


@interface UIImage (OpenCV)

//cv::Mat to UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithCVMat:(const cv::Mat&)cvMat;
- (id)initForFeatureMatching:(const cv::Mat&)referenceMat andOriginalMat: (const cv::Mat&)originalMat andIdentifier: (NSString *) identifier;

//UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // no alpha channel
- (cv::Mat)CVGrayscaleMat;

@end
