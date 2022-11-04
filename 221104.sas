*----------------------------------*
l      SAS Programming 교육 ㅠ.,ㅠ          l
*----------------------------------*;
/*===================22.11.04================*/
/*라이브러리 할당*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;


/*==================[Chapter8]==================*/
/*RETAIN 누적변수*/
data acc1;
	set orion.aprsales ;
	retain m2t 0 ;
	m2t = sum(saleamt , m2t) ;
run;

/*Sum 누적 변수 */
data acc1_1;
	set orion.aprsales ;
	m2t + saleamt ; /*sum*/
	n +1 ;
run;

/*그룹 별 누적*/

/*1) 그룹별 정렬*/
proc sort data=orion.specialsals out=sorted ;
	by dept ;
run ;

/*BY-Group*/
data acc2 (keep=dept acc);
	set work.sorted ;
	by dept ; /*2) 그룹 처리 변수 지정 : first.dept , last.dept*/
	if first.dept =1 then acc =0; /*3) 그룹내 첫번째 관측치 = 0 세팅*/
	acc + salary ; /*4) 값 누적*/
	if last.dept=1 then output ; /*그룹내 마지막 관측치 출력*/
run;

/*2개 이상 그룹*/


/*문제*/
/*1. 단일 그룹*/
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

/*2. 2개 그룹*/
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

/*2. 정답*/
data work.cust_type ;
	set work.order_sort2;
	by Customer_ID Order_type;

	if first.order_type =1 then do; /*가장 낮은 그룹변수만*/
		cnt2=0; total2=0;
	end;

	cnt2+1;
	total2+total_retail_price;


	if last.order_type=1 then output;
	keep Customer_ID Order_Type cnt2 total2;
run;

/*1,2 한번에 추출 */
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
/*반복문장*/
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

/*DO Loop 작업*/


/*문제 6년 반복 do loop 사용*/
data forecast;
   set orion.growth;/*6obs*/
   do Year=1 to 6;
   	Total_Employees=ceil(Total_Employees*(1+Increase));
   	output;
	end;
run;

/*조건이 참인 동안 반복 do while*/
/*300명 이상 일 때까지 반복*/
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

/*do until 참일때 까지 돌려라*/ /*적어도 한번은 루프를 실행하고 평가함*/
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

/*구구단*/
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

	array contrib[4] qtr1 qtr2 qtr3 qtr4 ;/*4개의 변수  하나의 array*/
	do i = 1 to 4;
		contrib[i] = contrib[i] *1.25;
	end;
run;
/*array sas 변수들에 대한 임시 그룹*/
/*같은 속성을 같는 변수들을 하나의 array로*/



/*모든 숫자변수의 미싱값을 0으로 표시*/
data donations(drop= i) ;
	set orion.employee_donations(keep=employee_id qtr1-qtr4);

	array contrib[*] _numeric_ ;/*4개의 변수  하나의 array*/
	do i = 1 to dim(contrib);
		if contrib{i} =. then contrib{i} =0 ; 
	end;
run;


/*==================[Chapter10]==================*/
/*전치*/
proc transpose data=orion.employee_donations
						out=work.trans1 (rename=(_name_=period col1=value)) ;
		var qtr1-qtr4 ;
		by Employee_ID ; /*전치 기준 변수*/
run;

proc transpose data=work.trans1 out=work.trans2 ;
	var value ;
	by Employee_ID;
	id period ;
run;

/*빈도 freq*/
proc freq data=orion.nonsales;
	tables Country gender ;
	tables country * gender / /*옵션*/ out= work.country_gender ; /*Y*X*/
run ;

proc freq data=orion.nonsales /*유용 옵션*/order=freq nlevels;
	table job_title;
run ;

/* 요약통계량 : means */
proc means data=orion.nonsales /*옵션*/ n nmiss sum mean  ;
	var salary ; /*분석변수*/
	class Country gender ; /*분류변수 : ~ 별로*/
run;

/*means 데이터 내보내기*//*sql group by 보다 빠름*/
proc means data=orion.nonsales noprint nway;
 var salary;
 class country gender ;
 output out=work.nonsales_summary n=salary_n sum= salary_sum mean = salary_mean ;
run ;