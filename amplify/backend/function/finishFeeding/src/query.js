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

const updateFeeding = async (params) => {
  return request(
    `
    mutation UpdateFeeding(
      $input: UpdateFeedingInput!
      $condition: ModelFeedingConditionInput
    ) {
      updateFeeding(input: $input, condition: $condition) {
        id
      }
    }
  `,
    params,
  );
};
const approveFeeding = async (params) => {
  return request(
    `
    mutation ApproveFeeding($feedingId: String!, $feeding: FeedingInput) {
      approveFeeding(feedingId: $feedingId, feeding: $feeding)
    }
  `,
    params,
  );
};

module.exports = module.exports = {
  updateFeeding,
  approveFeeding,
};
