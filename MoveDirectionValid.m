% Copyright @2017 MIT License - Author - Garrett Kaiser
% See the License document for further information
function valid = MoveDirectionValid(move)
% checks if the input vector is a valid set of moves
% meaning the moves are in the correct direction for the user
    valid = false;
    moveA = move(1:2:end);
    moveB = move(2:2:end);
    negIndex = find(moveA <  0);
    posIndex = find(moveA >= 0);
    if(all(moveA(posIndex) >= moveB(posIndex)) &&... 
       (all(moveB(negIndex)<=24) && all(moveB(negIndex)>=19)))
        valid = true;
    end  
end