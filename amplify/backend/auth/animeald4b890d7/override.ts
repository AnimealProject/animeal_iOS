import { AmplifyAuthCognitoStackTemplate } from '@aws-amplify/cli-extensibility-helper';

export function override(resources: AmplifyAuthCognitoStackTemplate) {
  const amplifyMetaJson = require('../../../amplify-meta.json');
  const accountId = amplifyMetaJson.providers.awscloudformation.StackId.split(':').slice(-2, -1).pop();
  const region = amplifyMetaJson.providers.awscloudformation.StackId.split(':').slice(-3, -2).pop();

  resources.userPool.emailConfiguration = {
    emailSendingAccount: 'DEVELOPER',
    from: 'no-reply@animeal.ge',
    sourceArn: `arn:aws:ses:${region}:${accountId}:identity/animeal.ge`,
  };

  const myCustomAttribute = [
    {
      name: 'trusted',
      attributeDataType: 'String',
      developerOnlyAttribute: false,
      mutable: true,
      required: false,
      stringAttributeConstraints: {
        minLength: '1',
        maxLength: '256',
      },
    }
  ];
  resources.userPool.schema = [...(resources.userPool.schema as any[]), ...myCustomAttribute];
}
