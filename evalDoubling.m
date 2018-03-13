% Copyright @2017 MIT License - Author - Tim Sheppard
% See the License document for further information
function [evalResult] = evalDoubling( probability, playerID, errorTracking, doublingCube, board )
% probability -> float 0-1, the probability that the computer will win
% playerID -> ID.AI or ID.USER
% errorTracking -> floats [skillEval,numOfErrors,numOfMoves]
% doublingCube -> [value,owner] 
% return a boolean 0 = false, 1 = true 
evalResult = 0; % output 

% set things up
cubeOwner = doublingCube{2};
skillEval = errorTracking(1);
numOfErrors = errorTracking(2);
numOfMoves = errorTracking(3);
avgMovesInBG = 20;
% calculate the score 
chance = probability; 
if (playerID == ID.USER)
	chance = 1 - probability; 
end

% used to weight the average error 
weight = (avgMovesInBG - numOfMoves + numOfErrors)/10; 
if (weight < 0.25)
	weight = 0.25;
end

maxShift = 15.0; % max that to shift from optimal 
% if the opponent has made errors calculate the average
errorDelta = skillEval*weight;
if (errorDelta > (maxShift/100)) % max error is 15percent 
	errorDelta = (maxShift/100);
end

% Set the thresholds 
proposeThres = (80/100.0)-errorDelta;
% Check if we're late into the game 
if (bearOffPossible(board,playerID) && ~(bearOffPossible(board,~playerID)))
	acceptThres = (15/100.0)-errorDelta;
elseif (bearOffPossible(board,~playerID) && ~(bearOffPossible(board,playerID)))
	acceptThres = (75/100.0)-errorDelta;
elseif (bearOffPossible(board,~playerID) && bearOffPossible(board,playerID))
	acceptThres = (55/100.0)-errorDelta;
else 
	acceptThres = (20/100.0)-errorDelta;
end


% find out if player should propose a double
if (playerID == cubeOwner) || (cubeOwner == ID.NULL) 
	
	if (chance > proposeThres)
		evalResult = 1;
	end
	
else % find out if player should accept a double
	
	if (chance > acceptThres)
		evalResult = 1;
	end
	
end

return 

end % function 

