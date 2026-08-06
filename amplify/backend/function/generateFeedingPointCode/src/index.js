/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */
const {
  getAddressInfo,
  getCategory,
  feedingPointByCode,
} = require('./query');

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  const { location, categoryId } = event.arguments;
  const addressRes = await getAddressInfo(location.lat.toFixed(4), location.lon.toFixed(4));
  if (addressRes?.data?.error) {
    throw new Error(JSON.stringify(addressRes.data?.error));
  }

  const categoryRes = await getCategory({ id: categoryId });
  if (categoryRes?.data?.errors?.length) {
    throw new Error(JSON.stringify(categoryRes.data?.errors));
  }

  const category = categoryRes.data.data.getCategory;
  const iso3166 = addressRes.data.address['ISO3166-2-lvl4'] ?? addressRes.data.address['ISO3166-2-lvl3'];
  const postCode = addressRes.data.address.postcode;

  try
  {
    const codeStart = `${iso3166}-${postCode ?? '0000'}-${category.tag[0].toUpperCase()}-`;
    let code = '';
    for (var index = 1; index <= 10; index++) {
      code = `${codeStart}${index.toString().padStart(4, '0')}`;
      const byCodeRes = await feedingPointByCode({ code });
      if (byCodeRes?.data?.errors?.length) {
        throw new Error(JSON.stringify(byCodeRes.data?.errors));
      }

      if (byCodeRes.data.data.feedingPointByCode.items.length == 0) {
        break;
      }
      code = '';
    }
    return {code};
  } catch (e) {
    throw new Error(`Failed to generate Feeding point code. Error: ${e.message}`);
  }
};
