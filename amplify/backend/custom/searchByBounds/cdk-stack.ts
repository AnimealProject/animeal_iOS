import * as cdk from '@aws-cdk/core';
import * as AmplifyHelpers from '@aws-amplify/cli-extensibility-helper';
import * as appsync from '@aws-cdk/aws-appsync';
import * as path from 'path';
import { AmplifyDependentResourcesAttributes } from '../../types/amplify-dependent-resources-ref';

export class cdkStack extends cdk.Stack {
  constructor(
    scope: cdk.Construct,
    id: string,
    props?: cdk.StackProps,
    amplifyResourceProps?: AmplifyHelpers.AmplifyResourceProps,
  ) {
    super(scope, id, props);
    /* Do not remove - Amplify CLI automatically injects the current deployment environment in this input parameter */
    new cdk.CfnParameter(this, 'env', {
      type: 'String',
      description: 'Current Amplify CLI env name',
    });

    // Access other Amplify Resources
    const retVal: AmplifyDependentResourcesAttributes = AmplifyHelpers.addResourceDependency(
      this,
      amplifyResourceProps.category,
      amplifyResourceProps.resourceName,
      [
        {
          category: 'api',
          resourceName: 'animeal',
        },
      ],
    );

    const resolver = new appsync.CfnResolver(this, 'custom-resolver', {
      apiId: cdk.Fn.ref(retVal.api.animeal.GraphQLAPIIdOutput),
      fieldName: 'searchByBounds',
      typeName: 'Query', // Query | Mutation | Subscription
      requestMappingTemplate: appsync.MappingTemplate.fromFile(
        path.join(__dirname, '..', 'Query.searchByBounds.req.vtl'),
      ).renderTemplate(),
      responseMappingTemplate: appsync.MappingTemplate.fromFile(
        path.join(__dirname, '..', 'Query.searchByBounds.res.vtl'),
      ).renderTemplate(),
      dataSourceName: 'OpenSearchDataSource',
    });
  }
}
