export type AmplifyDependentResourcesAttributes = {
    "auth": {
        "animeald4b890d7": {
            "IdentityPoolId": "string",
            "IdentityPoolName": "string",
            "UserPoolId": "string",
            "UserPoolArn": "string",
            "UserPoolName": "string",
            "AppClientIDWeb": "string",
            "AppClientID": "string",
            "CreatedSNSRole": "string"
        },
        "userPoolGroups": {
            "AdministratorGroupRole": "string",
            "ModeratorGroupRole": "string",
            "VolunteerGroupRole": "string"
        }
    },
    "storage": {
        "animealstorage": {
            "BucketName": "string",
            "Region": "string"
        }
    },
    "api": {
        "animeal": {
            "GraphQLAPIKeyOutput": "string",
            "GraphQLAPIIdOutput": "string",
            "GraphQLAPIEndpointOutput": "string"
        },
        "AdminQueries": {
            "RootUrl": "string",
            "ApiName": "string",
            "ApiId": "string"
        }
    },
    "geo": {
        "animealplaceindex": {
            "Name": "string",
            "Region": "string",
            "Arn": "string"
        }
    },
    "function": {
        "AdminQueries9b7a2344": {
            "Name": "string",
            "Arn": "string",
            "Region": "string",
            "LambdaExecutionRole": "string"
        },
        "translate": {
            "Name": "string",
            "Arn": "string",
            "Region": "string",
            "LambdaExecutionRole": "string"
        },
        "updateTranslationsTrigger": {
            "Name": "string",
            "Arn": "string",
            "Region": "string",
            "LambdaExecutionRole": "string"
        }
    }
}