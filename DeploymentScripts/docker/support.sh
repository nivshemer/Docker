#!/bin/bash
# Store the variables passed from the main script
REPLY=$1
echo "$1"


if [ "$REPLY" == y ]
then
while true; do
    read -p "Enter support number (9-14 digits, or include '+' as the first character): " supportnumber

    # Check if the input consists of only digits and/or the "+" character
    if [[ "$supportnumber" =~ ^\+?[0-9]+$ ]]; then
        # Remove the "+" character if present for length check
        stripped_number="${supportnumber#+}"

        # Check if the length of the input is between 9 and 14 characters after removing the "+"
        if (( ${#stripped_number} >= 9 && ${#stripped_number} <= 14 )); then
            echo "Valid support number: $supportnumber"
            break  # Exit the loop if the input is valid
        else
            echo "Support number must be between 9 and 14 digits, or include '+' as the first character. Try again."
        fi
    else
        echo "Invalid input. Please enter only digits. Try again."
    fi
done

echo "Valid support number entered: $supportnumber"

while true; do
    read -p "Enter support email: " supportemail

    # Regular expression for basic email validation
    email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"

    if [[ "$supportemail" =~ $email_regex ]]; then
        break  # Exit the loop if the input is a valid email address
    else
        echo "Invalid email address. Please enter a valid email address. Try again."
    fi
done

echo "Valid support email entered: $supportemail"

    if [ -f "support/help.component.html" ] ; then
        sed -i -e s/"><"/">$supportnumber<"/g "support/help.component.html"
        sed -i 's/support@nanolocksecurity.com/$supportemail/g' "support/help.component.html"
        outputString=$(echo "support&#64;nanolocksecurity.com" | sed "s/support&#64;nanolocksecurity.com/$supportemail/g")
        sed -i -e s/"support&#64;nanolocksecurity.com"/"$outputString"/g "support/help.component.html"
        sed -i '12s/@/\&#64;/g' "support/help.component.html"
    else
        echo "file support/help.component.html doesn't exists"
    fi
fi







