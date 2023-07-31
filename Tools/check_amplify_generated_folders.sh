#!/bin/bash

# Set the path and folder name
path="amplify/generated"
folder_name="models"

# Check if the folder exists
if [ -d "$path/$folder_name" ]; then
    echo "The folder already exists."
else
    # Create the folder
    mkdir -p "$path/$folder_name"

    if [ $? -eq 0 ]; then
        echo "Folder created successfully."
    else
        echo "Failed to create folder."
    fi
fi
