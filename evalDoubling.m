% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function [evalResult] = evalDoubling( favorability, playerID, opponentSkill, doublingCube )
% favorability -> 
% playerID -> ID.AI or ID.USER
% opponentSkill -> 
% doublingCube -> [value,owner] 
% return a boolean 0 = false, 1 = true 
evalResult = 0; % output 

% set things up
cubeOwner = doublingCube{2};
% calculate the score 
chance = 0; 
% Set the thresholds 
proposeThres = 0;
acceptThres = 0;


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

