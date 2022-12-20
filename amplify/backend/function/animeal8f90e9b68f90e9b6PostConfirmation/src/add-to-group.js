const aws = require('aws-sdk');

const cognitoidentityserviceprovider = new aws.CognitoIdentityServiceProvider();

/**
 * @type {import('@types/aws-lambda').PostConfirmationTriggerHandler}
 */
exports.handler = async (event) => {
  const groupParams = {
    GroupName: process.env.GROUP,
    UserPoolId: event.userPoolId,
  };
  const addUserParams = {
    GroupName: process.env.GROUP,
    UserPoolId: event.userPoolId,
    Username: event.userName,
  };
  try {
    await cognitoidentityserviceprovider.getGroup(groupParams).promise();
  } catch (e) {
    await cognitoidentityserviceprovider.createGroup(groupParams).promise();
  }

  await cognitoidentityserviceprovider
    .adminAddUserToGroup(addUserParams)
    .promise();
  if (event.request.userAttributes.email) {
    if (
      event.request.userAttributes['cognito:user_status'] ===
      'EXTERNAL_PROVIDER'
    ) {

      var params = {
        UserAttributes: [
          {
            Name: 'email_verified',
            Value: 'true',
          },
        ],
        UserPoolId: event.userPoolId,
        Username: event.userName,
      };

      await cognitoidentityserviceprovider
        .adminUpdateUserAttributes(params)
        .promise();
    }
  }
  return event;
};
