*----------------------------------*
l               SAS Programming ���� :)             l
*----------------------------------*;
/
*===================22.11.02================*/
/*==================[Chapter3]==================*/
/*-@ PROC CONTENTS : sas ������ �� �Ӽ� ���캸��*/

proc contents data=sashelp.class;
run;

*���� ������ ���� ������� CONTENTS ����;
proc contents data=sashelp.class varnum ; /*���� �ɼ� :���� �������*/;
run;
/*���̺� : ������ ���� ����*/

/*-@ DATA Portion : ������ �� ���� proc print*/
proc print data=sashelp.class (obs=10) ; /*������ �ɼ� : 10�� ����ġ �о����*/ ;
run;

/*-@ missing value ���� = blank, ���� = .*/

/*
-@ SAS Date Value
1960�� 1�� 1�� =0 ���� �Ϸ羿 +1
*/

/*-@ SAS library*/

/*-@ ����� ���� ���̺귯�� �Ҵ�
    1. ������ ��ġ Ȯ��
    2. sas ���̺귯�� ���� �����*/
/*LIBNAME libref "SAS-library' <options>;*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;

proc contents data=orion.sales varnum ;
run;

proc print data=orion.sales (obs=10) ;
run;

/*-@ table ����� ������ ���������� ���̺귯�� �Ҵ�*/
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;

proc contents data=orionx.australia varnum;
run;

proc print data=orionx.australia (obs=10) ;
run; 

/*����Ŭdb db table ���*/
libname ora_db oracle path=server userid= password= ; 

/*text ������(csv)�� SAS data set ���� ��������*/
proc import datafile='c:\educ\p12\sales.csv' dbms=csv
                 out=work.sales_csv replace /*�����*/ ;
run;

/*==================[Chapter4 : Reading SAS data sets]==================*/

/*part1(p4-4)*/

data work.subset1 /*��µ�����*/;
	set orion.sales ; /*�Էµ����� (�����ִ� ��������)*/
	where salary >= 30000 ; /*where ��, ��, ���, Ư�� ������*/
run;

data work.subset1 /*��µ�����*/;
	set orion.sales ; /*�Էµ����� (�����ִ� ��������)*/
	where country = 'AU'
	and job_title contains 'Rep';
run;

data work.subset1 /*��µ�����*/;
	set orion.sales ; /*�Էµ����� (�����ִ� ��������)*/
	where country = 'AU'
	and salary >= 30000;
run;

/*
# SAS����
				�����(�����Ȱ�)
���� ���� : "value" or 'value' ��, ���� ���� ��ҹ��ڱ���
���� ���� : value : ex.1234, 1234.5 ���� ���̿� Ư����ȣ ��� ����(1,234 X)
	- ��¥���� : ��¥ �����
						0 = "01jan1960"d  (o) , '1960-01-01'd (X)
*/

/*part2(p4-8)*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep' /*contains = ?*/
	and Hire_Date < '01jan2000'd ; /*��¥*/
run;

/*�� ���� �����, �Ҵ� ����*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep'                
	and Hire_Date < '01jan2000'd ;  
	Bonus = salary *0.1;                 /*������ = ǥ����*/
	gender = upcase(gender) ;         /*���� ���� ����*/     
run;

/*���� �� �ϳ��� missing value �� missing value return*/


/*part3*/
/*Drop : ���� ������ ������*//*Keep ������ ���� ����*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep'                
	and Hire_Date < '01jan2000'd ;  
	Bonus = salary *0.1;                 /*������ = ǥ����*/
	gender = upcase(gender) ;         /*���� ���� ����*/ 
	drop first_name Last_Name Country ;    /*Drop : ���� ������ ������*/
run;

/*DATA Step Processing*/
/*������ ������ ����*/

/*part4*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*���� ����*/
	set orion.sales ;
	where country in ('AU','au');
	Bonus = salary *0.1;
	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
run;

/*where ���忡 ���Ǵ� ������ �ݵ�� �Էµ�����(set)�� ���� �ؾ���*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*���� ����*/
	set orion.sales ;
	where country in ('AU','au');
	Bonus = salary *0.1;
	if bonus >=3000; /*���/��/�� (Ư��x)*/
	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
run;

/*part5*/
/*label, format*/

/*label : ���� ����*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*���� ����*/
	set orion.sales ;
	where country in ('AU','au');

	Bonus = salary *0.1;
	if bonus >=3000; /*���/��/�� (Ư��x)*/

	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
	label bonus='���� �޿��� 10%'; /*��*/
	format salary comma10. bonus comma10.1 hire_date Birth_Date yymmdd10.; /*����*/
run;

/*���� ��� ����*/


/*===p4-37 �������� 2��*/
data work.delays;
	set orion.orders;
 	where Delivery_Date > Order_Date +4
	and Employee_ID = 99999999;
	order_month = month(order_date);
	if order_month = 8;
	keep Employee_ID Customer_ID Order_Date Delivery_Date Order_month;
	label Order_month ='�ֹ� ��';
	format Order_Date Delivery_Date yymmdd10.;
run;