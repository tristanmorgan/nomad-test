#!/bin/bash


docker build -t counting:latest -t counting:$(date '+%s') .

