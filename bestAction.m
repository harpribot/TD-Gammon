% Copyright @2015 MIT License Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function [eval,boardNext] = bestAction(possibleMoves,boardPresent...
                            ,nextMoveMyMove,V_InHidden,V_HiddenOut,userChance)

if(size(possibleMoves) >= 1)                        
    if(userChance == 0)
        eval = -inf;
        for i = 1:size(possibleMoves,1)
            boardTemp = generateBoardFromMove(possibleMoves(i,:),boardPresent,nextMoveMyMove);
            if(eval < evaluateBoardNN(boardTemp,V_InHidden,V_HiddenOut))
                eval = evaluateBoardNN(boardTemp,V_InHidden,V_HiddenOut);
                boardNext = boardTemp;
            end
        end

    else
        eval = inf;
        for i = 1:size(possibleMoves,1)
            boardTemp = generateBoardFromMove(possibleMoves(i,:),boardPresent,nextMoveMyMove);
            if(eval > evaluateBoardNN(boardTemp,V_InHidden,V_HiddenOut))
                eval = evaluateBoardNN(boardTemp,V_InHidden,V_HiddenOut);
                boardNext = boardTemp;
            end
        end
    end
else
    boardNext = boardPresent;
    if(boardNext(193)==1)
        boardNext(193) = 0;
        boardNext(194) = 1;
    else
        boardNext(193) = 1;
        boardNext(194) = 0;
    end
    eval = evaluateBoardNN(boardNext,V_InHidden,V_HiddenOut);
end

end

