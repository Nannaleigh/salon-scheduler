#!/bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

print_header() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"
  echo
}

list_services() {
  # prints exactly: "1) cut" per line
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

get_service_id() {
  list_services
  read SERVICE_ID_SELECTED

  # validate service id exists
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"

  while [[ -z "$SERVICE_NAME" ]]; do
    echo
    echo "I could not find that service. What would you like today?"
    list_services
    read SERVICE_ID_SELECTED
    SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  done
}

get_customer() {
  echo
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"

  if [[ -z "$CUSTOMER_NAME" ]]; then
    echo
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
  fi

  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | tr -d '[:space:]')"
}

schedule_appointment() {
  # exact phrasing with commas just like the spec
  echo
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert appointment (FCC column is literally named time)
  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

  echo
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

main() {
  print_header
  get_service_id
  get_customer
  schedule_appointment
}

main