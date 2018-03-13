% Copyright @2017 MIT License
% See the License document for further information
% Author - Harshal Priyadarshi
% Revised - Garrett Kaiser 4/2/2017
function [eval,boardNext] = bestAction(possibleMoves,boardPresent,V_InHidden,V_HiddenOut,player)

    if(size(possibleMoves) ~= 0)                        
        possibleMoves = unique(possibleMoves,'rows');
        favorability = zeros(size(possibleMoves,1),size(possibleMoves,2) + 1);
        favorability(:,2:size(possibleMoves,2) + 1) = possibleMoves;
        for i = 1:size(possibleMoves,1)
            boardTemp = generateBoardFromMove(possibleMoves(i,:),boardPresent,false);
            tempEvalVal = evaluateBoardNN(boardTemp,V_InHidden,V_HiddenOut);
            favorability(i,1) = tempEvalVal;
        end
        if(~player)
            favorability = sortrows(favorability,-1);
        else
            favorability = sortrows(favorability,1);
        end

        eval = favorability(1,1);
        move = favorability(1,2:end);
        boardNext = generateBoardFromMove(move,boardPresent,false);
    else
        boardNext = boardPresent;
        if(player)
            boardNext(193) = 1;
            boardNext(194) = 0;
        else
            boardNext(193) = 0;
            boardNext(194) = 1;
        end
        eval = evaluateBoardNN(boardNext,V_InHidden,V_HiddenOut);
    end

end % function
