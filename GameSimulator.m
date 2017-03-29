% Copyright @2017 MIT License 
% Author - Harshal Priyadarshi - Tim Sheppard - Garrett Kaiser
% See the License document for further information
% Backgammon Game Simulation for TD-Gammon

%% Clean up
close all; clear all; clc;

%% Initial Setup
% load the learned parameters after 16k iterations
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
% Track error in plays made by user 
userError = [0.0,0.0]; % [sum of error, number of suboptimal moves]

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
        userPropose = input('Would you Like to double? Y/N:', 's');
        if(strcmpi(userPropose,'Y') || strcmpi(userPropose,'Yes'))
            % ask agent to accept double
            doublingCube{2} = ID.USER; % need this so that evalDoubling knows what to calc
            agentAccept = evalDoubling(gameProbability,ID.AI,userError,doublingCube);
            if (agentAccept)
                % double and give ownership to agent
                doublingCube{1} = doublingCube{1}*2;
                doublingCube{2} = ID.AI;
                disp('AI has accepted the doubling');
            else
                whoWon = ID.USER; 
                fprintf('AI has declined the doubling\n User Wins!\n');
                break; 
            end
        end
    elseif (doublingCube{2}==ID.AI || doublingCube{2}==ID.NULL)
        % ask agent for double decision
        agentPropose = evalDoubling(gameProbability,ID.AI,userError,doublingCube);
        if(agentPropose)
            % ask user to accept double
            userAccept = input('The AI would like to double\nWill you accept a double? Y/N:', 's');
            if (strcmpi(userAccept,'Y')||strcmpi(userAccept,'Yes'))
                % double and give owner ship to user
                doublingCube{1} = doublingCube{1}*2;
                doublingCube{2} = ID.USER;
            else
                whoWon = ID.AI; 
                fprintf('Double declined\n Agent Won.\n');
                break;
            end
        end
    end
    
    % New Roll
    dice = rollDice();
    disp('Dice Throw:');
    disp(dice);
    
    % Move Decision
    if(userTurn)
        % Users Turn
        favorability = TestRun(V_InHide, V_HideOut, boardReadable, boardPresent, dice, 1);
        if (isempty(favorability)) 
            % no legal moves
            disp('User has no legal moves Press "enter" to continue');pause;
            boardPresent(193) = 1;
            boardPresent(194) = 0;
        else
            correctMoveMade = false;
            while(correctMoveMade == false)
                userMove = str2num(input('Write your move in vector format separated by commas:', 's'));
                % check move format
                if(size(userMove,2) <= 8 && mod(size(userMove,2),2) == 0)
                    userMove = horzcat(userMove,zeros(1,8 - size(userMove,2)));
                    % check move direction
                    if(MoveDirectionValid(userMove))
                        [~,indx]=ismember(userMove,favorability(:,2:end),'rows');
                        % check move valid
                        if(indx ~= 0)
                            correctMoveMade = true;
                            printMoveEvaluations(favorability);
                            disp('Users Move:');
                            disp(userMove);
                            % calculate how suboptimal the user is playing
                            curError = abs(favorability(indx,1) - favorability(1,1)); 
                            userError = [userError(1)+curError, userError(2)+1];
                            % update the NN, readable board and userTurn
                            boardPresent = generateBoardFromMove(userMove,boardPresent,false);
                            boardReadable = generateReadableBoard(boardPresent);
                        end
                    end
                end
                if (~correctMoveMade)
                    disp('Invalid move!');
                end
            end %  while(correctMoveMade == false)
        end
        disp('Board State at present:');
        printBoard(boardReadable);
        userTurn = ~userTurn;
    else
        %{ 
            AIs Turn
            During training the AI that did best was in the user position,
            therefore some extra steps are taken to use this AI to play against the user. 
            The board must be reverted(flipped) and the move directions must be flipped
        %}
        boardRevertReadable = changeRoles(boardReadable);
        boardRevert = getNNfromReadableBoard(boardRevertReadable,1);
        favorability = TestRun(V_InHide, V_HideOut, boardRevertReadable, boardRevert, dice, 1);
        % printing is weird here because they are not actually the moves
        % the AI must flip its moves as noted above
        % printMoveEvaluations(favorability); 
        if (isempty(favorability)) 
            % no legal moves
            disp('AI has no legal moves');
            boardPresent(193) = 0;
            boardPresent(194) = 1;
        else
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
            % update the NN board and readable board
            boardPresent = generateBoardFromMove(bestMove,boardPresent,false);
            boardReadable = generateReadableBoard(boardPresent);
        end
        disp('Board State at present:');
        printBoard(boardReadable);
        userTurn = ~userTurn; 
    end

    % check if game has ended
    if(boardReadable(2,2) == 15)
        whoWon = ID.USER; 
        disp('User Won');
    elseif(boardReadable(1,27) == 15)
        whoWon = ID.AI; 
        disp('Agent Won');  
    end
         
end 

disp('End of script');
%% End of script
