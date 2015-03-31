% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
function NNboard = getNNfromReadableBoard( readableBoard,userChance )
% obtain the NN board from the readable board for testing purposes

NNboard = zeros(198,1);

for i = 1:27
    if(i == 1) % number on the bars
        NNboard(195) = 0.5 * readableBoard(1,1);
        NNboard(196) = 0.5 * readableBoard(2,1);
    elseif(i == 2) % number of borne off checkers for user
        NNboard(198) = readableBoard(2,i)/15;
    elseif(i == 27)% number of borne off checkers for agent
        NNboard(197) = readableBoard(1,i)/15;
    else
        position = i - 2;
        startAgent = (position - 1) * 8 + 1;
        endAgent = (position - 1) * 8 + 4;
        startUser = (position - 1) * 8 + 5;
        endUser = (position - 1) * 8 + 8;
        neuronAgent = zeros(4,1);
        if(readableBoard(1,i) <= 3)
            neuronAgent(1:readableBoard(1,i)) = 1;
        else
        neuronAgent(1:3) = 1;
        neuronAgent(4) = 0.5 * (readableBoard(1,i) - 3);
        end
        NNboard(startAgent:endAgent) = neuronAgent;
        
        neuronUser = zeros(4,1);
        if(readableBoard(2,i) <= 3)
            neuronUser(1:readableBoard(2,i)) = 1;
        else
        neuronUser(1:3) = 1;
        neuronUser(4) = 0.5 * (readableBoard(2,i) - 3);
        end
        NNboard(startUser:endUser) = neuronUser;
    end
        
        
end
if(userChance == 1)
    NNboard(194) = 1;
else
    NNboard(193) = 1;
end


end

