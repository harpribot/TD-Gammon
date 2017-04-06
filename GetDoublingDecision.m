% Copyright @2017 MIT License - Author - Garrett and Tim
% See the License document for further information
function decision = GetDoublingDecision(B1,B2,B3,P,foesError,cubeValue)
% This function is NOT intended to be used for the game simulation or training.
% this was created as a requisite 
% to make doubling decisions with the input format specified by our ADP Course.
% this can also be used for testing purposes
% P  -> [your bar,1 to 24,opponent's bar] 
%        Positive ints represent your pieces, negative ints represent opponents.
%        You are always moving your pieces towards square 24
%        Your opponent will always be moving towards square 1
% B1 -> 1(you offer a double to opponent) or 0( you are being doubled)
    % minimum number of args = 4
    if(nargin >= 4)
        load('trained_weights.mat');
        % set default values if not passed in as args
        if(~exist('foesError', 'var') || length(foesError) < 3)
            % [skillEvaluation, number of suboptimal moves, total moves]
            foesError = [.005,9,10];
        end
        if(~exist('cubeValue', 'var') || cubeValue < 1)
            cubeValue = 1;
        end
        % create doubling cube object {cubeValue,cubeOwner}
        doublingCube = {};
        if(~B2 && ~B3)
            doublingCube = {cubeValue,ID.NULL};
        elseif(B2 && ~B3)
            doublingCube = {cubeValue,ID.AI};
        elseif(B3 && ~B2)
            doublingCube = {cubeValue,ID.USER};
        else
            error('B2=1 and B3=1)');
        end
        if((~B1 && (doublingCube{2}==ID.USER || doublingCube{2}==ID.NULL)) ||...
           (B1 && (doublingCube{2}==ID.AI || doublingCube{2}==ID.NULL)))
            % create our board representation with the input P
            readableBoard = [];
            % board positions 1-24
            aiBoard = P(2:25);
            aiBoard(aiBoard<0)=0;
            readableBoard(1,3:26) = aiBoard;
            userBoard = P(2:25);
            userBoard(userBoard>0)=0;
            userBoard=abs(userBoard);
            readableBoard(2,3:26) = userBoard;
            % home/bearoff
            readableBoard(1,27) = 15 - (sum(aiBoard)+abs(P(26)));
            readableBoard(1,2)  = NaN;
            readableBoard(2,2)  = 15 - (sum(userBoard)+abs(P(1)));
            readableBoard(2,27) = NaN;
            % bar
            readableBoard(1,1) = abs(P(26));
            readableBoard(2,1) = abs(P(1));
            printBoard(readableBoard);
            player = ~B1; % 1(opponent) 0(ai) opposite of B1
            % evaluate
            nnBoard = getNNfromReadableBoard(readableBoard, player);
            gameProbability = evaluateBoardNN(nnBoard, V_InHide, V_HideOut);
            fprintf('Probability Evaluation:%f\n',gameProbability);
            decision = evalDoubling(gameProbability,ID.AI,foesError,doublingCube,readableBoard);
            fprintf('Doubling Decision:%d\n',decision);
        else
            error('invalid state or no reason to make decision');
        end
    else
        error('input must include B1,B2,B3,P');
    end
end
