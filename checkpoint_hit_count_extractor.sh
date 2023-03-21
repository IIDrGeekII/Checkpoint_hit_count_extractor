#!/bin/bash

banner() {

printf "\e[1;92m      _   _   _ ___ _____    ____ ___  _   _ _   _ _____   _  \e[0m\n"
printf "\e[1;92m     | | | | | |_ _|_   _|  / ___/ _ \| | | | \ | |_   _| | | \e[0m\n"
printf "\e[1;92m     | | | |_| || |  | |   | |  | | | | | | |  \| | | |   | | \e[0m\n"
printf "\e[1;92m     | | |  _  || |  | |   | |__| |_| | |_| | |\  | | |   | | \e[0m\n"
printf "\e[1;77m     | | |_| |_|___| |_|    \____\___/ \___/|_| \_| |_|   | | \e[0m\n"
printf "\e[1;77m     |_|                                                  |_| \e[0m\n"
printf "\n"

printf "\e[0;30m\e[46m  Checkpoint Firewall Hit Count Extractor. Author: @Vaibhav_Masane  \e[0m\n"
printf "\n"
}
banner""

#banner()
#{
 # echo "+------------------------------------------+"
  #printf "| %-40s |\n" "`date`"
  #echo "+------------------------------------------+"
#}
#banner""
banner()
{
  echo "          +------------------------------------------+"
  printf "          |      %s        |\n" "`date`"
  echo "          +------------------------------------------+"
}
banner ""

echo "+------------------------------------------------------------------+"
today="$(date +%d-%m-%Y)"
printf  "  This script will search a specific policy package for hit count\n  on rules.If for any reason you make a typo and need to exit then\n  use CTRL+C.\n"
echo "+------------------------------------------------------------------+"

printf "\n"
sleep 0.5
printf "Press ENTER to continue..."
read ANYKEY
printf "\nProvide IP address or Name of the Domain or SMS you want to check: "
read DOMAIN
sleep 2

printf "\nListing all available Policy Package Names...\n"
sleep 2
printf "\n"
access_layers=$(mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)')
printf "${MAGENTA}Available policy packages: \n${END}"
printf "\n"
echo "$access_layers"

# Loop until a valid access layer is selected
while true; do
  # Ask for input
  printf "\n${GREEN}Specify Policy Package Name from the above list[mention full name]: ${END}"
  read POL_NAME

  # Check if the input is a valid access layer
  if echo "$access_layers" | grep -q "^$POL_NAME$"; then
    break
  else
    printf "\n"
    echo "Error: Invalid input. Please select from the list above."
  fi
done
POL2="$(echo $POL_NAME | sed -e 's/ /-/g')"
clock="$(date | awk '{$1=""; print $4}' | sed 's/:/_/g')"
printf "\nDetermining Rulesbase size...\n"
printf "\n"
total=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" --format json |jq '.total')
echo "+-------------------------------------------------+"
printf "There are total \e[0;30m\e[43m$total\e[0m rules in \e[1m$POL_NAME\e[0m policy package.\n"
echo "+-------------------------------------------------+"

printf "\nSpecify what is required to find:\n"

printf "\n1. All Rules"
printf "\n2. Non-Zero Hit Rules"
printf "\n3. Zero Hit Rules"
printf "\n"
printf "\nEnter your option[1/2/3]: "
read DISDEL
printf "\n"
printf "Enter total number of rules: "
read COUNT
printf "\n"
printf "Fetching result...\n"
printf "\n"
printf "Note: This may take time depending on the number of rules to scan. Please be patient..."
echo
  if [ "$DISDEL" = "1" ]; then
      echo Rule_Number,Name,Hits,Traffic-level,Rule_Comment > all-rules-$POL2-$today-$clock.csv
      time mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level "standard" limit "$COUNT" use-object-dictionary true show-hits true --format json | jq  --raw-output '.rulebase[] | .rulebase[]? // . | "\(."rule-number"),\(.name),\(.hits.value),\(.hits.level),\(.comments)"' >> all-rules-$POL2-$today-$clock.csv
  echo -n Successfully extracted data and saved with filname to the location ./all-rules-$POL2-$today-$clock.csv.
  fi
  if [ "$DISDEL" = "2" ]; then
      echo Rule_Number,Name,Hits,Traffic-level,Rule_Comment > non-zero-hit-rules-$POL2-$today-$clock.csv
      time mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level "standard" limit "$COUNT" use-object-dictionary true show-hits true --format json | jq  --raw-output '.rulebase[] | .rulebase[]? // . | select(.hits.value != 0) | "\(."rule-number"),\(.name),\(.hits.value),\(.hits.level),\(.comments)"' >> non-zero-hit-rules-$POL2-$today-$clock.csv
  echo -n Successfully extracted data and and saved with filname to the location ./non-zero-hit-rules-$POL2-$today-$clock.csv.
  fi
  if [ "$DISDEL" = "3" ]; then
      echo Rule_Number,Name,Hits,Traffic-level,Rule_Comment > zero-hit-rules-$POL2-$today-$clock.csv
      time mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level "standard" limit "$COUNT" use-object-dictionary true show-hits true --format json | jq  --raw-output '.rulebase[] | .rulebase[]? // . | select(.hits.value == 0) | "\(."rule-number"),\(.name),\(.hits.value),\(.hits.level),\(.comments)"' >> zero-hit-rules-$POL2-$today-$clock.csv
  echo -n Successfully extracted data and saved with filname to the location ./zero-hit-rules-$POL2-$today-$clock.csv.
  fi
  echo
exit 0
