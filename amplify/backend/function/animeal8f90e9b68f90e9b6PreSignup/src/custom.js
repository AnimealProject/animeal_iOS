/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event, context) => {
  console.log('Received EVENT: ', JSON.stringify(event, null, 2));
  if (event.request.userAttributes.phone_number) {
    event.response.autoVerifyPhone = true;
  }
  event.response.autoConfirmUser = true;
  console.log('Received EVENT: ', JSON.stringify(event, null, 2));
  return event;
};
