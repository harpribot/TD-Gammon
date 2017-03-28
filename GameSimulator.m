% Copyright @2015 MIT License 
% Author - Harshal Priyadarshi - Tim Sheppard - Garrett Kaiser
% See the License document for further information
% Game Simulation for TD-Gammon

%% Initial Setup
close all; clear all; clc;
% load the learnt parameters after 16k iterations
load('bestUser16kIteration.mat');

% throw in dice to decide whose first
userTurn = randi([0,1]);
whoWon = ID.NULL;

% initial board
boardPresent = generateInitialBoard(userTurn);
boardReadable = generateReadableBoard(boardPresent);
boardIndex = -1:1:25;
disp('Board State at present:');
printBoard(boardReadable);

% doubling cube object [cubeValue,cubeOwner]
doublingCube = {1,ID.NULL};

% used to track how optimal user is playing
errorArray = [];
userError = [0,0];

%% Play Game
while(whoWon == ID.NULL)
    
    if(userTurn)
        disp('It is the Users Turn');
    else
        disp('It is the AIs Turn');
    end
    
    gameProbability = evaluateBoardNN(boardPresent, V_InHide, V_HideOut); 
    % Doubling Decision
    if(userTurn && (doublingCube(2)==ID.USER || doublingCube(2)==ID.NULL))
        % ask user for double decision
        userPropose = str2num(input('Would you Like to double? (0 or 1):', 's'));
        if(userPropose)
            disp('To bad not implemented');
%             % ask agent to accept double
%             doublingCube(2) = ID.USER;
%             agentAccept = evalDoubling(gameProbability,ID.AI,userError,doublingCube);
%             if (agentAccept)
%                 % double and give ownership to agent
%                 doublingCube(1) = doublingCube(1)*2;
%                 doublingCube(2) = ID.AI;
%             else
%                 whoWon = ID.USER; 
%                 fprintf('User Won');
%             end
        end
    elseif (doublingCube(2)==ID.AI || doublingCube(2)==ID.NULL)
%         % ask agent for double decision
%         agentPropose = evalDoubling(gameProbability,ID.AI,userError,doublingCube);
%         if(agentPropose)
%             % ask user to accept double
%             userAccept = str2num(input('The AI would like to double\nWill you accept a double? (0 or 1):', 's'));
%             if (userAccept)
%                 % double and give owner ship to user
%                 doublingCube(1) = doublingCube(1)*2;
%                 doublingCube(2) = ID.USER;
%             else
%                 whoWon = ID.AI; 
%                 fprintf('Agent Won');
%             end
%         end
    end
    
    % New Roll
    dice = rollDice();
    disp('Dice Throw:');
    disp(dice);
    
    % Move Decision
    if(userTurn)
        % Users Turn
        correctMoveMade = false;
        favorability = TestRun(V_InHide, V_HideOut, boardReadable, boardPresent, dice, 1);
        while(correctMoveMade == false)
            userMove = str2num(input('Write Your move in vector format separated by commas (0 to surrender turn):', 's'));
            if(userMove ~= 0)
                % check move format
                if(size(userMove,2) <= 8 && mod(size(userMove,2),2) == 0)
                    userMove = horzcat(userMove,zeros(1,8 - size(userMove,2)));
                    % check move direction
                    if(MoveDirectionValid(userMove))
                        [~,indx]=ismember(userMove,favorability(:,2:end),'rows');
                        % check move valid
                        if(indx ~= 0)
                            correctMoveMade = true;
                            disp(favorability);
                            disp('Users Move:');
                            disp(userMove);
                            % calculate how optimal the user is playing
                            if(indx ~= 1)
                                errorArray(end+1) = favorability(indx,1) - favorability(1,1);
                                userError = [mean(errorArray),nnz(errorArray)];
                            end
                            % update the NN, readable board and userTurn
                            boardPresent = generateBoardFromMove(userMove,boardPresent,false);
                            boardReadable = generateReadableBoard(boardPresent);
                            disp('Board State at present:');
                            printBoard(boardReadable);
                            userTurn = ~userTurn;
                        end
                    end
                end
            elseif ((userMove == 0) && isempty(favorability))
                % in case there are no moves let user surrenders his move
                correctMoveMade = true;
                boardPresent(193) = 1;
                boardPresent(194) = 0;
                userTurn = ~userTurn;
                % don't pentalize user error for no possible moves
                errorArray(end+1) = 0;
                userError = [mean(errorArray),nnz(errorArray)];
                break;
            end
        end
    else
        % AIs Turn
        boardRevertReadable = changeRoles(boardReadable);
        boardRevert = getNNfromReadableBoard(boardRevertReadable,1);
        % userTurn = 1 as our Agent-2 was the best learner while training
        favorability = TestRun(V_InHide, V_HideOut, boardRevertReadable, boardRevert, dice, 1);
        disp(favorability);  
        bestMoveTemp = favorability(1,2:end);
        bestMove = bestMoveTemp;
        for i = [1,3,5,7]
            if(bestMoveTemp(i + 1) ~= 0 || bestMoveTemp(i) ~= 0)
                bestMove(i) = 25 - bestMoveTemp(i);
                bestMove(i + 1) = 25 - bestMoveTemp(i + 1);
            end
            bestMove(bestMove == 26) = -1;
        end
        disp('AIs Move:');
        disp(bestMove);
        % update the NN,readable board and userTurn
        boardPresent = generateBoardFromMove(bestMove,boardPresent,false);
        boardReadable = generateReadableBoard(boardPresent);
        disp('Board State at present:');
        printBoard(boardReadable);
        userTurn = ~userTurn; 
    end

    % check if game has ended
    if(boardReadable(2,2) == 15)
        whoWon = ID.USER; 
        fprintf('User Won');
    elseif(boardReadable(1,27) == 15)
        whoWon = ID.AI; 
        fprintf('Agent Won');  
    end
         
end
