# Variable-unit-hydrograph
Supporting code for the paper "Variable unit hydrograph based on nonlinear factors of previous flood recession and rainfall spatial distribution: A case study in Liulin experimental watershed"'

for 'VUH-Chinese':
①文件夹包含'main','f','gen','test'四个m文件
②使用方法为，在matlab中打开VUH-Chinese文件夹，首先运行main。如果运行时间过长，可以把17行的maxdiedai改小再重新运行，或者运行过程中在274行加入断点，等程序暂停后再结束运行。运行完main之后，工作区的canshumax最后一列即为优化后的参数值。继续运行test可以得到可视化和统计信息等更多细节。
③作为示例，main中只输入了4场洪水。仅用前3场率定参数必然会出现过拟合的情况，导致第4场洪水检验效果较差。由于该率定算法带有随机性，重新率定参数可能会获得较好的结果。但正确的解决方法应为加入更多的洪水场次。
④VUH-English中的内容与VUH-Chinese完全一致，只是注释换成了英文。其余细节参见代码中的注释。

for 'VUH-English':
1. The folder contains four m files:'main','f','gen' and 'test'.
2. The usage method is to open the VUH-English folder in MATLAB and first run 'main'. If the running time is too long, you can reduce the 'maxdiedai' on line 17 and rerun it, or add a breakpoint on line 274 during the running process, and wait for the program to pause before ending the run. After running the 'main', the last column of 'canshumax' in the workspace is the optimized parameter values. Continuing to run 'test' can provide more details such as visualization and statistical information.
3. As an example, only 4 flood events were entered in the 'main'. Using only the first three events to calibrate parameters will inevitably lead to overfitting, resulting in poor performance of the fourth event when tested. Due to the randomness of the calibration algorithm, recalibrating parameters may yield better results. But the correct solution should be to add more flood events.
4. The content in VUH-Chinese is completely consistent with VUH-English, except that the comments have been changed to Chinese. Please refer to the comments in the code for more details.
