import os
import sys
import boto3
import shutil
import logging
from botocore.exceptions import ClientError

logging.basicConfig(stream=sys.stdout, level=logging.INFO)


def download_and_unzip_libs():
    download_android_libs_from_aws()
    download_ios_libmm2_from_aws()
    try:
        shutil.unpack_archive('ios-lib.zip', 'ios/')
        shutil.unpack_archive('android-libs.zip', 'android/app/src/main/cpp/')
        print('SUCCESSfully downloaded and copied mm2libs from aws')
    except FileNotFoundError as e:
        logging.error('something went wrong. check logs.')
        logging.error(e)


def download_android_libs_from_aws():
    file_name = 'android-libs.zip'

    bucket = 'dthbezumniy'
    object_name = 'android-libs.zip'
    s3_client = boto3.client('s3')
    try:
        s3_client.download_file(bucket, object_name, file_name)
        print('AWS-S3 android-libs.zip DOWNLOAD: SUCCESS')
    except ClientError as e:
        logging.error(e)
        logging.error('AWS-S3 android-libs.zip DOWNLOAD: FAILURE')


def download_ios_libmm2_from_aws():
    file_name = 'ios-lib.zip'
    bucket = 'dthbezumniy'
    object_name = 'ios-lib.zip'
    s3_client = boto3.client('s3')
    try:
        s3_client.download_file(bucket, object_name, file_name)
        print('AWS-S3 ios-lib.zip DOWNLOAD: SUCCESS')
    except ClientError as e:
        logging.error(e)
        logging.error('AWS-S3 ios-lib.zip DOWNLOAD: FAILURE')
    


if __name__ == "__main__":
    download_and_unzip_libs()
