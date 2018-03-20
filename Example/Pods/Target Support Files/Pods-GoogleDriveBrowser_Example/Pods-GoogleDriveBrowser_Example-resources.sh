#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset/3ds.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset/aac.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset/ai.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset/avi.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset/bmp.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset/cad.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset/css.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset/csv.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset/dat.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset/dmg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset/doc.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset/doc.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset/download.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset/eps.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset/file.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset/fla.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset/folder-1.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset/gif.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset/html.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset/iso.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset/jpg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset/js.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset/mp3.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset/mp4.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset/mpg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset/pdf.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset/php.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset/png.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset/ppt.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset/proj.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset/psd.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset/raw.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset/sql.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset/svg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset/txt.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset/wmv.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset/xls.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset/xml.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset/zip.png"
  install_resource "${PODS_ROOT}/../../Resources/SDGD.storyboard"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/AppIcon.appiconset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset"
  install_resource "${PODS_ROOT}/GoogleSignIn/Resources/GoogleSignIn.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset/3ds.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset/aac.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset/ai.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset/avi.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset/bmp.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset/cad.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset/css.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset/csv.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset/dat.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset/dmg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset/doc.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset/doc.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset/download.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset/eps.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset/file.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset/fla.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset/folder-1.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset/gif.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset/html.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset/iso.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset/jpg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset/js.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset/mp3.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset/mp4.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset/mpg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset/pdf.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset/php.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset/png.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset/ppt.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset/proj.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset/psd.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset/raw.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset/sql.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset/svg.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset/txt.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset/wmv.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset/xls.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset/xml.png"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset/Contents.json"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset/zip.png"
  install_resource "${PODS_ROOT}/../../Resources/SDGD.storyboard"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/3ds.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/aac.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ai.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/AppIcon.appiconset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/avi.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/bmp.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/cad.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/css.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/csv.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dat.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/dmg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/doc.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/docx.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/download.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/eps.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/file.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/fla.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/folder.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/gif.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/html.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/iso.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/jpg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/js.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp3.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mp4.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/mpg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/pdf.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/php.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/png.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/ppt.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/proj.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/psd.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/raw.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/sql.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/svg.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/txt.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/wmv.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xls.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/xml.imageset"
  install_resource "${PODS_ROOT}/../../Resources/Assets.xcassets/zip.imageset"
  install_resource "${PODS_ROOT}/GoogleSignIn/Resources/GoogleSignIn.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
