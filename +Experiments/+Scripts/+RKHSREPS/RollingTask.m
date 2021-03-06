%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');
%error('check whether the script works in the new toolbox!');
category = 'test';
experimentName = 'test';
numTrials = 1;
numIterations = 20;

configuredTask = Experiments.Tasks.ReflexHandTask();

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPSPeriodic');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew; 
% was: Experiments.Features.FeatureRBFKernelStates;

% don't need these?? configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew;
%was configuredActionFeatures = Experiments.Features.GaussianActionPeriodicStateKernel;

configureModelKernel = Experiments.Features.ModelFeatures;

% action policy configurator
%was: configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfigurator;
configuredPolicy = Experiments.ActionPolicies.SingleGaussianProcessPolicyConfiguratorNew;

evaluationCriterion = Experiments.EvaluationCriterion();



%evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());

evaluate = Experiments.Evaluation(...
    {'settings.useslowness',...
    'settings.RKHSparams_V','settings.RKHSparams_ns',...
    'settings.numSamples','settings.numInitialSamplesEpisodes','settings.maxSamples',...
    'stateKernel','policyKernel',...
    'modelKernel_s'},{...
    false, ... % use slowness objective
     [1    0.4  1.0  0.4], ... %0 indicates features should be optimized
     [-0.1 -0.4 -1.0 -0.4 -0.05], ... %0 indicates features should be optimized
     10,... #numsamples
     30,... #numInitialSamples
     30,... # maxSamples
     @(trial) Kernels.ProductKernel( ...
            trial.dataManager,6, ...
            {Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ExpQuadKernel1',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ExpQuadKernel2',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ExpQuadKernel3',false)},...
             {1:2, 3:4, 5:6}, 'stateKernelExpQuad'),...
     @(trial) Kernels.ProductKernel( ...
            trial.dataManager,6, ...
            {Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'PolicyKernel1',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'PolicyKernel2',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'PolicyKernel3',false)},...
             {1:2, 3:4, 5:6}, 'PolicyKernel'),...
     @(trial) Kernels.ProductKernel( ...
            trial.dataManager,6, ...
            {Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ModelStates1',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ModelStates2',false),...
             Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 2, 'ModelStates3',false)},...
             {1:2, 3:4, 5:6}, 'ModelStates'),....
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);


evaluate.setDefaultParameter('GPInitializer', @(dm,varOut, varIn, dimIndicesOut,trial) Kernels.GPs.GaussianProcess(dm, trial.policyKernel(trial), varOut, varIn, dimIndicesOut));
evaluate.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet);
evaluate.setDefaultParameter('useStateFeaturesForPolicy' , false);
evaluate.setDefaultParameter('settings.tolSF',0.0001);
evaluate.setDefaultParameter('settings.epsilonAction' , 0.5);
evaluate.setDefaultParameter('settings.numSamplesEvaluation' , 100);
evaluate.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );

%what is the difference between these two?
evaluate.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate.setDefaultParameter('maxNumberKernelSamples', 3000);

evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDExpQuadKernel1', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDExpQuadKernel2', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDExpQuadKernel3', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDPolicyKernel1', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDPolicyKernel2', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDPolicyKernel3', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDActions', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDModelStates1', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDModelStates2', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDModelStates3', false);
evaluate.setDefaultParameter('settings.ExponentialQuadraticKernelUseARDModelActions', false);



