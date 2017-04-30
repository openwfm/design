fmc=[0.03	0.055	0.08	0.105	0.13
     0.04	0.065	0.09	0.115	0.14
     0.05	0.075	0.1	    0.125	0.15]
 [D,logm,logs]=equal_logn(...
              [0.04 0.14         % 1 h moisture
               6,     50         % heat ext depth
               5       2],...     % heat flux multiplier
               0.1,...           % probability value outside given interval
               5)                % repetitions