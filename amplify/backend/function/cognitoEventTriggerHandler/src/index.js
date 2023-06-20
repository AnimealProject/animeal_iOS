/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const { listFavourites, deleteFavourite } = require('./query');

exports.handler = async (event) => {
  try {
    console.log(`EVENT: ${JSON.stringify(event)}`);

    const favourites = await listFavourites({
      sub: event.detail.additionalEventData.sub,
    });
    for (const favourite of favourites) {
      await deleteFavourite({
        input: {
          id: favourite.id,
        },
      });
    }
  } catch (e) {
    return Promise.reject(`Failure during processing event record: ${e}`);
  }

  return Promise.resolve('Successfully processed event record');
};
