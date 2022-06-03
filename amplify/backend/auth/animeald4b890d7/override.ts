import { AmplifyAuthCognitoStackTemplate } from '@aws-amplify/cli-extensibility-helper';

export function override(resources: AmplifyAuthCognitoStackTemplate) {

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
