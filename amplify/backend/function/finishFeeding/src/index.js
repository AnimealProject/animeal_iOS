/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	IS_APPROVAL_ENABLED
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const { updateFeeding, approveFeeding } = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;
  const images = event.arguments.images;

  if (images.length < 1) {
    throw new Error('Failed to to empty images');
  }

  if (process.env.IS_APPROVAL_ENABLED === 'true') {
    const updateFeedingUpdater = await updateFeeding({
      input: {
        id: feedingId,
        status: 'pending',
        images,
      },
    });
    if (updateFeedingUpdater.data?.errors?.length) {
      throw new Error('Failed to update Feeding status');
    }
    return feedingId;
  } else {
    const approveFeedingRes = await approveFeeding({
      feedingId,
    });

    if (approveFeedingRes.data?.errors?.length) {
      throw new Error('Failed to approve Feeding');
    }
  }
  return feedingId;
};
