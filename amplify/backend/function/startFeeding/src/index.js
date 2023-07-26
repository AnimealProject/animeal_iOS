/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
	API_ANIMEAL_FEEDINGUSERSTABLE_ARN
	API_ANIMEAL_FEEDINGUSERSTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	AUTH_ANIMEAL8F90E9B68F90E9B6_USERPOOLID
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
  getFeedingPoint,
  getUser,
  getUsersByFeedingPointId,
} = require('./query');
const PromiseBL = require('bluebird');

exports.handler = async (event, context, callback) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingPointId = event.arguments.feedingPointId;
  const expireAt = new Date();
  expireAt.setTime(expireAt.getTime() + 1 * 60 * 60 * 1000);

  try {
    const feedingPoint = await getFeedingPoint({ id: feedingPointId });
    const users = await getUsersByFeedingPointId({
      feedingPointId,
    });
    if (feedingPoint?.data?.errors?.length || users?.data?.errors?.length) {
      throw new Error('Failed to get Feeding point data.');
    }
    const assignedModeratorsIds = [];
    const assignedModeratorsDynamoRecords = [];

    const assignedModerators = await PromiseBL.map(
      users.data.data.relationUserFeedingPointByFeedingPointId.items,
      (user) => {
        assignedModeratorsIds.push(user.userId);
        return getUser(user.userId);
      },
      {
        concurrency: 5,
      },
    );
    assignedModerators.forEach((assignedModerator) => {
      assignedModeratorsDynamoRecords.push({
        Put: {
          Item: {
            id: assignedModerator.Username,
            userAttributes: assignedModerator.UserAttributes,
          },
          TableName: process.env.API_ANIMEAL_FEEDINGUSERSTABLE_NAME,
        },
      });
    });

    await dynamoDB
      .transactWrite({
        TransactItems: [
          ...assignedModeratorsDynamoRecords,
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
                feedingPointDetails: {
                  address: feedingPoint.data.data.getFeedingPoint.address,
                },
                assignedModerators: assignedModeratorsIds,
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
      },
    });

    if (updateRes?.data?.errors?.length) {
      throw new Error('Failed to update Feeding point status date.');
    }
    return feedingPointId;
  } catch (e) {
    throw new Error(`Failed to start feeding. Erorr: ${e.message}`);
  }
};
