#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 

  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  if [[ $USER_ID ]]; then
    GAMES_PLAYED=$($PSQL "SELECT frequent_games FROM users WHERE user_id = '$USER_ID'")
    BEST_GUESS=$($PSQL "SELECT MIN(best_guess) FROM games WHERE user_id = '$USER_ID' AND best_guess > 0")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    INSERTED_TO_USERS=$($PSQL "INSERT INTO users(username, frequent_games) VALUES('$USERNAME', 0)")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  fi

  GAME
}

GAME() {
  SECRET=$((1 + $RANDOM % 1000))
  TRIES=0

  echo -e "\nGuess the secret number between 1 and 1000:"

  while true; do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    elif [[ $GUESS -eq $SECRET ]]; then
      ((TRIES++))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"

      # Insert game result
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(user_id, best_guess) VALUES($USER_ID, $TRIES)")

      # Update frequent_games count
      UPDATED_GAMES_COUNT=$($PSQL "UPDATE users SET frequent_games = frequent_games + 1 WHERE user_id = $USER_ID")

      break
    elif [[ $GUESS -lt $SECRET ]]; then
      ((TRIES++))
      echo -e "\nIt's higher than that, guess again:"
    else
      ((TRIES++))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done

  echo -e "\nThanks for playing :)\n"
}

DISPLAY

