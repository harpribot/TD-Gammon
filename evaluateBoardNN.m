% Copyright @2017 MIT License - Author - Harshal Priyadarshi
% See the License document for further information
function output = evaluateBoardNN(input, weight_InHide, weight_HideOut)
%output - output of the neural net
%input  - input to the neural net
% weight_InHide - weight vector between input and hidden neuron
% weight_HideOut - weight vector between hidden and output neuron

% input to hidden
hideSum = weight_InHide * [input;1];
hide = 1./(1 + exp(-hideSum));


% hidden to output
outputSum = weight_HideOut * [hide;1];
output = 1./(1 + exp(-outputSum));
end

