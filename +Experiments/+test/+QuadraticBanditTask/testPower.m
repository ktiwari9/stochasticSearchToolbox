
            close all;
            Common.clearClasses();
            %clear all;
            clc;
            
            MySQL.mym('closeall');
            
            category = 'test';
            experimentName ='numSamples'
            numTrials = 10;
            numIterations = 100;
            
            configuredTask = Experiments.Tasks.QuadraticBanditTask();
            
            %%
            configuredLearner = Experiments.Learner.BanditLearningSetup('PowerTemperatureRewardNoise');
            
            evaluationCriterion = Experiments.EvaluationCriterion();
            evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
            evaluationCriterion.registerEvaluator(evaluator);
            


standard = Experiments.Evaluation(...
    { 'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', 'settings.maxCorrParameters',  'settings.initSigmaParameters', 'settings.numSamplesEpisodesVirtual', ...
    'settings.rewardNoiseMult','settings.maxSamples','settings.bayesNoiseSigma','settings.bayesParametersSigma'},{...
    10,100,1.0, 0.05, 1000,0,100,1,10^-3; ...
    },numIterations,numTrials);



variablesRewardNoiseMult = Experiments.Evaluation(...
    {'settings.rewardNoise'},{...
    0; ...
    1; ...
    2; ...
    3; ...
        },numIterations,numTrials);


variablesTemperatureScalingPower = Experiments.Evaluation(...
    {'settings.temperatureScalingPower'},{...
    25; ...
    5; ...
    10; ...
    15; ...
    20; ...
    },numIterations,numTrials);


            learner = Experiments.Evaluation(...
                {'learner'},{...
                @Learner.EpisodicRL.EpisodicPower.CreateFromTrial; ...
                },numIterations,numTrials);
            
            
            evaluate = Experiments.Evaluation.getCartesianProductOf([standard,variablesRewardNoiseMult,variablesTemperatureScalingPower,learner ]);

            experiment = Experiments.Experiment.createByName(experimentName, category, ...
                configuredTask, configuredLearner, evaluationCriterion, 5, ...
                {'127.0.0.1',2});
            
            experiment.addEvaluation(evaluate);
            experiment.startLocal();
            %experiment.startRemote();
