*----------------------------------*
l      SAS Programming ���� ��.,��          l
*----------------------------------*;
/*===================22.11.04================*/
/*���̺귯�� �Ҵ�*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;


/*==================[Chapter8]==================*/
/*RETAIN ��������*/
data acc1;
	set orion.aprsales ;
	retain m2t 0 ;
	m2t = sum(saleamt , m2t) ;
run;

/*Sum ���� ���� */
data acc1_1;
	set orion.aprsales ;
	m2t + saleamt ; /*sum*/
	n +1 ;
run;

/*�׷� �� ����*/

/*1) �׷캰 ����*/
proc sort data=orion.specialsals out=sorted ;
	by dept ;
run ;

/*BY-Group*/
data acc2 (keep=dept acc);
	set work.sorted ;
	by dept ; /*2) �׷� ó�� ���� ���� : first.dept , last.dept*/
	if first.dept =1 then acc =0; /*3) �׷쳻 ù��° ����ġ = 0 ����*/
	acc + salary ; /*4) �� ����*/
	if last.dept=1 then output ; /*�׷쳻 ������ ����ġ ���*/
run;

/*2�� �̻� �׷�*/


/*����*/
/*1. ���� �׷�*/
proc sort data=orion.order_fact (keep=Customer_ID order_type total_retail_price) out=order_sort ;
	by Customer_ID ;
run ;

data work.cust ;
	set work.order_sort ;
	by Customer_ID;
	if first.customer_id = 1 then do ; 
		total1 = 0 ; cnt1 =0 ;
	end;
	total1 + total_retail_price ;
	cnt1+1;
	if last.customer_id=1 then output ;
	keep customer_id cnt1 total1;
run;

/*2. 2�� �׷�*/
proc sort data=orion.order_fact(keep=Customer_ID order_type total_retail_price) out=order_sort2 ;
	by Customer_ID order_type;
run ;

data work.cust_type ;
	set work.order_sort2;
	by Customer_ID Order_type;
	if first.customer_id = 1 and first.order_type =1 then do; 
		total2 = 0;
		cnt2  =0 ;
	end;
	total2 + total_retail_price ;
	cnt2+1;
 	if last.customer_id=1 and last.order_type =1 then output ;
 	keep Customer_ID Order_Type cnt2 total2;
run;

/*2. ����*/
data work.cust_type ;
	set work.order_sort2;
	by Customer_ID Order_type;

	if first.order_type =1 then do; /*���� ���� �׷캯����*/
		cnt2=0; total2=0;
	end;

	cnt2+1;
	total2+total_retail_price;


	if last.order_type=1 then output;
	keep Customer_ID Order_Type cnt2 total2;
run;

/*1,2 �ѹ��� ���� */
data cust (keep = customer_id cnt1 total1) cust_type(keep=customer_id order_type cnt2 total2);
	set order_sort2 ;
	by customer_id order_type ;

	if first.customer_id =1 then do ;
	cnt1 =0 ; total1= 0;
	cnt1+1 ;
	total1+total_retail_price;
	end;

	if first.order_type =1 then do ; 
	cnt2 =0 ; total2=0;
	cnt2+1 ;
	total2+total_retail_price;
	end;

	if last.customer_id =1 then output cust ;
	if last.order_type =1 then output cust_type;
run; 


/*==================[Chapter9]==================*/
/*�ݺ�����*/
data compound;
	amount = 50000 ;
	rate = 0.045 ;
	yearly = amount * rate ;
	quarterly+((quarterly+amount)*rate/4);
	quarterly+((quarterly+amount)*rate/4);
	quarterly+((quarterly+amount)*rate/4);
	quarterly+((quarterly+amount)*rate/4);
run;
proc print data=compound noobs;
run; 

/*DO Loop �۾�*/


/*���� 6�� �ݺ� do loop ���*/
data forecast;
   set orion.growth;/*6obs*/
   do Year=1 to 6;
   	Total_Employees=ceil(Total_Employees*(1+Increase));
   	output;
	end;
run;

/*������ ���� ���� �ݺ� do while*/
/*300�� �̻� �� ������ �ݺ�*/
data forecast;
   set orion.growth;/*6obs*/
   year =0 ;
   output ;

   do while(total_employees < 300);
   		year +1 ;
   		Total_Employees=ceil(Total_Employees*(1+Increase));
   		output;
	end;
run;

/*do until ���϶� ���� ������*/ /*��� �ѹ��� ������ �����ϰ� ����*/
data forecast;
   set orion.growth;/*6obs*/
   year =0 ;
   output ;

   do until(total_employees >= 300);
   		year +1 ;
   		Total_Employees=ceil(Total_Employees*(1+Increase));
   		output;
	end;
run;

/*������*/
data test;
	do i =1 to 9;
		do j= 1 to 9;
		 value = i*j ;
		output ;
		end;
	end;
run;

/*array processing*/
data donations(drop= i) ;
	set orion.employee_donations(keep=employee_id qtr1 qtr2 qtr3 qtr4);

	array contrib[4] qtr1 qtr2 qtr3 qtr4 ;/*4���� ����  �ϳ��� array*/
	do i = 1 to 4;
		contrib[i] = contrib[i] *1.25;
	end;
run;
/*array sas �����鿡 ���� �ӽ� �׷�*/
/*���� �Ӽ��� ���� �������� �ϳ��� array��*/



/*��� ���ں����� �̰̽��� 0���� ǥ��*/
data donations(drop= i) ;
	set orion.employee_donations(keep=employee_id qtr1-qtr4);

	array contrib[*] _numeric_ ;/*4���� ����  �ϳ��� array*/
	do i = 1 to dim(contrib);
		if contrib{i} =. then contrib{i} =0 ; 
	end;
run;


/*==================[Chapter10]==================*/
/*��ġ*/
proc transpose data=orion.employee_donations
						out=work.trans1 (rename=(_name_=period col1=value)) ;
		var qtr1-qtr4 ;
		by Employee_ID ; /*��ġ ���� ����*/
run;

proc transpose data=work.trans1 out=work.trans2 ;
	var value ;
	by Employee_ID;
	id period ;
run;

/*�� freq*/
proc freq data=orion.nonsales;
	tables Country gender ;
	tables country * gender / /*�ɼ�*/ out= work.country_gender ; /*Y*X*/
run ;

proc freq data=orion.nonsales /*���� �ɼ�*/order=freq nlevels;
	table job_title;
run ;

/* �����跮 : means */
proc means data=orion.nonsales /*�ɼ�*/ n nmiss sum mean  ;
	var salary ; /*�м�����*/
	class Country gender ; /*�з����� : ~ ����*/
run;

/*means ������ ��������*//*sql group by ���� ����*/
proc means data=orion.nonsales noprint nway;
 var salary;
 class country gender ;
 output out=work.nonsales_summary n=salary_n sum= salary_sum mean = salary_mean ;
run ;