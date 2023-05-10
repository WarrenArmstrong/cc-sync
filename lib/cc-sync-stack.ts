import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as path from 'path';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as apigwv2 from '@aws-cdk/aws-apigatewayv2-alpha';
import { HttpLambdaIntegration } from '@aws-cdk/aws-apigatewayv2-integrations-alpha'
import { mainModule } from 'process';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CcSyncStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const apiFunctionRole = new iam.Role(this, 'APIFunctionRole', {
      roleName: 'APIFunctionRole',
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com')
    })

    apiFunctionRole.addManagedPolicy(
      iam.ManagedPolicy.fromManagedPolicyArn(
        this,
        'AWSLambdaBasicExecutionRole',
        'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
      )
    )

    const apiFunction = new lambda.Function(this, 'APIFunction', {
      code: lambda.Code.fromAsset(path.join(__dirname, '/../assets/lambda'), {
        bundling: {
          image: lambda.Runtime.PYTHON_3_10.bundlingImage,
          command: [
            'bash', '-c',
            'pip install -r requirements.txt -t /asset-output && cp -au . /asset-output'
          ]
        }
      }),
      handler: 'index.handler',
      runtime: lambda.Runtime.PYTHON_3_10,
      architecture: lambda.Architecture.X86_64,
      description: 'cc-sync api function',
      logRetention: logs.RetentionDays.ONE_WEEK,
      memorySize: 128,
      timeout: cdk.Duration.seconds(10),
      role: apiFunctionRole
    })

    const lambdaIntegration = new HttpLambdaIntegration('LambdaIntegration', apiFunction)

    const api = new apigwv2.HttpApi(this, 'CCSyncApi')

    api.addRoutes({
      path: '/{branch}',
      methods: [apigwv2.HttpMethod.GET],
      integration: lambdaIntegration
    })
    
  }
}
