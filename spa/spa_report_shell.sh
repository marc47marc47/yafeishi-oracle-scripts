vi gene_report_1.sh
sh gene_rep_1.sh $1 ALL $2
sh gene_rep_1.sh $1 ERRORS $2
sh gene_rep_1.sh $1 UNSUPPORTED  $2


sh report_1.sh 1112 ELAPSED_TIME time
sh report_1.sh 1112 cpu_time cpu
sh report_1.sh 1112 buffer_gets bget1

sh gene_report_1.sh 1112 time
sh gene_report_1.sh 1112 cpu
sh gene_report_1.sh 1112 bget1

------------------------------------------------------------
vi gene_report_2.sh
sh gene_rep_2.sh $1 ALL $2
sh gene_rep_2.sh $1 ERRORS $2
sh gene_rep_2.sh $1 UNSUPPORTED $2

sh report_2.sh 1112 ELAPSED_TIME time
sh report_2.sh 1112 cpu_time cpu
sh report_2.sh 1112 buffer_gets bget3

sh gene_rep_2.sh 1111 ALL bget
sh gene_rep_2.sh 1111 ALL cpu
sh gene_rep_2.sh 1112 ALL bget3

sh gene_report_2.sh 1112 time
sh gene_report_2.sh 1112 cpu
sh gene_report_2.sh 1112 bget3

vi gene_all.sh 
sh gene_report_$1.sh $2 time
sh gene_report_$1.sh $2 cpu
sh gene_report_$1.sh $2 bget
--------------------------------------------------------------
sh report_1.sh 1111 ELAPSED_TIME time
sh report_1.sh 1111 cpu_time cpu
sh report_1.sh 1111 buffer_gets bget

sh report_2.sh 1111 ELAPSED_TIME time
sh report_2.sh 1111 cpu_time cpu
sh report_2.sh 1111 buffer_gets bget


sh gene_all.sh 1 1111 
sh gene_all.sh 2 1111

