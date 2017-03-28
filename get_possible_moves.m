% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
function possibleMoves = get_possible_moves( dice,stateReadable,state,moves,possibleMoves,userChance )
% dice - the present dice
% state - the present readable board state
% moves - the present accumulated move from the root down to the present
%         node in the tree
% possibleMoves - final move matrix that is updated by the move upon
%                 reaching the leaf node
moveBuffer = moves;
nextMoveMyMove = true;
if(size(dice,2) == 0) % null dice - leaf node
    if(size(moves,2) ~= 8)
        moves = [moves,zeros(1,8 - size(moves,2))];
    end
    possibleMoves = [possibleMoves; moves];
    if(size(possibleMoves,1) < 300)
        possibleMoves = unique(possibleMoves,'rows');
    end
else
    for diePtr = 1:size(dice,2)
        dice_without_die = dice;
        dice_without_die(diePtr) = [];
        legal_moves = get_legal_moves(stateReadable,dice(diePtr),userChance); % n x 2 matrix

        if(size(legal_moves,1) > 0)
            for i = 1:size(legal_moves,1)
                legal_states = generateBoardFromMove(legal_moves(i,:),state,nextMoveMyMove);
                legal_readable_states = generateReadableBoard(legal_states);
                moves = [moveBuffer,legal_moves(i,:)];
                possibleMoves = get_possible_moves( dice_without_die,legal_readable_states,legal_states,moves,possibleMoves,userChance);
            end
        else
            if(size(moves,2) ~= 8)
                moves = [moves,zeros(1,8 - size(moves,2))];
            end
            possibleMoves = [possibleMoves; moves];
            if(size(possibleMoves,1) < 300)
                possibleMoves = unique(possibleMoves,'rows');
            end
        end
    end
end
end

