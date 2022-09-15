exports.handler = async (event) => {
  console.log('RECEIVED Event: ', JSON.stringify(event, null, 2));

  let expectedAnswer =
    event.request.privateChallengeParameters.passCode || null;

  if (event.request.challengeAnswer === expectedAnswer) {
    event.response.answerCorrect = true;
  } else {
    event.response.answerCorrect = false;
  }

  console.log('RETURNED Event: ', JSON.stringify(event, null, 2));

  return event;
};
