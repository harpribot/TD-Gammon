% Copyright @2017 MIT License - Author - Tim Sheppard
% See the License document for further information
function legal_moves = get_legal_moves(board,die,player)
% get all the legal moves for throw of just one die
% INPUTS: 
%   board  - present state of readable board
%   die    - the die for which we are generating the move
%   player - 0: agent's moves, 1: user's  moves
% OUTPUT: 
    legal_moves = []; % - table of legal moves

%% Setup variables
id  = player + 1;    % id of the current player
nid = (~player) + 1; % id of NOT the current player
% Array of player info [1 is for AI, 2 is for user]
playerHome  = [25,0]; 
playerTraj  = [1,-1];
% Info for the current player
start = playerHome(nid); % Index of start
home  = playerHome(id);  % Index of home (goal)
traj  = playerTraj(id);  % trajectory of moves 

%% Find legal moves
% Checker(s) on the bar
if (board(id,1) > 0) 
	moveStart = -1;
	moveEnd = abs(start - die);
	if(board(nid, moveEnd + 2) < 2)
		legal_moves = [moveStart,moveEnd];
	end % if
% Bearing off legal
elseif (bearOffPossible(board,player))
	% Check if checker available at the exact place for bearing off
	moveStart = abs(home - die);
	if(board(id,moveStart + 2) > 0)
		legal_moves = [moveStart,home];
	end % if
	% see if there are legal moves that do not bear off a checker
	for i = 6:-1:(die + 1)
		moveStart = abs(home - i);
		moveEnd = abs(home - i) + (traj * die); 
		% if user checkers available and die move possible
		if(board(id,moveStart + 2) > 0 && board(nid,moveEnd + 2) < 2)
			legal_moves = [legal_moves;[moveStart,moveEnd]];
		end % if 
	end % for 
	% if no legal moves so far 
	% bear off the nearest lower checker from the exact bearing off position
	if(isempty(legal_moves)) 
		for i = (die - 1):-1:1
			moveStart = abs(home - i);
			if(board(id,moveStart + 2) > 0)
				legal_moves = [moveStart, home];
				break;
			end % if 
		end % for 
	end % if 
% Normal play
elseif ((board(2,2) < 15) && (board(1,27) < 15))
	% Loop through the board 24:-1:2 for AI, 1:1:23 for user
	for moveStart = abs(start-1):traj:abs(home-2)
		% if movement possible for that move
		moveEnd = moveStart + (traj * die);
		% check if the end is valid
		if((moveEnd < 25) && (moveEnd > 0))
			% Check if there is a checker at start point and end is legal
			if(board(id,moveStart + 2) > 0 && board(nid,moveEnd + 2) < 2)
				legal_moves = [legal_moves;[moveStart,moveEnd]];
			end % if 
		else 
			break; % end of legal moves has been reached so exit loop
		end % if 
	end % for 
end % if 

end % function 
