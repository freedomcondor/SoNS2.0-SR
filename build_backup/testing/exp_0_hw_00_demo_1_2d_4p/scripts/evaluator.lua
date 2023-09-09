package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/logReader/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/scripts/../?.lua"

logger = require("Logger")
logReader = require("logReader")
logger.enable()

local gene = require("morphology")
local geneIndex = logReader.calcMorphID(gene)

local robotsData = logReader.loadData("./logs")

logReader.calcSegmentData(robotsData, geneIndex)

logReader.saveData(robotsData, "result_data.txt")
