*----------------------------------*
l               SAS Programming 교육 :)             l
*----------------------------------*;
/
*===================22.11.02================*/
/*==================[Chapter3]==================*/
/*-@ PROC CONTENTS : sas 데이터 셋 속성 살펴보기*/

proc contents data=sashelp.class;
run;

*내가 지정한 변수 순서대로 CONTENTS 실행;
proc contents data=sashelp.class varnum ; /*문장 옵션 :변수 순서대로*/;
run;
/*레이블 : 변수에 대한 설명*/

/*-@ DATA Portion : 데이터 값 보기 proc print*/
proc print data=sashelp.class (obs=10) ; /*데이터 옵션 : 10개 관측치 읽어오기*/ ;
run;

/*-@ missing value 문자 = blank, 숫자 = .*/

/*
-@ SAS Date Value
1960년 1월 1일 =0 부터 하루씩 +1
*/

/*-@ SAS library*/

/*-@ 사용자 정의 라이브러리 할당
    1. 데이터 위치 확인
    2. sas 라이브러리 참조 만들기*/
/*LIBNAME libref "SAS-library' <options>;*/
libname orion v9 'c:\educ\p12' ;
libname educ "c:\educ" ;

proc contents data=orion.sales varnum ;
run;

proc print data=orion.sales (obs=10) ;
run;

/*-@ table 모양의 데이터 엑셀데이터 라이브러리 할당*/
libname orionx xlsx 'c:\educ\p12\sales.xlsx' ;

proc contents data=orionx.australia varnum;
run;

proc print data=orionx.australia (obs=10) ;
run; 

/*오라클db db table 사용*/
libname ora_db oracle path=server userid= password= ; 

/*text 데이터(csv)를 SAS data set 으로 가져오기*/
proc import datafile='c:\educ\p12\sales.csv' dbms=csv
                 out=work.sales_csv replace /*덮어쓰기*/ ;
run;

/*==================[Chapter4 : Reading SAS data sets]==================*/

/*part1(p4-4)*/

data work.subset1 /*출력데이터*/;
	set orion.sales ; /*입력데이터 (원래있던 원데이터)*/
	where salary >= 30000 ; /*where 논리, 비교, 산술, 특별 연산자*/
run;

data work.subset1 /*출력데이터*/;
	set orion.sales ; /*입력데이터 (원래있던 원데이터)*/
	where country = 'AU'
	and job_title contains 'Rep';
run;

data work.subset1 /*출력데이터*/;
	set orion.sales ; /*입력데이터 (원래있던 원데이터)*/
	where country = 'AU'
	and salary >= 30000;
run;

/*
# SAS변수
				상수값(고정된값)
문자 변수 : "value" or 'value' 단, 값에 대한 대소문자구분
숫자 변수 : value : ex.1234, 1234.5 숫자 사이에 특수기호 사용 안함(1,234 X)
	- 날짜변수 : 날짜 상수값
						0 = "01jan1960"d  (o) , '1960-01-01'd (X)
*/

/*part2(p4-8)*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep' /*contains = ?*/
	and Hire_Date < '01jan2000'd ; /*날짜*/
run;

/*새 변수 만들기, 할당 문장*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep'                
	and Hire_Date < '01jan2000'd ;  
	Bonus = salary *0.1;                 /*변수명 = 표현식*/
	gender = upcase(gender) ;         /*기존 변수 수정*/     
run;

/*계산식 중 하나라도 missing value 면 missing value return*/


/*part3*/
/*Drop : 빼고 가져갈 변수들*//*Keep 가져갈 변수 문장*/
data work.subset1;
	set orion.sales ;
	where country='AU'
	and Job_Title ? 'Rep'                
	and Hire_Date < '01jan2000'd ;  
	Bonus = salary *0.1;                 /*변수명 = 표현식*/
	gender = upcase(gender) ;         /*기존 변수 수정*/ 
	drop first_name Last_Name Country ;    /*Drop : 빼고 가져갈 변수들*/
run;

/*DATA Step Processing*/
/*위에서 밑으로 실행*/

/*part4*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*변수 순서*/
	set orion.sales ;
	where country in ('AU','au');
	Bonus = salary *0.1;
	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
run;

/*where 문장에 사용되는 변수는 반드시 입력데이터(set)에 존재 해야함*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*변수 순서*/
	set orion.sales ;
	where country in ('AU','au');
	Bonus = salary *0.1;
	if bonus >=3000; /*산술/비교/논리 (특수x)*/
	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
run;

/*part5*/
/*label, format*/

/*label : 변수 설명*/
data work.auemps;
	retain Employee_ID Salary bonus Hire_Date Birth_Date; /*변수 순서*/
	set orion.sales ;
	where country in ('AU','au');

	Bonus = salary *0.1;
	if bonus >=3000; /*산술/비교/논리 (특수x)*/

	keep Employee_ID Salary bonus Hire_Date Birth_Date; 
	label bonus='현재 급여의 10%'; /*라벨*/
	format salary comma10. bonus comma10.1 hire_date Birth_Date yymmdd10.; /*포맷*/
run;

/*라벨은 계속 유지*/


/*===p4-37 연습문제 2번*/
data work.delays;
	set orion.orders;
 	where Delivery_Date > Order_Date +4
	and Employee_ID = 99999999;
	order_month = month(order_date);
	if order_month = 8;
	keep Employee_ID Customer_ID Order_Date Delivery_Date Order_month;
	label Order_month ='주문 월';
	format Order_Date Delivery_Date yymmdd10.;
run;