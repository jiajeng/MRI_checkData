### Outlier detection and removal improves accuracy of machine learning approach to multispectral burn diagnostic imagin  [[file]](OutlierDetectionAndRemoval.pdf)
- aim : optimized burn tissue image classification by removal outlier to improve accuracy
```
define parameter : N, α1, α2

outlier detection :
1. Select N samples in whole dataset
2. find median of these samples(N samples)
3. Set "first window" [median index - α1 X N : median index + α2 X N]
  if left bound < 0
    left bound = 0
  if right bound > N
    right bound = N
4. calculate the mean and standard deviation from "first window"
5. 
```
- outlier detection : maximum likelihood estimation and Z-score
  - N : select samples
  - α1 and α2 : include how many sample for left and right(from 0 to 0.5, unitless),  
       define as "first window" -- Select samples  
       $${\color{Gray}setting\ α1\ =\ α2\ =\ 0.5\ Get\ entire\ sample}$$  
  - n : number of samples n = (α1 X N) + (α2 X N) 
  - $$Z-score\ :\ P\left( Z \leq z \right) = \int\limits_{-\infty}^z\frac{1}{\sqrt{2\pi}}e^\frac{-x^2}{2} dx$$
  - 
