#!/bin/bash


docker build -t dashboard:latest -t dashboard:$(date '+%s') .

