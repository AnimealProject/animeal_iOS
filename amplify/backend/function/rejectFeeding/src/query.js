const axios = require('axios');

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

const getFeeding = async (params) => {
  return request(
    `
    query GetFeeding($id: ID!) {
      getFeeding(id: $id) {
        id
        userId
        images
        status
        createdAt
        feedingPointFeedingsId
        updatedAt
        createdBy
        updatedBy
        owner
        feedingPointDetails {
          address
        }
        expireAt
        assignedModerators
        moderatedBy
        moderatedAt
      }
    }
`,
    params,
  );
};
const createFeedingHistoryExt = async (params) => {
  return request(
    `
    mutation CreateFeedingHistoryExt($input: CreateFeedingHistoryInput!) {
      createFeedingHistoryExt(input: $input) {
        id
        userId
        images
        createdAt
        updatedAt
        createdBy
        updatedBy
        owner
        feedingPointId
        feedingPointDetails {
          address
        }
        status
        reason
        moderatedBy
        moderatedAt
        assignedModerators
      }
    }
  `,
    params,
  );
};

const deleteFeedingExt = async (params) => {
  return request(
    `
  mutation DeleteFeedingExt($input: DeleteFeedingExtInput!) {
    deleteFeedingExt(input: $input) {
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
  }
`,
    params,
  );
};

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

  const feedingRes = await getFeeding({
    id: feedingPointConstraintsItem.Item.feedingHistoryId,
  });
  if (feedingRes.data?.errors?.length) {
    throw new Error(JSON.stringify(feedingRes.data.errors));
  }

  if (!feedingRes.data.data.getFeeding) {
    throw new Error('Feeding not found');
  }

  return feedingRes.data.data.getFeeding;
};

const moveFeedingToHistory = async (
  dynamoDB,
  feeding,
  moderatedBy,
  reason,
  status,
  checkFeedingOnDelete,
) => {
  const updatedAt = new Date().toISOString();
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
    status,
    reason,
    moderatedBy,
    moderatedAt: updatedAt,
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
            ConditionExpression: checkFeedingOnDelete
              ? 'attribute_exists(id)'
              : null,
          },
        },
        {
          Delete: {
            TableName: process.env.API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME,
            Key: {
              id: feeding.feedingPointFeedingsId,
            },
            ConditionExpression: 'attribute_exists(id)',
          },
        },
        {
          Put: {
            TableName: process.env.API_ANIMEAL_FEEDINGHISTORYTABLE_NAME,
            Item: feedingHistoryItem,
          },
        },
        {
          Update: {
            TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
            Key: {
              id: feeding.feedingPointFeedingsId,
            },
            ExpressionAttributeNames: {
              '#status': 'status',
            },
            ExpressionAttributeValues: {
              ':value': 'starved',
              ':date': updatedAt,
            },
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
      statusUpdatedAt: updatedAt,
    },
  });

  await createFeedingHistoryExt({
    input: feedingHistoryItem,
  });

  await deleteFeedingExt({
    input: feeding,
  });

  if (updateRes?.data?.errors?.length) {
    throw new Error(JSON.stringify(updateRes.data.errors));
  }
};

module.exports = {
  updateFeedingPoint,
  getFeeding,
  createFeedingHistoryExt,
  deleteFeedingExt,
  getActiveFeeding,
  moveFeedingToHistory,
};
