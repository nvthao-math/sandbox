#!/bin/bash
redis-cli -h localhost -p 6379 incr mycounter
