import { AmplifyApiGraphQlResourceStackTemplate } from '@aws-amplify/cli-extensibility-helper';

export function override(resources: AmplifyApiGraphQlResourceStackTemplate) {
  Object.keys(resources.models).forEach((model) => {
    if (resources.models[model].modelDDBTable) {
      resources.models[model].modelDDBTable.pointInTimeRecoverySpecification = {
        pointInTimeRecoveryEnabled: true,
      };
    }
  });

  resources.models["Feeding"].modelDDBTable.timeToLiveSpecification = {
    attributeName: "expireAt",
    enabled: true
  }

  const amplifyMetaJson = require('../../../amplify-meta.json');
  const env = amplifyMetaJson.providers.awscloudformation.StackName.split('-').slice(-2, -1).pop();
  if (env === 'prod') {
    resources.opensearch.OpenSearchDomain.elasticsearchClusterConfig = {
      ...resources.opensearch.OpenSearchDomain.elasticsearchClusterConfig,
      instanceCount: 2,
      instanceType: 't2.medium.elasticsearch',
    };
  } else {
    resources.opensearch.OpenSearchDomain.elasticsearchClusterConfig = {
      ...resources.opensearch.OpenSearchDomain.elasticsearchClusterConfig,
      instanceCount: 1,
    };
  }
}
