% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function [hasGameEnded,agentWins,userWins,reward] = checkGameStatus(...
                                agentBorneOff,userBorneOff,agentWins,userWins)
% To check the status of the game
% if reward == 1 - agent won the game
%           == 0 - user won the game

hasGameEnded = false;
reward = 0;
if(agentBorneOff == 15 || userBorneOff == 15)
    hasGameEnded = true;
    if(agentBorneOff == 15)
        agentWins = agentWins + 1;
        reward = 1;
    else
        userWins = userWins + 1;
        reward = 0;
    end
end

end

