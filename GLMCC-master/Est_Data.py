#Author: Junichi haruna
'''
Estimate PSPs from Data.

Input : Data file and the number of data

Command : python3 Est_Data.py (Data file name) (the number of data) (sim or exp(simulation or experiment))

example command : python3 Est_Data.py simulation_data 20 sim

'''
import multiprocessing as mp
import time
import subprocess as proc
from glmcc import *
import sys
import subprocess as proc
import os

global log_name
global num_cpu

num_cpu=4
log_name="log "+time.strftime("%Y_%d_%H_%M_%S", time.gmtime())+".txt"

# put the data file into .\GLMCC-master\experimental_data folder
folder_path = 'experimental_data'
# Count the number of files in the folder
num_files = len([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))])
# str(num_files-1)
sys.argv = ['Est_Data.py', folder_path, str(num_files-1) , 'exp', 'GLMCC']
args = sys.argv

if len(args) != 5:
    print("Usage: python3 Est_Data.py (Data file name) (the number of data) (sim or exp) (GLM or LR)")
    exit(0)

DataFileName = args[1]
DataNum = int(args[2])
mode = args[3]
LR = False
beta = 4000
if args[4] == "LR":
    LR = True
    beta = 10000
time.time()
T = 5400

filename = "J_py_" + str(T) + ".txt"
if os.path.exists(filename):
    os.remove(filename)

def process_pair(args):
    i, j, DataFileName, mode, beta, WIN, DELTA, NPAR, LR = args
    start_time = time.time()
    filename1 = f'{DataFileName}/cell{i}.txt'
    filename2 = f'{DataFileName}/cell{j}.txt'
    print(filename1 + ' ' + filename2)

    # Make cross_correlogram
    cc_list = linear_crossCorrelogram(filename1, filename2, T)

    # Set tau
    tau = [4, 4]

    # Fitting a GLM
    if mode == 'sim':
        delay_synapse = 3
        par, log_pos, log_likelihood = GLMCC(cc_list[1], cc_list[0], tau, beta, cc_list[2], cc_list[3], delay_synapse)
    elif mode == 'exp':
        log_pos = 0
        log_likelihood = 0
        for m in range(1, 5):
            tmp_par, tmp_log_pos, tmp_log_likelihood = GLMCC(cc_list[1], cc_list[0], tau, beta, cc_list[2], cc_list[3], m)
            if m == 1 or (not LR and tmp_log_pos > log_pos) or (LR and tmp_log_likelihood > log_likelihood):
                log_pos = tmp_log_pos
                log_likelihood = tmp_log_likelihood
                par = tmp_par
                delay_synapse = m
    else:
        raise ValueError("Input error: You must write sim or exp in mode")

    # Connection parameters
    nb = int(WIN/DELTA)
    cc_0 = [0 for _ in range(2)]
    max_tau = [0 for _ in range(2)]
    Jmin = [0 for _ in range(2)]

    for l in range(2):
        cc_0[l] = 0
        max_tau[l] = int(tau[l] + 0.1)

        if l == 0:
            for m in range(max_tau[l]):
                cc_0[l] += np.exp(par[nb + int(delay_synapse) + m])
        if l == 1:
            for m in range(max_tau[l]):
                cc_0[l] += np.exp(par[nb - int(delay_synapse) - m])

        cc_0[l] /= max_tau[l]
        Jmin[l] = math.sqrt(16.3 / tau[l] / cc_0[l])
        n12 = tau[l] * cc_0[l]
        if n12 <= 10:
            par[NPAR - 2 + l] = 0

    D1, D2 = 0, 0
    if LR:
        tmp_par, tmp_log_pos, log_likelihood_p = GLMCC(cc_list[1], cc_list[0], tau, beta, cc_list[2], cc_list[3], delay_synapse, cond=1)
        tmp_par, tmp_log_pos, log_likelihood_n = GLMCC(cc_list[1], cc_list[0], tau, beta, cc_list[2], cc_list[3], delay_synapse, cond=2)
        D1 = log_likelihood - log_likelihood_p
        D2 = log_likelihood - log_likelihood_n

    result = (i, j, round(par[NPAR-1], 6), round(par[NPAR-2], 6), round(Jmin[1], 6), round(Jmin[0], 6), round(D2, 6), round(D1, 6))

    end_time = time.time()
    print(str(i) + ' time: ', end_time - start_time)

    return result

