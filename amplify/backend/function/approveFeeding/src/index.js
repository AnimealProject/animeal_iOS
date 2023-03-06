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

const { getFeeding, updateFeedingPoint } = require('./query');
var uuid = require('uuid');
const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient({});

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  if(process.env.IS_APPROVAL_ENABLED !== 'true') {
    throw new Error(`Operation isn't allowed. Approval process is disabled.`);
  }
  const feedingId = event.arguments.feedingId;
  const feedingInput = event.arguments.feeding;
  const reason = event.arguments.reason;

  let feeding = null;

  if (feedingInput) {
    feeding = feedingInput;
  } else {
    const feedingRes = await getFeeding({
      id: feedingId,
    });

    if (feedingRes.data?.errors?.length) {
      throw new Error('Failed to get Feeding');
    }
    feeding = feedingRes.data.data.getFeeding;
  }

  if (!feeding) {
    throw new Error('Feeding not found');
  }

  try {
    await dynamoDB
      .transactWrite({
        TransactItems: [
          {
            Put: {
              Item: {
                id: uuid.v4(),
                userId: feeding.userId,
                images: feeding.images,
                createdAt: feeding.createdAt,
                updatedAt: feeding.updatedAt,
                createdBy: feeding.createdBy,
                updatedBy: feeding.updatedBy,
                owner: feeding.owner,
                feedingPointId: feeding.feedingPointFeedingsId,
                status: 'approved',
                reason
              },
              TableName: process.env.API_ANIMEAL_FEEDINGHISTORYTABLE_NAME,
            },
          },
          {
            Delete: {
              ExpressionAttributeValues:
                process.env.IS_APPROVAL_ENABLED === 'true'
                  ? {
                      ':pending': 'pending',
                    }
                  : null,
              ExpressionAttributeNames:
                process.env.IS_APPROVAL_ENABLED === 'true'
                  ? {
                      '#status': 'status',
                    }
                  : null,
              TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
              Key: {
                id: feedingId,
              },
              ConditionExpression:
                process.env.IS_APPROVAL_ENABLED === 'true'
                  ? 'attribute_exists(id) AND #status = :pending'
                  : 'attribute_exists(id)',
            },
          },
          {
            Update: {
              ExpressionAttributeValues: {
                ':value': 'fed',
                ':date': new Date().toISOString(),
              },
              Key: {
                id: feeding.feedingPointFeedingsId,
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
    const updateRes = await updateFeedingPoint({
      input: {
        id: feeding.feedingPointFeedingsId,
        statusUpdatedAt: new Date().toISOString(),
      },
    });

    if (updateRes?.data?.errors?.length) {
      throw new Error('Failed to approve feeding.');
    }
    return feedingId;
  } catch (e) {
    throw new Error(`Failed to approve feeding. Erorr: ${e.message}`);
  }
};
