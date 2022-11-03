*----------------------------------*
l      SAS Programming ���� (^0^)       l
*----------------------------------*;
/*===================22.11.03================*/

/*���̺귯�� �Ҵ�*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;


/*==================[Chapter5]==================*/
proc contents data=orion.nonsales varnum;
run;
proc print data=orion.nonsales (obs=10) ;
run;

data work.comp;
	set orion.nonsales ; /*���� 9��*/
	bonus = 500 ;
	comp = salary + bonus ; /*���� ���� �߿�!*/
	bmonth = month(hire_date) ;
	
	drop first last  ;
run;

/*�Լ�*/
/*missing value ����
	sum(1,2,3) = 6
	sum(1,2,.) = 3
	mean(1,2,3) = 2
	mean(1,2,.) = 1.5 */

data work.comp;
	set orion.nonsales ; /*���� 9��*/
	bonus = 500 ;
	comp = sum(salary, bonus) ; /*missing value ����*/
	bmonth = month(hire_date) ;
	drop first last  ;
run;

/*���� ���ϱ�+���ʽ� ����*/
data work.comp;
	set orion.nonsales ; /*���� 9��*/
	bonus = 500 ;
	comp = sum(salary, bonus) ; /*missing value ����*/
	bmonth = month(hire_date) ;
	pay_day = mdy(bmonth,15,year(today())) ; 
	/*
	mdy
	0 = '01jan1960'd = mdy(1,1,1996)
	*/
	age = ceil((today()-birth_date ) / 365.25) ; /*ceil = �ø�*/
	age2 = (year(today())-year(birth_date)) ;
	format pay_day yymmdd10. ;
	drop first last  ;
run;

/*���� ���ʽ�*/
/*������ -> PDV(�̸�/Ÿ��/����) -> E(��)*/
/*do ���� end : ���� ����*/
/*���ں��� ���鶩 ũ�⿡ ���� ���� �ʿ� !! �߿�! */
data work.comp2 ;
	set orion.nonsales;
	/*if ���� then ���� ����*/
	length check $ 7 ; /*���� ũ�� ����*/
	if upcase(country) ='AU' /*upcase :�빮�� ġȯ*/ then do ; 
		bonus =100 ; 
		check = 'Type I'; 
	end; 
	else if country in ('us', 'US') then do ; 
 		bonus = 200 ;
		check = 'Type II' ;
	end;
	else bonus = 50;
	comp = sum(salary,bonus) ;

	keep Employee_ID Country Salary bonus comp check;
run ;

/*�������� P5-35. 3��*/
proc contents data=orion.customer_dim varnum;
run;
proc print data=orion.customer_dim (obs=10);
run;

data work.season;
	set orion.customer_dim ;

	c_qtr = qtr(customer_birthdate) ;

	length promo promo2 $ 10 ; /*���� ����*/ 

	if c_qtr = 1 then promo='Winter' ;
	else if c_qtr = 2 then promo='Spring' ;
	else if c_qtr = 3 then promo='Summer';
	else if c_qtr =4 then promo ='Fall';
	
	if customer_age >= 65 then promo2 ='Senior';
	else if 18 <= customer_age <=25 then promo2 = 'Ya' ;

	keep Customer_ID Customer_BirthDate Customer_Age promo promo2;
	format Customer_BirthDate yymmdd10. ;
run ;
/*���� ��Ȯ�ϰ� ������ �ֱ� missing value ���*/
	


/*==================[Chapter6]==================*/
/*combining data set*/
/*���� �����ʹ� set ���忡 ����*/

/*�������� p.6-23*/
data work.allemp_1980 ;
 set orion.sales orion.nonsales(rename=(first=first_name last=last_name)) ; 
 /*rename ���� ���� �̸� ���缭 ��ġ��*/
 bonus = salary * 0.1 ;
 where Hire_Date > '01jan1980'd /* �Ǵ� mdy(1,1,1980) */ ;
 keep Employee_ID First_Name Last_Name Salary bonus Hire_Date ;
 format Hire_Date yymmdd10. ;
run;

proc contents data=work.allemp_1980 varnum;
run;
proc print data=work.allemp_1980 (obs=10);
run;

/*merge : ������ ������ ���� ���� ����
 ���� -> ���� ����*/
proc sort data=orion.order_fact out=work.order_fact /*���� ����� ����������Ʈ ����!*/;
	by Customer_ID ;
run ;
/*���� ������Ʈ ����!!*/

proc sort data=orion.customer_dim out=work.customer_dim ;
	by Customer_id ;
run ;

/*merge by : ������ ����*/

data work.order_cust;
 merge work.order_fact work.customer_dim; /*��Ī ������ !!��Ī���� ������ ������ �ؾ���!!*/
 by customer_id; /*��Ī ����*/
 country1 = upcase(customer_country) ;
 if country1 = 'US' then tax = total_retail_price * 0.3 ;
 else if country1 = 'AU' then tax = total_retail_price * 0.2 ;
 else tax = total_retail_price * 0.1 ;
 keep customer_id product_id order_date total_retail_price customer_country customer_gender tax;
run; 

proc contents data=work.order_cust varnum;
run;
proc print data=work.order_cust (obs=10);
run;


/*in ������ ����*/
data work.order_cust;
 merge work.order_fact(in=ina) work.customer_dim(in=inb); /*��Ī ������ !!��Ī���� ������ ������ �ؾ���!!*/
 by customer_id; /*��Ī ����*/

 /*if ina=1 and inb=1;*/
 if ina=0 and inb=1;
run;

/* 3�� data �����
�ŷ�=1 and �� =1 => order_cust
�ŷ�=0 and �� =1 => noorder
�ŷ�=1 and �� =0 => nocust
*/
data work.order_cust work.noorder work.nocust ;
 merge work.order_fact(in=ina) work.customer_dim(in=inb); /*��Ī ������ !!��Ī���� ������ ������ �ؾ���!!*/
 by customer_id; /*��Ī ����*/
 if ina=1 and inb=1 then output work.order_cust; /*2. output������� : PDV ������ ������ ��µ����ͷ� ����*/
 else if ina=0 and inb=1 then output work.noorder;
 else if ina=1 and inb=0 then output work.nocust;  
run;/*output ����� �ڵ����(x) �ڵ�����*/

/*==================[Chapter7]==================*/
proc contents data=orion.growth varnum;
run;
proc print data=orion.growth (obs=10);
run;

/*1. OUTPUT ������� : ������ ����ġ*/
data forecast;
	set orion.growth;
    year =1;
	total_employees = total_employees * (1+increase);
 	output ;
	year =2;
	total_employees = total_employees * (1+increase);
	output ;
run; /*�ڵ���� �ڵ�����*/