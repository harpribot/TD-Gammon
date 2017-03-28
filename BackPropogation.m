% Copyright @2017 MIT License Author - Harshal Priyadarshi
% See the License document for further information
function [V_HideOut,V_InHide,e_HideOut,e_InHide] = BackPropogation(...
    V_HideOut,V_InHide,e_HideOut,e_InHide,~,nextOutput,presentOutput,alpha,lambda,inputNext)
% Backpropogation algorithm using TD-Lambda RL method

% update the hidden to output layer weight
V_HideOut = V_HideOut + alpha * (nextOutput - presentOutput) * e_HideOut;
%V_HideOut(1)
% update the input to hidden layer weight
V_InHide = V_InHide + alpha * (nextOutput - presentOutput) * e_InHide;

% find the hidden layer output i.e. hide
hideSum = V_InHide * [inputNext;1];
hide = 1./(1 + exp(-hideSum));
hideBias = [hide;1];

nextOutputAfterChange = evaluateBoardNN(inputNext,V_InHide,V_HideOut); % this is V1(s1)

% update hidden to output layer eligibility trace
e_HideOut = lambda * e_HideOut + (1 - nextOutputAfterChange) * nextOutputAfterChange * hideBias';

% update input to hidden layer eligibility trace
e_InHide = lambda * e_InHide + ((1 - nextOutputAfterChange) * nextOutputAfterChange *...
                           (((1 - hide).*hide).* V_HideOut(1,1:50)') * [inputNext;1]');





end

