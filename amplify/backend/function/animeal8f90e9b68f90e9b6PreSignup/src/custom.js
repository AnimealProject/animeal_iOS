/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
 exports.handler = async (event, context) => {
  console.log('Received EVENT: ', JSON.stringify(event, null, 2));
  event.response.autoConfirmUser = true;
  event.response.autoVerifyPhone = true;
  console.log('Received EVENT: ', JSON.stringify(event, null, 2));
  return event;
};
