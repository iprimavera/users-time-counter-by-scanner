#!/bin/bash

python3 -c "print(\"-\"*$(tput cols))"
tput setaf 11; column -s, -t gecos.csv; tput sgr0
python3 -c "print(\"-\"*$(tput cols))"
tput setaf 11; column -s, -t data.csv; tput sgr0
python3 -c "print(\"-\"*$(tput cols))"

exit 0
