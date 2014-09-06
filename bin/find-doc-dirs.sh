#!/bin/bash

locate '/doc/' | sed -rne 's|^(.*/doc/)(.*/doc){0}|\1//|
s|^(.*)(///.*)|@@\1@@|p'

