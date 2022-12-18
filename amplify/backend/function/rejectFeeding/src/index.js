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

const {
  deleteFeeding,
  updateFeedingPoint,
  getFeedingPoint,
} = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;

  const feedingDeleteRes = await deleteFeeding({
    input: {
      id: feedingId,
    },
  });

  if (feedingDeleteRes.data?.errors?.length) {
    throw new Error('Failed to reject Feeding');
  }

  const feedingPoint = await getFeedingPoint({
    id: feedingId,
  });

  const feedingPointUpdater = await updateFeedingPoint({
    input: {
      id: feedingId,
      status: 'starved',
      statusUpdatedAt: new Date().toISOString(),
      ...feedingPoint.data.data.getFeedingPoint,
    },
  });

  if (feedingPointUpdater.data?.errors?.length) {
    throw new Error('Failed to update Feeding point status');
  }

  return feedingId;
};
