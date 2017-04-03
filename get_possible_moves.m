% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
% Revised - Tim Sheppard 4/2/2017
function possibleMoves = get_possible_moves(dice,stateReadable,state,moves,possibleMoves,player)
% INPUTS:
%   dice          - the present dice
%   state         - the present readable board state
%   moves         - the present accumulated move from the root down to the present
%                   node in the tree
%   player        - 0: agent's moves, 1: user's  moves
% OUTPUT/INPUT: 
%   possibleMoves % final move matrix that is updated by the move upon reaching the leaf node


moveBuffer = moves;
nextMoveMyMove = true;

if(isempty(dice)) % null dice - leaf node
    if(size(moves,2) ~= 8 && ~isempty(moves))
        moves = [moves,zeros(1,8 - size(moves,2))];
    end
    possibleMoves = [possibleMoves; moves];
    if(size(possibleMoves,1) < 300)
        possibleMoves = unique(possibleMoves,'rows');
    end
else
    for diePtr = 1:size(dice,2)
        otherRolls = dice([1:diePtr-1 diePtr+1:end]);
        legal_moves = get_legal_moves(stateReadable,dice(diePtr),player); % n x 2 matrix

        if(size(legal_moves,1) > 0)
            for i = 1:size(legal_moves,1)
                legal_state = generateBoardFromMove(legal_moves(i,:),state,nextMoveMyMove);
                legal_readable_state = generateReadableBoard(legal_state);
                moves = [moveBuffer,legal_moves(i,:)];
                possibleMoves = get_possible_moves(otherRolls,legal_readable_state,legal_state,moves,possibleMoves,player);
            end
        else
            if(size(moves,2) ~= 8 && ~isempty(moves))
                moves = [moves,zeros(1,8 - size(moves,2))];
            end
            possibleMoves = [possibleMoves; moves];
            if(size(possibleMoves,1) < 300)
                possibleMoves = unique(possibleMoves,'rows');
            end
        end
    end
end

end % function 

