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



module.exports = module.exports = {
  approveFeeding,
  getUser,
  updateFeedingExt,
  updateFeedingPoint,
};
