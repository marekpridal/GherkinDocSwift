#!/bin/bash

swift build
chmod 700 .build/debug/GherkinDoc
cp .build/debug/GherkinDoc /usr/local/bin/GherkinDoc
echo "Run GherkinDoc anywhere by typing GherkinDoc"
