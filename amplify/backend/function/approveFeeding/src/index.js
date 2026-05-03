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
  const isAdmin =
    moderatedBy === 'System' || event.identity.groups.includes('Administrator');

  try {
    const feeding =
      feedingInput ?? (await getActiveFeeding(dynamoDB, feedingPointId));
    if (!feeding) {
      throw new Error('Feeding not found');
    }

    if (!isAdmin && !feeding.assignedModerators.includes(moderatedBy)) {
      throw new Error(
        'Just assigned moderators or admins can approve the feeding',
      );
    }

    await moveFeedingToHistory(
      dynamoDB,
      feeding,
      moderatedBy,
      reason,
      'approved',
    );

    return feedingPointId;
  } catch (e) {
    throw new Error(`Failed to Approve feeding. Error: ${e.message}`);
  }
};
