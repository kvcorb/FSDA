function Ytra=basicPower(Y,ColtoTra,la,Jacobian)
%basicPower computes the basic power transformation
%
%<a href="matlab: docsearchFS('basicPower')">Link to the help function</a>
%
%  Required input arguments:
%
%         Y :   n x v data matrix; n observations
%               and v variables
%               Rows of Y represent observations, and columns represent
%               variables.
%   ColToTra:   k x 1 integer vector specifying the variables which must be
%               transformed. If it is missing and length(la)=v all
%               variables are transformed
%        la :   k x 1 vector containing set of transformation
%               parameters for the k ColtoTra.
%
% Output:
%
%   Ytra    : n x v data matrix containing transformed observations
%
%             When \lambda \ne 0
%             ytra = (y^
%             
%             ytra = log(y)
%
% Copyright 2008-2015.
% Written by FSDA team
%
% See also normBoxCox,normYJ
% 
%
%<a href="matlab: docsearchFS('basicPower')">Link to the help function</a>
% Last modified 06-Feb-2015


% Examples:

%{
    % Mussels data.
    load('mussels.mat');
    Y=mussels.data;
    la=[0.5 0 0.5 0 0];
    % Transform all columns of matrix Y according to the values of la using
    % basic power transformation
    Y1=basicPower(Y,[],la);
%}



%% Input parameters checking
% Extract size of the data
v=size(Y,2);

if nargin<1
    error('FSDA:normBoxCox:missingInputs','Input data matrix is missing');
end

if nargin<2
    error('FSDA:normBoxCox:missingInputs','Vector ColtoTra which specifies which variables to transform is missing');
end

if nargin<3
    error('FSDA:normBoxCox:missingInputs','Vector la which specifies how to transforme the variables is missing');
end

if isempty(ColtoTra) && length(la)==v
    ColtoTra=1:v;
end


%% basic power transformation of columns ColtoTra using la
Ytra=Y;
for j=1:length(ColtoTra);
    cj=ColtoTra(j);
    laj=la(j);
    Ycj=Y(:,cj);
    
    if min(Ycj)<=0 && laj==1;
        % if min(Ycj)<=0 and la(cj)=1 then variable is not transformed
    elseif min(Ycj)<=0 && cj ~=1;
        error('FSDA:normBoxCox:Wronglaj',['lambda=' num2str(laj) ' for column ' num2str(cj) ' but min(Ycj)=' num2str(min(Ycj))])
    else
        if laj~=0
            Ytra(:,cj)=Y(:,cj).^laj;
        else
            Ytra(:,cj)=log(Y(:,cj));
        end
    end
end

end