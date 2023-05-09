import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda'
import * as path from 'path'
import * as logs from 'aws-cdk-lib/aws-logs'
// import { HttpUrlIntegration, HttpLambdaIntegration } from '@aws-cdk/aws-apigatewayv2-integrations-alpha';
import * as apigwv2 from '@aws-cdk/aws-apigatewayv2-alpha'
// import * as apigwv2integrations from '@aws-cdk/aws-apigatewayv2-integrations-alpha'
import { HttpLambdaIntegration } from '@aws-cdk/aws-apigatewayv2-integrations-alpha'
import { mainModule } from 'process';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CcSyncStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here

    // example resource
    // const queue = new sqs.Queue(this, 'CcSyncQueue', {
    //   visibilityTimeout: cdk.Duration.seconds(300)
    // });

    const testFunction = new lambda.Function(this, 'TestFunction', {
      code: lambda.Code.fromAsset(path.join(__dirname, '/../assets/lambda')),
      handler: 'index.handler',
      runtime: lambda.Runtime.PYTHON_3_10,
      architecture: lambda.Architecture.X86_64,
      description: 'test-function',
      // logRetention: logs.RetentionDays.ONE_WEEK
      memorySize: 128,
      timeout: cdk.Duration.seconds(10)
    })

    const testIntegration = new HttpLambdaIntegration('TestIntegration', testFunction)

    // const testIntegration = new apigwv2.HttpIntegration(this, 'TestIntegration', {

    // })

    // apigwv2.httpInt

    const testApi = new apigwv2.HttpApi(this, 'TestApi')

    testApi.addRoutes({
      path: '/hello',
      methods: [apigwv2.HttpMethod.GET],
      integration: testIntegration
    })


  }
}
