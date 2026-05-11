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
      }
    }
`,
    params,
  );

const resetFeedingPointStatus = async (dynamoDB, feedingPointId, status) => {
  const updatedAt = new Date().toISOString();
  await dynamoDB
    .transactWrite({
      TransactItems: [
        {
          Update: {
            TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
            ExpressionAttributeValues: {
              ':value': status,
              ':date': updatedAt,
              ':currentStatus': 'fed',
            },
            Key: {
              id: feedingPointId,
            },
            ExpressionAttributeNames: {
              '#status': 'status',
            },
            UpdateExpression: 'SET #status = :value, statusUpdatedAt = :date',
            ConditionExpression:
              'attribute_exists(id) AND #status = :currentStatus',
          },
        },
      ],
    })
    .promise();
  const updateRes = await updateFeedingPoint({
    input: {
      id: feedingPointId,
      statusUpdatedAt: updatedAt,
    },
  });
  if (updateRes?.data?.errors?.length) {
    throw new Error(JSON.stringify(updateRes?.data?.errors));
  }
};

module.exports = {
  updateFeedingPoint,
  resetFeedingPointStatus,
};
