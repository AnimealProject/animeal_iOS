/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGHISTORYTABLE_ARN
	API_ANIMEAL_FEEDINGHISTORYTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient({});

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  if (!event?.identity?.username) {
    throw new Error('User is not authenticated');
  }

  const {
    start,
    end,
    feedingPointId,
    moderatorId,
    status,
  } = event.arguments;

  const defaultPeriodDays = 30;
  const maxPeriodDays = 90;
  let endDate = new Date();
  let startDate = new Date(endDate.getTime() - defaultPeriodDays * 24 * 60 * 60 * 1000);
  if (start) startDate = new Date(start);
  if (end) endDate = new Date(end);

  if (startDate && endDate && endDate - startDate > maxPeriodDays * 24 * 60 * 60 * 1000) {
    throw new Error(`Start date must be within ${maxPeriodDays} days of the End date.`) 
  }

  const filter = [];
  const values = {};
  const attributeNames = {};

  const moderatorIdValue = !event.identity.groups.includes('Administrator') ? event.identity.username : moderatorId;
  // if filter by 'feedingPointId' but not 'moderatorId' do not filter by moderators
  if (moderatorIdValue && (!feedingPointId || moderatorId)) {
    filter.push('contains(assignedModerators, :moderatorId)');
    values[':moderatorId'] = moderatorIdValue;
  }
  if (feedingPointId) {
    filter.push('feedingPointId = :feedingPointId')
    values[':feedingPointId'] = feedingPointId;
  }
  if (status) {
    filter.push('#status = :status')
    values[':status'] = status;
    attributeNames['#status'] = 'status';
  }

  filter.push('createdAt between :startedAt AND :endedAt');
  values[':startedAt'] = startDate.toISOString();
  values[':endedAt'] = endDate.toISOString();

  try
  {
    const scanParams = {
      TableName: process.env.API_ANIMEAL_FEEDINGHISTORYTABLE_NAME,
      FilterExpression: filter.join(' AND '),
      ExpressionAttributeValues: values,
      ExpressionAttributeNames: Object.keys(attributeNames).length
        ? attributeNames
        : null,
    };

    const feedingRes = await dynamoDB.scan(scanParams).promise();
    return feedingRes.Items;
  } catch (e) {
    throw new Error(`Failed to get Historical feedings. Error: ${e.message}`);
  }
};