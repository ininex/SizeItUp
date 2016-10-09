//
//  UIImage+OpenCV.mm
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
//  adapted from
//  http://docs.opencv.org/doc/tutorials/ios/image_manipulation/image_manipulation.html#opencviosimagemanipulation

#import "UIImage+OpenCV.h"

#include <opencv2/opencv.hpp>


@implementation UIImage (OpenCV)

-(cv::Mat)CVMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)CVMat3
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2RGB);
    return result;
    
}

-(cv::Mat)CVGrayscaleMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    return [[UIImage alloc] initWithCVMat:cvMat];
}

//+(UIImage *)imageBySurfFeatureMatching:(UIImage*)image
//{
//    UIImage *sceneImage, *objectImage1;
//    cv::Mat sceneImageMat, objectImageMat1;
//    std::vector<cv::KeyPoint> sceneKeypoints, objectKeypoints1;
//    cv::Mat sceneDescriptors, objectDescriptors1;
//    cv::SurfFeatureDetector *surfDetector;
//    cv::FlannBasedMatcher flannMatcher;
//    cv::vector<cv::DMatch> matches;
//    int minHessian;
//    double minDistMultiplier;
//    
//    minHessian = 400;
//    minDistMultiplier= 3;
//    surfDetector = new cv::SurfFeatureDetector(minHessian);
//    
//    sceneImage = [UIImage imageNamed:@"twitter_scene.png"];
//    objectImage1 = [UIImage imageNamed:@"twitter.png"];
//    
//    sceneImageMat = cv::Mat(sceneImage.size.height, sceneImage.size.width, CV_8UC1);
//    objectImageMat1 = cv::Mat(objectImage1.size.height, objectImage1.size.width, CV_8UC1);
//    
//    cv::cvtColor([sceneImage CVMat], sceneImageMat, CV_RGB2GRAY);
//    cv::cvtColor([objectImage1 CVMat], objectImageMat1, CV_RGB2GRAY);
//    
//    if (!sceneImageMat.data || !objectImageMat1.data) {
//        NSLog(@"NO DATA");
//    }
//    
//    surfDetector->detect(sceneImageMat, sceneKeypoints);
//    surfDetector->detect(objectImageMat1, objectKeypoints1);
//    
//    surfExtractor.compute(sceneImageMat, sceneKeypoints, sceneDescriptors);
//    surfExtractor.compute(objectImageMat1, objectKeypoints1, objectDescriptors1);
//    
//    flannMatcher.match(objectDescriptors1, sceneDescriptors, matches);
//    
//    double max_dist = 0; double min_dist = 100;
//    
//    for( int i = 0; i < objectDescriptors1.rows; i++ )
//    {
//        double dist = matches[i].distance;
//        if( dist < min_dist ) min_dist = dist;
//        if( dist > max_dist ) max_dist = dist;
//    }
//    
//    cv::vector<cv::DMatch> goodMatches;
//    for( int i = 0; i < objectDescriptors1.rows; i++ )
//    {
//        if( matches[i].distance < minDistMultiplier*min_dist )
//        {
//            goodMatches.push_back( matches[i]);
//        }
//    }
//    NSLog(@"Good matches found: %lu", goodMatches.size());
//    
//    cv::Mat imageMatches;
//    cv::drawMatches(objectImageMat1, objectKeypoints1, sceneImageMat, sceneKeypoints, goodMatches, imageMatches, cv::Scalar::all(-1), cv::Scalar::all(-1),
//                    cv::vector<char>(), cv::DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
//    
//    for( int i = 0; i < goodMatches.size(); i++ )
//    {
//        //-- Get the keypoints from the good matches
//        obj.push_back( objectKeypoints1[ goodMatches[i].queryIdx ].pt );
//        scn.push_back( objectKeypoints1[ goodMatches[i].trainIdx ].pt );
//    }
//    
//    cv::vector<uchar> outputMask;
//    cv::Mat homography = cv::findHomography(obj, scn, CV_RANSAC, 3, outputMask);
//    int inlierCounter = 0;
//    for (int i = 0; i < outputMask.size(); i++) {
//        if (outputMask[i] == 1) {
//            inlierCounter++;
//        }
//    }
//    NSLog(@"Inliers percentage: %d", (int)(((float)inlierCounter / (float)outputMask.size()) * 100));
//    
//    cv::vector<cv::Point2f> objCorners(4);
//    objCorners[0] = cv::Point(0,0);
//    objCorners[1] = cv::Point( objectImageMat1.cols, 0 );
//    objCorners[2] = cv::Point( objectImageMat1.cols, objectImageMat1.rows );
//    objCorners[3] = cv::Point( 0, objectImageMat1.rows );
//    
//    cv::vector<cv::Point2f> scnCorners(4);
//    
//    cv::perspectiveTransform(objCorners, scnCorners, homography);
//    
//    cv::line( imageMatches, scnCorners[0] + cv::Point2f( objectImageMat1.cols, 0), scnCorners[1] + cv::Point2f( objectImageMat1.cols, 0), cv::Scalar(0, 255, 0), 4);
//    cv::line( imageMatches, scnCorners[1] + cv::Point2f( objectImageMat1.cols, 0), scnCorners[2] + cv::Point2f( objectImageMat1.cols, 0), cv::Scalar( 0, 255, 0), 4);
//    cv::line( imageMatches, scnCorners[2] + cv::Point2f( objectImageMat1.cols, 0), scnCorners[3] + cv::Point2f( objectImageMat1.cols, 0), cv::Scalar( 0, 255, 0), 4);
//    cv::line( imageMatches, scnCorners[3] + cv::Point2f( objectImageMat1.cols, 0), scnCorners[0] + cv::Point2f( objectImageMat1.cols, 0), cv::Scalar( 0, 255, 0), 4);
//    
//    [self.mainImageView setImage:[UIImage imageWithCVMat:imageMatches]];
//}

