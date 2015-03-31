% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function boardRevert = changeRoles( board )
% This is in accordance to the fact that the agent-2 was the best learner
%   board --> the original readable board
%   boardRevert --> the board obtained when the roles of user and agent is
%                   interchanged

boardtemp = rot90(board(:,2:end),2);  % rotate the matrix clockwise 2 times
boardRevert = [flipud(board(:,1)),boardtemp];



end

