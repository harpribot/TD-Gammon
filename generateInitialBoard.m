% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function board = generateInitialBoard( userChance )
% To Generate the initial board for the play
board = zeros(198,1);
% update neuron representations - lower 4 neurons - agent | upper 4 - user
checkers = [2,5,3,5];
cCount = 1;
for position = [1,12,17,19]
    startAgent = (position - 1) * 8 + 1;
    startUser = (24 - position) * 8 + 5;
    endAgent = (position - 1) * 8 + 4;
    endUser = (24 - position) * 8 + 8;
    neuronAgent = zeros(4,1);
    if(checkers(cCount) <= 3)
        neuronAgent(1:checkers(cCount)) = 1;
    else
        neuronAgent(1:3) = 1;
        neuronAgent(4) = 0.5 * (checkers(cCount) - 3);
    end
    neuronUser = neuronAgent;
    board(startAgent:endAgent) = neuronAgent;
    board(startUser:endUser) = neuronUser;
    cCount = cCount + 1;
end
% update two neurons for player's move 193/194(On/Off)->agent's move
%                                      193/194(Off/On)->user's move
if(userChance == 1)
    board(193) = 0;
    board(194) = 1;
else
    board(193) = 1;
    board(194) = 0;
end

% pieces on the bar are zeros so 195/196(Off/Off)
% pieces borne off are zero so 197/198(Off/Off)

end

