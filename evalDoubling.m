% Copyright @2017 MIT License - Author - Tim Sheppard
% See the License document for further information
function [evalResult] = evalDoubling( probability, playerID, opponentSkill, doublingCube )
% probability -> float 0-1, the probability that the computer will win
% playerID -> ID.AI or ID.USER
% opponentSkill -> floats [percent_error,num_of_errors]
% doublingCube -> [value,owner] 
% return a boolean 0 = false, 1 = true 
evalResult = 0; % output 

% set things up
cubeOwner = doublingCube{2};
% calculate the score 
chance = probability; 
if (playerID == ID.USER)
	chance = 1 - probability; 
end

weight = 1.5; % used to weight the average error 
% if the opponent has made errors calculate the average
if (opponentSkill(2) > 0)
	errorDelta = ( opponentSkill(1)/opponentSkill(2) )*weight;
	if (errorDelta > (15.0/100)) % max error is 15percent 
		errorDelta = (15.0/100);
	end
else
	errorDelta = 0; % the computer should always have 0 error
end

% Set the thresholds 
proposeThres = (80/100.0)-errorDelta;
acceptThres = (20/100.0)-errorDelta;


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

