function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices.
%
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);

% You need to return the following variables correctly
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% Part 1
% size(Theta1) = [25 401]
% size(Theta2) = [10 26]
% size(y) = [m 1]

X = [ones(m, 1), X];
z1 = X * Theta1'; %' size(z) = [m 25]
a1 = sigmoid(z1); % size(a1) = [m 25]
a1 = [ones(m, 1), a1]; % size(a1) = [m 26]
z2 = a1 * Theta2'; %' size(z2) = [m 10]
a2 = sigmoid(z2); % size(a2) = [m 10]

% Recode labels as vectors containing values 0 or 1 (at the right place, ex 5 pdf)
yVec = zeros(m, num_labels);
yRange = [1:num_labels]'; %' size(yRange) = [10 1]
for i=1:m
  yVec(i, :) = (yRange == y(i));
endfor;

h = a2;
term1 = yVec .* log(h);
term2 = (1 - yVec) .* log(1 - h);
J = (-1) * sum(sum(term1 + term2)) / m;

% Regularization
% Do not regularize the terms that correspond to the bias (1st column of each theta matrix)
Theta1Reg = Theta1(1:end, 2:end); % exclude 1st column
Theta2Reg = Theta2(1:end, 2:end); % exclude 1st column
regTerm = (lambda / (2 * m)) * (sum(sum(Theta1Reg .^ 2)) + sum(sum(Theta2Reg .^ 2)));
J = J + regTerm;


% Part 2 - Backpropagation
% size(X) = [m 401]
% size(Theta1) = [25 401]
% size(Theta2) = [10 26]

Delta1 = zeros(size(Theta1)); % size(Delta1) = [25 401]
Delta2 = zeros(size(Theta2)); % size(Delta2) = [10 26]

for i=1:m

  % Forward propagation (J calculation code can be reused)
  a1 = X(i, :)'; %' size(a1) = [401 1]
  z2 = Theta1 * a1; % size(z2) = [25 1]
  a2 = sigmoid(z2); % size(a2) = [25 1]
  a2 = [1; a2]; % size(a2) = [26 1]
  z3 = Theta2 * a2; % size(z3) = [10 1]
  a3 = sigmoid(z3); % size(a3) = [10 1]

  % Backpropagation - error terms
  delta3 = a3 - (yRange == y(i, :)); % size(delta3) = [10 1]
  delta2 = (Theta2' * delta3) .* [1; sigmoidGradient(z2)]; %'size(delta2) = [26 1]
  delta2 = delta2(2:end); % Skip delta2[0], size(delta2) = [25 1]

  % Backpropagation - gradients
  Delta2 = Delta2 + delta3 * a2'; %'
  Delta1 = Delta1 + delta2 * a1'; %'
endfor;

Theta2_grad_reg = (lambda / m) * [zeros(size(Theta2, 1), 1) Theta2Reg];
Theta1_grad_reg = (lambda / m) * [zeros(size(Theta1, 1), 1) Theta1Reg];

Theta2_grad = (1 / m) * Delta2 + Theta2_grad_reg;
Theta1_grad = (1 / m) * Delta1 + Theta1_grad_reg;















% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
