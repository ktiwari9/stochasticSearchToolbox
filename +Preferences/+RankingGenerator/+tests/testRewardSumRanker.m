clear variables;
close all;

settings = Common.Settings();
settings.setProperty('numTimeSteps', 100);   
            
sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();

environment = Environments.Gridworld.SimpleWorld(sampler);

sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);

sampler.setReturnFunction(RewardFunctions.ReturnForEpisode.ReturnSummedReward(sampler));

features = Preferences.RankingGenerator.RewardSumRanker(dataManager, 'returns');

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 5;

sampler.setParallelSampling(true);
fprintf('Generating Data 1\n');
tic
sampler.createSamples(newData);
toc

newData.getDataEntry('returnsranks')
