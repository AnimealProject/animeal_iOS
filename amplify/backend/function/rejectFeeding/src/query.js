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
        feedingPointFeedingsId
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
  updateFeedingPoint,
  getFeedingPoint,
};
