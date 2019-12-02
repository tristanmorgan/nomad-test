#!/bin/bash


docker build -t doh-server:latest -t doh-server:$(date '+%s') .

