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
    }
`,
    params,
  );

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
        feedings {
          items {
            id
            userId
            images
            status
            createdAt
            updatedAt
            createdBy
            updatedBy
            owner
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
            expireAt
            feedingPointFeedingsId
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


const updatePet = async (params) =>
  request(
    `mutation UpdatePet(
      $input: UpdatePetInput!
      $condition: ModelPetConditionInput
    ) {
      updatePet(input: $input, condition: $condition)  {
        id
        name
        images
        breed
        color
        chipNumber
        vaccinatedAt
        yearOfBirth
        caretaker {
          fullName
          email
          phoneNumber
        }
        i18n {
          locale
          name
          breed
          color
        }
        createdAt
        updatedAt
        createdBy
        updatedBy
        owner
        feedingPoints {
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
        medications {
          items {
            id
            name
            petId
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
            date
            i18n {
              name
            }
            createdAt
            updatedAt
            owner
          }
          nextToken
        }
        users {
          items {
            id
            userId
            petId
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
            createdAt
            updatedAt
            owner
          }
          nextToken
        }
        cover
        petCategoryId
      }
    }
`,
    params,
  );

  const updateQuestion = async (params) =>
  request(
    `  mutation UpdateCategory(
      $input: UpdateQuestionInput!
      $condition: ModelQuestionConditionInput
    ) {
      updateQuestion(input: $input, condition: $condition) {
        id
        value
        answer
        i18n {
          locale
          value
          answer
        }
        createdAt
        updatedAt
        createdBy
        updatedBy
        owner
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
  updateQuestion,
  getAllLanguagesSettings
};
