#!/bin/bash

####################################
# meld.sh
####################################
# author: gwen dallas
# contact: jim.dallas@gmail.com
# last updated: 1 Dec 2017
#
####################################
# calculates the meld value of a 
# 20-card double-deck pinochle hand
# using simplified meld point values
# as shown below:
#
# run: 15
# (A,10,K,Q,J of the trump suit)
#
# double run: 150
# (2x A,10,K,Q,J of trump suit)
#
# royal marriage: 4
# (K,Q of the same suit in trump)
#
# aces all around: 10
# (1x A for every suit)
#
# double aces all around: 100
# (2x A for every suit)
#
# kings all around: 8
# double kings all around: 80
#
# queens all around: 6
# double queens all around: 60
#
# jacks all around: 4
# double jacks all around: 40
#
# common marriage: 2
# (K,Q in same suit, not trump)
# 
# pinochle: 4
# (Q of spades and J of diamonds)
#
# double pinochle: 30
#
# a card cannot be used for both
# a run and a marriage.
# 
# a card cannot be used for both
# a common marriage and royal 
# marriage
#
# a "round house" is when you have
# a marriage in each suit, which
# necessarily implies kings and
# queens around. there is no scoring
# bonus per se for this.
#
# a technical misdeal can be called
# if a player is dealt 13 or more
# Jacks and Queens AND has no aces.
#
# sources:
# www.pagat.com/marriage/pindd.html
# en.wikipedia.org/wiki/
#   Pinochle#Double-deck_pinochle
#
####################################
# usage:
#
# meld.sh [spades] [hearts]
# [diamonds] [clubs] [trumpsuit]
#
# either 1 or 10 is used for the 10
# trump suit is S, H, D, or C
#
# example:
#
# meld.sh A1KQJ A1KQJ A1KQJ A1KQJ H
#
# would mean this hand --
# Spades: A, 10, K, Q, J
# Hearts: A, 10, K, Q, J
# Diamonds: A, 10, K, Q, J
# Clubs: A, 10, K, Q, J
# and the trump suit is Hearts
#
# if no cards of a suit are in a 
# hand, then a placeholder word
# should be used (for example
# "none")
#
####################################

# VARIABLES

THIS_SCRIPT="meld.sh"
SPADES="$1"
HEARTS="$2"
DIAMONDS="$3"
CLUBS="$4"

TRUMP_SUIT="${5:0:1}"
CARDS=""

MELD_POINTS=0
MESSAGES=""

# TRANSFORM HAND INTO NUMERICAL STRINGS

for SUIT in $SPADES $HEARTS $DIAMONDS $CLUBS
do 
    SUIT_CARDS=""

    for VALUE in "A" "1" "K" "Q" "J"
    do
      VALUE_COUNT=$(echo -e "$SUIT" | tr -d [:space:] | sed -e "s/[^"$VALUE"]//g" | wc -m)
#     echo $SUIT_NAME $VALUE $VALUE_COUNT
      SUIT_CARDS="$SUIT_CARDS$VALUE_COUNT " 
    done
    CARDS="$CARDS$SUIT_CARDS"
done

#echo $CARDS

# ANALYZE NUMERICAL STRINGS

SPADE_COUNTS=${CARDS:0:10}
HEART_COUNTS=${CARDS:10:10}
DIAMOND_COUNTS=${CARDS:20:10}
CLUB_COUNTS=${CARDS:30:10}

SPADE_ACES=${SPADE_COUNTS:0:1}
HEART_ACES=${HEART_COUNTS:0:1}
DIAMOND_ACES=${DIAMOND_COUNTS:0:1}
CLUB_ACES=${CLUB_COUNTS:0:1}
SUM_ACES=$(($SPADE_ACES+$HEART_ACES+$DIAMOND_ACES+$CLUB_ACES))

SPADE_TENS=${SPADE_COUNTS:2:1}
HEART_TENS=${HEART_COUNTS:2:1}
DIAMOND_TENS=${DIAMOND_COUNTS:2:1}
CLUB_TENS=${CLUB_COUNTS:2:1}
SUM_TENS=$(($SPADE_TENS+$HEART_TENS+$DIAMOND_TENS+$CLUB_TENS))

