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

const listFavourites = async (params) =>
  request(
    `
    query FavouritesByFeedingPointId(
      $feedingPointId: ID!
      $userId: ModelIDKeyConditionInput
      $sortDirection: ModelSortDirection
      $filter: ModelFavouriteFilterInput
      $limit: Int
      $nextToken: String
    ) {
      favouritesByFeedingPointId(
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
          feedingPointId
          createdAt
          updatedAt
          owner
        }
        nextToken
      }
    }
  `,
    params,
  ).then(({ data }) => {
    return data.data.favouritesByFeedingPointId.nextToken
      ? listFavourites({
          ...params,
          nextToken: data.data.favouritesByFeedingPointId.nextToken,
        }).then((items) => data.data.favouritesByFeedingPointId.items.concat(items))
      : data.data.favouritesByFeedingPointId.items;
  });

const deleteFavourite = async (params) =>
  request(
    `
    mutation DeleteFavourite(
      $input: DeleteFavouriteInput!
      $condition: ModelFavouriteConditionInput
    ) {
      deleteFavourite(input: $input, condition: $condition) {
        id
        userId
        feedingPointId
        createdAt
        updatedAt
        owner
      }
    }
`,
    params,
  );

module.exports = {
  listFavourites,
  deleteFavourite,
};
