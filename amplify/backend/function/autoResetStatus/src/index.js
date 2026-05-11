/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
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
const { resetFeedingPointStatus } = require('./query');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});

// reset feeding points has been fed 12 hours ago
exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  const hours = (val) => val * 60 * 60 * 1000;

  try {
    const filter = [
      '#status = :status',
      'statusUpdatedAt < :past12hours'
    ];
    const attributeNames = {
      '#status': 'status'
    };
    const values = {
      ':status': 'fed',
      ':past12hours': new Date(new Date().getTime() - hours(12)).toISOString()
    };

    const scanParams = {
      TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
      FilterExpression: filter.join(' AND '),
      ExpressionAttributeValues: values,
      ExpressionAttributeNames: attributeNames
    };

    const feedinPointsRes = await dynamoDB.scan(scanParams).promise();
    for (const record of feedinPointsRes.Items) {
      await resetFeedingPointStatus(dynamoDB, record.id, 'starved');
    }
  } catch (e) {
    throw new Error(
      `Failed to Auto reset feeding points statuses. Error: ${e.message}`,
    );
  }
};
