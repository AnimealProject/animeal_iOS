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
Amplify Params - DO NOT EDIT */ /* Amplify Params - DO NOT EDIT
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
var uuid = require('uuid');
const dynamoDB = new AWS.DynamoDB.DocumentClient({});
const { updateFeedingPoint, getFeeding } = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;
  const reason = event.arguments.reason;
  const feedingInput = event.arguments.feeding;
  const ConditionExpression = !feedingInput ? 'attribute_exists(id)' : null;

  const isApprovalTimeExpiredReason = (reason) =>
    /Approval time has expired/gi.test(reason);

  const isFeedingTimeExpiredReason = (reason) =>
    /Feeding time has expired/gi.test(reason);

  if (
    process.env.IS_APPROVAL_ENABLED !== 'true' &&
    event.fieldName === 'rejectFeeding' &&
    !isApprovalTimeExpiredReason(reason) &&
    !isFeedingTimeExpiredReason(reason)
  ) {
    throw new Error(`Operation isn't allowed. Approval process is disabled.`);
  }

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
            Delete: {
              TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
              Key: {
                id: feedingId,
              },
              ConditionExpression: ConditionExpression
                ? `${ConditionExpression} ${
                    event.fieldName === 'rejectFeeding' &&
                    !isFeedingTimeExpiredReason(reason)
                      ? 'AND #status = :pending'
                      : 'AND #status = :inProgress'
                  }`
                : ConditionExpression,

              ExpressionAttributeValues: ConditionExpression
                ? event.fieldName === 'rejectFeeding' &&
                  !isFeedingTimeExpiredReason(reason)
                  ? {
                      ':pending': 'pending',
                    }
                  : { ':inProgress': 'inProgress' }
                : null,
              ExpressionAttributeNames: ConditionExpression
                ? {
                    '#status': 'status',
                  }
                : null,
            },
          },
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
                status: !isApprovalTimeExpiredReason(reason)
                  ? 'rejected'
                  : 'outdated',
                reason,
              },
              TableName: process.env.API_ANIMEAL_FEEDINGHISTORYTABLE_NAME,
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
              ConditionExpression,
            },
          },
        ],
      })
      .promise();
    const updateRes = await updateFeedingPoint({
      input: {
        id: feedingId,
        statusUpdatedAt: new Date().toISOString(),
      },
    });

    if (updateRes?.data?.errors?.length) {
      throw new Error('Failed to reject Feeding.');
    }
    return feedingId;
  } catch (e) {
    throw new Error(`Failed to reject Feeding. Error: ${e.message}`);
  }
};
