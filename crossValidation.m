function [tThickSet, tThickPreSet, tRatioSet, tRatioPreSet, dataSet, k] = crossValidation(DM, step)
%此函数负责进行K折交叉验证, 并将验证结果汇总, DM是保存所有数据的对象, step是分组个数
    %初始索引
    idx = 1;
    %数据处理对象
    DP = DataProc();
    %-------->1 划分数据集合
    %首先获取所有数据编号信息
    dataSet = DM.getNumber();
    snum = size(dataSet, 1);
    %然后将dataSet随机化
    randIdx = randperm(snum); 
    dataSet = dataSet(randIdx, 1); 
    %折数
    k = ceil(snum / step);
    %通过按照step步长遍历数组的方式划分训练集和测试集
    for i = 1: step: snum
        
        %测试集范围
        sIdx1 = i;
        sIdx2 = min(i + step - 1, snum);
        %得到训练集编号
        trainSet = [dataSet(1: sIdx1 - 1, 1); dataSet(sIdx2 + 1: end, 1)];
        %获得划分后的训练集和测试集数据
        [trainData, trainThick, trainRatio, ...
                testData, testThick, testRatio] = DM.generateData(trainSet);

        %----step1 构建用于厚度回归的数据, 目标是厚度
        [trainData1, testData1] = DP.thickModel(trainData, testData, 1);
        %训练厚度回归模型
        [thickModel, ~] = trainThickModel(trainData1, trainThick);
        %预测厚度
        testThickPredict = thickModel.predictFcn(testData1);

        %----step2 构建用于比例回归的数据, 目标是水占比
        [trainData2, testData2] = DP.ratioModel(trainData, trainThick, testData, testThickPredict, 1);
        %训练比例回归模型
        [ratioModel, ~] = trainRatioModel(trainData2, trainRatio);
        %预测比例
        testRatioPredict = ratioModel.predictFcn(testData2);   

        %装载数据
        r = size(testThickPredict, 1);
        tThickSet(idx: idx + r - 1, 1) = testThick;
        tThickPreSet(idx: idx + r - 1, 1) = testThickPredict;
        tRatioSet(idx: idx + r - 1, 1) = testRatio;
        tRatioPreSet(idx: idx + r - 1, 1) = testRatioPredict;

        idx = idx + r;

        %输出进度
        fprintf("---->%0.1f%%<-----\n", 100 * floor((i + step) / step) / k);
    end
end