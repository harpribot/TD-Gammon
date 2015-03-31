% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function [eval,boardNxt] = boltzmannAction(possibleMoves,boardPresent...
                            ,nextMoveMyMove,V_InHidden,V_HiddenOut,userChance,temperature)
% update according to boltzmann update rule with temperature decreasing
% with time
if(size(possibleMoves,1) >= 1)
    boardTemp = zeros(198,size(possibleMoves,1));
    evalVal = zeros(size(possibleMoves,1),1);
    if(userChance == 0)
        for i = 1:size(possibleMoves,1)
            boardTemp(:,i) = generateBoardFromMove(possibleMoves(i,:),boardPresent,nextMoveMyMove);
            evalVal(i,1) = evaluateBoardNN(boardTemp(:,i),V_InHidden,V_HiddenOut);
        end
        % the probability distribution for the possible actions
        probDistribution = exp(evalVal/temperature);
        probDistribution = probDistribution/sum(probDistribution);
    else
        for i = 1:size(possibleMoves,1)
            boardTemp(:,i) = generateBoardFromMove(possibleMoves(i,:),boardPresent,nextMoveMyMove);
            evalVal(i,1) = evaluateBoardNN(boardTemp(:,i),V_InHidden,V_HiddenOut);
        end
        % the probability distribution for the possible actions
        probDistribution = exp(evalVal/temperature);
        probDistribution = probDistribution/sum(probDistribution);
    end

    if(size(possibleMoves,1) > 1)
        actionIndex = randsample(1:size(possibleMoves,1), 1, true, probDistribution);
    else
        actionIndex = 1;
    end

    eval = evalVal(actionIndex,1);
    boardNxt = boardTemp(:,actionIndex);

else
    boardNxt = boardPresent;
    eval = evaluateBoardNN(boardPresent,V_InHidden,V_HiddenOut);
end


end

