# Variable-unit-hydrograph
Supporting code for the paper "Variable unit hydrograph based on nonlinear factors of previous flood recession and rainfall spatial distribution: A case study in Liulin experimental watershed"

for 'VUH-Chinese':

1. 文件夹包含4个脚本文件和一个数据文件，数据文件（降雨径流）可以在matlab中查看和修改和导出。
2. 使用方法为，在matlab中打开VUH-Chinese文件夹，首先运行main。如果运行时间过长，可以把17行的maxdiedai改小再重新运行，或者运行过程中在274行加入断点，等程序暂停后再结束运行。运行完main之后，工作区的canshumax最后一列即为优化后的参数值。继续运行test可以得到可视化和统计信息等更多细节。
3. 由于该率定算法带有随机性，每次率定参数可能会获得不同的结果。如果需要提高模拟精度，应增加算法的迭代次数，即增加main中的maxdiedai值。研究时使用的迭代次数为10e7数量级，运行耗时约为两周。
4. VUH-English中的内容与VUH-Chinese完全一致，只是注释换成了英文。其余细节参见代码中的注释。

for 'VUH-English':

1. The folder contains four '.m' files and a '.dat' file. The '.dat' file (rainfall and runoff) can be viewed, modified, and exported in MATLAB.
2. The usage method is to open the VUH-English folder in MATLAB and first run 'main'. If the running time is too long, you can reduce the 'maxdiedai' on line 17 and rerun it, or add a breakpoint on line 274 during the running process, and wait for the program to pause before ending the run. After running the 'main', the last column of 'canshumax' in the workspace is the optimized parameter values. Continuing to run 'test' can provide more details such as visualization and statistical information.
3. Due to the randomness of this calibration algorithm, different results may be obtained for each calibration. If it is necessary to improve the accuracy, the number of iterations of the algorithm should be increased, that is, the 'maxdiedai' in 'main' should be increased. The number of iterations used in the research was on the order of 10e7, and the running time was approximately two weeks.
4. The content in VUH-Chinese is completely consistent with VUH-English, except that the comments have been changed to Chinese. Please refer to the comments in the code for more details.
