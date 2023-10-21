#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n" 

MAIN_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #display the list of services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services order by service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  #read SERVICE_REQUEST and search in services
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    #send to MAIN_SERVICE with message
    MAIN_SERVICE "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    #acquisisci phone number
    read CUSTOMER_PHONE
    #cerca cliente per phone number
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
    if [[ -z $CUSTOMER_ID ]]
    then
      #acquisisci il nome
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      #inserisci cliente
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      #estrai customer_id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
    fi
    #estrai nome
    CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
    #acquisisci orario
    echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
    #inserisci appuntamento
    read SERVICE_TIME
    INSERT_APP_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")
    #print messaggio finale ed esci
    echo -e "\nI have put you down for a cut at $SERVICE_TIME,$CUSTOMER_NAME.\n"
  fi
}

MAIN_SERVICE
