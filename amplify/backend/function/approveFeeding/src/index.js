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
  createFeedingHistory,
  updateFeedingPoint,
  getFeeding,
  getFeedingPoint,
} = require('./query');

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  const feedingId = event.arguments.feedingId;
  const feedingInput = event.arguments.feeding;
  let feeding = null;

  if (feedingInput) {
    feeding = feedingInput;
  } else {
    const feedingRes = await getFeeding({
      id: feedingId,
    });

    if (feedingRes.data?.errors?.length) {
      throw new Error('Failed to get Feeding');
    }
    feeding = feedingRes.data.data.getFeeding;
  }

  const feedingHistoryCreateRes = await createFeedingHistory({
    input: {
      userId: feeding.userId,
      images: feeding.images,
      createdAt: feeding.createdAt,
      updatedAt: feeding.updatedAt,
      createdBy: feeding.createdBy,
      updatedBy: feeding.updatedBy,
      owner: feeding.owner,
      feedingPointId: feeding.feedingPointFeedingsId,
    },
  });

  if (feedingHistoryCreateRes.data?.errors?.length) {
    throw new Error('Failed to create Feeding History record');
  }

  const feedingDeleteRes = await deleteFeeding({
    input: {
      id: feedingId,
    },
  });

  if (feedingDeleteRes.data?.errors?.length) {
    throw new Error('Failed to delete Feeding record');
  }

  const feedingPoint = await getFeedingPoint({
    id: feeding.feedingPointFeedingsId,
  });

  if (feedingPoint.data?.errors?.length) {
    throw new Error('Failed to update Feeding point status');
  }

  const feedingPointUpdater = await updateFeedingPoint({
    input: {
      id: feeding.feedingPointFeedingsId,
      status: 'fed',
      statusUpdatedAt: new Date().toISOString(),
      ...feedingPoint.data.data.getFeedingPoint,
    },
  });

  if (feedingPointUpdater.data?.errors?.length) {
    throw new Error('Failed to delete Feeding record');
  }

  return feedingId;
};
