% Copyright @2015 MIT License - Author - Garrett Kaiser
% See the License document for further information
function dice = rollDice()

    equalDiceAllowed = 6;
    dice = randi(6,[1,2]);
    if(dice(1) == dice(2))
        while(equalDiceAllowed > 0)
            dice = randi(6,[1,2]);
            if(dice(1) ~= dice(2))
                break;
            else
                equalDiceAllowed = equalDiceAllowed - 1;
            end
        end
    end
    if(dice(1) == dice(2))
        dice = [dice,dice];
    end
    
end
