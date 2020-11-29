export const awsConfig = {
  cw_dashboard: 'https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=EcsLoadTesting-xxxxxx',
  ecs_dashboard: 'https://us-east-1.console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/linkt-app-bff-load-test/tasks',
  aws_project_region: 'us-east-1',
  aws_cognito_region: 'us-east-1',
  aws_cognito_identity_pool_id: 'us-east-1:xxxxxx',
  aws_user_pools_id: 'us-east-1_xxxxxx',
  aws_user_pools_web_client_id: 'xxxxxx',
  oauth: {},
  aws_cloud_logic_custom: [
    {
      name: 'dlts',
      endpoint: 'https://xxxxxx.execute-api.us-east-1.amazonaws.com/prod',
      region: 'us-east-1'
    }
  ],
  aws_user_files_s3_bucket: 'linkt-app-bff-load-test-scenariosbucket-xxxxxx',
  aws_user_files_s3_bucket_region: 'us-east-1',

  Auth: {
    // Amazon Cognito Region
    region: 'us-east-1',

    // Amazon Cognito User Pool ID
    userPoolId: 'us-east-1_xxxxxx',

    // Amazon Cognito Web Client ID (26-char alphanumeric string)
    userPoolWebClientId: 'xxxxxx',

    // Enforce user authentication prior to accessing AWS resources or not
    mandatorySignIn: true,
  }
}
