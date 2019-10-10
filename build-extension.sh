#!/bin/bash
set -e

cd automation/Extension/webext-instrumentation
npm install --unsafe-perm
npm run build
cd ../firefox
npm install
npm run build
cp dist/*.zip ./openwpm.xpi

echo "Success: automation/Extension/firefox/openwpm.xpi has been built"
