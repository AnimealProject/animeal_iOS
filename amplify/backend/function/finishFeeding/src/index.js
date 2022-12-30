/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGHISTORYTABLE_ARN
	API_ANIMEAL_FEEDINGHISTORYTABLE_NAME
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

const { approveFeeding } = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;
  const images = event.arguments.images;

  if (images.length < 1) {
    throw new Error('Images are required');
  }

  if (process.env.IS_APPROVAL_ENABLED === 'true') {
    try {
      await dynamoDB
        .transactWrite({
          TransactItems: [
            {
              Update: {
                ExpressionAttributeValues: {
                  ':value': 'pending',
                  ':images': images,
                },
                Key: {
                  id: feedingId,
                },
                ExpressionAttributeNames: {
                  '#status': 'status',
                },
                TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
                UpdateExpression: 'SET #status = :value, images = :images',
                ConditionExpression: 'attribute_exists(id)',
              },
            },
          ],
        })
        .promise();
      return feedingId;
    } catch (e) {
      throw new Error(`Failed to finish feeding. Erorr: ${e.message}`);
    }
  } else {
    const approveFeedingRes = await approveFeeding({
      feedingId,
    });

    if (approveFeedingRes.data?.errors?.length) {
      throw new Error(
        `Failed to finish Feeding. Error: ${JSON.stringify(
          approveFeedingRes.data?.errors,
        )}`,
      );
    }
  }
  return feedingId;
};
