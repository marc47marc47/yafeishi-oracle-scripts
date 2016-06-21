不过在安装完Oracle XE后，可以在sqlplus(即Oracle XE的run SQL command line)中， 进行如下的操作来修改字符集：
　　connect system/oracle9i as sysdba
　　shutdown immediate
　　startup mount
　　alter system enable restricted session ;
　　alter system set JOB_QUEUE_PROCESSES=0;
　　alter system set AQ_TM_PROCESSES=0;
　　alter database open ;
　　alter database character set internal_use ZHS16GBK ;
　　shutdown immediate
　　startup
　　这样字符集的修改就完成了
