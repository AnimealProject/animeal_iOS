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

const deleteFeeding = async (params) => {
  return request(
    `
    mutation DeleteFeeding(
      $input: DeleteFeedingInput!
      $condition: ModelFeedingConditionInput
    ) {
      deleteFeeding(input: $input, condition: $condition) {
        id
      }
    }
  `,
    params,
  );
};

const createFeedingHistory = async (params) => {
  return request(
    `
    mutation CreateFeedingHistory(
      $input: CreateFeedingHistoryInput!
      $condition: ModelFeedingHistoryConditionInput
    ) {
      createFeedingHistory(input: $input, condition: $condition) {
        id
      }
    }
  `,
    params,
  );
};

const updateFeedingPoint = async (params) => {
  return request(
    `mutation UpdateFeedingPoint(
    $input: UpdateFeedingPointInput!
    $condition: ModelFeedingPointConditionInput
  ) {
    updateFeedingPoint(input: $input, condition: $condition) {
      id
    }
  }
`,
    params,
  );
};

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
      updatedAt
      createdBy
      updatedBy
      owner
      feedingPointFeedingsId
    }
  }
`,
    params,
  );
};
const getFeedingPoint = async (params) => {
  return request(
    `query GetFeedingPoint($id: ID!) {
      getFeedingPoint(id: $id) {
        id
        feedingPointCategoryId
      }
  }
`,
    params,
  );
};
module.exports = module.exports = {
  deleteFeeding,
  createFeedingHistory,
  updateFeedingPoint,
  getFeeding,
  getFeedingPoint,
};
