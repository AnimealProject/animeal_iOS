const digitGenerator = require('crypto-secure-random-digit');
const AWS = require('aws-sdk');
const sns = new AWS.SNS();

async function sendChallengeCode(phoneNumber, passCode) {
  const params = {
    Message: 'Your secret code: ' + passCode,
    PhoneNumber: phoneNumber,
  };
  await sns.publish(params).promise();
}

async function createAuthChallenge(event) {
  console.log('RECEIVED Event: ', JSON.stringify(event, null, 2));
  if (event.request.challengeName === 'CUSTOM_CHALLENGE') {
    const challengeCode = digitGenerator.randomDigits(6).join('');
    await sendChallengeCode(
      event.request.userAttributes.phone_number,
      challengeCode,
    );

    event.response.privateChallengeParameters = {};
    event.response.privateChallengeParameters.passCode = challengeCode;
  }
  console.log('RECEIVED Event: ', JSON.stringify(event, null, 2));
}

exports.handler = async (event) => {
  return createAuthChallenge(event);
};
