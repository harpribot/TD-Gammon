% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
% Rewritten - Tim Sheppard 4/3/2017
function possibleMoves = get_possible_moves(dice,stateReadable,state,move,player)
% INPUTS:
%   dice          - the present dice
%   state         - the present board state
%   stateReadable - the present readable board state
%   move          - the movement of the piece so far
%   player        - 0: agent's moves, 1: user's  moves
% OUTPUT:
    possibleMoves = []; % n x 8 matrix if there are any valid moves

legalMoves = [];
nextMoveMyMove = true; % Used to gen board
highRoll = 1; % Used in checking legal moves

for diePtr = 1:size(dice,2)
	otherRolls = dice([1:diePtr-1 diePtr+1:end]);
	legalMoves = get_legal_moves(stateReadable,dice(diePtr),player); % n x 2 matrix
	
	if (~isempty(legalMoves) && dice(diePtr) > highRoll)
		highRoll = abs(legalMoves(1,1) - legalMoves(1,2));
	end
	
	for i = 1:size(legalMoves,1)
		movedBoard = generateBoardFromMove(legalMoves(i,:),state,nextMoveMyMove);
		movedReadable = generateReadableBoard(movedBoard);
		newMove = [move,legalMoves(i,:)];
		nextMoves = get_possible_moves(otherRolls,movedReadable,movedBoard,newMove,player);
		possibleMoves = [possibleMoves;nextMoves]; % grow the tree 
	end
	if (size(dice,2) > 1)
		if (dice(1) == dice(2))
			break;
		end
	end
end

% End of movement branch
if (isempty(legalMoves) && ~isempty(move))
	% Pad all remaining moves with zeros to match expected size
	if(size(move,2) ~= 8 && ~isempty(move))
		move = [move,zeros(1,8 - size(move,2))];
	end
	possibleMoves = move; % return
% Check all the branches are valid, prune illegal.
elseif (~isempty(possibleMoves))
	possibleMoves = unique(possibleMoves,'rows');
	% Remove moves that don't use the max possible dice
	% Don't allow the player to leave a dice unused
	for i = 7:-2:1
		if ( ~all(possibleMoves(:,i) == 0) && any(possibleMoves(:,i) == 0) )
			for j = size(possibleMoves,1):-1:1
				if (possibleMoves(j,i) == 0)
					possibleMoves(j,:) = [];
				end
			end
		end
	end
	% Check for the rare case
	% where the player can move legally with either dice
	% but can't make a 2nd move, require the higher dice to be used
	if (size(dice,2) == 2 && dice(1) ~= dice(2) && all(possibleMoves(:,3) == 0))
		for i = size(possibleMoves,1):-1:1
			if ( abs(possibleMoves(i,1) - possibleMoves(i,2)) < highRoll )
				possibleMoves(i,:) = [];
			end
		end
	end
end

end % function
