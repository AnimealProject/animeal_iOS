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

const getAddressInfo = async (lat, lon) =>
  axios({
    url: `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`,
    method: 'get',
    headers: {
      'User-Agent': 'Animeal (info@animeal.ge)'
    }
  });

const getCategory = async (params) =>
  request(
    `query GetCategory($id: ID!) { getCategory(id: $id) { id tag } }`,
    params,
  );

const feedingPointByCode = async (params) =>
  request(
    `query FeedingPointByCode($code: String!) { feedingPointByCode(code: $code) { items { id } } }`,
    params,
  );

module.exports = {
  getAddressInfo,
  getCategory,
  feedingPointByCode,
};