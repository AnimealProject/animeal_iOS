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

const translate = async (params) => {
  return request(
    ` query Translate($text: String!, $to: String!, $from: String) {
      translate(text: $text, to: $to, from: $from)
    }`,
    params,
  );
};

const getAllLanguages = async (params) => {
  return request(
    ` query ListLanguages(
      $filter: ModelLanguageFilterInput
      $limit: Int
      $nextToken: String
    ) {
      listLanguages(filter: $filter, limit: $limit, nextToken: $nextToken) {
        items {
          id
          name
          code
          createdAt
          updatedAt
          createdBy
          updatedBy
          direction
          owner
        }
        nextToken
      }
    }`,
    params,
  ).then(({ data }) => {
    return data.data.listLanguages.nextToken
      ? getAllLanguages({
          ...params,
          nextToken: data.data.listLanguages.nextToken,
        }).then((items) => data.data.listLanguages.items.concat(items))
      : data.data.listLanguages.items;
  });
};

const getAllLanguagesSettings = (params) => {
  return request(
    ` query ListLanguagesSettings(
      $filter: ModelLanguagesSettingFilterInput
      $limit: Int
      $nextToken: String
    ) {
      listLanguagesSettings(
        filter: $filter
        limit: $limit
        nextToken: $nextToken
      ) {
        items {
          id
          name
          value
          createdAt
          updatedAt
          createdBy
          updatedBy
          owner
        }
        nextToken
      }
    }`,
    params,
  ).then(({ data }) => {
    return data.data.listLanguagesSettings.nextToken
      ? getAllLanguages({
          ...params,
          nextToken: data.data.listLanguagesSettings.nextToken,
        }).then((items) => data.data.listLanguagesSettings.items.concat(items))
      : data.data.listLanguagesSettings.items;
  });
};

const updateCategory = async (params) =>
  request(
    `  mutation UpdateCategory(
      $input: UpdateCategoryInput!
      $condition: ModelCategoryConditionInput
    ) {
      updateCategory(input: $input, condition: $condition) {
        id
      }
    }
`,
    params,
  );

const updateFeedingPoint = async (params) =>
  request(
    `  mutation UpdateFeedingPoint(
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

const updateReference = async (params) =>
  request(
    `mutation UpdateReference(
    $input: UpdateReferenceInput!
    $condition: ModelReferenceConditionInput
  ) {
    updateReference(input: $input, condition: $condition) {
      id
    }
  }
`,
    params,
  );


const updatePet = async (params) =>
  request(
    `mutation UpdatePet(
      $input: UpdatePetInput!
      $condition: ModelPetConditionInput
    ) {
      updatePet(input: $input, condition: $condition) {
        id
      }
    }
`,
    params,
  );

module.exports = {
  translate,
  getAllLanguages,
  updateCategory,
  updateFeedingPoint,
  updatePet,
  getAllLanguagesSettings
};
