
import sys
import math
import copy 
import statistics
import os

# get cmd arg for file output location 
pwd = os.getcwd()

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
            files += [pwd + "/output/" + c + "/" + "workload_" + str(w)]
    return files

files = generateFiles()

for file in files:
    for session in range(0, 6):
        tempThroughput = []
        tempLatency = []
        os.mkdir(dir)
        for run in range(1,4):
            for i in range(1, 11):
                f = open(file + "/" + str(session) + "/" + str(session) + "/" + "run_" + str(run) + "/" + str(i), "r") 
                contents = f.readline().split()
                throughput = getNumber(contents[4])
                latency = getNumber(contents[5])
                if throughput.isnumeric():
                    tempThroughput += [int(throughput)]
                if latency.isnumeric():
                    tempLatency += [int(latency)]
            w = open(pwd + "/output" + "/" + str(session) + "/" + str(i), "w+")
            w.write("Throughput: " + str(int(statistics.mean(tempThroughput))) + "\n")
            w.write("Latency: " + str(int(statistics.mean(tempLatency))))
