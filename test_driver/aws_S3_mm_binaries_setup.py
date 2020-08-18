import os
import sys
import boto3
import shutil
import logging
from botocore.exceptions import ClientError

logging.basicConfig(stream=sys.stdout, level=logging.ERROR)

def main():
    if os.path.exists('mm2bins'):
        try:
            print('copying...')
            shutil.copy('mm2bins/mm2', 'assets/')
            shutil.copy('mm2bins/libmm2.a', 'ios/')
            print('successfully copied bins from cache')
            return
        except FileNotFoundError as e:
            logging.error(e)
            logging.error('ERROR no mm2 bins in cache, lets download...')

    #just in case cache could be broken or something
    try:
        shutil.rmtree('mm2bins')
    except FileNotFoundError:
        pass

    os.mkdir('mm2bins')
    restore_android_mm2_from_aws()
    restore_ios_libmm2_from_aws()
    try:
        shutil.move('mm2', 'mm2bins/')
        shutil.move('libmm2.a', 'mm2bins/')
        shutil.copy('mm2bins/mm2', 'assets/')
        shutil.copy('mm2bins/libmm2.a', 'ios/')
        print('successfully downloaded and copied mm2 binaries from aws')
    except FileNotFoundError as e:
        logging.error('somehow mm2 binaries didnt download. check logs.')
        logging.error(e)


def restore_android_mm2_from_aws():
    file_name = 'mm2'
    bucket = 'dthbezumniy'
    object_name = 'mm2'
    s3_client = boto3.client('s3')
    try:
        s3_client.download_file(bucket, object_name, file_name)
    except ClientError as e:
        logging.error(e)
        logging.error('AWS-S3 ANDROID mm2 DOWNLOAD: FAILURE')
    print('AWS-S3 android mm2 DOWNLOAD: SUCCESS')


def restore_ios_libmm2_from_aws():
    file_name = 'libmm2.a'
    bucket = 'dthbezumniy'
    object_name = 'libmm2.a'
    s3_client = boto3.client('s3')
    try:
        s3_client.download_file(bucket, object_name, file_name)
    except ClientError as e:
        logging.error(e)
        logging.error('AWS-S3 iOS libmm2.a DOWNLOAD: FAILURE')
    print('AWS-S3 ios libmm2.a DOWNLOAD: SUCCESS')


if __name__ == "__main__":
    main()
