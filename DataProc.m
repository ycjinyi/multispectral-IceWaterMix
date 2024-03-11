classdef DataProc < DataAttribute
%此类用于专门同时处理训练集和测试集的数据

    properties

    end

    methods
        function obj = DataProc()
            obj = obj@DataAttribute();
        end
        
        %标准化数据, 注意行为一条数据, 列为特征
        function [trainData, testData] = zScore(~, trainData, testData)
            trainMean = mean(trainData, 1);
            trainVar = std(trainData, [], 1);
            trainData = (trainData - trainMean) ./ trainVar;
            testData = (testData - trainMean) ./ trainVar;
        end

        %PCA对数据进行降维
        function [trainData, testData] = PCA(~, trainData, testData, ratio)
            %计算协方差矩阵  
            covMatrix = cov(trainData);  
            %计算特征值和特征向量  
            [V, D] = eig(covMatrix);  
            %对特征值进行排序，并获取对应的特征向量  
            [D, sortIdx] = sort(diag(D), 'descend');  
            V = V(:, sortIdx);  
            %选择主成分以保留ratio的方差解释  
            cumVariance = cumsum(D) / sum(D);  
            numComponents = find(cumVariance >= ratio, 1, 'first');  
            %提取选定的主成分对应的特征向量  
            trainV = V(:, 1:numComponents);  
            %转换数据到新的低维空间  
            trainData = trainData * trainV;
            testData = testData * trainV;
        end

        %厚度回归的特征处理函数
        function [trainData, testData] = strucThickFeature(obj, trainData, testData)
            sIdx = size(trainData, 2) + 1;
            cIdx = sIdx;
            %只需要890nm波段的数据
            for i = 1: obj.rNum
                idx = (i - 1) * obj.pNum + 1;
                trainData(:, cIdx) = trainData(:, idx);
                testData(:, cIdx) = testData(:, idx);
                cIdx = cIdx + 1;
            end
            trainData = trainData(:, sIdx: cIdx - 1);
            testData = testData(:, sIdx: cIdx - 1);
            %进一步构造特征
            for i = 1: size(trainData, 2) - 1
                trainData(:, cIdx) = trainData(:, i) + trainData(:, i + 1);
                trainData(:, cIdx + 1) = trainData(:, i) ./ trainData(:, i + 1);
                testData(:, cIdx) = testData(:, i) + testData(:, i + 1);
                testData(:, cIdx + 1) = testData(:, i) ./ testData(:, i + 1);
                cIdx = cIdx + 2;
            end
        end

        %构造特征, 注意行为一条数据, 列为特征
        function [trainData, testData] = strucRatioFeature(obj, trainData, ...
                trainThick, testData, testThick)
            cIdx = size(trainData, 2) + 1;
            %将不同接收管的相同波段的比值作为特征 
            for i = 1: obj.rNum - 1
                idx1 = (i - 1) * obj.pNum;
                idx2 = i * obj.pNum;
                for j = 1: obj.pNum
                     trainData(:, cIdx) = trainData(:, idx1 + j) ./ trainData(:, idx2 + j);
                     trainData(:, cIdx + 1) = trainData(:, idx1 + j) + trainData(:, idx2 + j);
                     testData(:, cIdx) = testData(:, idx1 + j) ./ testData(:, idx2 + j);
                     testData(:, cIdx + 1) = testData(:, idx1 + j) + testData(:, idx2 + j);
                     cIdx = cIdx + 2; 
                end
            end
            %将相同接收管的不同波段的比值、和值作为特征
            for i = 1: obj.rNum
                idx = (i - 1) * obj.pNum;
                for j = 1: obj.pNum - 1
                    trainData(:, cIdx) = trainData(:, idx + j) ./ trainData(:, idx + j + 1);
                    trainData(:, cIdx + 1) = trainData(:, idx + j) + trainData(:, idx + j + 1);
                    testData(:, cIdx) = testData(:, idx + j) ./ testData(:, idx + j + 1);
                    testData(:, cIdx + 1) = testData(:, idx + j) + testData(:, idx + j + 1);
                    cIdx = cIdx + 2;
                end
            end
            %添加厚度特征
            trainData(:, cIdx) = trainThick;
            testData(:, cIdx) = testThick;
        end

        %冰厚回归的模型数据处理
        function [trainData, testData] = thickModel(obj, trainData, testData, ratio)
            %构造特征
            [trainData, testData] = obj.strucThickFeature(trainData, testData);
            %标准化数据
            [trainData, testData] = obj.zScore(trainData, testData);
            %PCA降维
            [trainData, testData] = obj.PCA(trainData, testData, ratio);
        end

        %冰水比例模型的数据处理
        function [trainData, testData] = ratioModel(obj, trainData, trainThick, ...
                testData, testThick, ratio)
            %构造特征
            [trainData, testData] = obj.strucRatioFeature(trainData, ...
                trainThick, testData, testThick);
            %标准化数据
            [trainData, testData] = obj.zScore(trainData, testData);
            %PCA降维
            [trainData, testData] = obj.PCA(trainData, testData, ratio);
        end

    end
end