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

const updateFeedingPoint = async (params) => {
  return request(
    `mutation UpdateFeedingPoint(
      $input: UpdateFeedingPointInput!
      $condition: ModelFeedingPointConditionInput
    ) {
      updateFeedingPoint(input: $input, condition: $condition) {
        id
        status
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


module.exports = {
  updateFeedingPoint,
  getFeeding
};
