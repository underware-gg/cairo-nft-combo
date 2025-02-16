#!/bin/bash
set -e
source scripts/setup.sh

sozo execute --world $WORLD_ADDRESS example-actions mint_character --wait --receipt
