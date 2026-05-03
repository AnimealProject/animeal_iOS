/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_ARN
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME
	API_ANIMEAL_FEEDINGHISTORYTABLE_ARN
	API_ANIMEAL_FEEDINGHISTORYTABLE_NAME
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const AWS = require('aws-sdk');
const { getActiveFeeding, moveFeedingToHistory } = require('./query');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  const {
    feedingId: feedingPointId,
    feeding: feedingInput,
    reason,
  } = event.arguments;

  const moderatedBy = event.identity?.username ?? 'System';
  const isSystem = moderatedBy === 'System';
  const isAdmin = event.identity?.groups.includes('Administrator');

  const rejectInfo = {
    isRejected: event.fieldName === 'rejectFeeding',
    isCanceled: event.fieldName === 'cancelFeeding',
    isExpired: event.fieldName === 'expireFeeding',
  };

  try {
    const feeding =
      feedingInput ?? (await getActiveFeeding(dynamoDB, feedingPointId));

    if (rejectInfo.isCanceled && feeding.userId !== moderatedBy) {
      throw new Error('Just user who created the feeding can cancel it');
    }

    if (
      rejectInfo.isRejected &&
      !isAdmin &&
      !isSystem &&
      !feeding.assignedModerators.includes(moderatedBy)
    ) {
      throw new Error(
        'Just assigned moderators or admins can reject the feeding',
      );
    }

    await moveFeedingToHistory(
      dynamoDB,
      feeding,
      moderatedBy,
      reason,
      !rejectInfo.isExpired && !isSystem ? 'rejected' : 'outdated',
      !feedingInput,
    );

    return feedingPointId;
  } catch (e) {
    throw new Error(`Failed to Reject feeding. Error: ${e.message}`);
  }
};
