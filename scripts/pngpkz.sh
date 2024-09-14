#!/bin/bash

cd ../baseaq/pak0
find textures -name "*.png" -print0 | xargs -0 zip -r mappng.pkz