SPADE_KING=${SPADE_COUNTS:4:1}
HEART_KING=${HEART_COUNTS:4:1}
DIAMOND_KING=${DIAMOND_COUNTS:4:1}
CLUB_KING=${CLUB_COUNTS:4:1}
SUM_KING=$(($SPADE_KING+$HEART_KING+$DIAMOND_KING+$CLUB_KING))

SPADE_QUEEN=${SPADE_COUNTS:6:1}
HEART_QUEEN=${HEART_COUNTS:6:1}
DIAMOND_QUEEN=${DIAMOND_COUNTS:6:1}
CLUB_QUEEN=${CLUB_COUNTS:6:1}
SUM_QUEEN=$(($SPADE_QUEEN+$HEART_QUEEN+$DIAMOND_QUEEN+$CLUB_QUEEN))

SPADE_JACK=${SPADE_COUNTS:8:1}
HEART_JACK=${HEART_COUNTS:8:1}
DIAMOND_JACK=${DIAMOND_COUNTS:8:1}
CLUB_JACK=${CLUB_COUNTS:8:1}
SUM_JACK=$(($SPADE_JACK+$HEART_JACK+$DIAMOND_JACK+$CLUB_JACK))

SUM_CARDS=$(($SUM_ACES+$SUM_TENS+$SUM_KING+$SUM_QUEEN+$SUM_JACK))
SUM_NONCOUNTERS=$(($SUM_QUEEN+$SUM_JACK))

if [[ "$SUM_CARDS" -ne "20" || ( "$SUM_NONCOUNTERS" -gt "13" && "$SUM_ACES" -eq 0 ) ]]
then
  MESSAGES="MISDEAL!!!"
  MELD_POINTS=0
