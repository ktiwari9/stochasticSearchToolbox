Common.clearClasses();

MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 2;
numIterations = 20;

configuredTask = Experiments.Tasks.StepBasedLinear(true);

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPS');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
% parameters:
% bw := bandwidth of the kernel
% settings.RKHSparamsstate: [regularizer, scale (=1), bw states 1, bw states 2, scale(=1), bw actions
% settings.RKHSparamsactions: [regularizer, scale (=1), bw states 1,  bw states 2, scale(=1), bw actions
% settings.tolSF: maximum violation of REPS' feature matching constraint
% settings.policyParameters: [regularizer, scale (!=1 usually), bw states 1, bw states2
% settings.epsilonAction: epsilon from the REPS problem

% Gaussian policy +  + default (exponential quadratic kernel) features
evaluate1 = Experiments.Evaluation(...
    {'actionPolicy','policyLearner','settings.RKHSparamsstate','settings.RKHSparamsactions','settings.tolSF','settings.policyParameters','settings.epsilonAction'},{...
    @(dm,kernel) Distributions.Gaussian.GaussianActionPolicy(dm),...
    @Learner.SupervisedLearner.LinearGaussianCV, ...
    [1e-4 1 1 1 1 1],...
    [1e-4 1 1 1 1 1],...
    0.01,...
    [1e-4 1 1 1 1 1],...
    0.5,...
    },numIterations,numTrials);

% Gaussian process (GP) policy + default (exponential quadratic kernel) features
evaluate2 = Experiments.Evaluation(...
    {'actionPolicy','policyLearner','settings.RKHSparamsstate','settings.RKHSparamsactions','settings.tolSF','settings.policyParameters','settings.epsilonAction'},{...
    @(dm, kernel) Distributions.NonParametric.GaussianProcessPolicy(dm, kernel),...
    @(dm, pol)Learner.SupervisedLearner.GaussianProcessPolicyLearner2(dm, pol,'sampleWeights', 'states', 'actions'),...
    [1e-4 1 1 1 1 1],...
    [1e-4 1 1 1 1 1],...
    0.01,...
    [1e-4 1 1 1],...
    0.5,...
    },numIterations,numTrials);

% Gaussian process (GP) policy + squared features
evaluate3 = Experiments.Evaluation(...
    {'actionPolicy', 'policyLearner', 'stateFeatures', 'nextStateFeatures','modelLearner','settings.RKHSparamsstate','settings.RKHSparamsactions','settings.tolSF','settings.policyParameters','settings.epsilonAction'},...
    { ...
        @(dm, kernel) Distributions.NonParametric.GaussianProcessPolicy(dm, kernel),...
        @(dm, pol)Learner.SupervisedLearner.GaussianProcessPolicyLearner2(dm, pol,'sampleWeights', 'states', 'actions'),...  
        @(dm) FeatureGenerators.SquaredFeatures(dm, 'states', ':'),...
        @(dm) FeatureGenerators.SquaredFeatures(dm, 'nextStates',':'),...
        @Learner.ModelLearner.SampleModelLearner, ...
        [1e-4 1 1 1 1 1],...
        [1e-4 1 1 1 1 1],...
        0.01,...
        [1e-4 1 1 1],...
        0.5,...
    },numIterations,numTrials);


%  gaussian policy + squared ft
evaluate4 = Experiments.Evaluation(...
    {'actionPolicy', 'policyLearner', 'stateFeatures', 'nextStateFeatures','modelLearner','settings.RKHSparamsstate','settings.RKHSparamsactions','settings.tolSF','settings.policyParameters','settings.epsilonAction'},...
    { ...
        @(dm, kernel) Distributions.Gaussian.GaussianActionPolicy(dm),...
        @Learner.SupervisedLearner.LinearGaussianCVLearner,...  
         @(dm) FeatureGenerators.SquaredFeatures(dm, 'states', ':'),...
         @(dm) FeatureGenerators.SquaredFeatures(dm, 'nextStates',':'),...
         [1e-4 1 1 1 1 1],...
        [1e-4 1 1 1 1 1],...
        0.01,...
        [1e-4 1 1 1],...
        0.5,...
        @Learner.ModelLearner.SampleModelLearner ...
    },numIterations,numTrials);





experiment = Experiments.Experiment.createByName(experimentName, category, configuredTask, configuredLearner, evaluationCriterion, 5);

experiment.addEvaluation(evaluate1);
experiment.addEvaluation(evaluate2);
%experiment.addEvaluation(evaluate3);
%experiment.addEvaluation(evaluate4);

experiment.startLocal();
