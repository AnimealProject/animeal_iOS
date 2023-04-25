/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FAVOURITETABLE_ARN
	API_ANIMEAL_FAVOURITETABLE_NAME
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const AWS = require('aws-sdk');

const parse = AWS.DynamoDB.Converter.unmarshall;

const { listFavourites, deleteFavourite } = require('./query');

exports.handler = async (event) => {
  try {
    console.log(`EVENT: ${JSON.stringify(event)}`);
    for (const record of event.Records) {
      const oldImage = parse(record.dynamodb.OldImage);
      const trackableEvents = ['REMOVE'];
      console.log(oldImage.id);

      if (trackableEvents.includes(record.eventName)) {
        switch (oldImage.__typename) {
          case 'FeedingPoint': {
            const favourites = await listFavourites({
              feedingPointId: oldImage.id,
            });
            for (const favourite of favourites) {
              await deleteFavourite({
                input: {
                  id: favourite.id,
                },
              });
            }
          }
        }
      }
    }
  } catch (e) {
    return Promise.reject(`Failure during processing DynamoDB record: ${e}`);
  }

  return Promise.resolve('Successfully processed DynamoDB record');
};

