/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT *//* Amplify Params - DO NOT EDIT
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

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;

  try {
    await dynamoDB
      .transactWrite({
        TransactItems: [
          {
            Delete: {
              TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
              Key: {
                id: feedingId,
              },
              ConditionExpression: 'attribute_exists(id)',
            },
          },
          {
            Update: {
              ExpressionAttributeValues: {
                ':value': 'starved',
                ':date': new Date().toISOString(),
              },
              Key: {
                id: feedingId,
              },
              ExpressionAttributeNames: {
                '#status': 'status',
              },
              TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
              UpdateExpression: 'SET #status = :value, statusUpdatedAt = :date',
              ConditionExpression: 'attribute_exists(id)',
            },
          },
        ],
      })
      .promise();
    return feedingId;
  } catch (e) {
    throw new Error(`Failed to reject Feeding. Error: ${e.message}`);
  }
};
