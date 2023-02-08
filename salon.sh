#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Salon Appointments Shop ~~~\n"

SERVICE_MENU() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  
  # display available services
  echo -e "\nHere are our available services:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # ask for service to pick
  echo -e "\nWhich services do you want?"
  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if service doesn't exist
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    SERVICE_MENU
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # add new customer
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      ADD_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    else        
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # ask service time
    echo -e "\nService time:"
    read SERVICE_TIME   

    # add appointment
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $ADD_APPOINTMENT == "INSERT 0 1" ]]
    then
      echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
}

SERVICE_MENU