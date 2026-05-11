import { AmplifyUserPoolGroupStackTemplate } from '@aws-amplify/cli-extensibility-helper';

export function override(resources: AmplifyUserPoolGroupStackTemplate) {
  resources.roleMapLambdaFunction.runtime = 'nodejs16.x';
}
