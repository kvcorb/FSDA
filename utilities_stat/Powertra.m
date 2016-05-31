function Ytra=Powertra(Y,la,varargin)
%Powertra computes power transformation (Box-Cox or  Yeo-Johnson)
%
%<a href="matlab: docsearchFS('Powertra')">Link to the help function</a>
%
%  Required input arguments:
%
% Y :           Input data. Matrix. 
%               n x v data matrix; n observations and v variables. Rows of
%               Y represent observations, and columns represent variables.
%               Missing values (NaN's) and infinite values (Inf's) are
%               allowed, since observations (rows) with missing or infinite
%               values will automatically be excluded from the
%               computations.
%                Data Types - single|double
%        la :   transformation parameters. Vector.
%               k x 1 vector containing set of transformation
%               parameters for the k ColtoTra.
%                Data Types - single|double
%
% Optional input arguments:
%
%    family :   family of transformations. String. String which identifies
%               the family of transformations which
%               must be used. Possible values are 'BoxCox' (default) or
%               'YeoJohnson' (string YeoJohnson can be abbreviated with YJ)
%               or 'basicpower'
%               The Box-Cox family of power transformations equals
%               (y^{\lambda}-1)/\ambda for \lambda not equal to zero, and
%               log(y)
%               if \lambda = 0.
%               The YJ (YeoJohnson) transformation is the Box-Cox
%               transformation of y+1 for nonnegative values, and of |y|+1 with
%               parameter 2-\lambda for y negative.
%               The basic power transformation returns y^{\lambda} if \lambda is not
%               zero, and log(\lambda) otherwise.
%                   Example - 'family','BoxCox'
%                   Data Types - string
%               Remark: BoxCox and the basic power family can be used just
%               if input y is positive. YeoJohnson family of
%               transformations does not have this limitation.
%  Jacobian :   Requested Jacobian of transformed values. true (default) or
%               false. If true (default) the transformation is normalized
%               to have Jacobian equal to 1
%                   Example - 'Jacobian',true
%                   Data Types - string
%   ColtoTra:   Variable to transform. Vector.  k x 1 integer vector
%               specifying the variables which must be
%               transformed. If it is missing and length(la)=v all
%               variables are transformed
%                   Example - 'ColtoTra',[1 2 4]
%                Data Types - single|double
%
% Output:
%
%   Ytra    : n x v data matrix containing transformed observations
%             acoording to the family specified in
%             The Yeo-Johnson transformation is the Box-Cox transformation
%             of y+1 for nonnegative values, and of |y|+1 with parameter
%             2-lambda for y negative.
%
%
% Copyright 2008-2016.
% Written by FSDA team
%
% Yeo, I.-K. and Johnson, R. (2000) A new family of power
% transformations to improve normality or symmetry. Biometrika, 87,
% 954-959.
%
%
% See also normBoxCox, normYJ
%
%
%<a href="matlab: docsearchFS('Powertra')">Link to the help function</a>
% Last modified mar 17 mag 2016 12:19:52

% Examples:

%{
    % Transform value -3, -2, ..., 3
    y=(1:5)';
    lambda=0
    y1=Powertra(y,0.2);

    plot(y,y1)
    xlabel('Original values')
    ylabel('Transformed values')

%}

%{

%}

%{
    % Comparison between Box-Cox and Yeo-Johnson transformation
    close all
    y=(-2:0.1:2)';
    n=length(y);
    la=-1:1:3;
    nla=length(la);
    YtraYJ=zeros(n,nla);
    YtraBC=nan(n,nla);
    posy=y>0;
    for j=1:nla
      YtraYJ(:,j)=Powertra(y,la(j),'family','YJ','Jacobian',false);
      YtraBC(posy,j)=Powertra(y(posy),la(j),'family','BoxCox','Jacobian',false);
    end
    subplot(1,2,1)
    plot(y,YtraYJ)
    for j=1:nla
        text(y(1), YtraYJ(1,j),['\lambda=' num2str(la(j))])
    end

    xlabel('Original values')
    ylabel('Transformed values')
    title('Yeo-Johnson transformation')

    subplot(1,2,2)
    plot(y,YtraBC)
    xlim([y(1) y(end)])
    for j=1:nla
        text(y(16), YtraBC(22,j),['\lambda=' num2str(la(j))])
    end
    xlabel('Original values')
    ylabel('Transformed values')
    title('Box-Cox transformation')
%}

%{
    % Mussels data.
    load('mussels.mat');
    Y=mussels.data;
    la=[0.5 0 0.5 0 0];
    % Transform all columns of matrix Y according to the values of la using
    % the basic power transformation
    Y=Powertra(Y,la,'family','basicpower');
%}



%% Input parameters checking
% Extract size of the data
v=size(Y,2);

if nargin<1
    error('FSDA:Powertra:missingInputs','Input data matrix is missing');
end

if nargin<2
    error('FSDA:Powertra:missingInputs','Vector la which specifies how to transforme the variables is missing');
end

% The default value is to use the normalized transformation
Jacobian=true;

% The default it to transform all columns of input matrix
ColtoTra=1:v;

% The default is to use the BoxCox family of transformations
family='BoxCox';

options=struct('ColtoTra',ColtoTra,'Jacobian',Jacobian,'family',family);


UserOptions=varargin(1:2:length(varargin));
if ~isempty(UserOptions)
    % Check if number of supplied options is valid
    if length(varargin) ~= 2*length(UserOptions)
        error('FSDA:Powertra:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
    end
    % Check if user options are valid options
    chkoptions(options,UserOptions)
end

%init1=options.init;
if nargin > 2
    % Write in structure 'options' the options chosen by the user
    for i=1:2:length(varargin);
        options.(varargin{i})=varargin{i+1};
    end
    ColtoTra=options.ColtoTra;
    Jacobian=options.Jacobian;
    family=options.family;
end



%% Normalized Yeo-Johnson transformation of columns ColtoTra using la
if strcmp(family,'BoxCox')
    Ytra=normBoxCox(Y,ColtoTra,la,Jacobian);
elseif strcmp(family,'YaoJohnson') || strcmp(family,'YJ')
    Ytra=normYJ(Y,ColtoTra,la,Jacobian);
elseif strcmp(family,'basicpower')
    Ytra=basicPower(Y,ColtoTra,la);
else
    warning('FSDA:Powertra:WrongFamily','Transformation family which has been chosen is not supported')
    error('FSDA:Powertra:WrongFamily','Supported values are BoxCox or YaoJohnson or basicpower')
end
end
%FScategory:UTISTAT