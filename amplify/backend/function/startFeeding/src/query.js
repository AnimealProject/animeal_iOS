const axios = require('axios');
const { CognitoIdentityServiceProvider } = require('aws-sdk');
const cognitoIdentityServiceProvider = new CognitoIdentityServiceProvider();

async function request(query, variables) {
  return axios({
    url: process.env.API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT,
    method: 'post',
    headers: {
      'x-api-key': process.env.API_ANIMEAL_GRAPHQLAPIKEYOUTPUT,
    },
    data: {
      query,
      variables,
    },
  });
}

const createFeedingExt = async (params) =>
  request(
    `mutation CreateFeedingExt($input: CreateFeedingInput!) {
      createFeedingExt(input: $input) {
        id
        userId
      }
    }`,
    params,
  );

const updateFeedingPoint = async (params) =>
  request(
    `mutation UpdateFeedingPoint(
      $input: UpdateFeedingPointInput!
      $condition: ModelFeedingPointConditionInput
    ) {
      updateFeedingPoint(input: $input, condition: $condition) {
        id
      }
    }`,
    params,
  );
const getFeedingPoint = async (params) =>
  request(
    `query GetFeedingPoint($id: ID!) {
      getFeedingPoint(id: $id) {
        id
        code
        name
        address
        status
        statusUpdatedAt
        owner
        disabled
      }
    }`,
    params,
  );
const getUsersByFeedingPointId = async (params) =>
  request(
    `query RelationUserFeedingPointByFeedingPointId(
      $feedingPointId: ID!
      $userId: ModelStringKeyConditionInput
      $sortDirection: ModelSortDirection
      $filter: ModelRelationUserFeedingPointFilterInput
      $limit: Int
      $nextToken: String
    ) {
      relationUserFeedingPointByFeedingPointId(
        feedingPointId: $feedingPointId
        userId: $userId
        sortDirection: $sortDirection
        filter: $filter
        limit: $limit
        nextToken: $nextToken
      ) {
        items {
          id
          userId
          owner
        }
        nextToken
      }
    }`,
    params,
  );

async function getUser(username) {
  const params = {
    UserPoolId: process.env.AUTH_ANIMEAL8F90E9B68F90E9B6_USERPOOLID,
    Username: username,
  };

  console.log(`Attempting to retrieve information for ${username}`);

  try {
    const result = await cognitoIdentityServiceProvider
      .adminGetUser(params)
      .promise();
    return result;
  } catch (err) {
    console.log(err);
    throw err;
  }
}

const createActiveFeeding = async (
  dynamoDB,
  assignedModerators,
  feedingItem,
) => {
  const usersDynamoRecords = [];
  assignedModerators.forEach((assignedModerator) => {
    usersDynamoRecords.push({
      Put: {
        TableName: process.env.API_ANIMEAL_FEEDINGUSERSTABLE_NAME,
        Item: {
          id: assignedModerator.Username,
          attributes: assignedModerator.UserAttributes,
        },
      },
    });
  });
  if (!assignedModerators.length) {
    throw new Error("There aren't any active assigned moderators");
  }

  if (
    feedingItem.userId !== 'System' &&
    !usersDynamoRecords.find((it) => it.Put.Item.id === feedingItem.userId)
  ) {
    const user = await getUser(feedingItem.userId);
    usersDynamoRecords.push({
      Put: {
        TableName: process.env.API_ANIMEAL_FEEDINGUSERSTABLE_NAME,
        Item: {
          id: user.Username,
          attributes: user.UserAttributes,
        },
      },
    });
  }

  const createdAt = new Date().toISOString();
  await dynamoDB
    .transactWrite({
      TransactItems: [
        ...usersDynamoRecords,
        {
          Put: {
            TableName: process.env.API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME,
            Item: {
              id: feedingItem.feedingPointFeedingsId,
              feedingHistoryId: feedingItem.id,
            },
            ConditionExpression: 'attribute_not_exists(id)',
          },
        },
        {
          Put: {
            TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
            Item: feedingItem,
          },
        },
        {
          Update: {
            TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
            Key: {
              id: feedingItem.feedingPointFeedingsId,
            },
            ExpressionAttributeValues: {
              ':value': 'inProgress',
              ':date': createdAt,
              ':starved': 'starved',
            },
            ExpressionAttributeNames: {
              '#status': 'status',
            },
            UpdateExpression: 'SET #status = :value, statusUpdatedAt = :date',
            ConditionExpression: `attribute_exists(id) AND #status = :starved`,
          },
        },
      ],
    })
    .promise();
  const updateRes = await updateFeedingPoint({
    input: {
      id: feedingItem.feedingPointFeedingsId,
      statusUpdatedAt: createdAt,
    },
  });

  await createFeedingExt({
    input: feedingItem,
  });
  if (updateRes?.data?.errors?.length) {
    throw new Error(JSON.stringify(updateRes.data?.errors));
  }
};

const expiresInHours = (hours) => {
  return Math.floor((new Date().getTime() + hours * 60 * 60 * 1000) / 1000);
};

module.exports = {
  getFeedingPoint,
  getUser,
  getUsersByFeedingPointId,
  createActiveFeeding,
  expiresInHours,
};
