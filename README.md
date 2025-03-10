# MRI_checkData
### for SPM protocal
- run [main.m](./code/main.m) file
- expect folder --> ./subject001/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./subject002/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./subject003/~  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --> ./.../~

- step 1 : `select first subejct SPM.mat folder`  
- step 2 : `select template file and info(.txt file)`
- output 1 : `cluster label file for contrast file(con*.nii)` `./subjectid/~/Clust_check/*.nii` in SPM.mat folder create Clust_check folder save cluster label file(*contrast name*.nii)
- output 2 : `excel table row is brainarea column has percentage, mean t, max t`  `./subjectid/~/Clust_check/*.xlsx` `copy to subject folder ./Res`

### for conn(all .nii file in one folder) protocal
- run [main_conn.m](./code/main_conn.m) file

- all .nii file are contains in one file
- step 1 : define variable `paths : file path`, `, `temfile : template nii file path`, `teminfo : template .txt info file`(line 4, 6, 7)
- step 1.5 : if file is `.gz` file then output to `niifile` folder
- step 2 : mask map file for certain threshold, if map value is z, z > 0.25 is 1 others is 0
- step 3 : use mask and original file to get brainarea percentage .xlsx file, `save in mask file path`
- step 4 : use brainarea percentage to calculate subject RR matrix
- step 5 : calculate how many subject is different(R to z<0.25) from self
- step 6 : get outlier subject, using Q3+1.5*iqr is outlier to define threshold(define how many subject is different from self as outlier)
- output 1 : save Result.mat file(contains difsubnum, r, z, outliersubName) in `mask path`
- output 2 : show outlier subjectName in command Window
