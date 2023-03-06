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
const dynamoDB = new AWS.DynamoDB.DocumentClient({});
const { searchFeedingPoints, updateFeedingPoint } = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);


  // expire records last been fed 12 hours ago
  const filterDate = new Date(new Date().getTime() - 12 * 60 * 60 * 1000);
  const filteredFeedingPoints = await searchFeedingPoints({
    filter: {
      status: {
        eq: 'fed',
      },
      statusUpdatedAt: {
        lte: filterDate.toISOString(),
      },
    },
  });
  if (filteredFeedingPoints?.data?.errors) {
    throw new Error('Failed to retrieve Feeding points');
  }
  for (const record of filteredFeedingPoints.data.data.searchFeedingPoints
    .items) {
    try {
      await dynamoDB
        .transactWrite({
          TransactItems: [
            {
              Update: {
                ExpressionAttributeValues: {
                  ':value': 'starved',
                  ':date': new Date().toISOString(),
                },
                Key: {
                  id: record.id,
                },
                ExpressionAttributeNames: {
                  '#status': 'status',
                },
                TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
                UpdateExpression:
                  'SET #status = :value, statusUpdatedAt = :date',
                ConditionExpression: 'attribute_exists(id)',
              },
            },
          ],
        })
        .promise();
      const updateRes = await updateFeedingPoint({
        input: {
          id: record.id,
          statusUpdatedAt: new Date().toISOString(),
        },
      });

      if (updateRes?.data?.errors?.length) {
        throw new Error('Failed to auto reset Fedding points statuses.');
      }
    } catch (e) {
      throw new Error(
        `Failed to auto reset Fedding points statuses. Erorr: ${e.message}`,
      );
    }
  }
};
