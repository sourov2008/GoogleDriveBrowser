//
//  SDGDTableViewController.h
//  GoogleDriveBroswer
//
//  Created by Shourob on 2/18/18.
//  Copyright © 2018 shourob datta. All rights reserved.
//

#import <UIKit/UIKit.h>



@import Foundation;
@import GoogleSignIn;
@import GoogleAPIClientForREST;

@protocol SDGDTableViewControllerDelegate;

@interface SDGDTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource,GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, weak) IBOutlet id <SDGDTableViewControllerDelegate> delegate;

/// The color that will be used to tint any objects. Defaults to a blue color.
@property (nonatomic, strong) UIColor *colorTheme;

/// A download button will appear right of the cell . set the image name
@property (nonatomic, strong) NSString *donwloadBtnImageName;

/// Bool value . If yes then after select the cell, browser will open the file otherwise file being download
@property (nonatomic,assign) BOOL isEnablefileViewOption;

/// progressView over navigation when file downloading appear download progress and after succeed a success message will appear
@property (nonatomic,assign) BOOL isEnableProgressView;

/// UIActivityIndicator when file fetching
@property (nonatomic,assign) BOOL isEnableActivityIndicator;

//  current user as being in the signed out state.
@property (nonatomic,assign) BOOL isSignOutSilently;

@end

@protocol SDGDTableViewControllerDelegate <NSObject>

@optional


// MARK: - Optional Delegate

/**
 *  Returns Query parameter.  Like this format
 *   query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,fileExtension,size, createdTime,modifiedTime)";
 *   query.pageSize = 1000;
 *   @param folderID is required for query coommand  Like In parents 'folderID'
 *
 */
- (GTLRDriveQuery_FilesList *)delegateSetQueryWithFolderID : (NSString*)folderID;

/**
 *  Delegate
 *  Like fileExtension, name, mimetype, iconLink etc . See in  GTLRDrive_File section
 */
- (void)delegateSelectedFileOrFolderInfo: (GTLRDrive_File *)fileInfo;

/**
 *  Download successfull
 *  Delegate Downloaded Data with File Info.
 *
 */
- (void)delegateDownloadedFileWithFileDetails: (GTLRDrive_File *)fileInfo downloadedData: (NSData*)data;

/**
 *  If file Download Fails Generate Error
 *
 */
- (void)delegateDownloadedFileFailure: (GTLRDrive_File *)fileInfo errorDetails: (NSError *)error;

/**
 *  File download Progress value . You may use your own progressbar presentation depends on this values
 *  @param downloaded  is download data size instant thread
 *  @param totalDownloaded is  Total downloaded data size
 *  @param fileInfo  from file info you may get file size
 */
- (void)delegateDownloadProgress: (GTLRDrive_File *)fileInfo downloadByte:(float)downloaded totalRecived : (float)totalDownloaded;


/**
 *  File Retrival Error. delegated when generate error in File listing
 *
 */
- (void)delegateFileRetrievalError: (NSError *)error;

/**
 *  Sign in Error. delegated when generate error signing in
 *
 */
- (void)delegateSignInError: (NSError *)error;

/**
 *  File Retrieve Start. called when start fetch file List
 *
 */
- (void)delegateFileListingDidStart;

/**
 *  File Retrieve End. called when eding of file list fetching
 *
 */
- (void)delegateFileListingDidFinishedSuccessed: (GTLRDrive_FileList *)result ;

/**
 *  set the file icon
 *  if you don't set default image will load from library
 */
- (UIImage *)delegateSetFIleOrFolderIcon: (GTLRDrive_File *)fileInfo;

/**
 *  Done Button CLicked
 *
 */
- (void)delegateDoneButtonTapped;


@end
