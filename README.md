# MRI_checkData
- run [main.m](./code/main.m) file
- expect folder --> ./subject001/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./subject002/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./subject003/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./.../~

- step 1 : `select first subejct SPM.mat folder`  
- step 2 : `select template file and info(.txt file)`
- output 1 : `cluster label file for contrast file(con*.nii)` `./subjectid/~/Clust_check/*.nii` in SPM.mat folder create Clust_check folder save cluster label file(*contrast name*.nii)
- output 2 : `excel table row is brainarea column has percentage, mean t, max t`  `./subjectid/~/Clust_check/*.xlsx` `copy to subject folder ./Res`
