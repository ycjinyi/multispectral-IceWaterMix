classdef DataManagement < DataAttribute
%该类用于管理不同组的实验数据, 并提供快速获取数据的接口

    properties

        %编号和数据对应的集合
        number2Data;
        %编号和待预测厚度对应的集合
        number2Tar;

        %保存数据的列
        dataCol = 4;
        %温度所在的行
        tempRow = 1;
        %890nm波段第一路接收的起始行
        p890 = 4;
        %时间数据的列
        timeCol = 5;
        %每帧数据的行数
        dataFrame = 30;
    end

    methods

        function obj = DataManagement()
            obj = obj@DataAttribute();
            obj.number2Data = containers.Map("KeyType", 'int32', "ValueType", 'any');  
            obj.number2Tar = containers.Map("KeyType", 'int32', "ValueType", 'any');
        end
        
        %此函数目标文件夹下读取数据并保存
        function readFile(obj, path)
            %获得目标路径下的所有文件名称
            names = dir(fullfile(path, '*.xlsx'));
            for i = 1: length(names)
                name = names(i).name;
                %获取编号
                number = str2double(name(1, 1: end - 5));
                %当前文件的路径
                nowFile = path + "\" + name;
                %读取数据
                data = readmatrix(nowFile);
                %不需要最开始的时间戳信息
                obj.number2Data(number) = data(:, 5: end);
                obj.number2Tar(number) = data(:, 2: 3);
            end
        end

        %获取数据的接口
        %numbers数组是需要获取的数据编号, 按行取
        function [data, tar] = getData(obj, numbers)
            data = [];
            tar = [];
            ridx = 1;
            for i = 1: size(numbers, 1)
                if ~isKey(obj.number2Data, numbers(i, 1))
                    continue;
                end
                rowData = obj.number2Data(numbers(i, 1));
                [r, c] = size(rowData);
                data(ridx: ridx + r - 1, 1: c) = rowData;
                rowTar = obj.number2Tar(numbers(i, 1));
                [r, c] = size(rowTar);
                tar(ridx: ridx + r - 1, 1: c) = rowTar;
                ridx = ridx + r;
            end
        end   

        %获取所有编号
        function numbers = getNumber(obj)
            keySets = keys(obj.number2Data);
            keyNums = size(keySets, 2);
            numbers = zeros(keyNums, 1);
            for i = 1: keyNums
                numbers(i, 1) = keySets{1, i};
            end
        end

        %根据指定的划分方式, 将数据划分为训练集和测试集合数据并返回
        %注意数据都是按行存储
        %trainSets指定了训练集的数据选取方式, 其余数据为测试集
        %每行为名称和数据编号
        function [trainData, trainTar, testData, testTar] = generateData(obj, trainSet)
            trainIdx = 1;
            testIdx = 1;
            keyNumbers = keys(obj.number2Data);
            for i = 1: length(keyNumbers)
                nowKey = keyNumbers{1, i};
                nowData = obj.number2Data(nowKey);
                nowTar = obj.number2Tar(nowKey);
                [r1, c1] = size(nowData);
                [~, c2] = size(nowTar);
                if find(trainSet == nowKey)
                    s = trainIdx;
                    e = trainIdx + r1 - 1;
                    trainData(s: e, 1: c1) = nowData;
                    trainTar(s: e, 1: c2) = nowTar;
                    trainIdx = trainIdx + r1;
                else
                    s = testIdx;
                    e = testIdx + r1 - 1;
                    testData(s: e, 1: c1) = nowData;
                    testTar(s: e, 1: c2) = nowTar; 
                    testIdx = testIdx + r1;
                end
            end
        end

    end
end