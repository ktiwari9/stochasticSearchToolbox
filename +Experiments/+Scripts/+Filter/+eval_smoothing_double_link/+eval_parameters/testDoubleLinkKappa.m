close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalDoubleLinkSmoothing';
%category = 'test';
experimentName = 'evalParameters_Kappa';

% set some variables
kappa = {exp(-6);exp(-7);exp(-8);exp(-9);exp(-10);exp(-11);exp(-12)};
numIterations = 1;
numTrials = 10;

% create a task
configuredTask = Experiments.Tasks.DoubleLinkSwingDownTask(false);

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Smoother.GeneralizedKernelKalmanSmootherConfiguratorNoOpt('gkksConf');

settings = Common.Settings();
settings.setProperty('observationIndex',1:2);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.SmoothedDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.GKKS_kappa'},kappa,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1e-1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',1000);
evaluate.setDefaultParameter('settings.numTimeSteps',23);

% evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
% evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
% evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 5);
evaluate.setDefaultParameter('settings.observationIndex', 1:2);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-4);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:5,18]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy'});
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 5);
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'endEffPositionsNoisy'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 10);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisy','obsPoints'});
% filterLearner_stateKernelType: ExponentialQuadraticKernel
% filterLearner_obsKernelType: ExponentialQuadraticKernel
% filterLearner_transitionModelLearnerType: TransitionModelLearnerReg
% filterLearner_observationModelLearnerType: ObservationModelLearnerReg
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');

% evaluate.setDefaultParameter('settings.GKKS_kappa',exp(-8));
evaluate.setDefaultParameter('settings.GKKS_lambdaO',exp(-12));
evaluate.setDefaultParameter('settings.GKKS_lambdaT',exp(-12));



% gkkf settings
% gkkfName = 'GKKF';
% GKKF_lambdaT
% GKKF_lambdaO
% GKKF_kappa

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 1);
evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 1);

evaluate.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
evaluate.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
% evaluate.setDefaultParameter('settings.ParameterMapGKKF_CMAES_optimization',[true false(1,14) true(1,3)]);
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','endEffPositions');
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1:2);
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','');
% evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
% evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 175);

evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositions');
evaluate.setDefaultParameter('evaluationObservations','endEffPositionsNoisy');
evaluate.setDefaultParameter('evaluationValid','endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('evaluationObjective','euclideanDistance');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8);
% experiment.startLocal