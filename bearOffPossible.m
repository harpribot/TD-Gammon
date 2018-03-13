% Copyright @2017 MIT License Author - Harshal Priyadarshi
% See the License document for further information
function condition = bearOffPossible(board,player)
% board --> the readable board
condition = false;
if(player == 1)
    totalCheckersInHome = 0;
    for i = 6:-1:0
        totalCheckersInHome = totalCheckersInHome + board(2,i + 2);
    end
    if(totalCheckersInHome == 15)
        condition = true;
    end
else
    totalCheckersInHome = 0;
    for i = 19:25
        totalCheckersInHome = totalCheckersInHome + board(1,i + 2);
    end
    if(totalCheckersInHome == 15)
        condition = true;
    end
end


end
