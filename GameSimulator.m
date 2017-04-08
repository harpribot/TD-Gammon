% Copyright @2017 MIT License 
% Author - Harshal Priyadarshi - Tim Sheppard - Garrett Kaiser
% See the License document for further information
% Backgammon Game Simulation for TD-Gammon

%% Clean up
close all; clear variables; clearvars; clc;

%% Initial Setup
% seed rand with epoch time 
rng(mod((todatenum(cdfepoch(now)))*(10.^11),(2.^32)));
% load the learned parameters 
load('trained_weights.mat');
fprintf('Weights after %d iterations \nTrained on %s \n\n',epochs_trained, datestr(date_trained));
% throw in dice to decide whose first
dice = [0,0];
while (dice(1) == dice(2))
    dice = rollDice();
    userTurn = (dice(2) > dice(1));
end
firstTurn = true;
whoWon = ID.NULL;
% initial board
boardPresent = generateInitialBoard(userTurn);
boardReadable = generateReadableBoard(boardPresent);
boardIndex = -1:1:25;
disp('Board State at present:');
printBoard(boardReadable);
% doubling cube object [cubeValue,cubeOwner]
doublingCube = {1,ID.NULL};
% Track error in moves made by user
error = []; % optimal move evaluation - chosen move evaluation
userError = [0.0,0.0,0.0]; % [skillEvaluation, number of suboptimal moves, total moves]

%% Play Game
while(whoWon == ID.NULL)
    
    if(userTurn)
        disp('It is the Users Turn');
    else
        disp('It is the AIs Turn');
    end
    
    gameProbability = evaluateBoardNN(boardPresent, V_InHide, V_HideOut); 
    % Doubling Decision
    if(userTurn && (doublingCube{2}==ID.USER || doublingCube{2}==ID.NULL))
        % ask user for double decision
        userPropose = input('Would you like to double? Y/N:', 's');
        if(strcmpi(userPropose,'Y') || strcmpi(userPropose,'Yes'))
            % ask agent to accept double
            doublingCube{2} = ID.USER; % need this so that evalDoubling knows what to calc
            agentAccept = evalDoubling(gameProbability,ID.AI,userError,doublingCube,boardReadable);
            if (agentAccept)
                % double and give ownership to agent
                doublingCube{1} = doublingCube{1}*2;
                doublingCube{2} = ID.AI;
                disp('AI has accepted the doubling');
            else
                whoWon = ID.USER; 
                fprintf('AI has declined the doubling\n User Wins.  Match value was %d.\n\n', doublingCube{1});
                break; 
            end
        end
    elseif (doublingCube{2}==ID.AI || doublingCube{2}==ID.NULL)
        % ask agent for double decision
        agentPropose = evalDoubling(gameProbability,ID.AI,userError,doublingCube,boardReadable);
        if(agentPropose)
            % ask user to accept double
            userAccept = input('The AI would like to double\nWill you accept a double? Y/N:', 's');
            if (strcmpi(userAccept,'Y')||strcmpi(userAccept,'Yes'))
                % double and give owner ship to user
                doublingCube{1} = doublingCube{1}*2;
                doublingCube{2} = ID.USER;
            else
                whoWon = ID.AI; 
                fprintf('Double declined\n Agent Wins. Match value was %d.\n\n', doublingCube{1});
                break;
            end
        end
    end
    
    % New Roll
    if (~firstTurn)
        dice = rollDice();
    end
    disp('Dice Throw:');
    disp(dice);
    
    % Move Decision
    if(userTurn)
        % Users Turn
        favorability = TestRun(V_InHide, V_HideOut, boardReadable, boardPresent, dice, userTurn);
        if (isempty(favorability)) 
            % no legal moves
            disp('User has no legal moves, press "enter" to continue');pause;
            boardPresent(193) = 1;
            boardPresent(194) = 0;
        else
            correctMoveMade = false;
            while(correctMoveMade == false)
                userMove = str2num(input('Write your move in vector format separated by commas:', 's'));
                % check move format
                if(size(userMove,2) <= 8 && mod(size(userMove,2),2) == 0)
                    userMove = horzcat(userMove,zeros(1,8 - size(userMove,2)));
                    % check if move is in table
                    [~,indx]=ismember(userMove,favorability(:,2:end),'rows');
                    if(indx ~= 0)
                        correctMoveMade = true;
                        fprintf('Probability Evaluations:\n');
                        printMoveEvaluations(favorability,userTurn);
                        % print user move from the evaluation table
                        disp('User Move');
                        printMoveEvaluations(favorability(indx,:),userTurn);
                        % calculate how suboptimal the user is playing
                        error(end+1) = abs(favorability(indx,1) - favorability(1,1));
                        userError(1) = mean(error) * nnz(error)/length(error);
                        userError(2) = nnz(error);
                        userError(3) = length(error);
                        % update the NN, readable board and userTurn
                        boardPresent = generateBoardFromMove(userMove,boardPresent,false);
                        boardReadable = generateReadableBoard(boardPresent);
                    end
                end
                if (~correctMoveMade)
                    disp('Invalid move!');
                end
            end %  while(correctMoveMade == false)
        end
    else
        %{ 
            AIs Turn
        %}
        favorability = TestRun(V_InHide, V_HideOut, boardReadable, boardPresent, dice, userTurn);
        if (isempty(favorability)) 
            % no legal moves
            disp('AI has no legal moves');
            boardPresent(193) = 0;
            boardPresent(194) = 1;
        else
            bestMove = favorability(1,2:end);
            disp('AIs Move:');
            % printMoveEvaluations(favorability,userTurn);
            printMoveEvaluations([favorability(1,1),bestMove],userTurn);
            % update the NN board and readable board
            boardPresent = generateBoardFromMove(bestMove,boardPresent,false);
            boardReadable = generateReadableBoard(boardPresent);
        end
    end
    disp('Board State at present:');
    printBoard(boardReadable);
    userTurn = ~userTurn; 
    firstTurn = false;

    % check if game has ended
    if(boardReadable(2,2) == 15)
        whoWon = ID.USER; 
        fprintf('User Wins.  Match value was %d.\n\n', doublingCube{1});
    elseif(boardReadable(1,27) == 15)
        whoWon = ID.AI; 
        fprintf('Agent Wins. Match value was %d.\n\n', doublingCube{1});
    end
         
end 
