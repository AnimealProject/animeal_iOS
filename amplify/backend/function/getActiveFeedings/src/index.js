/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
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

  const { feedingPointId, moderatorId, status } = event.arguments;

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
    filter.push('feedingPointFeedingsId = :feedingPointId')
    values[':feedingPointId'] = feedingPointId;
  }

  // if filter by 'feedingPointId' but not 'status' do not filter by status
  if (!feedingPointId || status) {
    filter.push('#status = :status')
    values[':status'] = status ?? "pending";
    attributeNames['#status'] = 'status';
  }

  try
  {
    const scanParams = {
      TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
      FilterExpression: filter.join(' AND '),
      ExpressionAttributeValues: values,
      ExpressionAttributeNames: Object.keys(attributeNames).length
        ? attributeNames
        : null,
    };

    const feedingRes = await dynamoDB.scan(scanParams).promise();
    return feedingRes.Items;
  } catch (e) {
    throw new Error(`Failed to get Active feedings. Error: ${e.message}`);
  }
};
