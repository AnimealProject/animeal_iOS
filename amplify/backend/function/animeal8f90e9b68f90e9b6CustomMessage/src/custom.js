/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
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
  }

  return event;
};
