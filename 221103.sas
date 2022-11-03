*----------------------------------*
l      SAS Programming 교육 (^0^)  l
*----------------------------------*;
/*===================22.11.03================*/

/*라이브러리 할당*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;


/*==================[Chapter5]==================*/
proc contents data=orion.nonsales varnum;
run;
proc print data=orion.nonsales (obs=10) ;
run;

data work.comp;
	set orion.nonsales ; /*변수 9개*/
	bonus = 500 ;
	comp = salary + bonus ; /*문장 순서 중요!*/
	bmonth = month(hire_date) ;
	
	drop first last  ;
run;

/*함수*/
/*missing value 무시
	sum(1,2,3) = 6
	sum(1,2,.) = 3
	mean(1,2,3) = 2
	mean(1,2,.) = 1.5 */

data work.comp;
	set orion.nonsales ; /*변수 9개*/
	bonus = 500 ;
	comp = sum(salary, bonus) ; /*missing value 무시*/
	bmonth = month(hire_date) ;
	drop first last  ;
run;

/*나이 구하기+보너스 데이*/
data work.comp;
	set orion.nonsales ; /*변수 9개*/
	bonus = 500 ;
	comp = sum(salary, bonus) ; /*missing value 무시*/
	bmonth = month(hire_date) ;
	pay_day = mdy(bmonth,15,year(today())) ; 
	/*
	mdy
	0 = '01jan1960'd = mdy(1,1,1996)
	*/
	age = ceil((today()-birth_date ) / 365.25) ; /*ceil = 올림*/
	age2 = (year(today())-year(birth_date)) ;
	format pay_day yymmdd10. ;
	drop first last  ;
run;

/*나라별 보너스*/
/*컴파일 -> PDV(이름/타입/길이) -> E(값)*/
/*do 문장 end : 문장 실행*/
/*문자변수 만들땐 크기에 대한 정의 필요 !! 중요! */
data work.comp2 ;
	set orion.nonsales;
	/*if 조건 then 실행 문장*/
	length check $ 7 ; /*변수 크기 설정*/
	if upcase(country) ='AU' /*upcase :대문자 치환*/ then do ; 
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

/*연습문제 P5-35. 3번*/
proc contents data=orion.customer_dim varnum;
run;
proc print data=orion.customer_dim (obs=10);
run;

data work.season;
	set orion.customer_dim ;

	c_qtr = qtr(customer_birthdate) ;

	length promo promo2 $ 10 ; /*변수 길이*/ 

	if c_qtr = 1 then promo='Winter' ;
	else if c_qtr = 2 then promo='Spring' ;
	else if c_qtr = 3 then promo='Summer';
	else if c_qtr =4 then promo ='Fall';
	
	if customer_age >= 65 then promo2 ='Senior';
	else if 18 <= customer_age <=25 then promo2 = 'Ya' ;

	keep Customer_ID Customer_BirthDate Customer_Age promo promo2;
	format Customer_BirthDate yymmdd10. ;
run ;
/*조건 정확하게 끝까지 주기 missing value 고려*/
	


/*==================[Chapter6]==================*/
/*combining data set*/
/*여러 데이터는 set 문장에 나열*/

/*연습문제 p.6-23*/
data work.allemp_1980 ;
 set orion.sales orion.nonsales(rename=(first=first_name last=last_name)) ; 
 /*rename 으로 변수 이름 맞춰서 합치기*/
 bonus = salary * 0.1 ;
 where Hire_Date > '01jan1980'd /* 또는 mdy(1,1,1980) */ ;
 keep Employee_ID First_Name Last_Name Salary bonus Hire_Date ;
 format Hire_Date yymmdd10. ;
run;

proc contents data=work.allemp_1980 varnum;
run;
proc print data=work.allemp_1980 (obs=10);
run;

/*merge : 연결할 변수에 대한 사전 정렬
 정렬 -> 가로 결합*/
proc sort data=orion.order_fact out=work.order_fact /*따로 만들기 원본업데이트 주의!*/;
	by Customer_ID ;
run ;
/*원본 업데이트 주의!!*/

proc sort data=orion.customer_dim out=work.customer_dim ;
	by Customer_id ;
run ;

/*merge by : 옆으로 연결*/

data work.order_cust;
 merge work.order_fact work.customer_dim; /*매칭 데이터 !!매칭기준 변수로 정렬을 해야함!!*/
 by customer_id; /*매칭 기준*/
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


/*in 데이터 유무*/
data work.order_cust;
 merge work.order_fact(in=ina) work.customer_dim(in=inb); /*매칭 데이터 !!매칭기준 변수로 정렬을 해야함!!*/
 by customer_id; /*매칭 기준*/

 /*if ina=1 and inb=1;*/
 if ina=0 and inb=1;
run;

/* 3개 data 만들기
거래=1 and 고객 =1 => order_cust
거래=0 and 고객 =1 => noorder
거래=1 and 고객 =0 => nocust
*/
data work.order_cust work.noorder work.nocust ;
 merge work.order_fact(in=ina) work.customer_dim(in=inb); /*매칭 데이터 !!매칭기준 변수로 정렬을 해야함!!*/
 by customer_id; /*매칭 기준*/
 if ina=1 and inb=1 then output work.order_cust; /*2. output수동출력 : PDV 공간의 내용을 출력데이터로 생성*/
 else if ina=0 and inb=1 then output work.noorder;
 else if ina=1 and inb=0 then output work.nocust;  
run;/*output 실행시 자동출력(x) 자동리턴*/

/*==================[Chapter7]==================*/
proc contents data=orion.growth varnum;
run;
proc print data=orion.growth (obs=10);
run;

/*1. OUTPUT 수동출력 : 여러개 관측치*/
data forecast;
	set orion.growth;
    year =1;
	total_employees = total_employees * (1+increase);
 	output ;
	year =2;
	total_employees = total_employees * (1+increase);
	output ;
run; /*자동출력 자동리턴*/
