#!/bin/bash

swift build -c release
sudo chmod 700 .build/release/GherkinDoc
sudo cp .build/release/GherkinDoc /usr/local/bin/GherkinDoc
echo "Run generator anywhere by typing GherkinDoc"
