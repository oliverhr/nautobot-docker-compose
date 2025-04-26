#!/usr/bin/env bash
# -----------------------------------------------------------------------------
source config.env
if [ -f config.dist.env ]; then
    source config.dist.env
fi

# -----------------------------------------------------------------------------
# BUILD_ARGS
# -----------------------------------------------------------------------------
COMPOSE_BUILD_ARGS=''
for key in "${!BUILD_ARGS[@]}"; do
    COMPOSE_BUILD_ARGS+="--build-arg $key "
    export $key=${BUILD_ARGS[$key]}
done
# echo "COMPOSE_BUILD_ARGS: $COMPOSE_BUILD_ARGS"

# -----------------------------------------------------------------------------
# COMPOSE_FILES
# -----------------------------------------------------------------------------
COMPOSE_FILE=$(IFS=":"; echo "${COMPOSE_FILES[*]}")

# -----------------------------------------------------------------------------
export COMPOSE_FILE
export COMPOSE_BUILD_ARGS

IMAGE_NAME="$IMAGE_NAME:${NAUTOBOT_VERSION}-py${PYTHON_VERSION}"
echo ----------------------------- Configuration ------------------------------
echo PYTHON_SUPPORTED_RANGE: "$PYTHON_SUPPORTED_RANGE"
echo NAUTOBOT_VERSION: "$NAUTOBOT_VERSION"
echo PYTHON_VERSION: "$PYTHON_VERSION"
echo COMPOSE_DIR: "$COMPOSE_DIR"
echo PROJECT_NAME: "$PROJECT_NAME"
echo IMAGE_NAME: "$IMAGE_NAME"
echo --------------------------------------------------------------------------
