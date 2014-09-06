#!/bin/bash

: ${EMREM_TO:=davep.reminders@meduseld.net}

source script-x

echo "$*" | mail -s "$*" ${EMREM_TO}
