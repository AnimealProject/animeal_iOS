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

const getUser = async (username, userPoolId) => {
  const params = {
    UserPoolId: userPoolId,
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


module.exports = module.exports = {
  approveFeeding,
  getUser,
};
