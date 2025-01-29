**Genomics Test**


**System Architecture and Flow**

The system is based on the following components:

**S3 Buckets:** There are two S3 buckets, Bucket A and Bucket B. Bucket A is used as the source bucket where users upload their .jpg images. Bucket B is the destination bucket where the images will be saved after the EXIF metadata is stripped.

**Lambda Function**: A Lambda function is set up to be triggered every time an image is uploaded to Bucket A. The function reads the image, removes the EXIF metadata, and then saves the clean image to Bucket B.

**EventBridge:** An EventBridge rule is used to listen for new object uploads in Bucket A. When a .jpg file is uploaded, the rule triggers the Lambda function to start processing.

**IAM Roles and Policies:** AWS IAM roles and policies control the permissions for the Lambda function and users. These policies ensure that the system operates securely and efficiently, with specific actions allowed for different users.

![Untitled Diagram](https://github.com/user-attachments/assets/06bf3aa5-9fd8-4866-b320-8a2c888793b6)

**TASK1**

The task1.tf file is responsible for setting up the infrastructure to automate the process of removing EXIF metadata from images uploaded to an S3 bucket. It begins by creating two S3 buckets: Bucket A, which acts as the source for uploaded .jpg images, and Bucket B, where the processed images are stored. Both buckets have versioning and encryption enabled, ensuring data integrity and security throughout the process.

To handle the metadata removal, a Lambda function is created. This function is triggered whenever a .jpg image is uploaded to Bucket A, stripping the metadata and saving the processed image to Bucket B. The Lambda function requires the necessary permissions to access both buckets, so an IAM execution role is created and associated with the function. The role is granted permissions to read from Bucket A and write to Bucket B.

Additionally, an IAM policy is attached to the Lambda role, specifying the exact permissions needed for accessing the S3 buckets. To complete the automation, an EventBridge rule is set up to trigger the Lambda function whenever a .jpg file is uploaded to Bucket A, ensuring the image is processed automatically.

**TASK2**

The task2.tf file focuses on creating IAM users with specific access permissions to the S3 buckets. It defines two users, User A and User B, each with distinct roles. User A is granted full permissions to Bucket A, enabling them to upload, retrieve, and list objects in this source bucket. On the other hand, User B is assigned read-only access to Bucket B, allowing them to view and download images that have been processed and stored in the destination bucket, but not to modify any objects.

To enforce these permissions, the file creates IAM policies for each user. User A’s policy allows them to perform actions like PutObject, GetObject, and ListBucket within Bucket A. Meanwhile, User B’s policy restricts them to GetObject and ListBucket permissions for Bucket B, ensuring they can only view and download files from the processed images bucket.


**Image Processor Lambda**

he lambda.py file contains the code for the Lambda function that processes images uploaded to Bucket A. This function is triggered automatically when a .jpg image is uploaded to the source bucket. It performs the task of removing EXIF metadata from the image before saving it to Bucket B.

Upon triggering, the Lambda function first downloads the image from Bucket A. It then uses Python’s PIL (Python Imaging Library) to strip the EXIF metadata, creating a new image without the metadata. The image is then saved to a BytesIO object, preserving the image's format. Finally, the processed image is uploaded to Bucket B, keeping the same file path and name as the original image.
