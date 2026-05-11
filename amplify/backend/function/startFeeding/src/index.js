/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_ARN
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME
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
const uuid = require('uuid');
const {
  getFeedingPoint,
  getUser,
  getUsersByFeedingPointId,
  createActiveFeeding,
  expiresInHours,
} = require('./query');
const PromiseBL = require('bluebird');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});

async function sendPush(tokens) {
  const addresses = Object.fromEntries(
    tokens.filter((t) => !!t).map((token) => [token, { ChannelType: 'GCM' }]),
  );
  if (!Object.keys(addresses).length) return;

  const params = {
    ApplicationId: process.env.MESSAGING_ANIMEAL_APPLICATION_ID,
    MessageRequest: {
      Addresses: addresses,
      MessageConfiguration: {
        GCMMessage: {
          RawContent: JSON.stringify({
            notification: {
              title: 'Animeal',
              body: 'Feeding is started',
            },
            data: { action: 'startFeeding' },
          }),
        },
      },
    },
  };

  try {
    const client = new AWS.Pinpoint({ region: process.env.REGION });
    const response = await client.sendMessages(params).promise();
    console.log('Push:', JSON.stringify(response, null, 2));
  } catch (err) {
    console.error('Push:', err);
  }
}

exports.handler = async (event, context, callback) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  if (!event?.identity?.username) {
    throw new Error('User is not authenticated');
  }

  const { feedingPointId } = event.arguments;

  try {
    const feedingPointRes = await getFeedingPoint({ id: feedingPointId });
    if (feedingPointRes?.data?.errors?.length) {
      throw new Error(JSON.stringify(feedingPoint.data?.errors));
    }

    const feedingPoint = feedingPointRes.data.data.getFeedingPoint;
    if (feedingPoint.disabled) {
      throw new Error('The feeding point is inactive');
    }

    if (feedingPoint.status !== 'starved') {
      throw new Error('The feeding point has sufficient supply');
    }

    const users = await getUsersByFeedingPointId({
      feedingPointId,
    });
    if (users?.data?.errors?.length) {
      throw new Error(JSON.stringify(users.data?.errors));
    }

    const assignedModerators = await PromiseBL.map(
      users.data.data.relationUserFeedingPointByFeedingPointId.items,
      (user) => getUser(user.userId).catch(() => null),
      {
        concurrency: 5,
      },
    ).filter((it) => it);

    const createdAt = new Date().toISOString();
    const feedingItem = {
      id: uuid.v4(),
      images: [],
      status: 'inProgress',
      feedingPointFeedingsId: feedingPointId,
      userId: event.identity.username,
      expireAt: expiresInHours(1),
      createdAt,
      updatedAt: createdAt,
      feedingPointDetails: {
        address: feedingPoint.address,
      },
      assignedModerators: assignedModerators.map((it) => it.Username),
    };

    await createActiveFeeding(dynamoDB, assignedModerators, feedingItem);

    // test sending push notifications to moderators
    const tokens = assignedModerators.map(
      (m) =>
        m.UserAttributes.find((atr) => atr.Name === 'custom:messaging_token')
          ?.Value,
    );

    await sendPush(tokens);

    return feedingPointId;
  } catch (e) {
    throw new Error(`Failed to Start feeding. Error: ${e.message}`);
  }
};
