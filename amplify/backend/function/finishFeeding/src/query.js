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

const updateFeedingPoint = async (params) =>
  request(
    `mutation UpdateFeedingPoint(
      $input: UpdateFeedingPointInput!
      $condition: ModelFeedingPointConditionInput
    ) {
      updateFeedingPoint(input: $input, condition: $condition) {
        id
        name
        description
        city
        street
        address
        images
        point {
          type
          coordinates
        }
        location {
          lat
          lon
        }
        region
        neighborhood
        distance
        status
        i18n {
          locale
          name
          description
          city
          street
          address
          region
          neighborhood
        }
        statusUpdatedAt
        createdAt
        updatedAt
        createdBy
        updatedBy
        owner
        pets {
          items {
            id
            petId
            feedingPointId
            pet {
              id
              name
              images
              breed
              color
              chipNumber
              vaccinatedAt
              yearOfBirth
              createdAt
              updatedAt
              createdBy
              updatedBy
              owner
              cover
              petCategoryId
            }
            feedingPoint {
              id
              name
              description
              city
              street
              address
              images
              region
              neighborhood
              distance
              status
              statusUpdatedAt
              createdAt
              updatedAt
              createdBy
              updatedBy
              owner
              cover
              feedingPointCategoryId
            }
            createdAt
            updatedAt
            owner
          }
          nextToken
        }
        category {
          id
          name
          icon
          tag
          i18n {
            locale
            name
          }
          createdAt
          updatedAt
          createdBy
          updatedBy
          owner
        }
        users {
          items {
            id
            userId
            feedingPointId
            feedingPoint {
              id
              name
              description
              city
              street
              address
              images
              region
              neighborhood
              distance
              status
              statusUpdatedAt
              createdAt
              updatedAt
              createdBy
              updatedBy
              owner
              cover
              feedingPointCategoryId
            }
            createdAt
            updatedAt
            owner
          }
          nextToken
        }
        cover
        feedingPointCategoryId
      }
    }
`,
    params,
  );

const approveFeeding = async (params) => {
  return request(
    `
    mutation ApproveFeeding(
      $feedingId: String!
      $reason: String!
      $feeding: FeedingInput
    ) {
      approveFeeding(feedingId: $feedingId, reason: $reason, feeding: $feeding)
    }
  `,
    params,
  );
};

const getUser = async (username) => {
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
};

const updateFeedingExt = async (params) =>
  request(
    `  mutation UpdateFeedingExt($input: UpdateFeedingInput!) {
      updateFeedingExt(input: $input) {
        id
        userId
        images
        status
        createdAt
        updatedAt
        createdBy
        updatedBy
        owner
        feedingPointDetails {
          address
        }
        feedingPointFeedingsId
        expireAt
        assignedModerators
        moderatedBy
        moderatedAt
      }
    }`,
    params,
  );

const getActiveFeeding = async (dynamoDB, feedingPointId) => {
  const feedingPointConstraintsItem = await dynamoDB
    .get({
      Key: {
        id: feedingPointId,
      },
      TableName: process.env.API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME,
    })
    .promise();
  if (!feedingPointConstraintsItem.Item) {
    throw new Error('Feeding not found');
  }

  const feedingItem = await dynamoDB
    .get({
      TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
      Key: {
        id: feedingPointConstraintsItem.Item.feedingHistoryId,
      },
    })
    .promise();
  if (!feedingItem.Item) {
    throw new Error('Feeding not found');
  }

  return feedingItem.Item;
};

const expiresInHours = (hours) => {
  return Math.floor((new Date().getTime() + hours * 60 * 60 * 1000) / 1000);
};

const updateFeedingAsPending = async (dynamoDB, feeding, images) => {
  const feedingStatus = 'pending';
  const updatedAt = new Date().toISOString();
  await dynamoDB
    .transactWrite({
      TransactItems: [
        {
          Update: {
            TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
            Key: {
              id: feeding.id,
            },
            ExpressionAttributeValues: {
              ':value': feedingStatus,
              ':inProgress': 'inProgress',
              ':images': images,
              ':updated_at': updatedAt,
              ':expireAt': expiresInHours(12),
            },
            ExpressionAttributeNames: {
              '#status': 'status',
            },
            UpdateExpression:
              'SET #status = :value, images = :images, updated_at = :updated_at, expireAt = :expireAt',
            ConditionExpression:
              'attribute_exists(id) AND #status = :inProgress',
          },
        },
        {
          Update: {
            TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
            Key: {
              id: feeding.feedingPointFeedingsId,
            },
            ExpressionAttributeValues: {
              ':value': feedingStatus,
              ':inProgress': 'inProgress',
            },
            ExpressionAttributeNames: {
              '#status': 'status',
            },
            UpdateExpression: 'SET #status = :value',
            ConditionExpression:
              'attribute_exists(id) AND #status = :inProgress',
          },
        },
      ],
    })
    .promise();

  await updateFeedingExt({
    input: {
      ...feeding,
      status: feedingStatus,
      images,
      updatedAt,
    },
  });

  const updateFeedingPointRes = await updateFeedingPoint({
    input: {
      id: feeding.feedingPointFeedingsId,
      statusUpdatedAt: updatedAt,
    },
  });

  if (updateFeedingPointRes?.data?.errors?.length) {
    throw new Error(JSON.stringify(updateFeedingPointRes.data?.errors));
  }
};

module.exports = {
  approveFeeding,
  getUser,
  updateFeedingExt,
  updateFeedingPoint,
  updateFeedingAsPending,
  getActiveFeeding,
};
