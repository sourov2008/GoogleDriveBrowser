//
//  SDGDViewController.m
//  GoogleDriveBroswer
//
//  Created by shourov datta on 2/18/18.
//  Copyright © 2018 shourov datta. All rights reserved.
//


#import "SDGDViewController.h"

@implementation SDGDViewController{
    
    SDGDTableViewController *obj;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)btnActionGD:(id)sender {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SDGD"
                                                         bundle:nil];
    obj=
    [storyboard instantiateViewControllerWithIdentifier:@"SDGDTableViewController"];
    
    obj.delegate = self;
    obj.title = @"Google Drive";
    obj.colorTheme = [UIColor greenColor];
    obj.donwloadBtnImageName = @"download";
    //obj.isSignOutSilently = YES;
    //    obj.isEnableActivityIndicator = false;
    //    obj.isEnableProgressView = false;
    //obj.isEnablefileViewOption = false;
    //obj.isSignOutSilently = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
    [self presentViewController:nav animated:YES completion:nil];
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
}

#pragma -mark SDGDTableViewControllerDelegate

-(GTLRDriveQuery_FilesList *)delegateSetQueryWithFolderID:(NSString *)folderID{
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,fileExtension,size, createdTime,modifiedTime)";
    
    query.q = [NSString stringWithFormat:@"trashed = false and '%@' In parents ",folderID];
    
    query.pageSize = 1000;
    return query;
}

//-(UIImage*)delegateSetFIleOrFolderIcon:(GTLRDrive_File *)fileInfo{
//
//
//    if ( ![self checkIsEmptyString:fileInfo.fileExtension] ) {
//          return [UIImage imageNamed:fileInfo.fileExtension];
//
//       }
//
//    else if (fileInfo.fileExtension == nil && [fileInfo.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
//        return [UIImage imageNamed:@"folder"];
//
//    }
//
//    return [UIImage imageNamed:@"file"];
//}

- (void)delegateSelectedFileOrFolderInfo: (GTLRDrive_File *)fileInfo{
    NSLog(@"fileName = %@",fileInfo.name);
    
}

- (void)delegateDownloadedFileWithFileDetails: (GTLRDrive_File *)fileInfo downloadedData: (NSData*)data{
    
    NSLog(@"Download Completed %@",fileInfo.name);
    NSLog(@"fileNSData = %@",data);
    
}

-(void)delegateDownloadedFileFailure:(GTLRDrive_File *)fileInfo errorDetails:(NSError *)error{
    
    NSLog(@"Download Success %@",error.localizedDescription);
}

-(void)delegateDownloadProgress:(GTLRDrive_File *)fileInfo downloadByte:(float)downloaded totalRecived:(float)totalDownloaded{
    
    float progress = totalDownloaded/[fileInfo.size floatValue];
    NSLog(@"progress = %lf",progress);
    
}

-(void)delegateDoneButtonTapped{
    NSLog(@"Done button clicked");
    obj = nil;
    
}

-(void)delegateFileListingDidStart{
    NSLog(@"Start File Listing");
}


-(void)delegateFileListingDidFinished:(GTLRDrive_FileList *)result{
    
    NSLog(@"End File Listing");
}



#pragma mark - Helper Function
-(BOOL)checkIsEmptyString:( NSString*_Nullable)str{
    
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:charSet];
    if ([trimmedString isEqualToString:@""]) {
        // it's empty or contains only white spaces
        return YES;
    }
    
    
    if(str==nil  || [str isKindOfClass:[NSNull class]] || str.length==0 || [str isEqualToString:@""]|| [str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"]){
        return YES;
    }
    return NO;
    
}
@end




