/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const { listGroupsForUser } = require('./queries');

exports.handler = async (event, context) => {
  switch (event.triggerSource) {
    case 'CustomMessage_AdminCreateUser': {
      const message =
        'Your username is {username} and temporary password is {####}';
      event.response.emailMessage = message;
      event.response.emailSubject = 'Your temporary password';
      event.response.smsMessage = message;
      break;
    }
    case 'CustomMessage_ForgotPassword': {
      const { Groups } = await listGroupsForUser(
        event.userPoolId,
        event.userName,
      );
      if (
        !Groups.some(
          (group) =>
            group.GroupName == 'Moderator' ||
            group.GroupName == 'Administrator',
        )
      ) {
        throw new Error(
          'Sorry, you do not have permissions. Please ask Administrator for support',
        );
      }
    }
  }

  return event;
};
