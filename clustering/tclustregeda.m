function [out, varargout] = tclustregeda(y,X,k,restrfact,alphaLik,alphaX,varargin)
%tclustregeda performs robust linear grouping analysis for a series of values of the trimming factor
%
%<a href="matlab: docsearchFS('tclustregeda')">Link to the help function</a>
%
%   tclustrefeda performs tclustreg for a series of values of the trimming
%   factor alpha given k (number of groups) and given restrfactor
%   (restriction factor) and alphaX (second levl trimming or cluster
%   weighted model). In order to increase the speed of the computations,
%   parfor is used.
%
%
%  Required input arguments:
%
%  Required input arguments:
%
%         y : Response variable. Vector.
%             A vector with n elements that contains the response variable.
%             y can be either a row or a column vector.
%             Data Types - single|double
%
%         X : Explanatory variables (also called 'regressors'). Matrix.
%             Data matrix of dimension $(n \times p-1)$. Rows of X represent
%             observations, and columns represent variables. Missing values
%             (NaN's) and infinite values (Inf's) are allowed, since
%             observations (rows) with missing or infinite values will
%             automatically be excluded from the computations.
%             Data Types - single|double
%
%         k : Number of clusters. Scalar.
%             This is a guess on the number of data groups.
%             Data Types - single|double
%
% restrfact : restriction factor for regression residuals and covariance
%             matrices of the explanatory variables. Scalar or vector with two
%             elements. If restrfact is a scalar it controls the
%             differences among group scatters of the residuals. The value
%             1 is the strongest restriction. If restrfactor is a vector
%             with two elements the first element controls the differences
%             among group scatters of the residuals and the second the
%             differences among covariance matrices of the explanatory
%             variables. Note that restrfactor(2) is used just if
%             input option $alphaX=1$, that is if constrained weighted
%             model for X is assumed.
%            Data Types - single|double
%
%     alphaLik: trimming level to monitor. Vector. Vector which specifies the
%               values of trimming levels which have to be considered.
%               alpha is a vector which contains decreasing elements which
%               lie in the interval 0 and 0.5.
%               For example if alpha=[0.1 0.05 0] tclustregeda considers these 3
%               values of trimming level.
%               If alphaLik=0 tclusteda does not trimming. The default for
%               alpha is vector [0.1 0.05 0]. The sequence is forced to be
%               monotonically decreasing.
%   alphaX : Second-level trimming or constrained weighted model for X. Scalar.
%            alphaX is a value in the interval [0 1].
%            - If alphaX=0 there is no second-level trimming.
%            - If alphaX is in the interval [0 0.5] it indicates the
%               fixed proportion of units subject to second level trimming.
%               In this case alphaX is usually smaller than alphaLik.
%               For further details see Garcia-Escudero et. al. (2010).
%            -  If alphaX is in the interval (0.5 1), it indicates a
%               Bonferronized confidence level to be used to identify the
%               units subject to second level trimming. In this case the
%               proportion of units subject to second level trimming is not
%               fixed a priori, but is determined adaptively.
%               For further details see Torti et al. (2018).
%            -  If alphaX=1, constrained weighted model for X is assumed
%               (Gershenfeld, 1997). The CWM estimator is able to
%               take into account different distributions for the explanatory
%               variables across groups, so overcoming an intrinsic limitation
%               of mixtures of regression, because they are implicitly
%               assumed equally distributed. Note that if alphaX=1 it is
%               also possible to apply using restrfactor(2) the constraints
%               on the cov matrices of the explanatory variables.
%               For further details about CWM see Garcia-Escudero et al.
%               (2017) or Torti et al. (2018).
%            Data Types - single|double
%
%  Optional input arguments:
%
%     intercept : Indicator for constant term. Scalar. If 1, a model with
%                constant term will be fitted (default), else no constant
%                term will be included.
%                Example - 'intercept',1
%                Data Types - double
%
%       mixt  : mixture modelling or crisp assignment. Scalar.
%               Option mixt specifies whether mixture modelling or crisp
%               assignment approach to model based clustering must be used.
%               In the case of mixture modelling parameter mixt also
%               controls which is the criterior to find the untrimmed units
%               in each step of the maximization
%               If mixt >=1 mixture modelling is assumed else crisp
%               assignment.
%                In mixture modelling the likelihood is given by
%                \[
%                \prod_{i=1}^n  \sum_{j=1}^k \pi_j \phi (y_i \; x_i' , \beta_j , \sigma_j),
%                \]
%               while in crisp assignment the likelihood is given by
%               \[
%               \prod_{j=1}^k   \prod _{i\in R_j} \pi_j  \phi (y_i \; x_i' , \beta_j , \sigma_j),
%               \]
%               where $R_j$ contains the indexes of the observations which
%               are assigned to group $j$,
%               Remark - if mixt>=1 previous parameter equalweights is
%               automatically set to 1.
%               Parameter mixt also controls the criterion to select the units to trim
%               if mixt == 2 the h units are those which give the largest
%               contribution to the likelihood that is the h largest
%               values of
%               \[
%                   \sum_{j=1}^k \pi_j \phi (y_i \; x_i' , \beta_j , \sigma_j)   \qquad
%                    i=1, 2, ..., n
%               \]
%               elseif mixt==1 the criterion to select the h units is
%               exactly the same as the one which is used in crisp
%               assignment. That is: the n units are allocated to a
%               cluster according to criterion
%               \[
%                \max_{j=1, \ldots, k} \hat \pi'_j \phi (y_i \; x_i' , \beta_j , \sigma_j)
%               \]
%               and then these n numbers are ordered and the units
%               associated with the largest h numbers are untrimmed.
%               Example - 'mixt',1
%               Data Types - single | double
%
%equalweights : cluster weights in the concentration and assignment steps.
%               Logical. A logical value specifying whether cluster weights
%               shall be considered in the concentration, assignment steps
%               and computation of the likelihood.
%               if equalweights = true we are (ideally) assuming equally
%               sized groups by maximizing the likelihood
%                 Example - 'equalweights',true
%                 Data Types - Logical
%
%    nsamp : number of subsamples to extract.
%            Scalar or matrix with k*p columns.
%            If nsamp is a scalar it contains the number of subsamples
%            which will be extracted.
%            If nsamp=0 all subsets will be extracted.
%            If the number of all possible subset is <300 the
%            default is to extract all subsets, otherwise just 300.
%            If nsamp is a matrix it contains in the rows the indexes of
%            the subsets which have to be extracted. nsamp in this case can
%            be conveniently generated  by function subsets.
%            nsamp must have k*p columns. The first p columns are used to
%            estimate the regression coefficient of group 1... the last p
%            columns are used to estimate the regression coefficient of
%            group k
%             Example - 'nsamp',1000
%             Data Types - double
%
% refsteps:  Number of refining iterations. Scalar. Number of refining
%               iterations in each subsample.  Default is 10.
%               refsteps = 0 means "raw-subsampling" without iterations.
%                 Example - 'refsteps',15
%                 Data Types - single | double
%
%     reftol  : Tolerance for the refining steps. Scalar.
%               The default value is 1e-14;
%                 Example - 'reftol',1e-05
%                 Data Types - single | double
%
%   wtrim: Application of observation weights. Scalar or structure. If
%           wtrim is a scalar, a flag taking values
%          in [0, 1, 2, 3, 4], to control the application of weights on the
%          observations for betaestimation.
%          -  If \texttt{wtrim}=0 (no weights) and $\texttt{mixt}=0$, the
%             algorithm reduces to the standard tclustreg algorithm.
%          -  If \texttt{wtrim}=0 and \texttt{mixt}=2, the maximum posterior
%             probability $D_i$ of equation 7 of Garcia et al. 2010 is
%             computing by maximizing the log-likelihood contributions of
%             the mixture model of each observation.
%          -  If \texttt{wtrim} = 1, trimming is done by weighting the
%             observations using values specified in vector \texttt{we}.
%             In this case, vector \texttt{we} must be supplied by the
%             user. For instance, \texttt{we} = $X$.
%          -  If \texttt{wtrim} = 2, trimming is again done by weighting
%             the observations using values specified in vector \texttt{we}.
%             In this case, vector \texttt{we} is computed from the data as
%             a function of the density estimate $\mbox{pdfe}$.
%            Specifically, the weight of each observation is the
%            probability of retaining the observation, computed as
%            \[\mbox{pretain}_{i g} = 1 - \mbox{pdfe}_{ig}/\max_{ig}(\mbox{pdfe}_{ig})\]
%         -  If \texttt{wtrim} = 3, trimming is again done by weighting the
%            observations using values specified in vector \texttt{we}. In
%            this case, each element $we_i$ of vector \texttt{we} is a
%            Bernoulli random variable with probability of success
%            $\mbox{pdfe}_{ig}$. In the clustering framework this is done
%            under the constraint that no group is empty.
%         -  If \texttt{wtrim} = 4, trimming is done with the tandem approach
%            of Cerioli and Perrotta (2014).
%         -  If \texttt{wtrim} = 5 (TO BE IMPLEMENTED)
%          -  If \texttt{wtrim} = 6 (TO BE IMPLEMENTED)
%          If wtrim is a structure, it is composed by:
%         -  wtrim.wtype_beta: the weight for the beta estimation. It can be
%           0, 1, 2, 3, as in the case of wtrim scalar
%         -  wtrim.wtype_obj: the weight for the objective function. It can
%         be:
%             - '0': no weights in the objective function
%             - 'Z': Bernoulli random variable with probability of success
%            $\mbox{pdfe}_{ig}$
%             - 'w': a function of the density estimate $\mbox{pdfe}$.
%             - 'Zw': the product of the two above.
%             - 'user': user weights we.
%            Example - 'wtrim',1
%            Data Types - double
%
%      we: Vector of observation weights. Vector. A vector of size n-by-1
%          containing application-specific weights that the user needs to
%          apply to each observation. Default
%          value is  a vector of ones.
%            Example - 'we',[0.2 0.2 0.2 0.2 0.2]
%            Data Types - double
%
%       k_dens_mixt: in the Poisson/Exponential mixture density function,
%                    number of clusters for density mixtures. Scalar.
%                    This is a guess on the number of data groups. Default
%                    value is 5.
%            Example - 'k_dens_mixt',6
%            Data Types - single|double
%
%   nsamp_dens_mixt: in the Poisson/Exponential mixture density function,
%                    number of subsamples to extract. Scalar. Default 300.
%                    Example - 'nsamp_dens_mixt',1000
%                    Data Types - double
%
%refsteps_dens_mixt: in the Poisson/Exponential mixture density function,
%                    number of refining iterations. Scalar. Number of refining
%                    iterations in each subsample.  Default is 10.
%                    Example - 'refsteps_dens_mixt',15
%                    Data Types - single | double
%
%  method_dens_mixt: in the Poisson/Exponential mixture density function,
%                    distribution to use. Character. If method_dens_mixt =
%                    'P', the Poisson distribution is used, with
%                    method_dens_mixt = 'E', the Exponential distribution
%                    is used. Default is 'P'.
%                    Example - 'method_dens_mixt','E'
%                    Data Types - char
%
%
%
% plots    :    Plot on the screen. Scalar structure.
%
%               Case 1: plots option used as scalar.
%               - If plots=0,  plots are not generated.
%               - If plots=1 (default), two plots are shown on the screen.
%                 The first plot ("monitor plot") shows three panels
%                 monitoring between two consecutive values of alpha the
%                 change in classification using ARI index (top panel), the
%                 change in centroids using squared euclidean distances
%                 (central panel), the change in covariance matrices using
%                 squared euclidean distance (bottom panel).
%                 The second plot ("gscatter plot") shows a series of
%                 subplots which monitor the classification for each value
%                 of alpha. In order to make sure that consistent labels
%                 are used for the groups, between two consecutive values
%                 of alpha, we assign label r to a group if this group
%                 shows the smallest distance with group r for the previous
%                 value of alpha. The type of plot which is used to monitor
%                 the stability of the classification depends on the value
%                 of v.
%                   * for v=1, we use histograms of the univariate data
%                   (function histFS is called).
%                   * for v=2, we use the scatter plot of the two
%                   variables (function gscatter is called).
%                   * for v>2, we use the scatter plot of the first two
%                   principal components (function gscatter is called and
%                   we show on the axes titles the percentage of variance
%                   explained by the first two principal components).
%
%               Case 2: plots option used as struct.
%                 If plots is a structure it may contain the following fields:
%                 plots.name = cell array of strings which enables to
%                   specify which plot to display. plots.name = {'gscatter'}
%                   produces a figure with a series of subplots which show the
%                   classification for each value of alpha. plots.name = {'monitor'}
%                   shows a figure with 3 panels which monitor between two
%                   consecutive values of alpha the change in classification
%                   using ARI index (top panel), the change in centroids
%                   using squared euclidean distances (central panel), the
%                   change in covariance matrices using squared euclidean
%                   distance (bottom panel). If this field is
%                   not specified plots.name={'gscatter' 'monitor'} and
%                   both figures will be shown.
%                 plots.alphasel = numeric vector which speciies for which
%                   values of alpha it is possible to see the classification.
%                   For example if plots.alphasel =[ 0.05 0.02], the
%                   classification will be shown just for alpha=0.05 and
%                   alpha=0.02; If this field is
%                   not specified plots.alphasel=alpha and therefore the
%                   classification is shown for each value of alpha.
%                 plots.ylimy = 2D array of size 3-by 2 which specifies the
%                   lower and upper limits for the monitoring plots. The
%                   first row refers the ARI index (top panel), the second
%                   row refers to the the change in centroids using squared
%                   euclidean distances (central panel), the third row is
%                   associated with the change in covariance matrices using
%                   squared euclidean distance (bottom panel).
%                   Example - 'plots', 1
%                   Data Types - single | double | struct
%
%        msg  : Level of output to display. Scalar.
%               Scalar which controls whether to display or not messages
%               on the screen.
%               If msg=0 nothing is displayed on the screen.
%               If msg=1 (default) messages are displayed
%               on the screen about estimated time to compute the estimator
%               or the number of subsets in which there was no convergence.
%               If msg=2 detailed messages are displayed. For example the
%               information at iteration level.
%                   Example - 'msg',1
%                   Data Types - single | double
%
%      nocheck: Check input arguments. Scalar.
%               If nocheck is equal to 1 no check is performed on
%               matrix Y.
%               As default nocheck=0.
%                   Example - 'nocheck',1
%                   Data Types - single | double
%
%
%RandNumbForNini: Pre-extracted random numbers to initialize proportions.
%                Matrix. Matrix with size k-by-size(nsamp,1) containing the
%                random numbers which are used to initialize the
%                proportions of the groups. This option is effective just
%                if nsamp is a matrix which contains pre-extracted
%                subsamples. The purpose of this option is to enable the
%                user to replicate the results in case routine tclust is
%                called using a parfor instruction (as it happens for
%                example in routine IC, where tclust is called through a
%                parfor for different values of the restriction factor).
%                The default value of RandNumbForNini is empty that is
%                random numbers from uniform are used.
%                   Example - 'RandNumbForNini',''
%                   Data Types - single | double
%
%
%   UnitsSameGroup :  list of the units which must (whenever possible)
%                   have a particular label. Numeric vector.  For example if
%                   UnitsSameGroup=[20 26], means that group which contains
%                   unit 20 is always labelled with number 1. Similarly,
%                   the group which contains unit 26 is always labelled
%                   with number 2, (unless it is found that unit 26 already
%                   belongs to group 1). In general, group which contains
%                   unit UnitsSameGroup(r) where r=2, ...length(kk)-1 is
%                   labelled with number r (unless it is found that unit
%                   UnitsSameGroup(r) has already been assigned to groups
%                   1, 2, ..., r-1).
%                 Example - 'UnitsSameGroup',[20 34]
%                 Data Types -  integer vector
%
%      numpool:     The number of parallel sessions to open. Integer. If
%                   numpool is not defined, then it is set equal to the
%                   number of physical cores in the computer.
%                 Example - 'numpool',4
%                 Data Types -  integer vector
%
%      cleanpool:   Function name. Scalar {0,1}. Indicated if the open pool
%                   must be closed or not. It is useful to leave it open if
%                   there are subsequent parallel sessions to execute, so
%                   that to save the time required to open a new pool.
%                 Example - 'cleanpool',true
%                   Data Types - integer | logical
%
%
%  Output:
%
%         out:   structure which contains the following fields
%
%            out.IDX  = n-by-length(alpha) vector containing assignment of each unit to
%                       each of the k groups. Cluster names are integer
%                       numbers from 1 to k. 0 indicates trimmed
%                       observations. First column refers of out.IDX refers
%                       to alphaLik(1), second column of out.IDX refers to
%                       alphaLik(2), ..., last column refers to alphaLik(end).
%
%            out.Beta  =  3D array of size k-by-p-by-length(alpha) containing
%                       the monitoring of the regression coefficients for each value of
%                       alphaLik. out.Beta(:,:,1), refers to alphaLik(1) ...,
%                       out.Beta(:,:,end) refers to alphaLik(end). First row in
%                       each slice refers to group 1, second row refers to
%                       group 2 ...
%
%         out.Sigma  =  matrix of size k-by-length(alphaLik) containing in column
%                       j, with j=1, 2, ...,  length(alphaLik), the
%                       estimates of the k (constrained) variances of the
%                       regressions trices associated with alphaLik(j).
%
%         out.Amon  =  Amon stands for alphaLik monitoring. Matrix of size
%                      (length(alphaLik)-1)-by-4 which contains for two
%                       consecutive values of alpha the monitoring of three
%                       quantities (change in classification, change in
%                       centroid location, change in variance of the errors).
%                       1st col = value of alphaLik.
%                       2nd col = ARI index.
%                       3rd col = squared Euclidean distance between
%                           two consecutive beta.
%                       4th col = squared Euclidean distance between
%                           two consecutive vector of variances of the
%                           errors of the k regressions.
%
%              out.y  = Original data matrix Y.
%
%  Optional Output:
%
%           outcell : cell of length length(alpha) which contains in jth
%                     position the structure which comes out from procedure
%                     tclustreg applied to alphaLik(j), with j =1, 2, ...,
%                     length(alphaLik).
%
% More About:
%
%
% This procedure extends to tclust the so called monitoring
% approach. The phylosophy is to investigate how the results change as the
% trimming proportion alpha reduces. This function enables us to monitor
% the change in classification (measured by the ARI index) and the change
% in regression coefficients and error variances (measured by the squared euclidean
% distances). In order to make sure that consistent labels are used for the
% groups, between two consecutive values of alpha, we assign label r to a
% group if this group shows the smallest distance with group r for the
% previous value of alpha.
%
% See also: tclustreg, tclustIC
%
% References:
%
% Garcia-Escudero, L.A., Gordaliza A., Greselin F., Ingrassia S., and
% Mayo-Iscar A. (2016), The joint role of trimming and constraints in
% robust estimation for mixtures of gaussian factor analyzers,
% "Computational Statistics & Data Analysis", Vol. 99, pp. 131-147.
%
% Garcia-Escudero, L.A., Gordaliza, A., Greselin, F., Ingrassia, S. and
% Mayo-Iscar, A. (2017), Robust estimation of mixtures of regressions with
% random covariates, via trimming and constraints, "Statistics and
% Computing", Vol. 27, pp. 377-402.
%
% Garcia-Escudero, L.A., Gordaliza A., Mayo-Iscar A., and San Martin R.
% (2010), Robust clusterwise linear regression through trimming,
% "Computational Statistics and Data Analysis", Vol. 54, pp.3057-3069.
%
% Cerioli, A. and Perrotta, D. (2014). Robust Clustering Around Regression
% Lines with High Density Regions. Advances in Data Analysis and
% Classification, Vol. 8, pp. 5-26.
%
% Torti F., Perrotta D., Riani, M. and Cerioli A. (2018). Assessing Robust
% Methodologies for Clustering Linear Regression Data, "Advances in Data
% Analysis and Classification".
%
%
% Copyright 2008-2019.
% Written by FSDA team
%
%
%
%<a href="matlab: docsearchFS('tclustregeda')">Link to the help function</a>
%
%$LastChangedDate:: 2018-01-29 18:52:14 #$: Date of the last commit

% Examples:

%{
    %% Monitoring using geyser data (all default options).
    close all
    Y=load('geyser2.txt');
    % alpha and restriction factor are not specified therefore for alpha
    % vector [0.10 0.05 0] is used while for the restriction factor, value c=12
    % is used
    k=3;
    [out]=tclusteda(Y,k);
%}

%{
    % Monitoring using geyser data with alpha and c specified.
    Y=load('geyser2.txt');
    close all
    % alphavec= vector which contains the trimming levels to consider
    alphavec=0.10:-0.01:0;
    % c = restriction factor to use
    c=100;
    % k= number of groups
    k=3;
    [out]=tclusteda(Y,k,alphavec,c);
%}

%{
    %% Monitoring using geyser data with option plots supplied as structure.
    Y=load('geyser2.txt');
    close all
    % alphavec= vector which contains the trimming levels to consider
    % in this case 31 values of alpha are considered
    alphavec=0.30:-0.01:0;
    % c = restriction factor to use
    c=100;
    % k= number of groups
    k=3;
    % The monitoring plot of allocation will shows just these four values of
    % alpha
    plots=struct;
    plots.alphasel=[0.2 0.10 0.05 0.01];
    [out]=tclusteda(Y,k,alphavec,c,'plots',plots);
%}

%{
    %% Monitoring geyser data with option UnitsSameGroup.
    Y=load('geyser2.txt');
    close all
    % alphavec= vector which contains the trimming levels to consider
    alphavec=0.30:-0.10:0;
    % c = restriction factor to use
    c=100;
    % k= number of groups
    k=3;
    % Make sure that group containing unit 10 is in a group which is labelled
    % group 1 and group containing unit 12 is in group which is labelled group 2
    UnitsSameGroup=[10 12];
    % Mixture model is used
    mixt=2;
    [out]=tclusteda(Y,k,alphavec,1000,'mixt',2,'UnitsSameGroup',UnitsSameGroup);
%}

%{
    %% tclusteda with M5 data.
    close all
    Y=load('M5data.txt');

    % alphavec= vector which contains the trimming levels to consider
    alphavec=0.10:-0.02:0;
    out=tclusteda(Y(:,1:2),3,alphavec,1000,'nsamp',1000,'plots',1);
%}

%{
    % Structured noise data ex1.
    close all
    Y=load('structurednoise.txt');
    alphavec=0.20:-0.01:0;
    out=tclusteda(Y,2,alphavec,100,'plots',1);
%}

%{
    % Structured noise data ex2.
    close all
    Y=load('structurednoise.txt');
    alphavec=0.20:-0.01:0;
    % just show the monitoring plot
    plots=struct;
    plots.name = {'monitor'};
    out=tclusteda(Y,2,alphavec,100,'plots',plots);
%}

%{
    % mixture100 data.
    close all
    Y=load('mixture100.txt');
    % Traditional tclust
    alphavec=0.20:-0.01:0;
    % just show the allocation plot
    plots=struct;
    plots.name = {'gscatter'};
    out=tclusteda(Y,2,alphavec,100,'plots',plots);
%}

%{
    %% tclusteda using simulated data.
    % 5 groups and 5 variables
    rng(100,'twister')
    n1=100;
    n2=80;
    n3=50;
    n4=80;
    n5=70;
    v=5;
    Y1=randn(n1,v)+5;
    Y2=randn(n2,v)+3;
    Y3=rand(n3,v)-2;
    Y4=rand(n4,v)+2;
    Y5=rand(n5,v);

    group=ones(n1+n2+n3+n4+n5,1);
    group(n1+1:n1+n2)=2;
    group(n1+n2+1:n1+n2+n3)=3;
    group(n1+n2+n3+1:n1+n2+n3+n4)=4;
    group(n1+n2+n3+n4+1:n1+n2+n3+n4+n5)=5;

    close all
    Y=[Y1;Y2;Y3;Y4;Y5];
    n=size(Y,1);
    % Set number of groups
    k=5;

    % Example of the subsets precalculated
    nsamp=2000;
    nsampscalar=nsamp;
    nsamp=subsets(nsamp,n,(v+1)*k);
    % Random numbers to compute proportions computed once and for all
    RandNumbForNini=rand(k,nsampscalar);
    % The allocation is shown on the space of the first two principal
    % components
    out=tclusteda(Y,k,[],6,'plots',1,'RandNumbForNini',RandNumbForNini,'nsamp',nsamp);
%}

%{
    % tclusteda using determinant constraint.
    % Search for spherical clusters.
    % 5 groups and 5 variables
    rng(100,'twister')
    n1=100;
    n2=80;
    n3=50;
    n4=80;
    n5=70;
    v=5;
    Y1=randn(n1,v)+5;
    Y2=randn(n2,v)+3;
    Y3=rand(n3,v)-2;
    Y4=rand(n4,v)+2;
    Y5=rand(n5,v);

    group=ones(n1+n2+n3+n4+n5,1);
    group(n1+1:n1+n2)=2;
    group(n1+n2+1:n1+n2+n3)=3;
    group(n1+n2+n3+1:n1+n2+n3+n4)=4;
    group(n1+n2+n3+n4+1:n1+n2+n3+n4+n5)=5;

    close all
    Y=[Y1;Y2;Y3;Y4;Y5];
    n=size(Y,1);
    % Set number of groups
    k=5;
    cshape=1
    out=tclusteda(Y,k,[],1000,'plots',1,'restrtype','deter','cshape',cshape);
%}

%{
    % An example of use of plots as a structure with field ylimy.
    load('swiss_banknotes');
    Y=swiss_banknotes.data;
    [n,v]=size(Y);
    alphavec=0.15:-0.01:0;
    % alphavec=0.12:-0.005:0;

    % c = restriction factor to use
    c=100;
    % k= number of groups
    k=2;
    % restriction on the determinants is imposed
    restrtype='deter';
    % Specify lower and upper limits for the monitoring plot
    plots=struct;
    % ylimits for monitoring of ARI index
    ylimARI=[0.95 1];
    % ylimits for change in centroids
    ylimCENT=[0 0.02];
    % ylimits for change in cov matrices
    ylimCOV=[0 0.01];
    ylimy=[ylimARI;ylimCENT;ylimCOV];
    plots.ylimy=ylimy;
    [outDet]=tclusteda(Y,k,alphavec,c,'restrtype',restrtype,'plots',plots,'nsamp',10000);
%}


%% Beginning of code
% Control variables, tolerances and internal flags
warning('off');


%% Input parameters checking

nnargin   = nargin;
vvarargin = varargin;

[y,X,n,p] = chkinputR(y,X,nnargin,vvarargin);

% Check the presence of the intercept in matrix X
if min(max(X)-min(X))==0
    intercept = 1;
else
    intercept = 0;
end

% check restrfact option
if nargin < 4 || isempty(restrfact) || ~isnumeric(restrfact)
    restrfact = 12;         % This is the default in R
elseif min(restrfact)<1
    disp('Restriction factor smaller than 1. It is set to 1 (maximum constraint==>spherical groups)');
    restrfact(restrfact<1)=1;
else
end

% Check if restrfact is a scalar or a vector or length 2 (i.e. if the
% restriction is applied also on the explanatory variables)
if length(restrfact)>1
    % restriction factor among eigenvalues of covariance matrices of
    % explanatory variables
    restrfactX=restrfact(2);
    restrfact=restrfact(1);
else
    % No restriction of scatter matrices of explanatory variables
    restrfactX=Inf;
end

% checks on alpha1 (alphaLik) and alpha2 (alphaX)
if alphaLik < 0
    error('FSDA:tclustreg:error','error must a scalar in the interval [0 0.5] or an integer specifying the number of units to trim')
else
    % h is the number of observations not to be trimmed (used for fitting)
    if alphaLik < 1
        h = floor(n*(1-alphaLik));
    else
        h = n - floor(alphaLik);
    end
end

% checks on cwm, which decides if clusterwise regression has to be used
if alphaX < 0 || alphaX >1
    error('FSDA:tclustreg:WrongAlphaX','alphaX must a scalar in the interval [0 1]')
elseif alphaX==1
    cwm=1;
else
    cwm=0;
end

%% *Bivariate thinning* (_if wtrim == 4 and p == 2_)

% Bivariate thinning is applied once on the full dataset, at the start.
% This is done before setting the number of random samples nsamp.

if nargin>6
    % check if wtrim is among the user parameters
    chknwtrim = strcmp(varargin,'wtrim');
    if sum(chknwtrim)>0
        tmp = cell2mat(varargin(find(chknwtrim)+1));
        if ~isstruct(tmp)
            wtrimdef = 0;
            if cell2mat(varargin(find(chknwtrim)+1)) == 4
                interc = find(max(X,[],1)-min(X,[],1) == 0);
                if p == numel(interc) + 1
                    
                    % The bandwidth is chosen following Baddeley, as in the R
                    % spatstats package (density.ppp function).
                    bw = (range([X(:,numel(interc)+1),y]))/8;
                    
                    %in order to reproduce results comparable with the paper
                    %Cerioli and Perrotta (2013) the bandwidth is divided by 3
                    bw = bw/3;
                    % Another option to be considered follwing Baddeley is:
                    %bw = min(max(X),max(y))/8;
                    
                    % Thinning step
                    [Wt4,~] = wthin([X(:,numel(interc)+1),y], 'retainby','comp2one','bandwidth',bw);
                    id_unthinned = Wt4==1;
                    %id_thinned = Wt4==0;
                    
                    % save original data
                    Xori = X;
                    yori = y;
                    
                    % set retained data
                    X    = X(Wt4,:);
                    y    = y(Wt4);
                    
                    %recompute n on the retained data
                    n = size(y,1);
                end
            end
        else
            wtrimdef = struct;
        end
    else
        %no_wtrim = 1;
        wtrimdef = 0;
    end
else
    wtrimdef = 0;
end


%% User options and their default values

%%% - nsamp: the number of subsets to extract randomly, or the indexes of the initial subsets pre-specified by the User

if nargin>6
    
    % Check whether option nsamp exists
    chknsamp = strcmp(varargin,'nsamp');
    if sum(chknsamp)>0
        nsamp=cell2mat(varargin(find(chknsamp)+1));
        
        % Check if options nsamp is a scalar
        if ~isscalar(nsamp)
            % if nsamp is not a scalar, it is a matrix containing in the
            % rows the indexes of the subsets which have to be extracted
            C=nsamp;
            [nsampdef,ncolC]=size(C);
            if ncolC ~= k*p
                disp('p is the total number of explanatory variables (including the constant if present)')
                error('FSDA:tclustreg:WrongInput','Input matrix C must contain k*p columns')
            end
            % The number of rows of nsamp (matrix C) is the number of
            % subsets which have to be extracted
            nselected=nsampdef;
            
            % Flag indicating if the user has selected a prior subset
            NoPriorSubsets=0;
            
            % In case of tandem thinning (Wtrim=4), the initial subset C
            % pre-specified by the user using the nsamp option might
            % include thinned units. In this case, we replace in C such
            % units with others that are close in terms of euclidean
            % distance. Verify the contiguity between the original and
            % replaced units with:
            %{
             figure;plot(Xori,yori,'.'); hold on ; text(Xori(nsamp(:)),yori(nsamp(:)),'X');
             figure;plot(Xori,yori,'.'); hold on ; text(X(C(:)),y(C(:)),'X');
            %}
            if sum(chknwtrim)>0 && ~isstruct(cell2mat(varargin(find(chknwtrim)+1)))
                if cell2mat(varargin(find(chknwtrim)+1))== 4
                    for f=1:size(C,1)*size(C,2)
                        if Wt4(C(f)) == 0
                            [~,C(f)] = min(pdist2([yori(C(f)),Xori(C(f))],[yori(Wt4),Xori(Wt4)]));
                        else
                            C(f) = sum(Wt4(1:C(f)));
                        end
                    end
                end
            end
            
        else
            % If nsamp is a scalar it simply contains the number of subsets
            % which have to be extracted. In this case NoPriorSubsets=1
            NoPriorSubsets=1;
        end
    else
        % If option nsamp is not supplied, then there are no prior subsets
        NoPriorSubsets=1;
    end
else
    % if nargin == 6, then the user has not supplied prior subsets
    NoPriorSubsets=1;
end
% If the user has not specified prior subsets (nsamp is not a scalar), then
% set the default number of samples to extract
if NoPriorSubsets == 1
    ncomb=bc(n,k*(p+intercept));
    nsampdef=min(300,ncomb);
end

%%% - Other user options

% default number of concentration steps
refstepsdef  = 10;

% default tolerance for comparing the classifications in two subsequent
% concentration steps
reftoldef=1e-5;

% default value for we: the observation weights
wedef = ones(n,1);

% default model: classification (mixt=0) or mixture likelihood (mixt=2)
mixtdef = 0;

% default choice for equalweight constraint
equalweightsdef = 1;

%seqk = sequence from 1 to the number of groups
seqk = 1:k;

% automatic extraction of user options
options = struct('intercept',1,'mixt',mixtdef,...
    'nsamp',nsampdef,'refsteps',refstepsdef,...
    'reftol',reftoldef,...
    'we',wedef,'wtrim',wtrimdef,...
    'equalweights',equalweightsdef,...
    'RandNumbForNini','','msg',1,'plots',1,...
    'nocheck',1,'k_dens_mixt',5,'nsamp_dens_mixt',nsampdef,...
    'refsteps_dens_mixt',refstepsdef,'method_dens_mixt','P');

if nargin > 6
    UserOptions = varargin(1:2:length(varargin));
    if ~isempty(UserOptions)
        % Check if number of supplied options is valid
        if length(varargin) ~= 2*length(UserOptions)
            error('FSDA:tclustreg:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
        end
        % Check if all the specified optional arguments were present in
        % structure options. Remark: the nocheck option has already been dealt
        % by routine chkinputR.
        inpchk=isfield(options,UserOptions);
        WrongOptions=UserOptions(inpchk==0);
        if ~isempty(WrongOptions)
            disp(strcat('Non existent user option found->', char(WrongOptions{:})))
            error('FSDA:tclustreg:NonExistInputOpt','In total %d non-existent user options found.', length(WrongOptions));
        end
    end
    
    % Write in structure 'options' the options chosen by the user
    for i = 1:2:length(varargin)
        options.(varargin{i}) = varargin{i+1};
    end
    
    % Check if the number of subsamples to extract is reasonable
    if isscalar(options.nsamp) && options.nsamp>ncomb
        disp('Number of subsets to extract greater than (n k). It is set to (n k)');
        options.nsamp=0;
    elseif  options.nsamp<0
        error('FSDA:tclustreg:WrongNsamp','Number of subsets to extract must be 0 (all) or a positive number');
    end
end

% global variable controlling if messages are displayed in the console.
msg = options.msg;

% Graphs summarizing the results
plots = options.plots;

% Number of subsets to extract or matrix containing the subsets
nsamp = options.nsamp;

% Concentration steps
refsteps = options.refsteps;
reftol   = options.reftol;

% Equalweights constraints
equalweights = options.equalweights;

% application-specific weights vector assigned by the user for beta
% estimation
we         = options.we;


% Flag to control the type of thinning scheme for estimate beta
% (wtype_beta) and to compute obj function (wtype_obj)
if isstruct(options.wtrim)
    % Flag to control the type of thinning scheme for beta estimation
    wtype_beta      = options.wtrim.wtype_beta;
    % Flag to control the type of thinning scheme for obj function
    wtype_obj       = options.wtrim.wtype_obj;
else
    % if options.wtrim is a double it referes only to the beta estimation. No
    % weighting will be done in the obj function.
    wtype_beta      = options.wtrim;
    wtype_obj       ='0';
end
% Flag associated to the strategy for choosing the best refining step
% In the standard TCLUST the best refining step is granted to be the last
% one, because the objective funcion is monothonic. However, with second
% trimming level or componentwise thinning, the objective function may not
% be monothonic and a different strategy for choosing the best refining
% step can be considered.

zigzag = (alphaX > 0 && alphaX<1) || wtype_beta == 3 || wtype_beta == 2 || ~strcmp(wtype_obj, '0');

% Mixt option: type of membership of the observations to the sub-populations
% Control the mixture model to use (classification/mixture, likelihood or a
% combination of both):
%
% * mixt = 0: Classification likelihood
% * mixt = 1: Mixture likelihood, with crisp assignement
% * mixt = 2: Mixture likelihood
%
% $$ \prod_{j=1}^k  \prod_{i\in R_j} \phi (x_i;\theta_j) $$ $$ \quad $$
% $$ \prod_{j=1}^k  \prod_{i\in R_j} \pi_j \phi(x_i;\theta_j) $$ $$ \quad $$
% $$ \prod_{i=1}^n \left[ \sum_{j=1}^k \pi_j \phi (x_i;\theta_j)  \right] $$
mixt       = options.mixt;

if msg == 1
    switch mixt
        case 0
            % Classification likelihood.
            % To select the h untrimmed units, each unit is assigned to a
            % group and then we take the h best maxima
            disp('ClaLik with untrimmed units selected using crisp criterion');
        case 1
            % Mixture likelihood.
            % To select the h untrimmed units, each unit is assigned to a
            % group and then we take the h best maxima
            disp('MixLik with untrimmed units selected using crisp criterion');
        case 2
            % Mixture likelihood.
            % To select the h untrimmed units we take those with h largest
            % contributions to the likelihood
            disp('MixLik with untrimmed units selected using h largest lik contributions');
    end
end

% Initial mixing proportions $\pi_j$ can be user-defined or randomly generated
RandNumbForNini=options.RandNumbForNini;
if isempty(RandNumbForNini)
    NoPriorNini=1;
else
    NoPriorNini=0;
end

%% Initializations

%%% - Observation weights (we)

% Initialize we, a vector of application-specific weights associated to the
% observations, according to the trimming/thinning strategy.

%%% - Subsets extraction

%case with no prior subsets from the User
if NoPriorSubsets
    
    [C,nselected]=subsets(nsamp, n, (p+intercept)*k, ncomb, 0, we);
    
    % C = matrix which contains the indexes of the subsets to extract
    % for the k groups
    
    %nselected is set equal to the number of subsets:
    % - nselected = nsamp, if nsamp is a scalar;
    % - nselected = size(nsamp,1), if nsamp is a matrix (containing the initial subsets)
    
end

%%% - Output structures

% Store the initial subsets indices C
if nargout==2
    varargout={C};
end

% sigma2ini= standard deviation of each group
sigma2ini = ones(1,k);

%%% - Find NParam penalty term to use inside AIC and BIC



%%  RANDOM STARTS
[bopt,sigma2opt,nopt,postprobopt,muXopt,sigmaXopt,vopt,subsetopt,idxopt]...
    =tclustregcore(y,X,RandNumbForNini,reftol,refsteps,mixt,equalweights,h,nselected,k,restrfact,restrfactX,alphaLik,alphaX,...
    seqk,NoPriorNini,sigma2ini,msg,C,intercept,cwm,wtype_beta,we,wtype_obj,zigzag);

%%  END OF RANDOM STARTS


%
% lalpha=length(alpha);
% if msg == 1
%     progbar = ProgressBar(lalpha);
% else
%     progbar=[];
% end
%
% IDX=zeros(n,lalpha);
% outcell=cell(lalpha,1);
%
% MU=zeros(k,v,lalpha);
% SIGMA=cell(lalpha,1);
%
% parfor (j=1:lalpha, numpool)
%     outj  = tclustcore(Y,Cini,Sigmaini,Niini,reftol,refsteps,mixt, ...
%         equalweights,hh(j),nselected,k,restrnum,restrfactor,userepmat,nParam);
%
%     if nnargout==2
%         outcell{j}=outj;
%     end
%
%     IDX(:,j)=outj.idx;
%
%     MU(:,:,j)=outj.muopt;
%     SIGMA{j}=outj.sigmaopt;
%
%     if msg == 1
%         progbar.progress;  %#ok<PFBNS>
%     end
% end
%
% if msg == 1
%     progbar.stop;
% end
%
%
% if ~isempty(UnitsSameGroup)
%
%     [IDXnew1, OldNewIndexes]=ClusterRelabel({IDX(:,1)}, UnitsSameGroup);
%
%     MUold1=MU(:,:,1);
%     SIGMAold1= SIGMA{1};
%
%     MUnew1=MUold1;
%     SIGMAnew1=SIGMAold1;
%     for jj=1:size(OldNewIndexes,1)
%         MUnew1(OldNewIndexes(jj,1),:)= MUold1(OldNewIndexes(jj,2),:);
%         MUnew1(OldNewIndexes(jj,2),:)= MUold1(OldNewIndexes(jj,1),:);
%         MUold1=MUnew1;
%
%         SIGMAnew1(:,:,OldNewIndexes(jj,1))=SIGMAold1(:,:,OldNewIndexes(jj,2));
%         SIGMAnew1(:,:,OldNewIndexes(jj,2))=SIGMAold1(:,:,OldNewIndexes(jj,1));
%         SIGMAold1=SIGMAnew1;
%     end
%     IDX(:,1)=IDXnew1{:};
%     MU(:,:,1)=MUold1;
%     SIGMA{1}=SIGMAold1;
% end
%
%


%% Apply consistency factor based on the variance of the truncated normal distribution.

% hh = number of non trimmed observations, after first and second level trimming
hh = sum(nopt);

% vt = variance of the truncated normal distribution
% 1-hh/n is the trimming percentage
vt = norminv(0.5*(1+hh/n));

if hh<n
    factor = 1/sqrt(1-2*(n/hh)*vt.*normpdf(vt));
    % Apply the asymptotic consistency factor to the preliminary squared scale estimate
    sigma2opt_corr = sigma2opt*factor;
    % Apply small sample correction factor of Pison et al.
    sigma2opt_corr = sigma2opt_corr*corfactorRAW(1,n,hh/n);
else
    sigma2opt_corr = sigma2opt;
end

%%  Set the output structure

out                     = struct;
out.subsetopt           =subsetopt;
%   bopt                = regression parameters
out.bopt                = bopt;
%   sigmaopt0           = estimated group variances
out.sigma2opt           = sigma2opt;
%   sigma2opt_corr      = estimated group variances corrected with  asymptotic
%                         consistency factor and small sample correction factor
out.sigma2opt_corr      = sigma2opt_corr;

%CWM
if cwm==1
    %out.muXopt= k-by-p matrix containing cluster centroid locations.
    out.muXopt=muXopt';
    %out.sigmaXopt= p-by-p-by-k array containing estimated constrained
    %covariance covariance matrices of the explanatory variables for the k
    %groups.
    out.sigmaXopt=sigmaXopt;
end

%   obj           = value of the target function
out.obj                = vopt;

out.C=C;
%in tandem thinning it is necessary to save information about not only
%retained units (idxopt), but also about thinned units.

out.idx   = idxopt;


% frequency distribution of the allocations
out.siz=tabulateFS(idxopt(:,1));

%postprobopt = posterior probabilities in the optimal cstep
if mixt == 2
    out.postprobopt     = postprobopt;
end

% Store the indices in varargout
if nargout==2
    varargout={C};
end

%% Compute INFORMATION CRITERIA

% % Discriminant functions for the assignments
% if equalweights == 1
%     for jj = 1:k
%         ll(:,jj) = log((1/k)) + logmvnpdfFS(y-X*bopt(:,jj),0,sigma2opt(jj));
%         if cwm==1
%             ll(:,jj)=  ll(:,jj)+ logmvnpdfFS(X(:,(intercept+1):end),muXopt(jj,:),sigmaXopt(:,:,jj));
%         end
%     end
% else
%     for jj = 1:k
%         ll(:,jj) = log((nopt(jj)/sum(nopt))) + logmvnpdfFS(y-X*bopt(:,jj),0,sigma2opt(jj));
%         if cwm==1
%             ll(:,jj)=  ll(:,jj)+logmvnpdfFS(X(:,(intercept+1):end),muXopt(jj,:),sigmaXopt(:,:,jj));
%         end
%     end
% end

% Now remove the rows which refer to first, or second level trimmed units
% or thinned units

% delunits=false(n,1);
% delunits(idxopt(:,end)<0)=true;
% delunits(webeta==0)=true;
% 
% ll(delunits,:)=[];

% if mixt>=1
%     [NlogLmixt]=estepFS(ll);
%     % NlogLmixt is the negative of the maximized MIXTURE LOG-LIKELIHOOD
%     % Note that if there was convergence NlogLmixt should be exactly equal to
%     % -vopt
%     NlogLmixt = -NlogLmixt;
% end
% 
% loglik= max(ll,[],2);


% NlogL is the negative of the CLASSIFICATION LOG-LIKELIHOOD  of the
% untrimmed units
% NlogL=-sum(max(ll(untrimmed units,[],2));
% Note that if there was convergence NlogL should be exactly equal to
% -vopt
% NlogL =-sum(loglik);
% 
% 
% logh=log(h);

% if mixt>0
%     % MIXMIX = BIC which uses parameters estimated using the mixture loglikelihood
%     % and the maximized mixture likelihood as goodness of fit measure (New BIC)
%     MIXMIX  = 2*NlogLmixt +nParam*logh;
%     
%     % MIXCLA = BIC which uses the classification likelihood based on
%     % parameters estimated using the mixture likelihood (New ICL)
%     MIXCLA  = 2*NlogL +nParam*logh;
%     
%     out.MIXMIX=MIXMIX;
%     out.MIXCLA=MIXCLA;
% else
%     % CLACLA = BIC which uses parameters estimated using the classification
%     % likelihood and the maximized classification likelihood as goodness of fit
%     % measure (New New)
%     CLACLA  = 2*NlogL +nParam*logh;
%     
%     out.CLACLA=CLACLA;
% end


%% Generate plots

% corfactorRAW function
    function rawcorfac = corfactorRAW(p,n,alpha)
        
        if p > 2
            coeffqpkwad875=[-0.455179464070565,1.11192541278794,2;-0.294241208320834,1.09649329149811,3]';
            coeffqpkwad500=[-1.42764571687802,1.26263336932151,2;-1.06141115981725,1.28907991440387,3]';
            y1_500=1+(coeffqpkwad500(1,1)*1)/p^coeffqpkwad500(2,1);
            y2_500=1+(coeffqpkwad500(1,2)*1)/p^coeffqpkwad500(2,2);
            y1_875=1+(coeffqpkwad875(1,1)*1)/p^coeffqpkwad875(2,1);
            y2_875=1+(coeffqpkwad875(1,2)*1)/p^coeffqpkwad875(2,2);
            y1_500=log(1-y1_500);
            y2_500=log(1-y2_500);
            y_500=[y1_500;y2_500];
            A_500=[1,log(1/(coeffqpkwad500(3,1)*p^2));1,log(1/(coeffqpkwad500(3,2)*p^2))];
            coeffic_500=A_500\y_500;
            y1_875=log(1-y1_875);
            y2_875=log(1-y2_875);
            y_875=[y1_875;y2_875];
            A_875=[1,log(1/(coeffqpkwad875(3,1)*p^2));1,log(1/(coeffqpkwad875(3,2)*p^2))];
            coeffic_875=A_875\y_875;
            fp_500_n=1-(exp(coeffic_500(1))*1)/n^coeffic_500(2);
            fp_875_n=1-(exp(coeffic_875(1))*1)/n^coeffic_875(2);
        else
            if p == 2
                fp_500_n=1-(exp(0.673292623522027)*1)/n^0.691365864961895;
                fp_875_n=1-(exp(0.446537815635445)*1)/n^1.06690782995919;
            end
            if p == 1
                fp_500_n=1-(exp(0.262024211897096)*1)/n^0.604756680630497;
                fp_875_n=1-(exp(-0.351584646688712)*1)/n^1.01646567502486;
            end
        end
        if 0.5 <= alpha && alpha <= 0.875
            fp_alpha_n=fp_500_n+(fp_875_n-fp_500_n)/0.375*(alpha-0.5);
        end
        if 0.875 < alpha && alpha < 1
            fp_alpha_n=fp_875_n+(1-fp_875_n)/0.125*(alpha-0.875);
        end
        if alpha < 0.5
            fp_alpha_n = 1;
            if msg==1
                disp('Warning: problem in subfunction corfactorRAW')
                disp('alpha < 0.5')
            end
        end
        rawcorfac=1/fp_alpha_n;
        if rawcorfac <=0 || rawcorfac>50
            rawcorfac=1;
            if msg==1
                disp('Warning: problem in subfunction corfactorRAW')
                disp(['Correction factor for covariance matrix based on simulations found =' num2str(rawcorfac)])
                disp('Given that this value is clearly wrong we put it equal to 1 (no correction)')
                disp('This may happen when n is very small and p is large')
            end
        end
    end
end


% %% Monitor the difference in classification, centroids and covariance matrices
%
% % Amon stands for alpha monitoring.
% % Amon is the matrix of size lenght(alpha)-1-by 4 which contains for two
% % consecutive values of alpha the monitoring of three quantities.
% % 1st col = value of alpha
% % 2nd col = ARI index
% % 3rd col = squared Euclidean distance between consecutive centroids
% % 4th col = squared Euclidean distance between consecutive covariance matrices
% Amon=[alpha(2:end)' zeros(lalpha-1,3)];
%
% noisecluster=0;
%
% IDXold=IDX;
%
% maxdist=zeros(lalpha,1);
% seqk=(1:k)';
%
% %verMatlab=verLessThanFS('9.2');
%
% for j=2:lalpha
%     newlab=zeros(k,1);
%     mindist=newlab;
%     for ii=1:k
%         % centroid of group ii for previous alpha value
%         muii=MU(ii,:,j-1);
%         % MU(:,:,j) =matrix of centroids for current alpha value
%
%         %if verMatlab==true;
%         muij=bsxfun(@minus,muii,MU(:,:,j));
%         %else
%         %    muij=muii-MU(:,:,j);
%         %end
%
%         [mind,indmin]=min(sum(muij.^2,2));
%         newlab(ii)=indmin;
%         mindist(ii)=mind;
%     end
%     % Store maximum among minimum distances
%     [maxmindist,indmaxdist] =max(mindist);
%     maxdist(j)=maxmindist;
%
%     if isequal(sort(newlab),seqk)
%         MU(:,:,j)=MU(newlab,:,j);
%         SIGMA(j)= {SIGMA{j}(:,:,newlab)};
%         for r=1:k
%             IDX(IDXold(:,j)==newlab(r),j)=r;
%         end
%     else
%         newlab(indmaxdist)=setdiff(seqk,newlab);
%         disp(['Preliminary relabelling not possible when alpha=' num2str(alpha(j))])
%         if isequal(sort(newlab),seqk)
%             MU(:,:,j)=MU(newlab,:,j);
%             SIGMA(j)= {SIGMA{j}(:,:,newlab)};
%             for r=1:k
%                 IDX(IDXold(:,j)==newlab(r),j)=r;
%             end
%         else
%             disp(['Automatic relabelling not possible when alpha=' num2str(alpha(j))])
%         end
%     end
% end
%
% for j=2:lalpha
%
%     % Compute ARI index between two consecutive alpha values
%     [ARI]=RandIndexFS(IDX(:,j-1),IDX(:,j),noisecluster);
%     % Store in the second column the ARI index
%     Amon(j-1,2)=ARI;
%
%     % Compute and store squared euclidean distance between consecutive
%     % centroids
%     Amon(j-1,3)=sum(sum( (MU(:,:,j)-MU(:,:,j-1)).^2, 2));
%
%     % Compute and store squared euclidean distance between consecutive
%     % covariance matrices (all elements of cov matrices are considered)
%     dxdiag=0;
%     for i=1:k
%         dxdiag=dxdiag+sum((diag(SIGMA{j}(:,:,i))-diag(SIGMA{j-1}(:,:,i))).^2);
%     end
%     Amon(j-1,4)=sum(sum(sum((SIGMA{j}-SIGMA{j-1}).^2,2)));
%     % sumdistCOVonlydiag(j)=dxdiag;
% end
%
% out=struct;
%
% % Store classification
% out.IDX=IDX;
% % Store centroids
% out.MU=MU;
% % Store covariance matrices
% out.SIGMA=SIGMA;
% % Store ARI index, variation in centroid location and
% % variation in covariance.
% out.Amon=Amon;
% % Store Y
% out.Y=Y;
%
% % Store the indices in varargout
% if nnargout==2
%     varargout=outcell;
% end
%
%
%
% %% Plotting part
% if isstruct(plots)
%     fplots=fieldnames(plots);
%
%     d=find(strcmp('name',fplots));
%     if d>0
%         name=plots.name;
%         if ~iscell(name)
%             error('FSDA:tclustregeda:Wronginput','plots.name must be a cell')
%         end
%     else
%         name={'gscatter' 'monitor'};
%     end
%
%     d=find(strcmp('alphasel',fplots));
%     if d>0
%         alphasel=plots.alphasel;
%     else
%         alphasel=alpha;
%     end
%
%
%     d=find(strcmp('ylimy',fplots));
%     if d>0
%         ylimy=plots.ylimy;
%         [nylim,vylim]=size(ylimy);
%         if nylim~=3
%             error('FSDA:tclusteda:Wronginput','plots.ylimy must be a matrix with 3 rows')
%         end
%         if vylim~=2
%             error('FSDA:tclusteda:Wronginput','plots.ylimy must be a matrix with 2 columns')
%         end
%     else
%         name={'gscatter' 'monitor'};
%         alphasel=alpha;
%         ylimy='';
%     end
% elseif plots==1
%     name={'gscatter' 'monitor'};
%     alphasel=alpha;
%     ylimy='';
% end
%
% d=find(strcmp('monitor',name));
%
% if d>0
%     % ARI between two consecutive values of alpha
%     subplot(3,1,1)
%     plot(Amon(:,1),Amon(:,2))
%     set(gca,'XDir','reverse');
%     xlabel('\alpha')
%     ylabel('ARI index')
%     set(gca,'FontSize',16)
%     if ~isempty(ylimy)
%         ylim(ylimy(1,:))
%     end
%
%     % Monitoring of centroid changes
%     subplot(3,1,2)
%     plot(Amon(:,1),Amon(:,3))
%     set(gca,'XDir','reverse');
%     xlabel('\alpha')
%     ylabel('Centroids')
%     set(gca,'FontSize',16)
%     if ~isempty(ylimy)
%         ylim(ylimy(2,:))
%     end
%
%     % Monitoring of covariance matrices change
%     subplot(3,1,3)
%     plot(Amon(:,1),Amon(:,3))
%     set(gca,'XDir','reverse');
%     xlabel('\alpha')
%     ylabel('Covariance')
%     set(gca,'FontSize',16)
%     if ~isempty(ylimy)
%         ylim(ylimy(3,:))
%     end
%
% end
%
% d=find(strcmp('gscatter',name));
% if d>0
%
%     % alphasel contains the indexes of the columns of matrix IDX which have
%     % to be plotted
%
%     % We use round(alpha*1e+7)/1e+7 to gaurrantee compatibility with old
%     % versions of MATLAB. For the new versions the instruction would have
%     % been:
%     % [~,alphasel]=intersect(round(alpha,9),alphasel,'stable');
%     [~,alphasel]=intersect(round(alpha*1e+7)/1e+7,round(alphasel*1e+7)/1e+7,'stable');
%     lalphasel=length(alphasel);
%
%     %% Monitoring of allocation
%     if  lalphasel==1
%         nr=1;
%         nc=1;
%     elseif lalphasel==2
%         nr=2;
%         nc=1;
%     elseif lalphasel<=4
%         nr=2;
%         nc=2;
%     elseif lalphasel<=6
%         nr=3;
%         nc=2;
%     elseif lalphasel<=9
%         nr=3;
%         nc=3;
%     elseif lalphasel<=12
%         nr=3;
%         nc=4;
%     else
%         nr=4;
%         nc=4;
%     end
%
%     resup=1;
%     figure('Name',['Monitoring allocation #' int2str(resup)])
%
%     colord='brkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcybrkmgcy';
%     symdef={'+';'o';'*';'x';'s';'d';'^';'v';'>';'<';'p';'h';'+';'o';'*';'x';'s';'d';'^';'v';'>';'<';'p';'h';'+';'o';'*';'x';'s';'d';'^';'v';'>';'<';'p';'h';'+';'o';'*';'x';'s';'d';'^';'v';'>';'<';'p';'h'};
%
%     % Plot first two principal components in presence of more than two
%     % variables
%     if v>2
%         Yst=zscore(Y);
%         [V,D]=eig(cov(Yst));
%         [Dsort,ind] = sort(diag(D),'descend');
%         Ypca=Yst*V(:,ind(1:2));
%         explained=100*Dsort(1:2)/sum(Dsort);
%         % Note that the rows above are just for retrocompatibility
%         % Those who have a release >=2012B can use
%         % [~,Ypca,~,~,explained]=pca(zscore(Y),'NumComponents',2);
%     else
%         Ypca=Y;
%     end
%
%     jk=1;
%     for j=1:lalphasel
%
%         % The monitoring must contain a maximum of 16 panels
%         % If length(alpha) is greater than 16 a new set of 16 subpanels is
%         if jk>16
%             jk=1;
%             resup=resup+1;
%             figure('Name',['Monitoring allocation #' int2str(resup)])
%             subplot(nr,nc,jk)
%         else
%             subplot(nr,nc,jk)
%         end
%         jk=jk+1;
%
%
%         if v>=2
%             if alpha(alphasel(j))~=0
%                 hh=gscatter(Ypca(:,1),Ypca(:,2),IDX(:,alphasel(j)),colord,[symdef{1:k+1}]);
%             else
%                 hh=gscatter(Ypca(:,1),Ypca(:,2),IDX(:,alphasel(j)),colord(2:k+1),[symdef{2:k+1}]);
%             end
%
%             if v>2
%                 xlabel(['PCA1 - ' num2str(explained(1)) '%'])
%                 ylabel(['PCA2 - ' num2str(explained(2)) '%'])
%             else
%                 xlabel('y1')
%                 ylabel('y2')
%             end
%
%             clickableMultiLegend(hh)
%             if jk>2
%                 legend hide
%             end
%             axis manual
%         else
%             % Univariate case: plot the histogram
%             if alpha(alphasel(j))~=0
%                 histFS(Y,10,IDX(:,alphasel(j)),[],[],colord)
%             else
%                 histFS(Y,10,IDX(:,alphasel(j)),[],[],colord(2:k+1))
%             end
%         end
%         title(['$\alpha=$' num2str(alpha(alphasel(j)))],'Interpreter','Latex')
%     end
% end
%

%FScategory:CLUS-RobClaMULT