def main(DataNum, DataFileName, mode, beta, WIN, DELTA, NPAR, LR):
    pool = mp.Pool(num_cpu)
    print(mp.cpu_count())
    for i in range(DataNum):

        start_time = time.time()
        # Prepare arguments for each process
        args_list = [(i, j, DataFileName, mode, beta, WIN, DELTA, NPAR, LR) for j in range(i)]

        if args_list == []:
            continue

        results = pool.map(process_pair, args_list)

        end_time = time.time()
        # print(str(i) + ' time: ', end_time - start_time)
        # Write results to file
        with open(f"J_py_{5400}.txt", 'a') as J_f:
            for result in results:
                J_f.write(f"{result[0]} {result[1]} {result[2]} {result[3]} {result[4]} {result[5]} {result[6]} {result[7]}\n")

        with open(log_name, 'a') as log_w:
            for result in results:
                log_w.write(f"{result[0]} {result[1]} {result[2]} {result[3]} {result[4]} {result[5]} {result[6]} {result[7]}\n")
        # # Create a unique log file name based on parameters
        # log_filename = f"log_{DataFileName}_{DataNum}_{mode}_{WIN}_{DELTA}_{NPAR}_{LR}.txt"
        # with open(log_filename, 'w') as log_file:
        #     log_file.write(f"Total time: {end_time-start_time}\n")


    pool.close()
    pool.join()

if __name__ == '__main__':
    start_time_total = time.time()
    # DataNum = 10  # Example value, set it as required
    # DataFileName = 'experimental_data'  # Example value, set it as required
    # mode = 'sim'  # or 'exp'
    # beta = 0.5  # Example value, set it as required
    # WIN = 100  # Example value, set it as required
    # DELTA = 1  # Example value, set it as required
    # NPAR = 102  # Example value, set it as required
    # LR = True  # Example value, set it as required
    main(DataNum, folder_path, mode, beta, WIN, DELTA, NPAR, LR)

    end_time_total = time.time()
    print('total_time: ', end_time_total - start_time_total)


    n = DataNum
    scale = 1.277
    z_a = 15.14

    #Read the required J file and create the resul file
    J_f = open("J_py_"+str(T)+".txt", 'r')
    J_f_list = J_f.readlines()
    W_f = open("../detection_result/result_GLMCC"+".csv", 'w')
    W = [[0 for i in range(n)] for j in range(n)]

    #calculate W
    for i in range(0, len(J_f_list)):
        J_f_list[i] = J_f_list[i].split()

        J_f_list[i][0] = int(float(J_f_list[i][0])) #pre
        J_f_list[i][1] = int(float(J_f_list[i][1])) #post
        J_f_list[i][2] = float(J_f_list[i][2])      #J_+
        J_f_list[i][3] = float(J_f_list[i][3])      #J_-
        J_f_list[i][4] = float(J_f_list[i][4])      #J_min_+
        J_f_list[i][5] = float(J_f_list[i][5])      #J_min_-
        J_f_list[i][6] = float(J_f_list[i][6])      #D_+
        J_f_list[i][7] = float(J_f_list[i][7])      #D_-

        if not LR:
            W[J_f_list[i][0]][J_f_list[i][1]] = round(calc_PSP(J_f_list[i][2], J_f_list[i][4]*scale), 6)
            W[J_f_list[i][1]][J_f_list[i][0]] = round(calc_PSP(J_f_list[i][3], J_f_list[i][5]*scale), 6)
        else:
            W[J_f_list[i][0]][J_f_list[i][1]] = round(calc_PSP_LR(J_f_list[i][2], J_f_list[i][6], z_a), 6)
            W[J_f_list[i][1]][J_f_list[i][0]] = round(calc_PSP_LR(J_f_list[i][3], J_f_list[i][7], z_a), 6)

    #write W
    for i in range(0, n):
        for j in range(0, n):
            W_f.write(str(W[i][j]))   # v1909,   JH
            if j == n-1:
                W_f.write('\n')
            else:
                W_f.write(', ')

    #remove J file

    # # debug
    # cmd = ['rm', "J_py_"+str(T)+".txt"]
    # proc.check_call(cmd)
    #
    # # wins
    cmd = ['del', "J_py_"+str(T)+".txt"]
    proc.check_call(cmd, shell=True)

