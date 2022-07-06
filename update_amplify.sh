#!/bin/bash
set -e
IFS='|'

# Read arguments passed to a script:
while getopts a:s:i:e: flag
do
    case "${flag}" in
        a) AWS_ACCESS_KEY_ID=${OPTARG};;
        s) AWS_SECRET_ACCESS_KEY=${OPTARG};;
        i) APP_ID=${OPTARG};;
		e) AMPLIFY_ENV=${OPTARG};;
    esac
done

# For debug purposes
#echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID";
#echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY";
#echo "APP_ID: $APP_ID";
#echo "AMPLIFY_ENV: $AMPLIFY_ENV";


AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":false,\
\"profileName\":\"default\",\
\"accessKeyId\":\"$AWS_ACCESS_KEY_ID\",\
\"secretAccessKey\":\"$AWS_SECRET_ACCESS_KEY\",\
\"region\":\"us-east-1\"\
}"
AMPLIFY="{\
\"projectName\":\"animeal\",\
\"envName\":\"$AMPLIFY_ENV\",\
\"defaultEditor\":\"Xcode\"\
\"appId\":\"$APP_ID\",\
}"
FRONTEND="{\
\"frontend\":\"ios\",\
}"
PROVIDERS="{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}"

# For debug purposes
# echo $AMPLIFY
# echo $FRONTEND
# echo $PROVIDERS
# echo $AWSCLOUDFORMATIONCONFIG


amplify pull \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--yes

# Sometimes it's required to run codegen explicitly
amplify codegen models
