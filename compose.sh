#!/usr/bin/env bash

usage() {
  echo "Usage: $0"
  echo "Options:"
  echo "    build        Build the images, by default uses cache, if don't"
  echo "                 want to use cache add the flag [--no-cache]."
  echo "    debug        Set debug mode."
  echo "    destroy      Destroy everything:: containers, volumes, images."
  echo "    start        Start the containers."
  echo "    restart      Restart the containers."
  echo "    stop         Stop the containers."
  echo "    help         Show this message."
  echo ""
  echo "    ie:"
  echo "           $0 build --no-cache"
}

opt="$1"
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
  usage
  exit 1
elif [ $# -eq 2 ] && [ "$opt" != "build" ]; then
  usage
  exit 1
fi

optarg=$2
case ${opt} in
  help ) # Display usage
    usage
    exit 0 ;;
  build ) # Build the images
    if [ ! -z "$optarg" ] && [ "$optarg" != '--no-cache' ]; then
      usage
      exit 1
    fi
    CMD+="build $optarg"
    ;;
  debug ) # Set debug mode
    CMD="up --timestamps"
    ;;
  start ) # Start container
    CMD="up --detach"
    ;;
  restart ) # Restart container
    CMD="restart"
    ;;
  stop ) # Stop and remove container
    CMD="down"
    ;;
  destroy ) # Destroy container, volumes, images
    CMD="down --volumes --rmi all"
    ;;
  * )
    usage
    exit 1 ;;
esac

source ./_util.sh
docker \
  compose \
    --project-name "$PROJECT_NAME" \
    --project-directory "$COMPOSE_DIR" \
  ${CMD}

# vim: set ft=sh ts=4 sw=4 noet: