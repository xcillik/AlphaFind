#!/bin/bash

# Training
(
    cd training || exit 1

    docker build -t alphafind:train -f ./Dockerfile .

    docker run \
        -v /$(pwd)/data:/training/data \
        -v /$(pwd)/models:/training/models \
        -e WANDB_MODE=offline \
        alphafind:train
)

# API
(
    cd api || exit 2

    # Create symlinks to training data and models
    ln -s ../training/models models
    ln -s ../training/data data

    docker build -t alphafind:server -f ./server/Dockerfile .

    # Run the server in the background
    docker run -d -p 8080:8000 \
        -v /$(pwd)/data:/data \
        -v /$(pwd)/models:/models \
        -v /$(pwd)/eph:/eph \
        alphafind:server
)

# UI
(
    cd ui || exit 3

    docker build -t alphafind:ui -f ./Dockerfile .

    # Run the UI in the background
    docker run -d -p 8081:8081 alphafind:ui
)