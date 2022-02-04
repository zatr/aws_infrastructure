import json
import logging
import boto3


def start_test_runner(event, context):
    job_id = event['CodePipeline.job']['id']
    print(f"Received event: CodePipeline.job: {job_id}")
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.debug(json.dumps(event))

    codepipeline = boto3.client('codepipeline')
    response = codepipeline.put_job_success_result(jobId=job_id)
    logger.debug(response)
