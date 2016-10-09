//
//  OpenCVWrapper.h
//  Demo
//
//  Created by GUANJIU ZHANG on 9/28/16.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject
    +(UIImage*)processImageWithOpenCV: (UIImage*)inputImage;
    +(UIImage*)feature2DRecognitionForImage: (UIImage*)referenceImage andOriginalImage: (UIImage*)originalImage;
@end
