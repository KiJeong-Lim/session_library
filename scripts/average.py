
import sys
import math
import copy 
import statistics

# get cmd arg for file output location 
output_folder_location = (sys.argv[0])

def getNumber(s):
    output = ""
    for i in range(len(s)):
        if s[i].isdigit():
            output += s[i]
    return output

def generateFiles():
    files = []
    configs = ["GossipRandom", "PinnedRoundRobin", "PrimaryBackUpRandom", "PrimaryBackUpRoundRobin"]
    workloads = ["50"]
    for c in configs:
        for w in workloads:
            files.append(output_folder_location + c + "/" + "workload_" + w)
    return files

files = generateFiles()

for file in files:
    for session in range(0, 6):
        for i in range(1, 11):
            tempThroughput = []
            tempLatency = []
            for run in range(1,4):
                f = open(file + "/" + str(session) + "/" + "run_" + str(run) + "/" + str(i), "r") 
                contents = f.read().splitlines()
                throughput = getNumber(contents[4])
                latency = getNumber(contents[5])
                if throughput.isnumeric():
                    tempThroughput.append(int(throughput))
                if latency.isnumeric():
                    tempLatency.append(int(latency))
                
            w = open(file + "/" + str(session) + "/" + str(i), "w")
            w.write("Throughput: " + str(int(statistics.mean(tempThroughput))) + "\n")
            w.write("Latency: " + str(int(statistics.mean(tempLatency))))
