#!/bin/bash

sed -e 's/^.* Date: \([-0-9]*\) .*$/\1/' | tr - .
