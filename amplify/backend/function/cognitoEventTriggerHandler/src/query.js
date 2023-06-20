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
    query FavouritesBySubId(
      $sub: ID!
      $feedingPointId: ModelIDKeyConditionInput
      $sortDirection: ModelSortDirection
      $filter: ModelFavouriteFilterInput
      $limit: Int
      $nextToken: String
    ) {
      favouritesBySubId(
        sub: $sub
        feedingPointId: $feedingPointId
        sortDirection: $sortDirection
        filter: $filter
        limit: $limit
        nextToken: $nextToken
      ) {
        items {
          id
          userId
          sub
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
    return data.data.favouritesBySubId.nextToken
      ? listFavourites({
          ...params,
          nextToken: data.data.favouritesBySubId.nextToken,
        }).then((items) => data.data.favouritesBySubId.items.concat(items))
      : data.data.favouritesBySubId.items;
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
