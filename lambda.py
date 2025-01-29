import boto3
from PIL import Image
from io import BytesIO

s3 = boto3.client('s3')

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    
    destination_bucket = 'bucket-b'
    destination_key = source_key

    try:
    
        # Download the image from S3
        response = s3.get_object(Bucket=source_bucket, Key=source_key)
        image_content = response['Body'].read()
        
        # Remove metadata
        image = Image.open(BytesIO(image_content))
        image_without_metadata = Image.new(image.mode, image.size)
        image_without_metadata.putdata(list(image.getdata()))
        
        # Save the image without metadata to a BytesIO object
        output = BytesIO()
        image_without_metadata.save(output, format='JPG')
        output.seek(0)
        
        # Upload the image to the destination bucket
        s3.put_object(Bucket=destination_bucket, Key=destination_key, Body=output)
        
        return {
            'statusCode': 200,
            'body': 'Metadata removed and image saved to destination bucket'
        }
    except Exception as e:
        print(f"Error processing file {object_key}: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Error processing file {object_key}: {str(e)}'
        }