- (id)initWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    self = [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

- (id)initForFeatureMatching:(const cv::Mat&)referenceMat andOriginalMat: (const cv::Mat&)originalMat andIdentifier: (NSString *) identifier
{
    
    cv::SurfFeatureDetector surf(50);
    std::vector<cv::KeyPoint> keypoints_object, keypoints_scene;
    surf.detect( originalMat, keypoints_object );
    surf.detect( referenceMat, keypoints_scene );
    
    //-- Step 2: Calculate descriptors (feature vectors)
    cv::SurfDescriptorExtractor extractor;
    
    cv::Mat descriptors_object, descriptors_scene;
    
    extractor.compute( originalMat, keypoints_object, descriptors_object );
    extractor.compute( referenceMat, keypoints_scene, descriptors_scene );
    
    //MARK:NOTE: add following lines to avoid FLANN error
    if(descriptors_object.empty()) {
        return self;
    }
    
    if(descriptors_scene.empty()) {
        return self;
    }
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    cv::FlannBasedMatcher matcher;
    std::vector< cv::DMatch > matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< cv::DMatch > good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    { if( matches[i].distance < 3*min_dist )
    { good_matches.push_back( matches[i]); }
    }
    
    cv::Mat img_matches;
    drawMatches( originalMat, keypoints_object, referenceMat, keypoints_scene,
                good_matches, img_matches, cv::Scalar::all(-1), cv::Scalar::all(-1),
                cv::vector<char>(), cv::DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    //-- Localize the object
    std::vector<cv::Point2f> obj;
    std::vector<cv::Point2f> scene;
    self.accessibilityIdentifier = identifier;
    //MARK: NOTE: good matches should always be greater than 4, or cvFindHomography will return error
    if(good_matches.size()<20) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"UIImageFeatureMatchingKeypointsWaiting"
         object:self];
        return self;
    }
    
    NSDictionary* userInfo = @{@"keypoints": @(good_matches.size())};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UIImageFeatureMatchingKeypointsUpdated" object:self userInfo:userInfo];
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }
    
    cv::Mat H = findHomography( obj, scene, CV_RANSAC );
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<cv::Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( originalMat.cols, 0 );
    obj_corners[2] = cvPoint( originalMat.cols, originalMat.rows ); obj_corners[3] = cvPoint( 0, originalMat.rows );
    std::vector<cv::Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line( img_matches, scene_corners[0] + cv::Point2f( originalMat.cols, 0), scene_corners[1] + cv::Point2f( originalMat.cols, 0), cvScalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + cv::Point2f( originalMat.cols, 0), scene_corners[2] + cv::Point2f( originalMat.cols, 0), cvScalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + cv::Point2f( originalMat.cols, 0), scene_corners[3] + cv::Point2f( originalMat.cols, 0), cvScalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + cv::Point2f( originalMat.cols, 0), scene_corners[0] + cv::Point2f( originalMat.cols, 0), cvScalar( 0, 255, 0), 4 );
    
    self = MatToUIImage(img_matches);
    
    return self;
}


@end
