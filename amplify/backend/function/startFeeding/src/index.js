/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
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
const { updateFeedingPoint } = require('./query');

exports.handler = async (event, context, callback) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingPointId = event.arguments.feedingPointId;
  const expireAt = new Date();
  expireAt.setTime(expireAt.getTime() + 60 * 60 * 1000);

  try {
    await dynamoDB
      .transactWrite({
        TransactItems: [
          {
            Put: {
              Item: {
                id: feedingPointId,
                images: [],
                status: 'inProgress',
                feedingPointFeedingsId: feedingPointId,
                userId: event?.identity?.username || 'admin',
                expireAt: Math.floor(expireAt.getTime() / 1000),
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
              },
              TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
              ConditionExpression: 'attribute_not_exists(id)',
            },
          },
          {
            Update: {
              ExpressionAttributeValues: {
                ':value': 'pending',
                ':date': new Date().toISOString(),
                ':fed': 'fed',
              },
              Key: {
                id: feedingPointId,
              },
              ExpressionAttributeNames: {
                '#status': 'status',
              },
              TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
              UpdateExpression: 'SET #status = :value, statusUpdatedAt = :date',
              ConditionExpression: `attribute_exists(id) AND #status <> :fed`,
            },
          },
        ],
      })
      .promise();
    const updateRes = await updateFeedingPoint({
      input: {
        id: feedingPointId,
        statusUpdatedAt: new Date().toISOString(),
      }
    });

    if (updateRes?.data?.errors?.length) {
      throw new Error('Failed to update Feeding point status date.');
    }
    return feedingPointId;
  } catch (e) {
    throw new Error(`Failed to start feeding. Erorr: ${e.message}`);
  }
};