% -> cannot overload well in current script?
evaluate3_notactile = Experiments.Evaluation(...
    {'settings.usetomlab','settings.optimalg', 'settings.useslowness',...
    'actionPolicy','policyLearner',...
    'useStateFeaturesForPolicy','settings.RKHSparams_V','settings.RKHSparams_ns',...
    'settings.tolSF','settings.policyParameters','settings.epsilonAction',...
    'settings.numSamplesEvaluation','maxNumberKernelSamples',...
    'settings.maxSizeReferenceSet',...
    'settings.numSamples','settings.numInitialSamplesEpisodes','settings.maxSamples',...
    'stateFeatures','nextStateFeatures','policyKernel','actionFeatures',...
    'kernel_s2', 'kernel_a'},{...
    false,... % use tomlab
    0, ...
    false, ... % use slowness objective
    @(trial,ft) Distributions.NonParametric.GaussianProcessPolicy(trial.dataManager,trial.policyFeatures,ft),...
    @(dm, pol, ft) Learner.SupervisedLearner.GaussianProcessPolicyLearner3(dm, pol,'sampleWeights', 'states', 'actions',ft),...  
    false,...
    [1 1 1e6 1 0.6 1 0.6], ... %0 indicates features should be optimized
    [-0.1 1 1e6 1 -0.6 1 -0.6 1 -0.2], ... %0 indicates features should be optimized
     0.0001,...
     [-0.001, -0.001, 1e6 1 -0.6, 1, -0.6],...
     0.5,...
     100,...
     3000,...
     3000,...
     10,... #numsamples
     10,... #numInitialSamples
     30,... # maxSamples
      @(trial) FeatureGenerators.KernelBasedFeature(trial.dataManager, ...
        FeatureGenerators.Kernel.ProductKernel( ...
            trial.dataManager,trial.maxNumberKernelSamples, ...
            {FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 1:2, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel1',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 3:4, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 5:6, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false)}),...
                trial.maxNumberKernelSamples),...
     @(trial) FeatureGenerators.KernelBasedFeature(trial.dataManager, ...
        FeatureGenerators.Kernel.ProductKernel( ...
            trial.dataManager,trial.maxNumberKernelSamples, ...
            {FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 1:2, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel1',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 3:4, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 5:6, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false)}),...
            trial.maxNumberKernelSamples, {'states'}),...  
     @(trial) FeatureGenerators.Kernel.ProductKernel( ...
            trial.dataManager,trial.maxNumberKernelSamples, ...
            {FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 1:2, trial.maxNumberKernelSamples, ...
                'PolicyKernel1',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 3:4, trial.maxNumberKernelSamples, ...
                'PolicyKernel1',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, 5:6, trial.maxNumberKernelSamples, ...
                'PolicyKernel1',false, false)}, 'PolicyKernel'),...
     @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {'actions'}, ':', trial.maxNumberKernelSamples, ...
                'ExpQuadKernel',false, false),...
     @(trial) FeatureGenerators.Kernel.ProductKernel( ...
            trial.dataManager,trial.maxNumberKernelSamples, ...
            {FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 1:2, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel1',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 3:4, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false),...
             FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStates'}}, 5:6, trial.maxNumberKernelSamples, ...
                'ExpQuadKernel2',false, false)}),...
     @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {'actions'}, ':', trial.maxNumberKernelSamples,...
                'ExpQuadKernel', false,false),...
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);



% evaluate_modellearners_rkhs = Experiments.Evaluation(...
%     {'modelLearner'},...
%     {...
%         @(trial) Learner.ModelLearner.RKHSModelLearner_unc(trial.dataManager, ...
%                 ':', trial.stateFeatures,...
%                 trial.nextStateFeatures,trial.stateActionFeatures);...
%     },numIterations,numTrials);

evaluate_modellearners_rkhs = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @(trial) Learner.ModelLearner.RKHSModelLearnernew(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.modelKernel);...
    },numIterations,numTrials);




evaluate_modellearners_rkhs = Experiments.Evaluation.getCartesianProductOf([evaluate, evaluate_modellearners_rkhs]);
%evaluate_modellearners_notactile = Experiments.Evaluation.getCartesianProductOf([evaluate3_notactile, evaluate_modellearners_rkhs]);


 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configureModelKernel, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_modellearners_rkhs);
%experiment.addEvaluation(evaluate_modellearners_notactile);

experiment.startLocal();
%experiment.startBatch(20);

