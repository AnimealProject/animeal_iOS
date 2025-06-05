/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_ARN
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME
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
const {
  updateFeedingPoint,
  getFeeding,
  createFeedingHistoryExt,
  deleteFeedingExt,
} = require('./query');

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

  const isCalledBySystem =
    isApprovalTimeExpiredReason(reason) || isFeedingTimeExpiredReason(reason);

  if (
    process.env.IS_APPROVAL_ENABLED !== 'true' &&
    event.fieldName === 'rejectFeeding' &&
    !isApprovalTimeExpiredReason(reason) &&
    !isFeedingTimeExpiredReason(reason)
  ) {
    throw new Error(`Operation isn't allowed. Approval process is disabled.`);
  }

  let feeding = null;

  const feedingPointConstraintsItem = await dynamoDB
    .get({
      Key: {
        id: feedingId,
      },
      TableName: process.env.API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME,
    })
    .promise();

  if (feedingInput) {
    feeding = feedingInput;
  } else {
    const feedingRes = await getFeeding({
      id: feedingPointConstraintsItem.Item.feedingHistoryId,
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
    const feedingHistoryItem = {
      id: feeding.id,
      userId: feeding.userId,
      images: feeding.images,
      createdAt: feeding.createdAt,
      updatedAt: feeding.updatedAt,
      createdBy: feeding.createdBy,
      updatedBy: feeding.updatedBy,
      owner: feeding.owner,
      feedingPointId: feeding.feedingPointFeedingsId,
      feedingPointDetails: feeding.feedingPointDetails,
      assignedModerators: feeding.assignedModerators,
      status: !isApprovalTimeExpiredReason(reason) ? 'rejected' : 'outdated',
      reason,
      moderatedBy: isCalledBySystem
        ? 'System'
        : event?.identity?.username
        ? event?.identity?.username
        : 'Admin',
      moderatedAt: new Date().toISOString(),
    };
    await dynamoDB
      .transactWrite({
        TransactItems: [
          {
            Delete: {
              TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
              Key: {
                id: feeding.id,
              },
              ConditionExpression: ConditionExpression
                ? `${ConditionExpression} ${
                    (event.fieldName === 'rejectFeeding' &&
                      !isFeedingTimeExpiredReason(reason)) ||
                    (!feedingInput &&
                      event.fieldName !== 'cancelFeeding' &&
                      event.fieldName !== 'expireFeeding')
                      ? 'AND #status = :pending'
                      : 'AND #status = :inProgress'
                  }`
                : ConditionExpression,

              ExpressionAttributeValues: ConditionExpression
                ? (event.fieldName === 'rejectFeeding' &&
                    !isFeedingTimeExpiredReason(reason)) ||
                  (!feedingInput &&
                    event.fieldName !== 'cancelFeeding' &&
                    event.fieldName !== 'expireFeeding')
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
            Delete: {
              Key: {
                id: feeding.feedingPointFeedingsId,
              },
              TableName: process.env.API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME,
              ConditionExpression: 'attribute_exists(id)',
            },
          },
          {
            Put: {
              Item: feedingHistoryItem,
              TableName: process.env.API_ANIMEAL_FEEDINGHISTORYTABLE_NAME,
            },
          },
          {
            Update: {
              Key: {
                id: feeding.feedingPointFeedingsId,
              },
              ExpressionAttributeNames: {
                '#status': 'status',
              },
              ExpressionAttributeValues:
                (event.fieldName === 'rejectFeeding' &&
                  !isFeedingTimeExpiredReason(reason)) ||
                (!feedingInput &&
                  event.fieldName !== 'cancelFeeding' &&
                  event.fieldName !== 'expireFeeding')
                  ? {
                      ':pending': 'pending',
                      ':value': 'starved',
                      ':date': new Date().toISOString(),
                    }
                  : {
                      ':inProgress': 'inProgress',
                      ':value': 'starved',
                      ':date': new Date().toISOString(),
                    },
              TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
              UpdateExpression: 'SET #status = :value, statusUpdatedAt = :date',

              ConditionExpression:
                (event.fieldName === 'rejectFeeding' &&
                  !isFeedingTimeExpiredReason(reason)) ||
                (!feedingInput &&
                  event.fieldName !== 'cancelFeeding' &&
                  event.fieldName !== 'expireFeeding')
                  ? 'attribute_exists(id) AND #status = :pending'
                  : 'attribute_exists(id) AND #status = :inProgress',
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

    await createFeedingHistoryExt({
      input: feedingHistoryItem,
    });

    await deleteFeedingExt({
      input: feeding,
    });

    if (updateRes?.data?.errors?.length) {
      throw new Error('Failed to reject Feeding.');
    }
    return feedingId;
  } catch (e) {
    throw new Error(`Failed to reject Feeding. Error: ${e.message}`);
  }
};
