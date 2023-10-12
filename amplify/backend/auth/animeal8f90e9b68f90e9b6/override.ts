import { AmplifyAuthCognitoStackTemplate } from '@aws-amplify/cli-extensibility-helper';

export function override(resources: AmplifyAuthCognitoStackTemplate) {
  const amplifyMetaJson = require('../../../amplify-meta.json');
  const accountId = amplifyMetaJson.providers.awscloudformation.StackId.split(':').slice(-2, -1).pop();
  const region = amplifyMetaJson.providers.awscloudformation.StackId.split(':').slice(-3, -2).pop();

  resources.userPool.autoVerifiedAttributes = ['phone_number'];
  resources.userPool.smsConfiguration = {
    externalId: '34a848dc-25e0-4385-9cf8-380f18bad969',
    snsCallerArn: `arn:aws:iam::${accountId}:role/service-role/animeal-sns-role`,
  };

  resources.userPool.emailConfiguration = {
    emailSendingAccount: 'DEVELOPER',
    from: 'no-reply@animeal.ge',
    sourceArn: `arn:aws:ses:${region}:${accountId}:identity/animeal.ge`,
  };

  (<any>resources.userPool.userAttributeUpdateSettings).attributesRequireVerificationBeforeUpdate = ['phone_number'];

  resources.userPoolClient.tokenValidityUnits = {
    accessToken: 'minutes',
    refreshToken: 'days',
    idToken: 'minutes',
  };

  resources.userPoolClientWeb.tokenValidityUnits = {
    accessToken: 'minutes',
    refreshToken: 'days',
    idToken: 'minutes',
  };

  resources.userPoolClient.accessTokenValidity = 60;
  resources.userPoolClient.refreshTokenValidity = 365;
  resources.userPoolClient.idTokenValidity = 60;

  resources.userPoolClientWeb.accessTokenValidity = 60;
  resources.userPoolClientWeb.refreshTokenValidity = 365;
  resources.userPoolClientWeb.idTokenValidity = 60;

  const myCustomAttribute = [];
  if (!resources.userPool.schema) {
    resources.userPool.schema = [
      {
        name: 'trusted',
        attributeDataType: 'Boolean',
        developerOnlyAttribute: false,
        mutable: true,
        required: false,
      },
      {
        name: 'login_method',
        attributeDataType: 'String',
        developerOnlyAttribute: false,
        mutable: true,
        required: false,
      },
    ];
  }
  resources.userPool.schema = [...(resources.userPool.schema as any[]), ...myCustomAttribute];
}
