% Copyright @2017 MIT License - Author - Garrett Kaiser
% See the License document for further information
function dice = rollDice()

    dice(1) = randi(6);
    dice(2) = randi(6);
    if(dice(1) == dice(2))
        dice = [dice,dice];
    end
    
end
