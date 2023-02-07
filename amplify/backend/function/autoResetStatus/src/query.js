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

const searchFeedingPoints = async (params) => {
  return request(
    `
    query SearchFeedingPoints(
      $filter: SearchableFeedingPointFilterInput
      $sort: [SearchableFeedingPointSortInput]
      $limit: Int
      $nextToken: String
      $from: Int
      $aggregates: [SearchableFeedingPointAggregationInput]
    ) {
      searchFeedingPoints(
        filter: $filter
        sort: $sort
        limit: $limit
        nextToken: $nextToken
        from: $from
        aggregates: $aggregates
      ) {
        items {
          id
          name
        }
        nextToken
        total
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
        status
      }
    }
  `,
    params,
  );
};


module.exports = {
  searchFeedingPoints,
  updateFeedingPoint
};