else
  
  if [[ "$SPADE_ACES" -ge "4" && "$HEART_ACES" -ge "4" && "$DIAMOND_ACES" -ge "4" && "$CLUB_ACES" -ge "4" ]]
  then
    MESSAGES="$MESSAGES\n200\t4X Aces Around"
    MELD_POINTS=$(($MELD_POINTS+200))
  elif [[ "$SPADE_ACES" -ge "3" && "$HEART_ACES" -ge "3" && "$DIAMOND_ACES" -ge "3" && "$CLUB_ACES" -ge "3" ]]
  then
    MESSAGES="$MESSAGES\n150\t3X Aces Around"
    MELD_POINTS=$(($MELD_POINTS+150))
  elif [[ "$SPADE_ACES" -ge "2" && "$HEART_ACES" -ge "2" && "$DIAMOND_ACES" -ge "2" && "$CLUB_ACES" -ge "2" ]]
  then
    MESSAGES="$MESSAGES\n100\tDouble Aces Around"
    MELD_POINTS=$(($MELD_POINTS+100))
  elif [[ "$SPADE_ACES" -ge "1" && "$HEART_ACES" -ge "1" && "$DIAMOND_ACES" -ge "1" && "$CLUB_ACES" -ge "1" ]]
  
  then
    MESSAGES="$MESSAGES\n10\tAces Around"
    MELD_POINTS=$(($MELD_POINTS+10))
  fi
  
  if [[ "$SPADE_KING" -ge "4" && "$HEART_KING" -ge "4" && "$DIAMOND_KING" -ge "4" && "$CLUB_KING" -ge "4" ]]
  then
    MESSAGES="$MESSAGES\n160\t4X Kings Around"
    MELD_POINTS=$(($MELD_POINTS+160))
  elif [[ "$SPADE_KING" -ge "3" && "$HEART_KING" -ge "3" && "$DIAMOND_KING" -ge "3" && "$CLUB_KING" -ge "3" ]]
  then
    MESSAGES="$MESSAGES\n120\t3X Kings Around"
    MELD_POINTS=$(($MELD_POINTS+120))
  elif [[ "$SPADE_KING" -ge "2" && "$HEART_KING" -ge "2" && "$DIAMOND_KING" -ge "2" && "$CLUB_KING" -ge "2" ]]
  then
    MESSAGES="$MESSAGES\n80\tDouble Kings Around"
    MELD_POINTS=$(($MELD_POINTS+80))
  elif [[ "$SPADE_KING" -ge "1" && "$HEART_KING" -ge "1" && "$DIAMOND_KING" -ge "1" && "$CLUB_KING" -ge "1" ]]
  then
    MESSAGES="$MESSAGES\n8\tKings Around"
    MELD_POINTS=$(($MELD_POINTS+8))
  fi
  
  if [[ "$SPADE_QUEEN" -ge "3" && "$HEART_QUEEN" -ge "3" && "$DIAMOND_QUEEN" -ge "3" && "$CLUB_QUEEN" -ge "3" ]]
  then
    MESSAGES="$MESSAGES\n120\t3X Queens Around"
    MELD_POINTS=$(($MELD_POINTS+90))
  elif [[ "$SPADE_QUEEN" -ge "2" && "$HEART_QUEEN" -ge "2" && "$DIAMOND_QUEEN" -ge "2" && "$CLUB_QUEEN" -ge "2" ]]
  then
    MESSAGES="$MESSAGES\n80\tDouble Queens Around"
    MELD_POINTS=$(($MELD_POINTS+60))
  elif [[ "$SPADE_QUEEN" -ge "1" && "$HEART_QUEEN" -ge "1" && "$DIAMOND_QUEEN" -ge "1" && "$CLUB_QUEEN" -ge "1" ]]
  then
    MESSAGES="$MESSAGES\n8\tQueens Around"
    MELD_POINTS=$(($MELD_POINTS+6))
  fi
  
  if [[ "$SPADE_JACK" -ge "3" && "$HEART_JACK" -ge "3" && "$DIAMOND_JACK" -ge "3" && "$CLUB_JACK" -ge "3" ]]
  then
    MESSAGES="$MESSAGES\n60\t3X Jacks Around"
    MELD_POINTS=$(($MELD_POINTS+90))
  elif [[ "$SPADE_JACK" -ge "2" && "$HEART_JACK" -ge "2" && "$DIAMOND_JACK" -ge "2" && "$CLUB_JACK" -ge "2" ]]
  then
    MESSAGES="$MESSAGES\n40\tDouble Jacks Around"
    MELD_POINTS=$(($MELD_POINTS+60))
  elif [[ "$SPADE_JACK" -ge "1" && "$HEART_JACK" -ge "1" && "$DIAMOND_JACK" -ge "1" && "$CLUB_JACK" -ge "1" ]]
  then
    MESSAGES="$MESSAGES\n4\tJacks Around"
    MELD_POINTS=$(($MELD_POINTS+6))
  fi

  if [[ "$SPADE_QUEEN" -ge "4" && "$DIAMOND_JACK" -ge "4" ]]
  then
    MESSAGES="$MESSAGES\n90\t4X Pinochle"
    MELD_POINTS=$(($MELD_POINTS+90))
  elif [[ "$SPADE_QUEEN" -ge "3" && "$DIAMOND_JACK" -ge "3" ]]
  then
    MESSAGES="$MESSAGES\n60\t3X Pinochle"
    MELD_POINTS=$(($MELD_POINTS+60))
  elif [[ "$SPADE_QUEEN" -ge "2" && "$DIAMOND_JACK" -ge "2" ]]
  then
    MESSAGES="$MESSAGES\n30\tDouble Pinochle"
    MELD_POINTS=$(($MELD_POINTS+30))
  elif [[ "$SPADE_QUEEN" -ge "1" && "$DIAMOND_JACK" -ge "1" ]]
  then
    MESSAGES="$MESSAGES\n4\tPinochle"
    MELD_POINTS=$(($MELD_POINTS+4))
  fi

  for SUIT in "Spades" "Hearts" "Diamonds" "Clubs"
  do
    case ${SUIT:0:1} in
      "S")
        SUIT_ACES="$SPADE_ACES"
        SUIT_TENS="$SPADE_TENS"
        SUIT_KING="$SPADE_KING"
        SUIT_QUEEN="$SPADE_QUEEN"
        SUIT_JACK="$SPADE_JACK"
        ;;
      "H")
        SUIT_ACES="$HEART_ACES"
        SUIT_TENS="$HEART_TENS"
        SUIT_KING="$HEART_KING"
        SUIT_QUEEN="$HEART_QUEEN"
        SUIT_JACK="$HEART_JACK"
        ;;
      "D")
        SUIT_ACES="$DIAMOND_ACES"
        SUIT_TENS="$DIAMOND_TENS"
        SUIT_KING="$DIAMOND_KING"
        SUIT_QUEEN="$DIAMOND_QUEEN"
        SUIT_JACK="$DIAMOND_JACK"
        ;;
      "C")
        SUIT_ACES="$CLUB_ACES"
        SUIT_TENS="$CLUB_TENS"
        SUIT_KING="$CLUB_KING"
        SUIT_QUEEN="$CLUB_QUEEN"
        SUIT_JACK="$CLUB_JACK"
        ;;
    esac

    if [[ "$SUIT_KING" -lt "$SUIT_QUEEN" ]]
    then
      SUIT_MIN_SPOUSE="$SUIT_KING"
    else
      SUIT_MIN_SPOUSE="$SUIT_QUEEN"
    fi

    if [[ "$SUIT_ACES" -le "$SUIT_TENS" && "$SUIT_ACES" -le "$SUIT_KING" && "$SUIT_ACES" -le "$SUIT_QUEEN" && "$SUIT_ACES" -le "$SUIT_JACK" ]]
    then
      SUIT_MIN_VALUE="$SUIT_ACES"
    elif  [[ "$SUIT_TENS" -le "$SUIT_ACES" && "$SUIT_TENS" -le "$SUIT_KING" && "$SUIT_TENS" -le "$SUIT_QUEEN" && "$SUIT_TENS" -le "$SUIT_JACK" ]]
    then
      SUIT_MIN_VALUE="$SUIT_TENS"
    elif  [[ "$SUIT_KING" -le "$SUIT_ACES" && "$SUIT_KING" -le "$SUIT_TENS" && "$SUIT_KING" -le "$SUIT_QUEEN" && "$SUIT_KING" -le "$SUIT_JACK" ]]
    then
      SUIT_MIN_VALUE="$SUIT_KING"
    elif  [[ "$SUIT_QUEEN" -le "$SUIT_ACES" && "$SUIT_QUEEN" -le "$SUIT_TENS" && "$SUIT_QUEEN" -le "$SUIT_KING" && "$SUIT_QUEEN" -le "$SUIT_JACK" ]]
    then
      SUIT_MIN_VALUE="$SUIT_QUEEN"
    else
      SUIT_MIN_VALUE="$SUIT_JACK"
    fi


    if [[ "$SUIT_MIN_VALUE" -ge "1" && ( "$TRUMP_SUIT" = ${SUIT:0:1} ) ]]
      then
        case $SUIT_MIN_VALUE in
          "1")
            RUN_POINTS="15"
            ;;
          "2")
            RUN_POINTS="150"
            ;;
          "3")
            RUN_POINTS="225"
            ;;
          "4")
            RUN_POINTS="300"
            ;;
        esac
        MESSAGES="$MESSAGES\n$RUN_POINTS\t${SUIT_MIN_VALUE}X Run(s) in $SUIT"
        MELD_POINTS=$(($MELD_POINTS+$RUN_POINTS))
    elif [[ "$SUIT_MIN_SPOUSE" -ge "1" ]]
    then
      if [ "$TRUMP_SUIT" = ${SUIT:0:1} ]
      then
        MULTIPLIER=$(($SUIT_MIN_SPOUSE*2))
        TRUMP_MESSAGE=" Royal"
      else
        MULTIPLIER="$SUIT_MIN_SPOUSE"
        COUNT=$SUIT_KING
      fi
      
      MARRIAGE_POINTS=$(($MULTIPLIER*2))
      MESSAGES="$MESSAGES\n$MARRIAGE_POINTS\t${SUIT_MIN_SPOUSE}X$TRUMP_MESSAGE Marriage(s) in $SUIT"
      MELD_POINTS=$(($MELD_POINTS+$MARRIAGE_POINTS))
    fi

  done
      
fi

echo -e "\n$MESSAGES"
echo "-----------------------------------------"
echo -e "$MELD_POINTS\tTotal Points\n"
