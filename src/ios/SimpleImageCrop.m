/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDV.h>
#import "SimpleImageCrop.h"


@implementation SimpleImageCrop

- (void)crop:(CDVInvokedUrlCommand *)command {
    
    NSString* file = [command.arguments objectAtIndex:0];
    BOOL removeFile = [[command.arguments objectAtIndex:1 withDefault:[NSNumber numberWithBool:NO]] boolValue]; // allow self-signed certs
    
    CDVPluginResult* result = nil;
    SimpleImageCropError errorCode = 0;
    
    CDVFilesystemURL *fsURL = [CDVFilesystemURL fileSystemURLWithString:file];
    if (!fsURL) {
        errorCode = FILE_NOT_FOUND_ERR;
        NSLog(@"SimpleImageCrop Error: Invalid file path or URL %@", file);
    }
    
    if (errorCode > 0) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:errorCode];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [self.commandDelegate runInBackground:^{
        
        CDVFile *filePlugin = [self.commandDelegate getCommandInstance:@"File"];
        NSObject<CDVFileSystem> *fs = [filePlugin filesystemForURL:fsURL];
        NSString *path = [fs filesystemPathForURL:fsURL];
        
        NSLog(@"SimpleImageCrop load image from: %@", path);
        
        // Get the file manager
        NSFileManager* fMgr = [NSFileManager defaultManager];
        NSString* appFile = path; // [ self getFullPath: argPath];
        
        BOOL bExists = [fMgr fileExistsAtPath:appFile];
        if(bExists == false) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:FILE_NOT_FOUND_ERR];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        float x = [[command.arguments objectAtIndex:2] floatValue];
        float y = [[command.arguments objectAtIndex:3] floatValue];
        float width = [[command.arguments objectAtIndex:4] floatValue];
        float height = [[command.arguments objectAtIndex:5] floatValue];
        float quality = [[command.arguments objectAtIndex:6] floatValue] / 100.0f;
        int maxWidth = [[command.arguments objectAtIndex:7] intValue];
        
        NSLog(@"SimpleImageCrop crop image with: %f %f %f %f %i", x, y, width, height, maxWidth);
        
        // Center the crop area
        CGRect clippedRect = CGRectMake(x, y, width, height);
        
        // Crop logic
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        UIImage *croppedImageFinal = [SimpleImageCrop imageWithImage:croppedImage scaledToWidth:maxWidth];
        
        NSData *croppedImageData = UIImageJPEGRepresentation(croppedImageFinal, quality);
        NSString *mimeType = @"image/jpeg";
        
        NSLog(@"SimpleImageCrop croppedImageData size: %lu", (unsigned long)croppedImageData.length);
        
        NSString* output = [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, [croppedImageData base64EncodedString]];
        
        SimpleImageCropError errorCode = 0;
        
        if(removeFile) {
            CDVPluginResult* removeFileResult = [fs removeFileAtURL:fsURL];
            NSLog(@"SimpleImageCrop removeFileResult: %@", removeFileResult.status);
            if([removeFileResult.status intValue] != CDVCommandStatus_OK) {
                errorCode = FILE_NOT_REMOVED_ERR;
                NSLog(@"SimpleImageCrop Error: file not removed for or URL %@", file);
            }
        }
        
        CDVPluginResult* result;
        if (errorCode > 0) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:errorCode];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:output];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        
    }];
    
}

- (void)resize:(CDVInvokedUrlCommand *)command {
    
    NSString* file = [command.arguments objectAtIndex:0];
    BOOL removeFile = [[command.arguments objectAtIndex:1 withDefault:[NSNumber numberWithBool:NO]] boolValue]; // allow self-signed certs
    
    CDVPluginResult* result = nil;
    SimpleImageCropError errorCode = 0;
    
    CDVFilesystemURL *fsURL = [CDVFilesystemURL fileSystemURLWithString:file];
    if (!fsURL) {
        errorCode = FILE_NOT_FOUND_ERR;
        NSLog(@"SimpleImageCrop Error: Invalid file path or URL %@", file);
    }
    
    if (errorCode > 0) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:errorCode];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [self.commandDelegate runInBackground:^{
        
        CDVFile *filePlugin = [self.commandDelegate getCommandInstance:@"File"];
        NSObject<CDVFileSystem> *fs = [filePlugin filesystemForURL:fsURL];
        NSString *path = [fs filesystemPathForURL:fsURL];
        
        NSLog(@"SimpleImageCrop load image from: %@", path);
        
        // Get the file manager
        NSFileManager* fMgr = [NSFileManager defaultManager];
        NSString* appFile = path; // [ self getFullPath: argPath];
        
        BOOL bExists = [fMgr fileExistsAtPath:appFile];
        if(bExists == false) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:FILE_NOT_FOUND_ERR];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        float quality = [[command.arguments objectAtIndex:2] floatValue] / 100.0f;
        int maxWidth = [[command.arguments objectAtIndex:3] intValue];
        
        UIImage *croppedImageFinal = [SimpleImageCrop imageWithImage:image scaledToWidth:maxWidth];
        
        NSData *croppedImageData = UIImageJPEGRepresentation(croppedImageFinal, quality);
        NSString *mimeType = @"image/jpeg";
        
        NSLog(@"SimpleImageCrop croppedImageData size: %lu", (unsigned long)croppedImageData.length);
        
        NSString* output = [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, [croppedImageData base64EncodedString]];
        
        SimpleImageCropError errorCode = 0;
        
        if(removeFile) {
            CDVPluginResult* removeFileResult = [fs removeFileAtURL:fsURL];
            NSLog(@"SimpleImageCrop removeFileResult: %@", removeFileResult.status);
            if([removeFileResult.status intValue] != CDVCommandStatus_OK) {
                errorCode = FILE_NOT_REMOVED_ERR;
                NSLog(@"SimpleImageCrop Error: file not removed for or URL %@", file);
            }
        }
        
        CDVPluginResult* result;
        if (errorCode > 0) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:errorCode];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:output];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        
    }];
    
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
